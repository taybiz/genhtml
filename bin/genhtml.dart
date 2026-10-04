import 'dart:io';

import 'package:args/args.dart';
import 'package:genhtml/genhtml.dart';

/// The tool version, kept in sync with `pubspec.yaml` by hand.
const String version = '1.0.1';

/// Builds the argument parser for the genhtml CLI.
ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag('version', negatable: false, help: 'Print the tool version.')
    ..addOption(
      'output-directory',
      abbr: 'o',
      help: 'Output directory for generated HTML files.',
      defaultsTo: 'coverage_html',
    )
    ..addOption(
      'title',
      abbr: 't',
      help: 'Title for the coverage report.',
      defaultsTo: 'LCOV - Code Coverage Report',
    )
    ..addFlag(
      'show-branches',
      help: 'Show branch coverage information.',
      defaultsTo: true,
    )
    ..addFlag(
      'show-functions',
      help: 'Show function coverage information.',
      defaultsTo: true,
    )
    ..addOption(
      'line-threshold',
      help: 'Line coverage threshold percentage (0-100).',
      defaultsTo: '0',
    )
    ..addOption(
      'function-threshold',
      help: 'Function coverage threshold percentage (0-100).',
      defaultsTo: '0',
    )
    ..addOption(
      'branch-threshold',
      help: 'Branch coverage threshold percentage (0-100).',
      defaultsTo: '0',
    )
    ..addFlag(
      'quiet',
      abbr: 'q',
      negatable: false,
      help: 'Suppress all output except errors.',
    )
    ..addFlag(
      'no-sort',
      negatable: false,
      help: 'Do not sort files by coverage percentage.',
    );
}

/// Prints usage information for the CLI.
void printUsage(ArgParser argParser) {
  print('Usage: dart genhtml.dart [options] <lcov-file>');
  print('');
  print('Generate HTML coverage reports from LCOV trace files.');
  print('');
  print('Options:');
  print(argParser.usage);
  print('');
  print('Examples:');
  print('  dart genhtml.dart coverage.info');
  print(
    '  dart genhtml.dart -o html_report --title "My Project" coverage.info',
  );
  print(
    '  dart genhtml.dart --line-threshold 80 --function-threshold 90 coverage.info',
  );
}

/// CLI entry point.
///
/// This is the single permitted throw surface in the project: it consumes the
/// `Either` / `TaskEither` values returned by the core, prints any failure and
/// maps it onto the process exit code. Library code never throws.
Future<void> main(List<String> arguments) async {
  final ArgParser argParser = buildParser();

  try {
    final ArgResults results = argParser.parse(arguments);

    // Handle help and version first — no validation needed.
    if (results.flag('help')) {
      printUsage(argParser);
      exit(0);
    }

    if (results.flag('version')) {
      print('genhtml version: $version');
      exit(0);
    }

    // Validate the command-line arguments (failure is a value).
    final argsCheck = Validation.validateCommandLineArgs(arguments);
    if (argsCheck.isLeft()) {
      stderr.writeln('Error: ${argsCheck.getLeft().toNullable()!.message}');
      exit(1);
    }

    if (results.rest.isEmpty) {
      stderr.writeln('Error: No input LCOV file specified.');
      printUsage(argParser);
      exit(1);
    }

    if (results.rest.length > 1) {
      stderr.writeln('Error: Multiple input files not supported yet.');
      exit(1);
    }

    final inputFile = results.rest.first;
    final outputDir = results['output-directory'] as String;
    final title = results['title'] as String;
    final verbose = results.flag('verbose');
    final quiet = results.flag('quiet');
    final showBranches = results.flag('show-branches');
    final showFunctions = results.flag('show-functions');

    // Parse threshold values.
    final lineThreshold =
        double.tryParse(results['line-threshold'] as String) ?? 0.0;
    final functionThreshold =
        double.tryParse(results['function-threshold'] as String) ?? 0.0;
    final branchThreshold =
        double.tryParse(results['branch-threshold'] as String) ?? 0.0;

    // Validate thresholds.
    for (final threshold in [
      lineThreshold,
      functionThreshold,
      branchThreshold,
    ]) {
      final thresholdCheck = Validation.validateCoverageThreshold(threshold);
      if (thresholdCheck.isLeft()) {
        stderr.writeln(
          'Error: ${thresholdCheck.getLeft().toNullable()!.message}',
        );
        exit(1);
      }
    }

    // A title that fails validation is a warning, not a fatal error.
    final titleCheck = Validation.validateHtmlTitle(title);
    if (titleCheck.isLeft() && verbose) {
      print('Warning: ${titleCheck.getLeft().toNullable()!.message}');
    }

    // Validate the input file exists.
    const fileDatasource = LcovFileDatasource();
    final existsEither = await fileDatasource.exists(inputFile).run();
    if (existsEither.isLeft() || existsEither.getRight().toNullable() != true) {
      stderr.writeln('Error: File does not exist: $inputFile');
      exit(1);
    }

    if (!quiet) {
      print('Reading LCOV file: $inputFile');
    }

    // Read and parse the LCOV trace — failures are values, never throws.
    final readEither = await fileDatasource.read(inputFile).run();
    if (readEither.isLeft()) {
      stderr.writeln(
        'Error parsing LCOV file: ${readEither.getLeft().toNullable()!.message}',
      );
      exit(1);
    }

    final content = readEither.getRight().toNullable()!;
    final parsed = const ParseLcovUseCase()(content, title: title);
    if (parsed.isLeft()) {
      stderr.writeln(
        'Error parsing LCOV file: ${parsed.getLeft().toNullable()!.message}',
      );
      exit(1);
    }

    final coverageData = parsed.getRight().toNullable()!;

    if (!quiet) {
      print('Found ${coverageData.fileCount} source files');
      print(
        'Overall coverage: ${CoverageCalculator.formatCoveragePercentage(coverageData.summary.overallCoveragePercentage)}',
      );
      print(
        '  Lines: ${coverageData.summary.linesCoverageString} (${CoverageCalculator.formatCoveragePercentage(coverageData.summary.lineCoveragePercentage)})',
      );
      print(
        '  Functions: ${coverageData.summary.functionsCoverageString} (${CoverageCalculator.formatCoveragePercentage(coverageData.summary.functionCoveragePercentage)})',
      );
      print(
        '  Branches: ${coverageData.summary.branchesCoverageString} (${CoverageCalculator.formatCoveragePercentage(coverageData.summary.branchCoveragePercentage)})',
      );
    }

    // Check thresholds.
    var exitCode = 0;

    if (lineThreshold > 0 &&
        !coverageData.summary.meetsLineCoverageThreshold(lineThreshold)) {
      stderr.writeln(
        'Line coverage ${CoverageCalculator.formatCoveragePercentage(coverageData.summary.lineCoveragePercentage)} is below threshold ${CoverageCalculator.formatCoveragePercentage(lineThreshold)}',
      );
      exitCode = 1;
    }

    if (functionThreshold > 0 &&
        !coverageData.summary.meetsFunctionCoverageThreshold(
          functionThreshold,
        )) {
      stderr.writeln(
        'Function coverage ${CoverageCalculator.formatCoveragePercentage(coverageData.summary.functionCoveragePercentage)} is below threshold ${CoverageCalculator.formatCoveragePercentage(functionThreshold)}',
      );
      exitCode = 1;
    }

    if (branchThreshold > 0 &&
        !coverageData.summary.meetsBranchCoverageThreshold(branchThreshold)) {
      stderr.writeln(
        'Branch coverage ${CoverageCalculator.formatCoveragePercentage(coverageData.summary.branchCoveragePercentage)} is below threshold ${CoverageCalculator.formatCoveragePercentage(branchThreshold)}',
      );
      exitCode = 1;
    }

    // Render the report (pure) and write it (adapter).
    if (!quiet) {
      print('Generating HTML report in: $outputDir');
    }

    final pages = const GenerateHtmlReportUseCase()(
      coverageData,
      options: HtmlReportOptions(
        title: title,
        showBranches: showBranches,
        showFunctions: showFunctions,
      ),
    );

    const reportDatasource = HtmlReportDatasource();
    final writeEither = await reportDatasource.write(outputDir, pages).run();
    if (writeEither.isLeft()) {
      stderr.writeln(
        'Error generating HTML report: ${writeEither.getLeft().toNullable()!.message}',
      );
      exit(1);
    }

    if (!quiet) {
      print(
        'Generated index.html and ${coverageData.fileCount} source file pages',
      );
      print('Open $outputDir/index.html in your browser to view the report');
    }

    if (!quiet && exitCode == 0) {
      print('Coverage report generation completed successfully.');
    }

    exit(exitCode);
  } on FormatException catch (e) {
    stderr.writeln('Error: ${e.message}');
    print('');
    printUsage(argParser);
    exit(1);
  } catch (e) {
    stderr.writeln('Unexpected error: $e');
    exit(1);
  }
}
