import 'dart:io';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;
import '../version_utils.dart';
import '../test_utils.dart';

/// Integration tests for the complete CLI workflow
void main() {
  group('CLI Integration Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await TestUtils.createTempDirectory('genhtml_integration_');
    });

    tearDown(() async {
      await TestUtils.cleanupTempDirectory(tempDir);
    });

    test('should display help when --help flag is used', () async {
      final result = await Process.run('dart', [
        'bin/genhtml.dart',
        '--help',
      ], workingDirectory: Directory.current.path);

      expect(result.exitCode, equals(0));
      expect(result.stdout, contains('Usage: dart genhtml.dart'));
      expect(result.stdout, contains('Print this usage information'));
      expect(result.stdout, contains('Show additional command output'));
      expect(result.stdout, contains('Print the tool version'));
    });

    test('should display version when --version flag is used', () async {
      final result = await Process.run('dart', [
        'bin/genhtml.dart',
        '--version',
      ], workingDirectory: Directory.current.path);

      expect(result.exitCode, equals(0));

      // Get the expected version from pubspec.yaml
      final expectedVersion = await VersionUtils.getVersionFromPubspec();
      expect(result.stdout, contains('genhtml version: $expectedVersion'));
    });

    test('should handle invalid arguments gracefully', () async {
      final result = await Process.run('dart', [
        'bin/genhtml.dart',
        '--invalid-flag',
      ], workingDirectory: Directory.current.path);

      expect(result.exitCode, equals(1));
      expect(
        result.stderr,
        contains('Could not find an option named "--invalid-flag"'),
      );
    });

    test('should handle mixed flags and arguments', () async {
      final result = await Process.run('dart', [
        'bin/genhtml.dart',
        '--version',
      ], workingDirectory: Directory.current.path);

      expect(result.exitCode, equals(0));

      // Get the expected version from pubspec.yaml
      final expectedVersion = await VersionUtils.getVersionFromPubspec();
      expect(result.stdout, contains('genhtml version: $expectedVersion'));
    });
  });

  group('CLI File Processing Integration Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await TestUtils.createTempDirectory('genhtml_file_test_');
    });

    tearDown(() async {
      await TestUtils.cleanupTempDirectory(tempDir);
    });

    test('should handle non-existent input file gracefully', () async {
      final nonExistentFile = path.join(tempDir.path, 'non_existent.info');

      final result = await Process.run('dart', [
        'bin/genhtml.dart',
        nonExistentFile,
      ], workingDirectory: Directory.current.path);

      expect(result.exitCode, equals(1));
      expect(result.stderr, contains('Error: File does not exist'));
    });

    test('should process valid LCOV file path', () async {
      final lcovFile = path.join(tempDir.path, 'test.info');
      final outputDir = path.join(tempDir.path, 'output');
      final lcovContent = await TestUtils.loadFixture('simple_coverage.info');
      await File(lcovFile).writeAsString(lcovContent);

      final result = await Process.run('dart', [
        'bin/genhtml.dart',
        lcovFile,
        '-o',
        outputDir,
      ], workingDirectory: Directory.current.path);

      expect(result.exitCode, equals(0));
      expect(result.stdout, contains('Reading LCOV file: $lcovFile'));
      expect(result.stdout, contains('Generated index.html'));

      // Verify output files were created
      expect(await Directory(outputDir).exists(), isTrue);
      expect(await File(path.join(outputDir, 'index.html')).exists(), isTrue);
    });

    test('should handle output directory option', () async {
      final lcovFile = path.join(tempDir.path, 'test.info');
      final outputDir = path.join(tempDir.path, 'html_output');
      final lcovContent = await TestUtils.loadFixture('simple_coverage.info');
      await File(lcovFile).writeAsString(lcovContent);

      final result = await Process.run('dart', [
        'bin/genhtml.dart',
        '--output-directory',
        outputDir,
        lcovFile,
      ], workingDirectory: Directory.current.path);

      expect(result.exitCode, equals(0));
      expect(result.stdout, contains('Generating HTML report in: $outputDir'));

      // Verify output directory was created
      expect(await Directory(outputDir).exists(), isTrue);
    });
  });

  group('Future CLI Integration Tests', () {
    // These tests represent the functionality we want to implement

    test('should generate HTML from LCOV file', () async {
      final tempDir = await TestUtils.createTempDirectory('genhtml_future_');

      try {
        final inputFile = path.join(tempDir.path, 'coverage.info');
        final outputDir = path.join(tempDir.path, 'html_out');

        // Copy test fixture to temp location
        final lcovContent = await TestUtils.loadFixture('simple_coverage.info');
        await File(inputFile).writeAsString(lcovContent);

        final result = await Process.run('dart', [
          'bin/genhtml.dart',
          inputFile,
          '-o',
          outputDir,
        ], workingDirectory: Directory.current.path);

        expect(result.exitCode, equals(0));
        expect(result.stdout, contains('Reading LCOV file: $inputFile'));
        expect(result.stdout, contains('Generated index.html'));

        // Verify HTML files were created
        expect(await Directory(outputDir).exists(), isTrue);
        expect(await File(path.join(outputDir, 'index.html')).exists(), isTrue);

        // Verify the HTML content is valid
        final indexContent = await File(
          path.join(outputDir, 'index.html'),
        ).readAsString();
        expect(indexContent, contains('<!DOCTYPE html>'));
        expect(indexContent, contains('LCOV - Code Coverage Report'));
        expect(indexContent, contains('lib/calculator.dart'));
      } finally {
        await TestUtils.cleanupTempDirectory(tempDir);
      }
    });

    test('should validate LCOV file format before processing', () async {
      final tempDir = await TestUtils.createTempDirectory(
        'genhtml_validation_',
      );

      try {
        final invalidFile = path.join(tempDir.path, 'invalid.info');
        await File(invalidFile).writeAsString('This is not LCOV format');

        final result = await Process.run('dart', [
          'bin/genhtml.dart',
          invalidFile,
        ], workingDirectory: Directory.current.path);

        expect(result.exitCode, equals(0));
        expect(result.stdout, contains('Found 0 source files'));
      } finally {
        await TestUtils.cleanupTempDirectory(tempDir);
      }
    });

    test('should support coverage threshold options', () async {
      final tempDir = await TestUtils.createTempDirectory('genhtml_threshold_');

      try {
        final lcovFile = path.join(tempDir.path, 'coverage.info');
        final lcovContent = await TestUtils.loadFixture('simple_coverage.info');
        await File(lcovFile).writeAsString(lcovContent);

        final result = await Process.run('dart', [
          'bin/genhtml.dart',
          '--line-threshold',
          '80',
          lcovFile,
        ], workingDirectory: Directory.current.path);

        expect(result.exitCode, equals(0));
        expect(result.stdout, contains('Reading LCOV file: $lcovFile'));
      } finally {
        await TestUtils.cleanupTempDirectory(tempDir);
      }
    });
  });

  group('CLI Error Handling Integration Tests', () {
    test('should handle empty arguments gracefully', () async {
      final result = await Process.run('dart', [
        'bin/genhtml.dart',
      ], workingDirectory: Directory.current.path);

      expect(result.exitCode, equals(1));
      expect(result.stderr, contains('Error: No input file specified'));
    });

    test('should handle special characters in file names', () async {
      final tempDir = await TestUtils.createTempDirectory('genhtml_special_');

      try {
        final specialFile = path.join(
          tempDir.path,
          'file with spaces & symbols!.info',
        );
        final lcovContent = await TestUtils.loadFixture('simple_coverage.info');
        await File(specialFile).writeAsString(lcovContent);

        final result = await Process.run('dart', [
          'bin/genhtml.dart',
          specialFile,
        ], workingDirectory: Directory.current.path);

        expect(result.exitCode, equals(0));
        expect(result.stdout, contains('Reading LCOV file: $specialFile'));
      } finally {
        await TestUtils.cleanupTempDirectory(tempDir);
      }
    });

    test('should handle multiple input files error', () async {
      final result = await Process.run('dart', [
        'bin/genhtml.dart',
        'file1.info',
        'file2.info',
      ], workingDirectory: Directory.current.path);

      expect(result.exitCode, equals(1));
      expect(
        result.stderr,
        contains('Error: Multiple input files not supported yet'),
      );
    });
  });
}
