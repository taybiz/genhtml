import '../models/source_file.dart';
import '../models/line_coverage.dart';
import '../models/function_coverage.dart';
import '../models/branch_coverage.dart';

/// Utility class for calculating coverage percentages and statistics.
class CoverageCalculator {
  /// Calculates line coverage percentage for a list of lines
  static double calculateLineCoverage(List<LineCoverage> lines) {
    if (lines.isEmpty) return 100.0;

    final hitLines = lines.where((line) => line.isCovered).length;
    return (hitLines / lines.length) * 100.0;
  }

  /// Calculates function coverage percentage for a list of functions
  static double calculateFunctionCoverage(List<FunctionCoverage> functions) {
    if (functions.isEmpty) return 100.0;

    final hitFunctions = functions.where((func) => func.isCovered).length;
    return (hitFunctions / functions.length) * 100.0;
  }

  /// Calculates branch coverage percentage for a list of branches
  static double calculateBranchCoverage(List<BranchCoverage> branches) {
    if (branches.isEmpty) return 100.0;

    final hitBranches = branches.where((branch) => branch.isCovered).length;
    return (hitBranches / branches.length) * 100.0;
  }

  /// Calculates overall coverage for a source file
  static double calculateOverallCoverage(SourceFile sourceFile) {
    double total = sourceFile.lineCoveragePercentage;
    int count = 1;

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

  /// Calculates weighted coverage based on importance factors
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

  /// Determines the coverage level based on percentage
  static CoverageLevel getCoverageLevel(double percentage) {
    if (percentage >= 90.0) return CoverageLevel.high;
    if (percentage >= 60.0) return CoverageLevel.medium;
    return CoverageLevel.low;
  }

  /// Gets the CSS class name for a coverage percentage
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

  /// Formats a coverage percentage as a string with specified decimal places
  static String formatCoveragePercentage(
    double percentage, {
    int decimalPlaces = 1,
  }) {
    return '${percentage.toStringAsFixed(decimalPlaces)}%';
  }

  /// Formats coverage counts as a fraction string (e.g., "85/100")
  static String formatCoverageFraction(int hit, int total) {
    return '$hit/$total';
  }

  /// Calculates coverage delta between two percentages
  static double calculateCoverageDelta(double current, double previous) {
    return current - previous;
  }

  /// Formats coverage delta with appropriate sign and color indication
  static String formatCoverageDelta(double delta, {int decimalPlaces = 1}) {
    final sign = delta >= 0 ? '+' : '';
    return '$sign${delta.toStringAsFixed(decimalPlaces)}%';
  }

  /// Calculates the number of additional hits needed to reach a target percentage
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

  /// Calculates coverage statistics for a list of source files
  static CoverageStatistics calculateStatistics(List<SourceFile> sourceFiles) {
    if (sourceFiles.isEmpty) {
      return CoverageStatistics.empty();
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

    // Calculate standard deviation
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

  /// Validates that coverage percentages are within valid range
  static bool isValidCoveragePercentage(double percentage) {
    return percentage >= 0.0 && percentage <= 100.0;
  }

  /// Clamps a coverage percentage to valid range (0.0 to 100.0)
  static double clampCoveragePercentage(double percentage) {
    return percentage.clamp(0.0, 100.0);
  }
}

/// Represents different levels of coverage quality.
enum CoverageLevel { low, medium, high }

/// Statistical information about coverage across multiple files.
class CoverageStatistics {
  /// Mean (average) coverage percentage
  final double mean;

  /// Median coverage percentage
  final double median;

  /// Minimum coverage percentage
  final double min;

  /// Maximum coverage percentage
  final double max;

  /// Standard deviation of coverage percentages
  final double standardDeviation;

  /// Number of files included in the statistics
  final int fileCount;

  const CoverageStatistics({
    required this.mean,
    required this.median,
    required this.min,
    required this.max,
    required this.standardDeviation,
    required this.fileCount,
  });

  /// Creates empty statistics
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

/// Extension to add sqrt method to double
extension DoubleExtension on double {
  double sqrt() {
    if (this < 0) return double.nan;
    if (this == 0) return 0;

    // Newton's method for square root
    double x = this;
    double prev;
    do {
      prev = x;
      x = (x + this / x) / 2;
    } while ((x - prev).abs() > 1e-10);

    return x;
  }
}
