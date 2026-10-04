import '../domain/entities/branch_coverage.dart';
import '../domain/entities/function_coverage.dart';
import '../domain/entities/line_coverage.dart';
import '../domain/entities/source_file.dart';

/// Pure helpers for computing and formatting coverage percentages.
///
/// Every method here is a total function of its arguments — no I/O, no
/// throwing, no failure value. Failure-as-a-value applies to the fallible
/// seams (parsing, the adapters); arithmetic on valid coverage data cannot
/// fail, so it returns plain values.
class CoverageCalculator {
  /// Line coverage percentage for [lines]; 100.0 when there are no lines.
  static double calculateLineCoverage(List<LineCoverage> lines) {
    if (lines.isEmpty) return 100.0;

    final hitLines = lines.where((line) => line.isCovered).length;
    return (hitLines / lines.length) * 100.0;
  }

  /// Function coverage percentage for [functions]; 100.0 when there are none.
  static double calculateFunctionCoverage(List<FunctionCoverage> functions) {
    if (functions.isEmpty) return 100.0;

    final hitFunctions = functions.where((func) => func.isCovered).length;
    return (hitFunctions / functions.length) * 100.0;
  }

  /// Branch coverage percentage for [branches]; 100.0 when there are none.
  static double calculateBranchCoverage(List<BranchCoverage> branches) {
    if (branches.isEmpty) return 100.0;

    final hitBranches = branches.where((branch) => branch.isCovered).length;
    return (hitBranches / branches.length) * 100.0;
  }

  /// Overall coverage for [sourceFile]: the average of line coverage and, when
  /// present, function and branch coverage.
  static double calculateOverallCoverage(SourceFile sourceFile) {
    var total = sourceFile.lineCoveragePercentage;
    var count = 1;

    if (sourceFile.totalFunctions > 0) {
      total += sourceFile.functionCoveragePercentage;
      count++;
    }

    if (sourceFile.totalBranches > 0) {
      total += sourceFile.branchCoveragePercentage;
      count++;
    }

    return total / count;
  }

  /// Weighted average of the three coverage ratios.
  static double calculateWeightedCoverage({
    required double lineCoverage,
    required double functionCoverage,
    required double branchCoverage,
    double lineWeight = 1.0,
    double functionWeight = 1.0,
    double branchWeight = 1.0,
  }) {
    final totalWeight = lineWeight + functionWeight + branchWeight;
    if (totalWeight == 0) return 0.0;

    return (lineCoverage * lineWeight +
            functionCoverage * functionWeight +
            branchCoverage * branchWeight) /
        totalWeight;
  }

  /// Classifies [percentage] into a [CoverageLevel].
  static CoverageLevel getCoverageLevel(double percentage) {
    if (percentage >= 90.0) return CoverageLevel.high;
    if (percentage >= 60.0) return CoverageLevel.medium;
    return CoverageLevel.low;
  }

  /// The CSS class name used to colour a coverage [percentage].
  static String getCoverageCssClass(double percentage) {
    switch (getCoverageLevel(percentage)) {
      case CoverageLevel.high:
        return 'coverage-high';
      case CoverageLevel.medium:
        return 'coverage-medium';
      case CoverageLevel.low:
        return 'coverage-low';
    }
  }

  /// Formats [percentage] as e.g. `"85.5%"`.
  static String formatCoveragePercentage(
    double percentage, {
    int decimalPlaces = 1,
  }) {
    return '${percentage.toStringAsFixed(decimalPlaces)}%';
  }

  /// Formats a hit/total pair as a fraction string, e.g. `"85/100"`.
  static String formatCoverageFraction(int hit, int total) {
    return '$hit/$total';
  }

  /// The signed difference `current - previous`.
  static double calculateCoverageDelta(double current, double previous) {
    return current - previous;
  }

  /// Formats [delta] with an explicit sign, e.g. `"+2.5%"`.
  static String formatCoverageDelta(double delta, {int decimalPlaces = 1}) {
    final sign = delta >= 0 ? '+' : '';
    return '$sign${delta.toStringAsFixed(decimalPlaces)}%';
  }

  /// Extra hits required to reach [targetPercentage]; never negative.
  static int calculateHitsNeededForTarget(
    int currentHits,
    int total,
    double targetPercentage,
  ) {
    if (total == 0) return 0;

    final targetHits = (total * targetPercentage / 100.0).ceil();
    final additionalHits = targetHits - currentHits;
    return additionalHits > 0 ? additionalHits : 0;
  }

  /// Descriptive statistics over the per-file overall coverage of [sourceFiles].
  static CoverageStatistics calculateStatistics(List<SourceFile> sourceFiles) {
    if (sourceFiles.isEmpty) {
      return const CoverageStatistics.empty();
    }

    final coveragePercentages = sourceFiles
        .map((file) => file.overallCoveragePercentage)
        .toList();
    coveragePercentages.sort();

    final sum = coveragePercentages.reduce((a, b) => a + b);
    final mean = sum / coveragePercentages.length;

    final median = coveragePercentages.length % 2 == 0
        ? (coveragePercentages[coveragePercentages.length ~/ 2 - 1] +
                  coveragePercentages[coveragePercentages.length ~/ 2]) /
              2
        : coveragePercentages[coveragePercentages.length ~/ 2];

    final min = coveragePercentages.first;
    final max = coveragePercentages.last;

    final variance =
        coveragePercentages
            .map((x) => (x - mean) * (x - mean))
            .reduce((a, b) => a + b) /
        coveragePercentages.length;
    final standardDeviation = variance.sqrt();

    return CoverageStatistics(
      mean: mean,
      median: median,
      min: min,
      max: max,
      standardDeviation: standardDeviation,
      fileCount: sourceFiles.length,
    );
  }

  /// Whether [percentage] lies within the valid `0.0 .. 100.0` range.
  static bool isValidCoveragePercentage(double percentage) {
    return percentage >= 0.0 && percentage <= 100.0;
  }

  /// [percentage] clamped to the valid `0.0 .. 100.0` range.
  static double clampCoveragePercentage(double percentage) {
    return percentage.clamp(0.0, 100.0);
  }
}

/// Bands used to colour a coverage percentage.
enum CoverageLevel {
  /// Below 60%.
  low,

  /// 60% to just under 90%.
  medium,

  /// 90% and above.
  high,
}

/// Descriptive statistics about coverage across several files.
class CoverageStatistics {
  /// Mean (average) coverage percentage.
  final double mean;

  /// Median coverage percentage.
  final double median;

  /// Minimum coverage percentage.
  final double min;

  /// Maximum coverage percentage.
  final double max;

  /// Standard deviation of the coverage percentages.
  final double standardDeviation;

  /// Number of files included in the statistics.
  final int fileCount;

  /// Creates statistics with explicit values.
  const CoverageStatistics({
    required this.mean,
    required this.median,
    required this.min,
    required this.max,
    required this.standardDeviation,
    required this.fileCount,
  });

  /// All-zero statistics, used when there are no files.
  const CoverageStatistics.empty()
    : mean = 0.0,
      median = 0.0,
      min = 0.0,
      max = 0.0,
      standardDeviation = 0.0,
      fileCount = 0;

  @override
  String toString() {
    return 'CoverageStatistics('
        'mean: ${mean.toStringAsFixed(1)}%, '
        'median: ${median.toStringAsFixed(1)}%, '
        'range: ${min.toStringAsFixed(1)}%-${max.toStringAsFixed(1)}%, '
        'stdDev: ${standardDeviation.toStringAsFixed(1)}%, '
        'files: $fileCount'
        ')';
  }
}

/// Square root for [double], implemented without `dart:math`.
extension DoubleExtension on double {
  /// The square root of this value by Newton's method; `NaN` for negatives.
  double sqrt() {
    if (this < 0) return double.nan;
    if (this == 0) return 0;

    var x = this;
    double prev;
    do {
      prev = x;
      x = (x + this / x) / 2;
    } while ((x - prev).abs() > 1e-10);

    return x;
  }
}
