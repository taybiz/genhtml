import 'package:equatable/equatable.dart';

/// Value object for line-level coverage information on a single source line.
class LineCoverage extends Equatable {
  /// The line number (1-based).
  final int lineNumber;

  /// The number of times this line was executed (0 means not covered).
  final int hitCount;

  /// Creates a new line coverage value object.
  const LineCoverage({required this.lineNumber, required this.hitCount});

  /// Whether this line is covered (hit count > 0).
  bool get isCovered => hitCount > 0;

  /// Serialises this line coverage to an LCOV `DA:` record.
  ///
  /// Format: `DA:line_number,hit_count`.
  String toLcovData() {
    return 'DA:$lineNumber,$hitCount';
  }

  @override
  List<Object?> get props => [lineNumber, hitCount];

  @override
  String toString() {
    return 'LineCoverage(line: $lineNumber, hits: $hitCount, covered: $isCovered)';
  }
}
