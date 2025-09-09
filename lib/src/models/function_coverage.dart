/// Represents function-level coverage information for a single function.
class FunctionCoverage {
  /// The line number where the function is defined
  final int lineNumber;

  /// The name of the function
  final String functionName;

  /// The number of times this function was called (0 means not covered)
  final int hitCount;

  /// Creates a new function coverage instance.
  const FunctionCoverage({
    required this.lineNumber,
    required this.functionName,
    required this.hitCount,
  });

  /// Whether this function is covered (hit count > 0)
  bool get isCovered => hitCount > 0;

  /// Creates a FunctionCoverage from LCOV FN (function name) and FNDA (function data) records
  /// FN format: FN:line_number,function_name
  /// FNDA format: FNDA:hit_count,function_name
  factory FunctionCoverage.fromLcovData({
    required String fnLine,
    required String fndaLine,
  }) {
    // Parse FN line
    if (!fnLine.startsWith('FN:')) {
      throw ArgumentError('Invalid LCOV function name format: $fnLine');
    }

    final fnData = fnLine.substring(3); // Remove 'FN:' prefix
    final fnParts = fnData.split(',');

    if (fnParts.length != 2) {
      throw ArgumentError('Invalid LCOV function name format: $fnLine');
    }

    final lineNumber = int.tryParse(fnParts[0]);
    final functionName = fnParts[1];

    if (lineNumber == null) {
      throw ArgumentError('Invalid LCOV function name format: $fnLine');
    }

    // Parse FNDA line
    if (!fndaLine.startsWith('FNDA:')) {
      throw ArgumentError('Invalid LCOV function data format: $fndaLine');
    }

    final fndaData = fndaLine.substring(5); // Remove 'FNDA:' prefix
    final fndaParts = fndaData.split(',');

    if (fndaParts.length != 2) {
      throw ArgumentError('Invalid LCOV function data format: $fndaLine');
    }

    final hitCount = int.tryParse(fndaParts[0]);
    final fndaFunctionName = fndaParts[1];

    if (hitCount == null) {
      throw ArgumentError('Invalid LCOV function data format: $fndaLine');
    }

    // Verify function names match
    if (functionName != fndaFunctionName) {
      throw ArgumentError(
        'Function name mismatch: FN has "$functionName", FNDA has "$fndaFunctionName"',
      );
    }

    return FunctionCoverage(
      lineNumber: lineNumber,
      functionName: functionName,
      hitCount: hitCount,
    );
  }

  /// Creates a FunctionCoverage from individual components
  factory FunctionCoverage.create({
    required int lineNumber,
    required String functionName,
    required int hitCount,
  }) {
    return FunctionCoverage(
      lineNumber: lineNumber,
      functionName: functionName,
      hitCount: hitCount,
    );
  }

  /// Converts this function coverage to LCOV FN format
  String toLcovFn() {
    return 'FN:$lineNumber,$functionName';
  }

  /// Converts this function coverage to LCOV FNDA format
  String toLcovFnda() {
    return 'FNDA:$hitCount,$functionName';
  }

  @override
  String toString() {
    return 'FunctionCoverage(line: $lineNumber, name: "$functionName", hits: $hitCount, covered: $isCovered)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FunctionCoverage &&
        other.lineNumber == lineNumber &&
        other.functionName == functionName &&
        other.hitCount == hitCount;
  }

  @override
  int get hashCode => Object.hash(lineNumber, functionName, hitCount);
}
