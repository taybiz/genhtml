/// Failure hierarchy for the genhtml functional core.
///
/// Every fallible operation in `lib/` returns its failure **as a value** —
/// an `Either<GenhtmlFailure, T>` or a `TaskEither<GenhtmlFailure, T>` — and
/// never throws. A [GenhtmlFailure] is data, not an exception: the core does
/// not throw, and the only permitted throw surface is the single-binary CLI
/// entry point in `bin/genhtml.dart`, which inspects the returned `Either`,
/// prints the failure message and sets the process exit code.
///
/// The hierarchy is `sealed`, so consumers can switch exhaustively over the
/// failure kinds.
sealed class GenhtmlFailure {
  /// Creates a failure carrying a human-readable [message].
  const GenhtmlFailure(this.message);

  /// A human-readable description of what went wrong.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The input is not valid LCOV: empty, missing required records, or a
/// malformed record.
final class ParseFailure extends GenhtmlFailure {
  /// Creates a parse failure with the given [message].
  const ParseFailure(super.message);
}

/// A supplied option (command-line argument, threshold, title, path) failed
/// validation.
final class ValidationFailure extends GenhtmlFailure {
  /// Creates a validation failure with the given [message].
  const ValidationFailure(super.message);
}

/// A file-system or other I/O operation failed at an adapter boundary.
final class IoFailure extends GenhtmlFailure {
  /// Creates an I/O failure with the given [message].
  const IoFailure(super.message);
}
