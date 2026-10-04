import 'package:fpdart/fpdart.dart';

import '../entities/branch_coverage.dart';
import '../entities/coverage_data.dart';
import '../entities/function_coverage.dart';
import '../entities/line_coverage.dart';
import '../entities/source_file.dart';
import '../failures.dart';
import '../validation.dart';

/// Pure use case that turns raw LCOV trace text into [CoverageData].
///
/// Failure is a value: malformed input yields a `Left(ParseFailure(...))` and
/// nothing here throws. Reading the trace from disk is a separate concern and
/// lives in the datasource layer (`LcovFileDatasource`).
///
/// Supports the standard LCOV record types — `TN`, `SF`, `FN`, `FNDA`, `FNF`,
/// `FNH`, `DA`, `LF`, `LH`, `BRDA`, `BRF`, `BRH` and the `end_of_record`
/// terminator. Unknown record types are tolerated so that future LCOV
/// extensions do not break parsing; a `BRDA` hit count of `-` means the branch
/// was never executed.
class ParseLcovUseCase {
  /// Creates the parser use case.
  const ParseLcovUseCase();

  /// Parses [lcovContent] into [CoverageData], tagging the result with [title].
  ///
  /// Returns `Left(ParseFailure(...))` when the content is not valid LCOV
  /// (empty, no `SF:` record, missing `end_of_record`) or when a record is
  /// malformed, and `Right(data)` otherwise. A document whose records are all
  /// tolerated but that declares no source file parses to an empty
  /// [CoverageData] — matching the historical CLI behaviour.
  Either<GenhtmlFailure, CoverageData> call(
    String lcovContent, {
    String? title,
  }) {
    return Validation.validateLcovFormat(lcovContent)
        .mapLeft<GenhtmlFailure>(
          (failure) => ParseFailure('Invalid LCOV format: ${failure.message}'),
        )
        .flatMap((_) => _parse(lcovContent, title));
  }

  Either<GenhtmlFailure, CoverageData> _parse(String content, String? title) {
    final sourceFiles = <SourceFile>[];
    _SourceFileBuilder? current;

    final lines = content.split('\n');
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final row = i + 1;

      if (line.startsWith('TN:')) {
        // Test name — valid but not tracked.
        continue;
      } else if (line.startsWith('SF:')) {
        final flushed = _flush(current, sourceFiles);
        if (flushed != null) return Left(flushed);
        current = _SourceFileBuilder(line.substring(3));
      } else if (line.startsWith('FNDA:')) {
        final failure = _requireFile(current, row);
        if (failure != null) return Left(failure);
        final error = current!.addFunctionData(line);
        if (error != null) return Left(ParseFailure(error));
      } else if (line.startsWith('FN:')) {
        final failure = _requireFile(current, row);
        if (failure != null) return Left(failure);
        final error = current!.addFunctionName(line);
        if (error != null) return Left(ParseFailure(error));
      } else if (line.startsWith('FNF:')) {
        final failure = _requireCounter(current, row, line, 'FNF', 4);
        if (failure != null) return Left(failure);
        current!.setFunctionsFound(_count(line, 4));
      } else if (line.startsWith('FNH:')) {
        final failure = _requireCounter(current, row, line, 'FNH', 4);
        if (failure != null) return Left(failure);
        current!.setFunctionsHit(_count(line, 4));
      } else if (line.startsWith('DA:')) {
        final failure = _requireFile(current, row);
        if (failure != null) return Left(failure);
        final error = current!.addLineData(line);
        if (error != null) return Left(ParseFailure(error));
      } else if (line.startsWith('LF:')) {
        final failure = _requireCounter(current, row, line, 'LF', 3);
        if (failure != null) return Left(failure);
        current!.setLinesFound(_count(line, 3));
      } else if (line.startsWith('LH:')) {
        final failure = _requireCounter(current, row, line, 'LH', 3);
        if (failure != null) return Left(failure);
        current!.setLinesHit(_count(line, 3));
      } else if (line.startsWith('BRDA:')) {
        final failure = _requireFile(current, row);
        if (failure != null) return Left(failure);
        final error = current!.addBranchData(line);
        if (error != null) return Left(ParseFailure(error));
      } else if (line.startsWith('BRF:')) {
        final failure = _requireCounter(current, row, line, 'BRF', 4);
        if (failure != null) return Left(failure);
        current!.setBranchesFound(_count(line, 4));
      } else if (line.startsWith('BRH:')) {
        final failure = _requireCounter(current, row, line, 'BRH', 4);
        if (failure != null) return Left(failure);
        current!.setBranchesHit(_count(line, 4));
      } else if (line == 'end_of_record') {
        final flushed = _flush(current, sourceFiles);
        if (flushed != null) return Left(flushed);
        current = null;
      }
      // Any other record type is tolerated and skipped.
    }

    // A file that does not terminate with `end_of_record` is still flushed.
    final flushed = _flush(current, sourceFiles);
    if (flushed != null) return Left(flushed);

    return Right(CoverageData.fromSourceFiles(sourceFiles, title: title));
  }

  /// Builds and appends [current] to [sink]; returns a failure when the
  /// declared counters do not match the parsed records.
  GenhtmlFailure? _flush(_SourceFileBuilder? current, List<SourceFile> sink) {
    if (current == null) return null;
    final built = current.build();
    if (built.getLeft().isSome()) return built.getLeft().toNullable();
    sink.add(built.getRight().toNullable()!);
    return null;
  }

  /// Returns a failure when no `SF:` record has opened a file yet.
  GenhtmlFailure? _requireFile(_SourceFileBuilder? current, int row) {
    if (current == null) {
      return ParseFailure('Record found before SF record at line $row');
    }
    return null;
  }

  /// Requires an open file and a parseable integer counter.
  GenhtmlFailure? _requireCounter(
    _SourceFileBuilder? current,
    int row,
    String line,
    String record,
    int prefixLength,
  ) {
    final missing = _requireFile(current, row);
    if (missing != null) return missing;
    if (int.tryParse(line.substring(prefixLength).trim()) == null) {
      return ParseFailure('Invalid $record format at line $row: $line');
    }
    return null;
  }

  /// Parses the integer counter of a record with the given prefix length.
  int _count(String line, int prefixLength) =>
      int.parse(line.substring(prefixLength).trim());
}

/// Accumulates the records of one `SF:` block and builds a [SourceFile].
class _SourceFileBuilder {
  _SourceFileBuilder(this.path);

  final String path;
  final List<LineCoverage> _lines = [];
  final Map<int, String> _functionNames = {};
  final Map<String, int> _functionHits = {};
  final List<BranchCoverage> _branches = [];

  int? _functionsFound;
  int? _functionsHit;
  int? _linesFound;
  int? _linesHit;
  int? _branchesFound;
  int? _branchesHit;

  /// Parses an `FN:line,name` record.
  String? addFunctionName(String fnLine) {
    final parts = fnLine.substring(3).split(',');
    if (parts.length != 2) return 'Invalid FN format: $fnLine';
    final lineNumber = int.tryParse(parts[0]);
    if (lineNumber == null) return 'Invalid FN format: $fnLine';
    _functionNames[lineNumber] = parts[1];
    return null;
  }

  /// Parses an `FNDA:hits,name` record.
  String? addFunctionData(String fndaLine) {
    final parts = fndaLine.substring(5).split(',');
    if (parts.length != 2) return 'Invalid FNDA format: $fndaLine';
    final hitCount = int.tryParse(parts[0]);
    if (hitCount == null) return 'Invalid FNDA format: $fndaLine';
    _functionHits[parts[1]] = hitCount;
    return null;
  }

  /// Parses a `DA:line,hits` record.
  String? addLineData(String daLine) {
    final parts = daLine.substring(3).split(',');
    if (parts.length != 2) return 'Invalid DA format: $daLine';
    final lineNumber = int.tryParse(parts[0]);
    final hitCount = int.tryParse(parts[1]);
    if (lineNumber == null || hitCount == null) {
      return 'Invalid DA format: $daLine';
    }
    _lines.add(LineCoverage(lineNumber: lineNumber, hitCount: hitCount));
    return null;
  }

  /// Parses a `BRDA:line,block,branch,hits` record where hits may be `-`.
  String? addBranchData(String brdaLine) {
    final parts = brdaLine.substring(5).split(',');
    if (parts.length != 4) return 'Invalid BRDA format: $brdaLine';
    final lineNumber = int.tryParse(parts[0]);
    final blockNumber = int.tryParse(parts[1]);
    final branchNumber = int.tryParse(parts[2]);
    if (lineNumber == null || blockNumber == null || branchNumber == null) {
      return 'Invalid BRDA format: $brdaLine';
    }
    var hitCount = 0;
    if (parts[3] != '-') {
      final parsed = int.tryParse(parts[3]);
      if (parsed == null) return 'Invalid BRDA format: $brdaLine';
      hitCount = parsed;
    }
    _branches.add(
      BranchCoverage(
        lineNumber: lineNumber,
        blockNumber: blockNumber,
        branchNumber: branchNumber,
        hitCount: hitCount,
      ),
    );
    return null;
  }

  /// Records the declared function count (`FNF:`).
  void setFunctionsFound(int count) => _functionsFound = count;

  /// Records the declared hit-function count (`FNH:`).
  void setFunctionsHit(int count) => _functionsHit = count;

  /// Records the declared line count (`LF:`).
  void setLinesFound(int count) => _linesFound = count;

  /// Records the declared hit-line count (`LH:`).
  void setLinesHit(int count) => _linesHit = count;

  /// Records the declared branch count (`BRF:`).
  void setBranchesFound(int count) => _branchesFound = count;

  /// Records the declared hit-branch count (`BRH:`).
  void setBranchesHit(int count) => _branchesHit = count;

  /// Builds the [SourceFile], validating declared counters against the records.
  Either<GenhtmlFailure, SourceFile> build() {
    final functions = <FunctionCoverage>[];
    for (final entry in _functionNames.entries) {
      functions.add(
        FunctionCoverage(
          lineNumber: entry.key,
          functionName: entry.value,
          hitCount: _functionHits[entry.value] ?? 0,
        ),
      );
    }

    _lines.sort((a, b) => a.lineNumber.compareTo(b.lineNumber));
    functions.sort((a, b) => a.lineNumber.compareTo(b.lineNumber));
    _branches.sort((a, b) => a.lineNumber.compareTo(b.lineNumber));

    final sourceFile = SourceFile(
      path: path,
      lines: _lines,
      functions: functions,
      branches: _branches,
    );

    final mismatch = _countMismatch(sourceFile);
    if (mismatch != null) return Left(ParseFailure(mismatch));

    return Right(sourceFile);
  }

  /// Returns the first declared-vs-actual counter mismatch, or `null`.
  String? _countMismatch(SourceFile sourceFile) {
    if (_linesFound != null && sourceFile.totalLines != _linesFound) {
      return 'Line count mismatch for $path: expected $_linesFound, '
          'got ${sourceFile.totalLines}';
    }
    if (_linesHit != null && sourceFile.hitLines != _linesHit) {
      return 'Hit line count mismatch for $path: expected $_linesHit, '
          'got ${sourceFile.hitLines}';
    }
    if (_functionsFound != null &&
        sourceFile.totalFunctions != _functionsFound) {
      return 'Function count mismatch for $path: expected $_functionsFound, '
          'got ${sourceFile.totalFunctions}';
    }
    if (_functionsHit != null && sourceFile.hitFunctions != _functionsHit) {
      return 'Hit function count mismatch for $path: expected $_functionsHit, '
          'got ${sourceFile.hitFunctions}';
    }
    // BRF/BRH counts are only validated when individual BRDA records exist —
    // some LCOV writers report totals without per-branch records.
    if (_branchesFound != null &&
        _branches.isNotEmpty &&
        sourceFile.totalBranches != _branchesFound) {
      return 'Branch count mismatch for $path: expected $_branchesFound, '
          'got ${sourceFile.totalBranches}';
    }
    if (_branchesHit != null &&
        _branches.isNotEmpty &&
        sourceFile.hitBranches != _branchesHit) {
      return 'Hit branch count mismatch for $path: expected $_branchesHit, '
          'got ${sourceFile.hitBranches}';
    }
    return null;
  }
}
