import 'package:fpdart/fpdart.dart';

import 'failures.dart';

/// Pure input validation for the genhtml core.
///
/// Every check returns its failure as a value — `Either<GenhtmlFailure, Unit>`
/// — where a [Right] carrying [unit] means the input passed. Nothing here
/// touches the file system or throws; I/O checks live in the adapters.
abstract final class Validation {
  /// Validates the shape of an LCOV trace file.
  ///
  /// Mirrors the tolerance of the LCOV format itself: an unknown record type
  /// is accepted (so future LCOV extensions do not break parsing), while an
  /// empty document, a document with no `SF:` record, or a document that never
  /// terminates with `end_of_record` is rejected.
  static Either<GenhtmlFailure, Unit> validateLcovFormat(String content) {
    if (content.isEmpty) {
      return const Left(ValidationFailure('LCOV content is empty'));
    }

    final lines = content.split('\n');
    var hasSourceFile = false;
    var hasEndRecord = false;

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      if (trimmedLine.startsWith('SF:')) {
        hasSourceFile = true;
      } else if (trimmedLine == 'end_of_record') {
        hasEndRecord = true;
      } else if (trimmedLine.startsWith('TN:')) {
        // Test name - valid but optional.
      } else if (_isKnownRecord(trimmedLine)) {
        // Valid LCOV record type.
      } else {
        // Unknown record type: tolerated, so parsing continues.
        return const Right(unit);
      }
    }

    if (!hasSourceFile) {
      return const Left(
        ValidationFailure('LCOV file must contain at least one SF: record'),
      );
    }

    if (!hasEndRecord) {
      return const Left(
        ValidationFailure('LCOV file must end with end_of_record'),
      );
    }

    return const Right(unit);
  }

  /// Validates that [threshold] is a coverage percentage in `0.0 .. 100.0`.
  static Either<GenhtmlFailure, Unit> validateCoverageThreshold(
    double threshold,
  ) {
    if (threshold < 0.0 || threshold > 100.0) {
      return const Left(
        ValidationFailure('Coverage threshold must be between 0.0 and 100.0'),
      );
    }
    return const Right(unit);
  }

  /// Validates that [title] is safe to embed in generated HTML.
  static Either<GenhtmlFailure, Unit> validateHtmlTitle(String title) {
    if (title.isEmpty) {
      return const Left(ValidationFailure('HTML title is empty'));
    }

    if (title.length > 200) {
      return Left(
        ValidationFailure(
          'HTML title is very long (${title.length} characters)',
        ),
      );
    }

    if (title.contains('<') || title.contains('>')) {
      return const Left(
        ValidationFailure('HTML title contains unsafe characters'),
      );
    }

    return const Right(unit);
  }

  /// Validates the raw command-line [args] list.
  static Either<GenhtmlFailure, Unit> validateCommandLineArgs(
    List<String> args,
  ) {
    if (args.isEmpty) {
      return const Left(ValidationFailure('No input file specified'));
    }
    return const Right(unit);
  }

  static bool _isKnownRecord(String line) {
    const prefixes = [
      'FN:',
      'FNDA:',
      'FNF:',
      'FNH:',
      'DA:',
      'LF:',
      'LH:',
      'BRDA:',
      'BRF:',
      'BRH:',
    ];
    return prefixes.any(line.startsWith);
  }
}
