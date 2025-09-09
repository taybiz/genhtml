# Test Suite Documentation

This directory contains the comprehensive test suite for the genhtml Dart CLI project.

## Directory Structure

```
test/
├── unit/                   # Unit tests for individual components
│   ├── lcov_parser_test.dart      # Tests for LCOV file parsing
│   ├── html_generator_test.dart   # Tests for HTML generation
│   └── cli_args_test.dart         # Tests for CLI argument parsing
├── integration/            # Integration tests for complete workflows
│   └── cli_integration_test.dart  # End-to-end CLI testing
├── fixtures/               # Test data files
│   ├── simple_coverage.info       # Single-file coverage data
│   ├── multi_file_coverage.info   # Multi-file project coverage
│   ├── zero_coverage.info         # Zero coverage edge case
│   ├── perfect_coverage.info      # 100% coverage scenario
│   ├── branch_coverage.info       # Branch coverage data
│   └── expected_simple.html       # Expected HTML output
├── test_utils.dart         # Test utilities and helper functions
├── all_tests.dart          # Main test runner
└── README.md              # This documentation
```

## Test Categories

### Unit Tests

Unit tests focus on testing individual components in isolation:

- **LCOV Parser Tests** (`lcov_parser_test.dart`): Tests for parsing LCOV info files, handling various coverage scenarios, and validating LCOV format.
- **HTML Generator Tests** (`html_generator_test.dart`): Tests for generating HTML coverage reports, CSS styling, and template structure.
- **CLI Arguments Tests** (`cli_args_test.dart`): Tests for command-line argument parsing, flag handling, and error cases.

### Integration Tests

Integration tests verify the complete workflow from input to output:

- **CLI Integration Tests** (`cli_integration_test.dart`): End-to-end testing of the CLI tool, including file processing, error handling, and output generation.

### Test Fixtures

The `fixtures/` directory contains realistic test data representing various coverage scenarios:

- **Simple Coverage**: Basic single-file coverage with 100% line and function coverage
- **Multi-file Coverage**: Complex project with multiple files and varying coverage percentages
- **Zero Coverage**: Edge case with no code execution
- **Perfect Coverage**: 100% coverage across all metrics
- **Branch Coverage**: Advanced coverage including branch/conditional coverage data

## Running Tests

### Using Dart Test Command

```bash
# Run all tests
dart test

# Run specific test file
dart test test/unit/lcov_parser_test.dart

# Run tests with coverage
dart test --coverage=coverage

# Run tests with verbose output
dart test --reporter=expanded
```

### Using Custom Test Runner

```bash
# Run all tests
dart scripts/run_tests.dart

# Run with coverage report
dart scripts/run_tests.dart --coverage

# Run only unit tests
dart scripts/run_tests.dart --unit

# Run only integration tests
dart scripts/run_tests.dart --integration

# Verbose output
dart scripts/run_tests.dart --verbose
```

## Test Utilities

The `test_utils.dart` file provides helper functions for:

- **Fixture Loading**: Load test data files easily
- **Temporary Directories**: Create and cleanup test environments
- **HTML Comparison**: Compare generated HTML with expected output
- **Coverage Validation**: Validate LCOV format and extract metrics
- **Mock Data Generation**: Create test LCOV data programmatically

### Example Usage

```dart
import '../test_utils.dart';

test('should load fixture correctly', () async {
  final lcovContent = await TestUtils.loadFixture('simple_coverage.info');
  expect(TestUtils.isValidLcovFormat(lcovContent), isTrue);
});

test('should compare HTML output', () async {
  final expectedHtml = await TestUtils.loadFixture('expected_simple.html');
  final actualHtml = generateHtml(coverageData);
  TestUtils.expectHtmlEquals(actualHtml, expectedHtml);
});
```

## Coverage Goals

The test suite is designed to achieve comprehensive coverage:

- **Line Coverage**: Target 90%+ coverage of all source code
- **Function Coverage**: Target 90%+ coverage of all functions
- **Branch Coverage**: Target 80%+ coverage of conditional branches
- **Integration Coverage**: Complete workflow testing from LCOV input to HTML output

## Test Data Scenarios

The test fixtures cover realistic scenarios that genhtml should handle:

1. **Single File Projects**: Simple libraries with basic coverage
2. **Multi-file Projects**: Complex applications with varying coverage across files
3. **Edge Cases**: Zero coverage, perfect coverage, missing files
4. **Advanced Metrics**: Branch coverage, function coverage, line coverage
5. **Real-world Data**: Representative of actual Dart project coverage reports

## Continuous Integration

The test suite is designed to run in CI environments:

- All tests should pass on clean checkout
- Coverage reports are generated automatically
- Integration tests validate complete functionality
- Performance benchmarks ensure reasonable execution time

## Contributing to Tests

When adding new functionality:

1. **Add Unit Tests**: Test individual components in isolation
2. **Add Integration Tests**: Test complete workflows
3. **Add Test Fixtures**: Include realistic test data
4. **Update Documentation**: Keep this README current
5. **Validate Coverage**: Ensure new code is well-tested

### Test Naming Conventions

- Test files end with `_test.dart`
- Test groups describe the component being tested
- Test cases describe the specific behavior being verified
- Use descriptive names that explain the expected behavior

### Test Structure

```dart
void main() {
  group('Component Name', () {
    setUp(() {
      // Setup code
    });

    tearDown(() {
      // Cleanup code
    });

    test('should do something specific', () {
      // Test implementation
    });
  });
}
```

## Future Enhancements

Planned improvements to the test suite:

- **Performance Tests**: Benchmark coverage report generation speed
- **Memory Tests**: Validate memory usage with large LCOV files
- **Cross-platform Tests**: Ensure compatibility across operating systems
- **Regression Tests**: Prevent breaking changes to existing functionality
- **Property-based Tests**: Generate random test data for edge case discovery

## Troubleshooting

Common issues and solutions:

- **Test Failures**: Check that all dependencies are installed with `dart pub get`
- **Coverage Issues**: Ensure coverage directory exists and has proper permissions
- **Integration Test Failures**: Verify that the CLI tool builds successfully
- **Fixture Loading Errors**: Check that test fixture files exist and are readable

For more help, see the main project README or open an issue on the project repository.