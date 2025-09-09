import 'source_file.dart';
import 'coverage_summary.dart';

/// Represents the complete coverage data for a project, containing all source files
/// and overall summary statistics.
class CoverageData {
  /// List of all source files with coverage information
  final List<SourceFile> sourceFiles;

  /// Overall coverage summary across all files
  final CoverageSummary summary;

  /// Optional title for the coverage report
  final String? title;

  /// Timestamp when the coverage data was generated
  final DateTime timestamp;

  /// Creates a new coverage data instance.
  const CoverageData({
    required this.sourceFiles,
    required this.summary,
    this.title,
    required this.timestamp,
  });

  /// Creates an empty coverage data instance
  CoverageData.empty({this.title})
    : sourceFiles = const [],
      summary = const CoverageSummary.empty(),
      timestamp = DateTime.now();

  /// Creates coverage data from a list of source files
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

  /// Number of source files in this coverage data
  int get fileCount => sourceFiles.length;

  /// Gets a source file by its path
  SourceFile? getSourceFile(String path) {
    try {
      return sourceFiles.firstWhere((file) => file.path == path);
    } catch (e) {
      return null;
    }
  }

  /// Gets all source files that match a given pattern
  List<SourceFile> getSourceFilesMatching(Pattern pattern) {
    return sourceFiles
        .where((file) => pattern.allMatches(file.path).isNotEmpty)
        .toList();
  }

  /// Gets source files sorted by coverage percentage (lowest first)
  List<SourceFile> getSourceFilesSortedByCoverage() {
    final files = List<SourceFile>.from(sourceFiles);
    files.sort(
      (a, b) =>
          a.overallCoveragePercentage.compareTo(b.overallCoveragePercentage),
    );
    return files;
  }

  /// Gets source files with coverage below the specified threshold
  List<SourceFile> getSourceFilesBelowThreshold(double threshold) {
    return sourceFiles
        .where((file) => file.overallCoveragePercentage < threshold)
        .toList();
  }

  /// Gets source files with perfect coverage (100%)
  List<SourceFile> getSourceFilesWithPerfectCoverage() {
    return sourceFiles
        .where((file) => file.overallCoveragePercentage >= 100.0)
        .toList();
  }

  /// Gets source files with no coverage (0%)
  List<SourceFile> getSourceFilesWithNoCoverage() {
    return sourceFiles
        .where((file) => file.overallCoveragePercentage == 0.0)
        .toList();
  }

  /// Adds a source file to the coverage data
  CoverageData addSourceFile(SourceFile sourceFile) {
    final updatedFiles = List<SourceFile>.from(sourceFiles)..add(sourceFile);
    return CoverageData.fromSourceFiles(
      updatedFiles,
      title: title,
      timestamp: timestamp,
    );
  }

  /// Removes a source file from the coverage data
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

  /// Updates a source file in the coverage data
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

  /// Filters source files by a predicate function
  CoverageData filterSourceFiles(bool Function(SourceFile) predicate) {
    final filteredFiles = sourceFiles.where(predicate).toList();
    return CoverageData.fromSourceFiles(
      filteredFiles,
      title: title,
      timestamp: timestamp,
    );
  }

  /// Creates a copy of this coverage data with updated values
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

  /// Validates the coverage data for consistency
  List<String> validate() {
    final errors = <String>[];

    // Check for duplicate file paths
    final paths = <String>{};
    for (final file in sourceFiles) {
      if (paths.contains(file.path)) {
        errors.add('Duplicate source file path: ${file.path}');
      }
      paths.add(file.path);
    }

    // Validate summary matches source files
    final calculatedSummary = CoverageSummary.fromSourceFiles(sourceFiles);
    if (summary != calculatedSummary) {
      errors.add('Summary does not match calculated values from source files');
    }

    return errors;
  }

  @override
  String toString() {
    return 'CoverageData('
        'files: ${sourceFiles.length}, '
        'title: "$title", '
        'timestamp: $timestamp, '
        'summary: $summary'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CoverageData &&
        _listEquals(other.sourceFiles, sourceFiles) &&
        other.summary == summary &&
        other.title == title &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(sourceFiles, summary, title, timestamp);

  /// Helper method to compare lists for equality
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
