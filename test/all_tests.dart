import 'package:test/test.dart';

// Import all test files
import 'unit/lcov_parser_test.dart' as lcov_parser_tests;
import 'unit/html_generator_test.dart' as html_generator_tests;
import 'unit/cli_args_test.dart' as cli_args_tests;
import 'integration/cli_integration_test.dart' as cli_integration_tests;

/// Main test runner that imports and runs all tests
void main() {
  group('Unit Tests', () {
    group('LCOV Parser', lcov_parser_tests.main);
    group('HTML Generator', html_generator_tests.main);
    group('CLI Arguments', cli_args_tests.main);
  });

  group('Integration Tests', () {
    group('CLI Integration', cli_integration_tests.main);
  });
}
