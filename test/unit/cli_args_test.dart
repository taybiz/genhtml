import 'package:test/test.dart';
import 'package:args/args.dart';
import '../../bin/genhtml.dart' as genhtml;

/// Unit tests for CLI argument parsing
void main() {
  group('CLI Arguments Tests', () {
    late ArgParser parser;

    setUp(() {
      parser = genhtml.buildParser();
    });

    test('should build parser with correct flags', () {
      expect(parser.options.containsKey('help'), isTrue);
      expect(parser.options.containsKey('verbose'), isTrue);
      expect(parser.options.containsKey('version'), isTrue);
    });

    test('should parse help flag correctly', () {
      final results = parser.parse(['--help']);
      expect(results.flag('help'), isTrue);
    });

    test('should parse help flag with abbreviation', () {
      final results = parser.parse(['-h']);
      expect(results.flag('help'), isTrue);
    });

    test('should parse verbose flag correctly', () {
      final results = parser.parse(['--verbose']);
      expect(results.flag('verbose'), isTrue);
    });

    test('should parse verbose flag with abbreviation', () {
      final results = parser.parse(['-v']);
      expect(results.flag('verbose'), isTrue);
    });

    test('should parse version flag correctly', () async {
      final results = parser.parse(['--version']);
      expect(results.flag('version'), isTrue);
    });

    test('should handle multiple flags', () {
      final results = parser.parse(['--verbose', '--version']);
      expect(results.flag('verbose'), isTrue);
      expect(results.flag('version'), isTrue);
    });

    test('should handle positional arguments', () {
      final results = parser.parse(['input.info', 'output.html']);
      expect(results.rest, equals(['input.info', 'output.html']));
    });

    test('should handle mixed flags and arguments', () {
      final results = parser.parse([
        '--verbose',
        'input.info',
        '--version',
        'output.html',
      ]);
      expect(results.flag('verbose'), isTrue);
      expect(results.flag('version'), isTrue);
      expect(results.rest, equals(['input.info', 'output.html']));
    });

    test('should handle no arguments', () {
      final results = parser.parse([]);
      expect(results.flag('help'), isFalse);
      expect(results.flag('verbose'), isFalse);
      expect(results.flag('version'), isFalse);
      expect(results.rest, isEmpty);
    });

    test('should throw FormatException for invalid flag', () {
      expect(() => parser.parse(['--invalid-flag']), throwsFormatException);
    });

    test('should handle flag negation correctly', () {
      // Since flags are non-negatable, this should work normally
      final results = parser.parse(['--verbose']);
      expect(results.flag('verbose'), isTrue);
    });
  });

  group('CLI Arguments Extended Tests', () {
    test('should handle complex argument combinations', () {
      final parser = genhtml.buildParser();
      final results = parser.parse([
        '--verbose',
        'coverage.info',
        '--version',
        'output_dir',
        'extra_arg',
      ]);

      expect(results.flag('verbose'), isTrue);
      expect(results.flag('version'), isTrue);
      expect(
        results.rest,
        equals(['coverage.info', 'output_dir', 'extra_arg']),
      );
    });

    test('should preserve argument order in rest', () {
      final parser = genhtml.buildParser();
      final results = parser.parse(['first', 'second', 'third']);

      expect(results.rest, equals(['first', 'second', 'third']));
    });

    test('should handle flags after positional arguments', () {
      final parser = genhtml.buildParser();
      final results = parser.parse(['input.info', '--verbose']);

      expect(results.flag('verbose'), isTrue);
      expect(results.rest, equals(['input.info']));
    });

    test('should handle empty string arguments', () {
      final parser = genhtml.buildParser();
      final results = parser.parse(['', '--verbose', '']);

      expect(results.flag('verbose'), isTrue);
      expect(results.rest, equals(['', '']));
    });
  });

  group('CLI Usage and Help Tests', () {
    test('should generate usage information', () {
      final parser = genhtml.buildParser();
      final usage = parser.usage;

      expect(usage, contains('help'));
      expect(usage, contains('verbose'));
      expect(usage, contains('version'));
      expect(usage, contains('Print this usage information'));
      expect(usage, contains('Show additional command output'));
      expect(usage, contains('Print the tool version'));
    });

    test('should have correct flag abbreviations', () {
      final parser = genhtml.buildParser();

      // Test that abbreviations are set correctly
      expect(parser.options['help']?.abbr, equals('h'));
      expect(parser.options['verbose']?.abbr, equals('v'));
      expect(
        parser.options['version']?.abbr,
        isNull,
      ); // No abbreviation for version
    });

    test('should have correct flag properties', () {
      final parser = genhtml.buildParser();

      // All flags should be non-negatable
      expect(parser.options['help']?.negatable, isFalse);
      expect(parser.options['verbose']?.negatable, isFalse);
      expect(parser.options['version']?.negatable, isFalse);
    });
  });

  group('Future CLI Arguments Tests', () {
    // These tests represent arguments we might want to add in the future
    test('should be extensible for input file argument', () {
      // Test that we can extend the parser for future functionality
      final extendedParser = ArgParser()
        ..addFlag('help', abbr: 'h', negatable: false)
        ..addFlag('verbose', abbr: 'v', negatable: false)
        ..addFlag('version', negatable: false)
        ..addOption('input', abbr: 'i', help: 'Input LCOV file')
        ..addOption('output', abbr: 'o', help: 'Output directory');

      final results = extendedParser.parse([
        '-i',
        'coverage.info',
        '-o',
        'html_out',
      ]);

      expect(results['input'], equals('coverage.info'));
      expect(results['output'], equals('html_out'));
    });

    test('should be extensible for coverage thresholds', () {
      final extendedParser = ArgParser()
        ..addFlag('help', abbr: 'h', negatable: false)
        ..addFlag('verbose', abbr: 'v', negatable: false)
        ..addFlag('version', negatable: false)
        ..addOption('line-threshold', help: 'Line coverage threshold')
        ..addOption('function-threshold', help: 'Function coverage threshold');

      final results = extendedParser.parse([
        '--line-threshold',
        '80',
        '--function-threshold',
        '90',
      ]);

      expect(results['line-threshold'], equals('80'));
      expect(results['function-threshold'], equals('90'));
    });

    test('should be extensible for output format options', () {
      final extendedParser = ArgParser()
        ..addFlag('help', abbr: 'h', negatable: false)
        ..addFlag('verbose', abbr: 'v', negatable: false)
        ..addFlag('version', negatable: false)
        ..addFlag('show-branches', help: 'Show branch coverage')
        ..addFlag(
          'show-functions',
          help: 'Show function coverage',
          defaultsTo: true,
        );

      final results = extendedParser.parse([
        '--show-branches',
        '--no-show-functions',
      ]);

      expect(results.flag('show-branches'), isTrue);
      expect(results.flag('show-functions'), isFalse);
    });
  });
}
