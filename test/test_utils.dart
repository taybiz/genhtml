import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

/// Test utilities for the genhtml project
class TestUtils {
  /// Get the path to a test fixture file
  static String getFixturePath(String filename) {
    return path.join('test', 'fixtures', filename);
  }

  /// Load the contents of a test fixture file
  static Future<String> loadFixture(String filename) async {
    final fixturePath = getFixturePath(filename);
    final file = File(fixturePath);

    if (!await file.exists()) {
      throw FileSystemException('Fixture file not found: $fixturePath');
    }

    return await file.readAsString();
  }

  /// Create a temporary directory for test outputs
  static Future<Directory> createTempDirectory([String? prefix]) async {
    final tempDir = await Directory.systemTemp.createTemp(
      prefix ?? 'genhtml_test_',
    );
    return tempDir;
  }

  /// Clean up a temporary directory and its contents
  static Future<void> cleanupTempDirectory(Directory tempDir) async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  }

  /// Compare two HTML files, ignoring whitespace differences
  static void expectHtmlEquals(
    String actual,
    String expected, {
    String? reason,
  }) {
    final normalizedActual = normalizeHtml(actual);
    final normalizedExpected = normalizeHtml(expected);

    expect(normalizedActual, equals(normalizedExpected), reason: reason);
  }

  /// Normalize HTML content for comparison by removing extra whitespace
  static String normalizeHtml(String html) {
    return html
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        ) // Replace multiple whitespace with single space
        .replaceAll(RegExp(r'>\s+<'), '><') // Remove whitespace between tags
        .trim();
  }

  /// Check if a file contains expected content
  static Future<void> expectFileContains(
    String filePath,
    String expectedContent,
  ) async {
    final file = File(filePath);
    expect(await file.exists(), isTrue, reason: 'File should exist: $filePath');

    final content = await file.readAsString();
    expect(content, contains(expectedContent));
  }

  /// Check if a file matches expected content exactly
  static Future<void> expectFileEquals(
    String filePath,
    String expectedContent,
  ) async {
    final file = File(filePath);
    expect(await file.exists(), isTrue, reason: 'File should exist: $filePath');

    final content = await file.readAsString();
    expect(content, equals(expectedContent));
  }

  /// Validate that generated HTML has proper structure
  static void validateHtmlStructure(String html) {
    expect(
      html,
      contains('<!DOCTYPE html>'),
      reason: 'HTML should have DOCTYPE',
    );
    expect(html, contains('<html>'), reason: 'HTML should have html tag');
    expect(html, contains('<head>'), reason: 'HTML should have head tag');
    expect(html, contains('<body>'), reason: 'HTML should have body tag');
    expect(
      html,
      contains('</html>'),
      reason: 'HTML should have closing html tag',
    );
  }

  /// Extract coverage percentage from HTML content
  static double? extractCoveragePercentage(String html, String metric) {
    final regex = RegExp('$metric.*?(\\d+\\.\\d+)%');
    final match = regex.firstMatch(html);
    if (match != null) {
      return double.tryParse(match.group(1)!);
    }
    return null;
  }

  /// Create a mock LCOV info content for testing
  static String createMockLcovInfo({
    required String sourceFile,
    required int totalLines,
    required int hitLines,
    required int totalFunctions,
    required int hitFunctions,
    List<String>? functionNames,
    List<int>? functionHits,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('TN:');
    buffer.writeln('SF:$sourceFile');

    // Add function data
    if (functionNames != null && functionHits != null) {
      for (int i = 0; i < functionNames.length; i++) {
        buffer.writeln('FN:${i + 1},${functionNames[i]}');
      }
      for (int i = 0; i < functionNames.length; i++) {
        final hits = i < functionHits.length ? functionHits[i] : 0;
        buffer.writeln('FNDA:$hits,${functionNames[i]}');
      }
    }

    buffer.writeln('FNF:$totalFunctions');
    buffer.writeln('FNH:$hitFunctions');

    // Add line data
    for (int i = 1; i <= totalLines; i++) {
      final hits = i <= hitLines ? 1 : 0;
      buffer.writeln('DA:$i,$hits');
    }

    buffer.writeln('LF:$totalLines');
    buffer.writeln('LH:$hitLines');
    buffer.writeln('BRF:0');
    buffer.writeln('BRH:0');
    buffer.writeln('end_of_record');

    return buffer.toString();
  }

  /// Validate LCOV info format
  static bool isValidLcovFormat(String content) {
    final lines = content.split('\n');
    bool hasSourceFile = false;
    bool hasEndRecord = false;

    for (final line in lines) {
      if (line.startsWith('SF:')) hasSourceFile = true;
      if (line == 'end_of_record') hasEndRecord = true;
    }

    return hasSourceFile && hasEndRecord;
  }

  /// Get all fixture files
  static Future<List<String>> getFixtureFiles() async {
    final fixturesDir = Directory(path.join('test', 'fixtures'));
    if (!await fixturesDir.exists()) {
      return [];
    }

    final files = await fixturesDir.list().toList();
    return files
        .whereType<File>()
        .map((file) => path.basename(file.path))
        .where((name) => !name.startsWith('.'))
        .toList();
  }
}

/// Custom matchers for testing
class CoverageMatcher extends Matcher {
  final double expectedPercentage;
  final double tolerance;

  const CoverageMatcher(this.expectedPercentage, {this.tolerance = 0.01});

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! double) return false;
    return (item - expectedPercentage).abs() <= tolerance;
  }

  @override
  Description describe(Description description) {
    return description.add(
      'coverage percentage within $tolerance of $expectedPercentage%',
    );
  }
}

/// Matcher for coverage percentages
Matcher coverageEquals(double percentage, {double tolerance = 0.01}) {
  return CoverageMatcher(percentage, tolerance: tolerance);
}
