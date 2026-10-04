/// genhtml — generate HTML coverage reports from LCOV trace files.
///
/// A Windows-native, single-binary reimplementation of the Linux `genhtml`
/// tool: it reads an LCOV `.info` trace and writes a self-contained HTML
/// coverage report.
///
/// ## Error style
///
/// This package is functional-core: **consumers receive failures as values,
/// never exceptions.** Every fallible operation returns
/// `Either<GenhtmlFailure, T>` or `TaskEither<GenhtmlFailure, T>`:
///
/// * [ParseLcovUseCase] returns `Either` (pure string → data).
/// * [Validation] returns `Either` (pure checks).
/// * [LcovFileDatasource] and [HtmlReportDatasource] return `TaskEither`
///   (asynchronous file I/O).
///
/// Failures are the sealed [GenhtmlFailure] hierarchy — [ParseFailure],
/// [ValidationFailure], [IoFailure] — so a consumer can switch over the kinds
/// exhaustively. `try`/`catch` appears only inside the datasource adapters,
/// where the third-party `dart:io` calls are wrapped once by
/// `TaskEither.tryCatch`.
///
/// The single permitted throw surface is the CLI entry point,
/// `bin/genhtml.dart`: it inspects the returned value, prints the failure
/// message on `stderr` and sets the process exit code. Library consumers never
/// see an exception. See `AGENTS.md` for the declaration in context.
library;

// Domain — entities and value objects.
export 'src/domain/entities/branch_coverage.dart';
export 'src/domain/entities/coverage_data.dart';
export 'src/domain/entities/coverage_summary.dart';
export 'src/domain/entities/function_coverage.dart';
export 'src/domain/entities/html_report_options.dart';
export 'src/domain/entities/line_coverage.dart';
export 'src/domain/entities/source_file.dart';

// Domain — failures and pure validation.
export 'src/domain/failures.dart';
export 'src/domain/validation.dart';

// Domain — use cases.
export 'src/domain/usecases/generate_html_report_use_case.dart';
export 'src/domain/usecases/parse_lcov_use_case.dart';

// Datasource adapters (the only `tryCatch` boundary).
export 'src/datasources/html_report_datasource.dart';
export 'src/datasources/lcov_file_datasource.dart';

// Pure helpers.
export 'src/generators/css_generator.dart';
export 'src/utils/coverage_calculator.dart';
export 'src/utils/file_utils.dart';
