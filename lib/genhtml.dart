/// A Dart implementation of genhtml for generating HTML coverage reports from LCOV data.
library;

// Export data models
export 'src/models/coverage_data.dart';
export 'src/models/source_file.dart';
export 'src/models/coverage_summary.dart';
export 'src/models/line_coverage.dart';
export 'src/models/function_coverage.dart';
export 'src/models/branch_coverage.dart';

// Export parsers
export 'src/parsers/lcov_parser.dart';

// Export generators
export 'src/generators/html_generator.dart';
export 'src/generators/css_generator.dart';

// Export utilities
export 'src/utils/file_utils.dart';
export 'src/utils/coverage_calculator.dart';
export 'src/utils/validation.dart';
