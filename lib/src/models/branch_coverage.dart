/// Represents branch-level coverage information for a single branch.
class BranchCoverage {
  /// The line number where the branch occurs
  final int lineNumber;

  /// The block number within the line
  final int blockNumber;

  /// The branch number within the block
  final int branchNumber;

  /// The number of times this branch was taken (0 means not taken)
  final int hitCount;

  /// Creates a new branch coverage instance.
  const BranchCoverage({
    required this.lineNumber,
    required this.blockNumber,
    required this.branchNumber,
    required this.hitCount,
  });

  /// Whether this branch is covered (hit count > 0)
  bool get isCovered => hitCount > 0;

  /// Creates a BranchCoverage from LCOV BRDA (branch data) record
  /// Format: BRDA:line_number,block_number,branch_number,hit_count
  factory BranchCoverage.fromLcovData(String lcovLine) {
    if (!lcovLine.startsWith('BRDA:')) {
      throw ArgumentError('Invalid LCOV branch data format: $lcovLine');
    }

    final data = lcovLine.substring(5); // Remove 'BRDA:' prefix
    final parts = data.split(',');

    if (parts.length != 4) {
      throw ArgumentError('Invalid LCOV branch data format: $lcovLine');
    }

    final lineNumber = int.tryParse(parts[0]);
    final blockNumber = int.tryParse(parts[1]);
    final branchNumber = int.tryParse(parts[2]);

    if (lineNumber == null || blockNumber == null || branchNumber == null) {
      throw ArgumentError('Invalid LCOV branch data format: $lcovLine');
    }

    // Hit count can be '-' for branches that were not executed
    int hitCount = 0;
    if (parts[3] != '-') {
      final parsedHitCount = int.tryParse(parts[3]);
      if (parsedHitCount == null) {
        throw ArgumentError('Invalid LCOV branch data format: $lcovLine');
      }
      hitCount = parsedHitCount;
    }

    return BranchCoverage(
      lineNumber: lineNumber,
      blockNumber: blockNumber,
      branchNumber: branchNumber,
      hitCount: hitCount,
    );
  }

  /// Converts this branch coverage to LCOV BRDA format
  String toLcovData() {
    final hitCountStr = hitCount == 0 ? '-' : hitCount.toString();
    return 'BRDA:$lineNumber,$blockNumber,$branchNumber,$hitCountStr';
  }

  @override
  String toString() {
    return 'BranchCoverage(line: $lineNumber, block: $blockNumber, branch: $branchNumber, hits: $hitCount, covered: $isCovered)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BranchCoverage &&
        other.lineNumber == lineNumber &&
        other.blockNumber == blockNumber &&
        other.branchNumber == branchNumber &&
        other.hitCount == hitCount;
  }

  @override
  int get hashCode =>
      Object.hash(lineNumber, blockNumber, branchNumber, hitCount);
}
