/// Represents line-level coverage information for a single line of code.
class LineCoverage {
  /// The line number (1-based)
  final int lineNumber;

  /// The number of times this line was executed (0 means not covered)
  final int hitCount;

  /// Creates a new line coverage instance.
  const LineCoverage({required this.lineNumber, required this.hitCount});

  /// Whether this line is covered (hit count > 0)
  bool get isCovered => hitCount > 0;

  /// Creates a LineCoverage from LCOV DA (line data) record
  /// Format: DA:line_number,hit_count
  factory LineCoverage.fromLcovData(String lcovLine) {
    if (!lcovLine.startsWith('DA:')) {
      throw ArgumentError('Invalid LCOV line data format: $lcovLine');
    }

    final data = lcovLine.substring(3); // Remove 'DA:' prefix
    final parts = data.split(',');

    if (parts.length != 2) {
      throw ArgumentError('Invalid LCOV line data format: $lcovLine');
    }

    final lineNumber = int.tryParse(parts[0]);
    final hitCount = int.tryParse(parts[1]);

    if (lineNumber == null || hitCount == null) {
      throw ArgumentError('Invalid LCOV line data format: $lcovLine');
    }

    return LineCoverage(lineNumber: lineNumber, hitCount: hitCount);
  }

  /// Converts this line coverage to LCOV DA format
  String toLcovData() {
    return 'DA:$lineNumber,$hitCount';
  }

  @override
  String toString() {
    return 'LineCoverage(line: $lineNumber, hits: $hitCount, covered: $isCovered)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LineCoverage &&
        other.lineNumber == lineNumber &&
        other.hitCount == hitCount;
  }

  @override
  int get hashCode => Object.hash(lineNumber, hitCount);
}
