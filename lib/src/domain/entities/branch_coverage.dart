import 'package:equatable/equatable.dart';

/// Value object for branch-level coverage information on a single branch.
class BranchCoverage extends Equatable {
  /// The line number where the branch occurs.
  final int lineNumber;

  /// The block number within the line.
  final int blockNumber;

  /// The branch number within the block.
  final int branchNumber;

  /// The number of times this branch was taken (0 means not taken).
  final int hitCount;

  /// Creates a new branch coverage value object.
  const BranchCoverage({
    required this.lineNumber,
    required this.blockNumber,
    required this.branchNumber,
    required this.hitCount,
  });

  /// Whether this branch is covered (hit count > 0).
  bool get isCovered => hitCount > 0;

  /// Serialises this branch coverage to an LCOV `BRDA:` record.
  ///
  /// Format: `BRDA:line_number,block_number,branch_number,hit_count`.
  /// A zero hit count is serialised as `-`, matching the LCOV convention for
  /// a branch that was never executed.
  String toLcovData() {
    final hitCountStr = hitCount == 0 ? '-' : hitCount.toString();
    return 'BRDA:$lineNumber,$blockNumber,$branchNumber,$hitCountStr';
  }

  @override
  List<Object?> get props => [lineNumber, blockNumber, branchNumber, hitCount];

  @override
  String toString() {
    return 'BranchCoverage(line: $lineNumber, block: $blockNumber, branch: $branchNumber, hits: $hitCount, covered: $isCovered)';
  }
}
