import 'package:equatable/equatable.dart';

/// Value object for function-level coverage information on a single function.
class FunctionCoverage extends Equatable {
  /// The line number where the function is defined.
  final int lineNumber;

  /// The name of the function.
  final String functionName;

  /// The number of times this function was called (0 means not covered).
  final int hitCount;

  /// Creates a new function coverage value object.
  const FunctionCoverage({
    required this.lineNumber,
    required this.functionName,
    required this.hitCount,
  });

  /// Whether this function is covered (hit count > 0).
  bool get isCovered => hitCount > 0;

  /// Serialises this function coverage to an LCOV `FN:` record.
  ///
  /// Format: `FN:line_number,function_name`.
  String toLcovFn() {
    return 'FN:$lineNumber,$functionName';
  }

  /// Serialises this function coverage to an LCOV `FNDA:` record.
  ///
  /// Format: `FNDA:hit_count,function_name`.
  String toLcovFnda() {
    return 'FNDA:$hitCount,$functionName';
  }

  @override
  List<Object?> get props => [lineNumber, functionName, hitCount];

  @override
  String toString() {
    return 'FunctionCoverage(line: $lineNumber, name: "$functionName", hits: $hitCount, covered: $isCovered)';
  }
}
