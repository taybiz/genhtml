import 'package:equatable/equatable.dart';

import 'coverage_summary.dart';
import 'source_file.dart';

/// Aggregate entity holding all source files and overall summary statistics.
class CoverageData extends Equatable {
  /// All source files with coverage information.
  final List<SourceFile> sourceFiles;

  /// Overall coverage summary across all files.
  final CoverageSummary summary;

  /// Optional title for the coverage report.
  final String? title;

  /// Timestamp when the coverage data was generated.
  final DateTime timestamp;

  /// Creates a new coverage data instance.
  const CoverageData({
    required this.sourceFiles,
    required this.summary,
    this.title,
    required this.timestamp,
  });

  /// Creates an empty coverage data instance.
  CoverageData.empty({this.title})
    : sourceFiles = const [],
      summary = const CoverageSummary.empty(),
      timestamp = DateTime.now();

  /// Creates coverage data from a list of [sourceFiles].
  factory CoverageData.fromSourceFiles(
    List<SourceFile> sourceFiles, {
    String? title,
    DateTime? timestamp,
  }) {
    final summary = CoverageSummary.fromSourceFiles(sourceFiles);

    return CoverageData(
      sourceFiles: sourceFiles,
      summary: summary,
      title: title,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  /// Number of source files in this coverage data.
  int get fileCount => sourceFiles.length;

  /// Gets a source file by its [path], or `null` when absent.
  SourceFile? getSourceFile(String path) {
    for (final file in sourceFiles) {
      if (file.path == path) return file;
    }
    return null;
  }

  /// Gets all source files whose path matches [pattern].
  List<SourceFile> getSourceFilesMatching(Pattern pattern) {
    return sourceFiles
        .where((file) => pattern.allMatches(file.path).isNotEmpty)
        .toList();
  }

  /// Gets source files sorted by coverage percentage (lowest first).
  List<SourceFile> getSourceFilesSortedByCoverage() {
    final files = List<SourceFile>.from(sourceFiles);
    files.sort(
      (a, b) =>
          a.overallCoveragePercentage.compareTo(b.overallCoveragePercentage),
    );
    return files;
  }

  /// Gets source files with coverage below [threshold].
  List<SourceFile> getSourceFilesBelowThreshold(double threshold) {
    return sourceFiles
        .where((file) => file.overallCoveragePercentage < threshold)
        .toList();
  }

  /// Gets source files with perfect coverage (100%).
  List<SourceFile> getSourceFilesWithPerfectCoverage() {
    return sourceFiles
        .where((file) => file.overallCoveragePercentage >= 100.0)
        .toList();
  }

  /// Gets source files with no coverage (0%).
  List<SourceFile> getSourceFilesWithNoCoverage() {
    return sourceFiles
        .where((file) => file.overallCoveragePercentage == 0.0)
        .toList();
  }

  /// Returns a copy with [sourceFile] added.
  CoverageData addSourceFile(SourceFile sourceFile) {
    final updatedFiles = List<SourceFile>.from(sourceFiles)..add(sourceFile);
    return CoverageData.fromSourceFiles(
      updatedFiles,
      title: title,
      timestamp: timestamp,
    );
  }

  /// Returns a copy with the file at [path] removed.
  CoverageData removeSourceFile(String path) {
    final updatedFiles = sourceFiles
        .where((file) => file.path != path)
        .toList();
    return CoverageData.fromSourceFiles(
      updatedFiles,
      title: title,
      timestamp: timestamp,
    );
  }

  /// Returns a copy with [updatedFile] replacing the file at the same path.
  CoverageData updateSourceFile(SourceFile updatedFile) {
    final updatedFiles = sourceFiles.map((file) {
      return file.path == updatedFile.path ? updatedFile : file;
    }).toList();

    return CoverageData.fromSourceFiles(
      updatedFiles,
      title: title,
      timestamp: timestamp,
    );
  }

  /// Returns a copy with only the files matching [predicate].
  CoverageData filterSourceFiles(bool Function(SourceFile) predicate) {
    final filteredFiles = sourceFiles.where(predicate).toList();
    return CoverageData.fromSourceFiles(
      filteredFiles,
      title: title,
      timestamp: timestamp,
    );
  }

  /// Creates a copy of this coverage data with the given fields replaced.
  CoverageData copyWith({
    List<SourceFile>? sourceFiles,
    CoverageSummary? summary,
    String? title,
    DateTime? timestamp,
  }) {
    return CoverageData(
      sourceFiles: sourceFiles ?? this.sourceFiles,
      summary: summary ?? this.summary,
      title: title ?? this.title,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Returns the consistency problems found in this data (empty means valid).
  List<String> validate() {
    final errors = <String>[];

    // Check for duplicate file paths.
    final paths = <String>{};
    for (final file in sourceFiles) {
      if (paths.contains(file.path)) {
        errors.add('Duplicate source file path: ${file.path}');
      }
      paths.add(file.path);
    }

    // Validate summary matches source files.
    final calculatedSummary = CoverageSummary.fromSourceFiles(sourceFiles);
    if (summary != calculatedSummary) {
      errors.add('Summary does not match calculated values from source files');
    }

    return errors;
  }

  @override
  List<Object?> get props => [sourceFiles, summary, title, timestamp];

  @override
  String toString() {
    return 'CoverageData('
        'files: ${sourceFiles.length}, '
        'title: "$title", '
        'timestamp: $timestamp, '
        'summary: $summary'
        ')';
  }
}
