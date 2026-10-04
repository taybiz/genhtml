import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:path/path.dart' as path;

import '../domain/failures.dart';

/// Adapter that writes an already-rendered HTML report to the file system.
///
/// This is the second allowed `tryCatch` boundary: `dart:io` is wrapped once,
/// here, and any failure is returned as a value ([IoFailure]). The report
/// contents themselves are produced purely by `GenerateHtmlReportUseCase`.
class HtmlReportDatasource {
  /// Creates the datasource.
  const HtmlReportDatasource();

  /// Writes every page of [pages] (report-relative name to HTML) under
  /// [outputDirectory], creating the directory tree as needed.
  TaskEither<GenhtmlFailure, Unit> write(
    String outputDirectory,
    Map<String, String> pages,
  ) {
    return TaskEither.tryCatch(
      () async {
        final directory = Directory(outputDirectory);
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        for (final entry in pages.entries) {
          final file = File(path.join(outputDirectory, entry.key));
          final parent = file.parent;
          if (!await parent.exists()) {
            await parent.create(recursive: true);
          }
          await file.writeAsString(entry.value);
        }

        return unit;
      },
      (error, stackTrace) => IoFailure(
        'Failed to write HTML report to "$outputDirectory": $error',
      ),
    );
  }
}
