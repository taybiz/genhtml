import 'source_file.dart';

/// Represents overall coverage summary statistics across all source files.
class CoverageSummary {
  /// Total number of lines across all files
  final int totalLines;

  /// Number of lines that were hit (covered) across all files
  final int hitLines;

  /// Total number of functions across all files
  final int totalFunctions;

  /// Number of functions that were hit (covered) across all files
  final int hitFunctions;

  /// Total number of branches across all files
  final int totalBranches;

  /// Number of branches that were hit (covered) across all files
  final int hitBranches;

  /// Creates a new coverage summary instance.
  const CoverageSummary({
    required this.totalLines,
    required this.hitLines,
    required this.totalFunctions,
    required this.hitFunctions,
    required this.totalBranches,
    required this.hitBranches,
  });

  /// Creates an empty coverage summary
  const CoverageSummary.empty()
    : totalLines = 0,
      hitLines = 0,
      totalFunctions = 0,
      hitFunctions = 0,
      totalBranches = 0,
      hitBranches = 0;

  /// Creates a coverage summary from a list of source files
  factory CoverageSummary.fromSourceFiles(List<SourceFile> sourceFiles) {
    int totalLines = 0;
    int hitLines = 0;
    int totalFunctions = 0;
    int hitFunctions = 0;
    int totalBranches = 0;
    int hitBranches = 0;

    for (final sourceFile in sourceFiles) {
      totalLines += sourceFile.totalLines;
      hitLines += sourceFile.hitLines;
      totalFunctions += sourceFile.totalFunctions;
      hitFunctions += sourceFile.hitFunctions;
      totalBranches += sourceFile.totalBranches;
      hitBranches += sourceFile.hitBranches;
    }

    return CoverageSummary(
      totalLines: totalLines,
      hitLines: hitLines,
      totalFunctions: totalFunctions,
      hitFunctions: hitFunctions,
      totalBranches: totalBranches,
      hitBranches: hitBranches,
    );
  }

  /// Line coverage percentage (0.0 to 100.0)
  double get lineCoveragePercentage {
    if (totalLines == 0) return 100.0;
    return (hitLines / totalLines) * 100.0;
  }

  /// Function coverage percentage (0.0 to 100.0)
  double get functionCoveragePercentage {
    if (totalFunctions == 0) return 100.0;
    return (hitFunctions / totalFunctions) * 100.0;
  }

  /// Branch coverage percentage (0.0 to 100.0)
  double get branchCoveragePercentage {
    if (totalBranches == 0) return 100.0;
    return (hitBranches / totalBranches) * 100.0;
  }

  /// Overall coverage percentage (average of line, function, and branch coverage)
  double get overallCoveragePercentage {
    double total = lineCoveragePercentage;
    int count = 1;

    if (totalFunctions > 0) {
      total += functionCoveragePercentage;
      count++;
    }

    if (totalBranches > 0) {
      total += branchCoveragePercentage;
      count++;
    }

    return total / count;
  }

  /// Returns true if line coverage meets the specified threshold
  bool meetsLineCoverageThreshold(double threshold) {
    return lineCoveragePercentage >= threshold;
  }

  /// Returns true if function coverage meets the specified threshold
  bool meetsFunctionCoverageThreshold(double threshold) {
    return functionCoveragePercentage >= threshold;
  }

  /// Returns true if branch coverage meets the specified threshold
  bool meetsBranchCoverageThreshold(double threshold) {
    return branchCoveragePercentage >= threshold;
  }

  /// Returns true if overall coverage meets the specified threshold
  bool meetsOverallCoverageThreshold(double threshold) {
    return overallCoveragePercentage >= threshold;
  }

  /// Formats line coverage as a string (e.g., "85/100")
  String get linesCoverageString => '$hitLines/$totalLines';

  /// Formats function coverage as a string (e.g., "12/15")
  String get functionsCoverageString => '$hitFunctions/$totalFunctions';

  /// Formats branch coverage as a string (e.g., "8/10")
  String get branchesCoverageString => '$hitBranches/$totalBranches';

  /// Creates a copy of this summary with updated values
  CoverageSummary copyWith({
    int? totalLines,
    int? hitLines,
    int? totalFunctions,
    int? hitFunctions,
    int? totalBranches,
    int? hitBranches,
  }) {
    return CoverageSummary(
      totalLines: totalLines ?? this.totalLines,
      hitLines: hitLines ?? this.hitLines,
      totalFunctions: totalFunctions ?? this.totalFunctions,
      hitFunctions: hitFunctions ?? this.hitFunctions,
      totalBranches: totalBranches ?? this.totalBranches,
      hitBranches: hitBranches ?? this.hitBranches,
    );
  }

  @override
  String toString() {
    return 'CoverageSummary('
        'lines: $linesCoverageString (${lineCoveragePercentage.toStringAsFixed(1)}%), '
        'functions: $functionsCoverageString (${functionCoveragePercentage.toStringAsFixed(1)}%), '
        'branches: $branchesCoverageString (${branchCoveragePercentage.toStringAsFixed(1)}%)'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CoverageSummary &&
        other.totalLines == totalLines &&
        other.hitLines == hitLines &&
        other.totalFunctions == totalFunctions &&
        other.hitFunctions == hitFunctions &&
        other.totalBranches == totalBranches &&
        other.hitBranches == hitBranches;
  }

  @override
  int get hashCode => Object.hash(
    totalLines,
    hitLines,
    totalFunctions,
    hitFunctions,
    totalBranches,
    hitBranches,
  );
}
