import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../domain/failures.dart';

/// Adapter that reads LCOV traces from the file system.
///
/// This is one of the two allowed `tryCatch` boundaries in the codebase: the
/// third-party `dart:io` calls are wrapped once, here, and every failure is
/// returned as a value ([IoFailure]). Nothing above this layer catches.
class LcovFileDatasource {
  /// Creates the datasource.
  const LcovFileDatasource();

  /// Whether [filePath] exists on disk.
  TaskEither<GenhtmlFailure, bool> exists(String filePath) {
    return TaskEither.tryCatch(
      () => File(filePath).exists(),
      (error, stackTrace) => IoFailure('Cannot access "$filePath": $error'),
    );
  }

  /// Reads [filePath] as a UTF-8 string.
  TaskEither<GenhtmlFailure, String> read(String filePath) {
    return TaskEither.tryCatch(
      () => File(filePath).readAsString(),
      (error, stackTrace) =>
          IoFailure('Failed to read LCOV file "$filePath": $error'),
    );
  }
}
