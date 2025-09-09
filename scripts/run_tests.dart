#!/usr/bin/env dart

import 'dart:io';

/// Test runner script for the genhtml project
void main(List<String> args) async {
  print('🧪 Running genhtml test suite...\n');

  final stopwatch = Stopwatch()..start();

  try {
    // Parse command line arguments
    final runCoverage = args.contains('--coverage') || args.contains('-c');
    final runUnit = args.contains('--unit') || args.contains('-u');
    final runIntegration =
        args.contains('--integration') || args.contains('-i');
    final verbose = args.contains('--verbose') || args.contains('-v');

    // If no specific test type is specified, run all tests
    final runAll = !runUnit && !runIntegration;

    if (runAll || runUnit) {
      print('📋 Running unit tests...');
      await runTestSuite('test/unit/', verbose: verbose, coverage: runCoverage);
    }

    if (runAll || runIntegration) {
      print('🔗 Running integration tests...');
      await runTestSuite(
        'test/integration/',
        verbose: verbose,
        coverage: runCoverage,
      );
    }

    if (runCoverage) {
      print('📊 Generating coverage report...');
      await generateCoverageReport();
    }

    stopwatch.stop();
    print('\n✅ All tests completed in ${stopwatch.elapsed.inMilliseconds}ms');
  } catch (e) {
    print('❌ Test execution failed: $e');
    exit(1);
  }
}

/// Run a specific test suite
Future<void> runTestSuite(
  String testPath, {
  bool verbose = false,
  bool coverage = false,
}) async {
  final args = <String>['test'];

  if (coverage) {
    args.addAll(['--coverage', 'coverage']);
  }

  if (verbose) {
    args.add('--reporter=expanded');
  }

  args.add(testPath);

  final result = await Process.run('dart', args);

  if (result.exitCode != 0) {
    print('Test output:\n${result.stdout}');
    print('Test errors:\n${result.stderr}');
    throw Exception('Tests failed with exit code ${result.exitCode}');
  }

  if (verbose) {
    print(result.stdout);
  }
}

/// Generate coverage report in multiple formats
Future<void> generateCoverageReport() async {
  final coverageDir = Directory('coverage');
  if (!await coverageDir.exists()) {
    print('⚠️  No coverage data found. Run tests with --coverage flag first.');
    return;
  }

  // Generate LCOV report
  final lcovResult = await Process.run('dart', [
    'run',
    'coverage:format_coverage',
    '--lcov',
    '--in=coverage',
    '--out=coverage/lcov.info',
    '--packages=.dart_tool/package_config.json',
    '--report-on=lib',
  ]);

  if (lcovResult.exitCode == 0) {
    print('📄 LCOV report generated: coverage/lcov.info');
  } else {
    print('⚠️  Failed to generate LCOV report: ${lcovResult.stderr}');
  }

  // Generate HTML report (this will use our own genhtml once implemented)
  final htmlResult = await Process.run('dart', [
    'bin/genhtml.dart',
    'coverage/lcov.info',
    'coverage/html',
  ]);

  if (htmlResult.exitCode == 0) {
    print('🌐 HTML report generated: coverage/html/index.html');
  } else {
    print('⚠️  HTML report generation not yet implemented');
  }
}

/// Print usage information
void printUsage() {
  print('''
Usage: dart scripts/run_tests.dart [options]

Options:
  -c, --coverage      Generate coverage report
  -u, --unit          Run only unit tests
  -i, --integration   Run only integration tests
  -v, --verbose       Verbose output
  -h, --help          Show this help message

Examples:
  dart scripts/run_tests.dart                    # Run all tests
  dart scripts/run_tests.dart --coverage        # Run all tests with coverage
  dart scripts/run_tests.dart --unit --verbose  # Run unit tests with verbose output
''');
}
