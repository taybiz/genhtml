# Backlog

Tracked issues, build problems, and standards divergences for `genhtml`.
Items under **Build problems** were observed during a real build/test run
(`dart pub get` -> `dart analyze` -> `dart test` -> `dart compile exe`).
Items under **Deviations** compare the code against the Dart/Flutter Bible
(<https://github.com/staylorx/dart-flutter-bible>, `docs/`). A deviation is a
place the code differs from the bible where the bible might itself be wrong,
so each one is flagged for later review rather than "fixed" on sight.

## Build problems

- [ ] **Full test suite is red; every file passes in isolation.**
  `dart test` (whole package) fails 4-6 tests; running each test file alone
  (`dart test test/unit/lcov_parser_test.dart`, etc.) is fully green.
  Failing tests: `lcov_parser_test` ("should handle perfect coverage files",
  "should parse branch coverage data") and `html_generator_test` ("should
  generate file list table correctly", "should apply correct CSS classes for
  coverage levels", "should extract coverage percentages correctly",
  "HTML Template Tests should have responsive table structure") — the exact
  set varies run to run.
  Root cause: `test/unit/version_test.dart` assigns the process-wide
  `Directory.current` (lines ~39-256) and restores it only on its own happy
  path, while `test/test_utils.dart:9` resolves fixtures from a *relative*
  `test/fixtures/...` path. `dart test` runs several files in one isolate
  group/process, so the CWD mutation leaks into the sibling files and their
  `File(...).exists()` returns false.
  Fix direction: restore `Directory.current` in `tearDown`/`addTearDown`, or
  resolve fixture paths from an absolute path (`Platform.script`/package root),
  not from the mutable CWD. Then re-check the gate.
- [ ] **Unused dev dependency `io: ^1.0.0`.** Declared in `pubspec.yaml`
  (`dev_dependencies`) but never imported in `lib/`, `bin/`, `test/`, or
  `scripts/` (`grep -rn "package:io" => 0 hits`). Its API overlaps the
  `dart:io` it shadows; remove unless a concrete use is intended.
- [ ] **`dart format` reports unformatted files.** `dart format --output=none
  --set-exit-if-changed .` flags 2 files:
  `test/integration/cli_integration_test.dart`, `test/unit/html_generator_test.dart`.
  Run `dart format .` before the next release so the tree is format-clean.
- [ ] **CHANGELOG has no entry for the released `1.0.1`.** `pubspec.yaml`
  `version: 1.0.1` and `bin/genhtml.dart` `const version = "1.0.1"`, but
  `CHANGELOG.md`'s newest heading is `## [1.0.0] - 2025-09-09`. Add a `1.0.1`
  section (Keep a Changelog format) so the released version is documented.
- [ ] **Stale dependency set (informational).** `dart pub get` reports 23
  packages with newer versions incompatible with current constraints
  (`analyzer`, `test`, `coverage`, `vm_service`, ...). No action required now;
  revisit when bumping the SDK constraint (see Deviation SDK item).

Build result observed (for the record): `dart pub get` OK; `dart analyze
--fatal-infos --fatal-warnings` -> "No issues found!"; `dart compile exe
bin/genhtml.dart -o genhtml-test.exe` OK; the binary runs `--help` / `--version`
and generates a report (`index.html` + `<file>.html`) from
`test/fixtures/simple_coverage.info`. Only `dart test` (whole package) is red.

## Deviations

- [ ] **Deviation: SDK constraint is `^3.9.2`, bible pins `>=3.10.0 <4.0.0`.**
  `pubspec.yaml` declares `environment: sdk: ^3.9.2`; the bible's Toolchain
  section requires `>=3.10.0 <4.0.0` in every pubspec.
- [ ] **Deviation: failure is thrown, not returned as a value.**
  `lib/` raises exceptions across the core: `throw LcovParseException(...)`
  and `throw ArgumentError(...)` throughout `lib/src/parsers/lcov_parser.dart`,
  `lib/src/models/*.dart`, plus `try`/`catch` inside `lcov_parser.dart:46-206`,
  `coverage_data.dart:54-56`, `source_file.dart:89-100`. The bible requires
  exceptions ONLY at the UI ring and failure-as-a-value everywhere else
  (`Either`/`TaskEither`, sealed failure hierarchies), with `tryCatch` confined
  to third-party adapter boundaries. `fpdart` is not a dependency at all.
  (Reviewer's call: for a single-binary CLI the "UI ring" may reasonably be the
  entry point — but the bible's default is unambiguous.)
- [ ] **Deviation: no `equatable` on entities; equality is hand-rolled.**
  Every model implements `operator ==` / `hashCode` by hand
  (`branch_coverage.dart`, `coverage_data.dart`, `coverage_summary.dart`,
  `function_coverage.dart`, `line_coverage.dart`) instead of extending
  `Equatable` with a `props` list as the bible requires for immutable entities
  and value objects.
- [ ] **Deviation: analysis gate is weaker than the bible's.**
  `analysis_options.yaml` only does `include: package:lints/recommended.yaml`.
  The bible requires `public_member_api_docs` ON, `todo:error`, and a CI gate of
  `dart analyze --fatal-infos --fatal-warnings` (ZERO diagnostics of any
  severity). CI (`.github/workflows/build.yml`) runs a plain `dart analyze`.
  (Local `dart analyze --fatal-infos --fatal-warnings` is currently clean, so
  turning the gate on is low-risk — but the missing lints are still off.)
- [ ] **Deviation: multiple classes per file.**
  The bible is one class per file. Violations:
  `lib/src/generators/html_generator.dart` (`HtmlGenerator` + `HtmlGeneratorOptions`),
  `lib/src/parsers/lcov_parser.dart` (`LcovParser` + `SourceFileBuilder` + `LcovParseException`),
  `lib/src/utils/coverage_calculator.dart` (`CoverageCalculator` + `CoverageStatistics`),
  `lib/src/utils/validation.dart` (`Validation` + `ValidationResult`).
- [ ] **Deviation: tests use `package:test` + `expect`; bible mandates shouldly
  and Given/When/Then.** No `shouldly` or `mocktail` anywhere in `pubspec.yaml`
  or `test/`. The bible's testing section requires `x.should.be(...)` (never
  `expect()`), Given/When/Then test names, and mocktail at usecase seams.
- [ ] **Deviation: no architecture/boundary test.**
  There is no `dart_arch_test` (or equivalent resolved-import-graph) test
  asserting inward dependencies / cycle-free. The bible lists this as a CI hard
  gate. (Single-package CLI, so the onion is thin — still absent.)
- [ ] **Deviation: error style is not declared loudly.**
  The bible requires every package to state whether consumers get FP-style
  tuples or plain exceptions — in the barrel doc comment, the README, and
  `AGENTS.md` on deviation. `lib/genhtml.dart` has a one-line barrel doc comment
  but no error-style declaration; there is no `AGENTS.md`. Silence is itself the
  violation.
- [ ] **Deviation: dev-dependency stack does not match the bible.**
  Missing `shouldly`, `mocktail`, and `dart_arch_test`; `fpdart` and `equatable`
  (core-stack) are absent. `pubspec.yaml` dev deps are `lints`, `test`, `io`,
  `coverage`. (See the related build-problem item about the unused `io`.)

## Project hygiene (not a bible rule)

- [ ] **No `.gitattributes`.** Nothing pins line endings. Add
  `* text=auto eol=lf` if the repo is to stay LF-only across Windows/macOS/Linux
  checkouts (current tree is already LF).
