import 'line_coverage.dart';
import 'function_coverage.dart';
import 'branch_coverage.dart';

/// Represents coverage information for a single source file.
class SourceFile {
  /// The path to the source file
  final String path;

  /// Line coverage data for this file
  final List<LineCoverage> lines;

  /// Function coverage data for this file
  final List<FunctionCoverage> functions;

  /// Branch coverage data for this file
  final List<BranchCoverage> branches;

  /// Creates a new source file coverage instance.
  const SourceFile({
    required this.path,
    required this.lines,
    required this.functions,
    required this.branches,
  });

  /// Creates an empty source file with the given path
  SourceFile.empty(this.path)
    : lines = const [],
      functions = const [],
      branches = const [];

  /// Total number of lines in this file
  int get totalLines => lines.length;

  /// Number of lines that were hit (covered)
  int get hitLines => lines.where((line) => line.isCovered).length;

  /// Line coverage percentage (0.0 to 100.0)
  double get lineCoveragePercentage {
    if (totalLines == 0) return 100.0;
    return (hitLines / totalLines) * 100.0;
  }

  /// Total number of functions in this file
  int get totalFunctions => functions.length;

  /// Number of functions that were hit (covered)
  int get hitFunctions => functions.where((func) => func.isCovered).length;

  /// Function coverage percentage (0.0 to 100.0)
  double get functionCoveragePercentage {
    if (totalFunctions == 0) return 100.0;
    return (hitFunctions / totalFunctions) * 100.0;
  }

  /// Total number of branches in this file
  int get totalBranches => branches.length;

  /// Number of branches that were hit (covered)
  int get hitBranches => branches.where((branch) => branch.isCovered).length;

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

  /// Gets the coverage for a specific line number
  LineCoverage? getLineCoverage(int lineNumber) {
    try {
      return lines.firstWhere((line) => line.lineNumber == lineNumber);
    } catch (e) {
      return null;
    }
  }

  /// Gets the function coverage for a specific function name
  FunctionCoverage? getFunctionCoverage(String functionName) {
    try {
      return functions.firstWhere((func) => func.functionName == functionName);
    } catch (e) {
      return null;
    }
  }

  /// Gets all branches for a specific line number
  List<BranchCoverage> getBranchesForLine(int lineNumber) {
    return branches.where((branch) => branch.lineNumber == lineNumber).toList();
  }

  /// Creates a copy of this source file with updated coverage data
  SourceFile copyWith({
    String? path,
    List<LineCoverage>? lines,
    List<FunctionCoverage>? functions,
    List<BranchCoverage>? branches,
  }) {
    return SourceFile(
      path: path ?? this.path,
      lines: lines ?? this.lines,
      functions: functions ?? this.functions,
      branches: branches ?? this.branches,
    );
  }

  @override
  String toString() {
    return 'SourceFile(path: "$path", lines: ${lines.length}, functions: ${functions.length}, branches: ${branches.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SourceFile &&
        other.path == path &&
        _listEquals(other.lines, lines) &&
        _listEquals(other.functions, functions) &&
        _listEquals(other.branches, branches);
  }

  @override
  int get hashCode => Object.hash(path, lines, functions, branches);

  /// Helper method to compare lists for equality
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
