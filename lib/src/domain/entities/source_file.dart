import 'package:equatable/equatable.dart';

import 'branch_coverage.dart';
import 'function_coverage.dart';
import 'line_coverage.dart';

/// Entity describing the coverage recorded for a single source file.
class SourceFile extends Equatable {
  /// The path to the source file.
  final String path;

  /// Line coverage recorded for this file.
  final List<LineCoverage> lines;

  /// Function coverage recorded for this file.
  final List<FunctionCoverage> functions;

  /// Branch coverage recorded for this file.
  final List<BranchCoverage> branches;

  /// Creates a new source file coverage entity.
  const SourceFile({
    required this.path,
    required this.lines,
    required this.functions,
    required this.branches,
  });

  /// Creates an empty source file with the given [path].
  SourceFile.empty(this.path)
    : lines = const [],
      functions = const [],
      branches = const [];

  /// Total number of lines in this file.
  int get totalLines => lines.length;

  /// Number of lines that were hit (covered).
  int get hitLines => lines.where((line) => line.isCovered).length;

  /// Line coverage percentage (0.0 to 100.0).
  double get lineCoveragePercentage {
    if (totalLines == 0) return 100.0;
    return (hitLines / totalLines) * 100.0;
  }

  /// Total number of functions in this file.
  int get totalFunctions => functions.length;

  /// Number of functions that were hit (covered).
  int get hitFunctions => functions.where((func) => func.isCovered).length;

  /// Function coverage percentage (0.0 to 100.0).
  double get functionCoveragePercentage {
    if (totalFunctions == 0) return 100.0;
    return (hitFunctions / totalFunctions) * 100.0;
  }

  /// Total number of branches in this file.
  int get totalBranches => branches.length;

  /// Number of branches that were hit (covered).
  int get hitBranches => branches.where((branch) => branch.isCovered).length;

  /// Branch coverage percentage (0.0 to 100.0).
  double get branchCoveragePercentage {
    if (totalBranches == 0) return 100.0;
    return (hitBranches / totalBranches) * 100.0;
  }

  /// Overall coverage percentage (average of line, function and branch coverage).
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

  /// Gets the coverage for a specific line number, or `null` when absent.
  LineCoverage? getLineCoverage(int lineNumber) {
    for (final line in lines) {
      if (line.lineNumber == lineNumber) return line;
    }
    return null;
  }

  /// Gets the coverage for a specific function name, or `null` when absent.
  FunctionCoverage? getFunctionCoverage(String functionName) {
    for (final func in functions) {
      if (func.functionName == functionName) return func;
    }
    return null;
  }

  /// Gets all branches recorded on [lineNumber].
  List<BranchCoverage> getBranchesForLine(int lineNumber) {
    return branches.where((branch) => branch.lineNumber == lineNumber).toList();
  }

  /// Creates a copy of this entity with the given fields replaced.
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
  List<Object?> get props => [path, lines, functions, branches];

  @override
  String toString() {
    return 'SourceFile(path: "$path", lines: ${lines.length}, functions: ${functions.length}, branches: ${branches.length})';
  }
}
