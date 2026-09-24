# Backlog

Tracked issues, build problems, and standards divergences for `genhtml`.
Items under **Build problems** were observed during a real build/analyze/test
run on the Windows lane (Dart 3.13.1, Windows x64):

`dart pub get` -> `dart analyze --fatal-infos --fatal-warnings` ->
`dart format --output=none --set-exit-if-changed .` -> `dart test` ->
`dart compile exe` -> `dart pub publish --dry-run`.

Items under **Deviations** compare the code against the Dart/Flutter Bible
(<https://github.com/staylorx/dart-flutter-bible>, `docs/01`-`docs/12`). A
deviation is a place the code differs from the bible where the bible might
itself be wrong, so each one is flagged for later review rather than "fixed"
on sight. Which sections were compared is recorded in **Bible section
coverage** at the end.

Last full audit: 2026-09-24 (Dart 3.13.1, Windows x64).

## Build problems

- [ ] **Whole-package `dart test` is flaky: it passes or fails on unmodified
  code.** Three consecutive `dart test` runs of the same commit gave three
  different results — run A `Some tests failed.` (75 passed, 2 skipped, 2
  failed), run B `All tests passed!` (77 passed, 2 skipped), run C
  `Some tests failed.` (72 passed, 2 skipped, 5 failed). Failures seen:
  `test/unit/lcov_parser_test.dart` ("should extract function data from LCOV",
  "should extract line data from LCOV") and
  `test/unit/html_generator_test.dart` ("should have consistent HTML template
  structure", "should include meta charset", "should have responsive table
  structure"), all with
  `FileSystemException: Fixture file not found: test\fixtures\simple_coverage.info`.
  Every test file passes in isolation (`dart test test/unit/<file>.dart` is
  green for all four unit files), and `dart test test/all_tests.dart` is green
  (62 passed, 2 skipped) because that runner pulls every suite into one isolate
  where they run sequentially.
  Root cause: `Directory.current` is **process-global** and `dart test` runs
  the suites **concurrently in one process**. `version_test.dart` sets
  `Directory.current = <temp dir>` inside a dozen tests (lines 39, 54, 68, 82,
  100, 120, 130, 155, 181, 206, 231, 256) and restores it only in that group's
  `tearDown` (line 17, `Directory.current = originalWorkingDir`), while
  `test/test_utils.dart:9` resolves fixtures from the **relative** path
  `path.join('test', 'fixtures', filename)`. Any sibling suite that reads a
  fixture inside that window resolves it against `version_test`'s temp dir and
  `exists()` returns false. It is a race, not a missing cleanup.
  Fix direction (not applied): resolve fixture paths from an absolute path
  (package root / `Platform.script`, not the mutable CWD) **and/or** stop
  mutating the global CWD in `version_test` (inject the directory), then
  re-check the gate. `--concurrency=1` would mask it, not fix it.
  **Consequence for CI:** `.github/workflows/build.yml` runs `dart test` on
  every push to `main`, so CI can go red on an unmodified tree.
- [ ] **Unused dev dependency `io: ^1.0.0`.** Declared in `pubspec.yaml`
  (`dev_dependencies`) but never imported in `lib/`, `bin/`, `test/`, or
  `scripts/` (`grep -rn "package:io"` -> 0 hits). Its API overlaps the
  `dart:io` it shadows; remove unless a concrete use is intended.
- [ ] **`dart format` reports unformatted files.** `dart format --output=none
  --set-exit-if-changed .` (exit 1) flags 2 of 24 files:
  `test/integration/cli_integration_test.dart`, `test/unit/html_generator_test.dart`.
  Run `dart format .` before the next release so the tree is format-clean.
- [ ] **CHANGELOG has no entry for the released `1.0.1`.** `pubspec.yaml`
  `version: 1.0.1` and `bin/genhtml.dart` `const version = "1.0.1"`, but
  `CHANGELOG.md`'s newest released heading is `## [1.0.0] - 2025-09-09`. Add a
  `1.0.1` section (Keep a Changelog format) so the released version is
  documented.
- [ ] **Repository metadata points at a repo that does not exist.**
  `pubspec.yaml` `repository: https://github.com/staylorx/genhtml-dart` returns
  **HTTP 404** from the GitHub API (so does `staylorx/genhtml`); the actual
  remote of this clone is `https://github.com/taybiz/genhtml` (HTTP 200). The
  same dead URL is used by the README version badge (line 3) and
  `memory-bank/projectBrief.md` ("Repository URL"). Decide the canonical home
  and correct all three — `dart pub publish --dry-run` does not catch this.
- [ ] **`memory-bank/projectBrief.md` is stale and contradicts the code.**
  It still claims version `1.0.0` with a "Version Sync Issue"
  (`bin/genhtml.dart` = `1.0.0-rc2` vs `pubspec.yaml` = `1.0.0`) that no longer
  exists (both are `1.0.1`), claims "78 tests passing, 1 skipped" (observed:
  77 passed + 2 skipped on a green run, failures on a red one), points at the
  dead `staylorx/genhtml-dart` URL, and names the build directory
  `c:/awork/dart/genhtml`. Either refresh it or retire it.
- [ ] **Undocumented public members.** `public_member_api_docs` is off, so
  nothing enforces the bible's "terse `///` on every declaration and public
  member" rule, and three public members carry no doc comment:
  `SourceFileBuilder.path` (`lib/src/parsers/lcov_parser.dart:213`),
  `SourceFileBuilder.build()` (line 284), `LcovParseException.message`
  (line 367). (`toString()` overrides are exempt as overrides.) Document them
  when the lint is switched on.
- [ ] **Stale dependency set (informational).** `dart pub get` reports 23
  packages with newer versions incompatible with current constraints
  (`analyzer`, `test`, `coverage`, `vm_service`, ...). No action required now;
  revisit when bumping the SDK constraint (see Deviation SDK item).

Build result observed on 2026-09-24 (for the record): `dart pub get` OK
("Got dependencies!"); `dart analyze --fatal-infos --fatal-warnings` ->
"No issues found!" (exit 0); `dart compile exe bin/genhtml.dart -o
genhtml-audit.exe` OK, and the binary prints `genhtml version: 1.0.1`, prints
usage on `--help`, and generates `index.html` + `lib_calculator.dart.html` from
`test/fixtures/simple_coverage.info`; `dart pub publish --dry-run` -> exit 0,
"Package has 0 warnings." (53 KB archive). Only `dart test` (whole package) is
reliably unreliable.

## Deviations

- [ ] **Deviation: SDK constraint is `^3.9.2`, bible pins `>=3.10.0 <4.0.0`.**
  `pubspec.yaml` declares `environment: sdk: ^3.9.2`; the bible's Toolchain
  section (§2, "Dart SDK | `sdk: '>=3.10.0 <4.0.0'` — floor 3.10, never 4.x")
  requires `>=3.10.0 <4.0.0` in every pubspec. CI pins `sdk: '3.9.2'` in
  `.github/workflows/build.yml`, so both would have to move together.
- [ ] **Deviation: no workspace, no layer packages, no repository seam (§3/§9).**
  The bible's Topology section (§3) sanctions exactly two layouts, both a pub
  workspace with `*_domain` / `*_usecases` / `*_datasource_*` (>=2 adapters) /
  delivery packages, and Bootstrap (§9 step 3) says to create those packages.
  `genhtml` is a single flat package
  (`bin/` + `lib/src/{models,parsers,generators,utils}`) with no domain, no use
  cases, no repository contract and no adapters — so the at-least-two-repository
  -adapter rule and its shared contract suite have no seam to attach to.
  (Counter-argument: §3 says Topology A is "best when there is a single
  delivery mechanism (CLI only)", and a four-file parser/generator CLI may be
  below the size where the onion pays for itself. Flagged, not fixed.)
- [ ] **Deviation: fails by throwing, not by returning a value.**
  `lib/` raises exceptions across the core: `throw LcovParseException(...)`
  and `throw ArgumentError(...)` throughout `lib/src/parsers/lcov_parser.dart`,
  `lib/src/models/*.dart`, plus `try`/`catch` inside `lcov_parser.dart:46-206`,
  `coverage_data.dart:54-56`, `source_file.dart:89-100`. The bible (§1 "Four
  Laws" #4, §4) requires exceptions ONLY at the UI ring and failure-as-a-value
  everywhere else (`Either`/`TaskEither`, sealed failure hierarchies), with
  `tryCatch` confined to third-party adapter boundaries. `fpdart` is not a
  dependency at all. (Reviewer's call: for a single-binary CLI the "UI ring"
  may reasonably be the entry point — but the bible's default is unambiguous.)
- [ ] **Deviation: no `equatable` on entities; equality is hand-rolled.**
  Every model implements `operator ==` / `hashCode` by hand
  (`branch_coverage.dart`, `coverage_data.dart`, `coverage_summary.dart`,
  `function_coverage.dart`, `line_coverage.dart`) instead of extending
  `Equatable` with a `props` list as the bible requires (§1 Law 2, §4) for
  immutable entities and value objects.
- [ ] **Deviation: analysis gate is weaker than the bible's.**
  `analysis_options.yaml` only does `include: package:lints/recommended.yaml`.
  The bible requires `public_member_api_docs` ON, `todo:error`, and a CI gate of
  `dart analyze --fatal-infos --fatal-warnings` (§2; CLEAN = ZERO diagnostics
  of ANY severity). CI (`.github/workflows/build.yml`) runs a plain
  `dart analyze`. (Local `dart analyze --fatal-infos --fatal-warnings` is
  currently clean, so turning the gate on is low-risk — but the missing lints
  are still off.)
- [ ] **Deviation: multiple classes per file.**
  The bible is one class per file (§3 Package rules). Violations:
  `lib/src/generators/html_generator.dart` (`HtmlGenerator` + `HtmlGeneratorOptions`),
  `lib/src/parsers/lcov_parser.dart` (`LcovParser` + `SourceFileBuilder` + `LcovParseException`),
  `lib/src/utils/coverage_calculator.dart` (`CoverageCalculator` + `CoverageStatistics`),
  `lib/src/utils/validation.dart` (`Validation` + `ValidationResult`).
- [ ] **Deviation: tests use `package:test` + `expect`; bible mandates shouldly
  and Given/When/Then.** No `shouldly` or `mocktail` anywhere in `pubspec.yaml`
  or `test/`. §6 requires `x.should.be(...)` (never `expect()`), Given/When/Then
  test names, and mocktail at usecase seams.
- [ ] **Deviation: no architecture/boundary test.**
  There is no `dart_arch_test` (or equivalent resolved-import-graph) test
  asserting inward dependencies / cycle-free. The bible lists this as a CI hard
  gate (§2, §9 step 7). (Single-package CLI, so the onion is thin — still absent.)
- [ ] **Deviation: error style is not declared loudly.**
  The bible requires every package to state whether consumers get FP-style
  tuples or plain exceptions — in the barrel doc comment, the README, and
  `AGENTS.md` on deviation (§4, §11). `lib/genhtml.dart` has a one-line barrel
  doc comment but no error-style declaration; there is no `AGENTS.md`. Silence
  is itself the violation.
- [ ] **Deviation: dev-dependency stack does not match the bible.**
  Missing `shouldly`, `mocktail`, and `dart_arch_test`; `fpdart` and `equatable`
  (core-stack) are absent. `pubspec.yaml` dev deps are `lints`, `test`, `io`,
  `coverage`. (See the related build-problem item about the unused `io`.)
- [ ] **Deviation: the CLI is built on `ArgParser`, not `CommandRunner`.**
  §3 ("CLI (`thing_cli`): `CommandRunner` + composition root in `bin/`") is the
  bible's CLI convention; `bin/genhtml.dart` parses with `ArgParser` directly.
  (Counter-argument: genhtml has to clone the Linux `genhtml` flag surface as a
  single flat command, so `CommandRunner` subcommands buy nothing here.)
- [ ] **Deviation: code lives in prose docs.**
  `CONTRIBUTING.md` ("Example Code Style") contains a full Dart code sample,
  implementation body included. §2 "Code placement" forbids it — example code
  lives in tests first, `examples/` only for packages, "never READMEs/prose";
  §10 repeats it in the review checklist.
- [ ] **Deviation: D.R.Y. — project docs restate rules instead of linking doctrine.**
  `CONTRIBUTING.md` carries its own "Code Style" / "Code Quality" / "Key
  Principles" rules ("Run `dart analyze` to check for issues", "Add dartdoc
  comments for public APIs", ...) and `README.md` describes the architecture in
  prose. The bible (§1, §10) requires project docs to *reference* doctrine,
  never restate it — a second copy is a second truth. No document in this repo
  links to the bible at all.
- [ ] **Deviation (flagged question): license is Apache-2.0, the compact bible
  blob records MIT.** `LICENSE` is Apache License 2.0 (the README badge agrees)
  while `docs/00-compact.md`'s DECISIONS list reads "License: MIT". That line
  is arguably about the bible repo itself, and the human change record
  (`docs/11-decisions.md`) contains no license decision — so the compact blob
  may be over-reaching. Flagged for review: either doctrine should say the
  license is per-project, or the blob should be corrected. Do not relicense on
  the strength of this item alone.

## Bible section coverage (last audit, 2026-09-24)

Compared against `docs/01`-`docs/12` of staylorx/dart-flutter-bible
(`00-compact` read as the derived index, not as authority):
`01-architecture`, `02-toolchain`, `03-topology`, `04-functional-core`,
`06-testing`, `09-bootstrap-checklist`, `10-review-checklist`, `11-decisions`.

- `05-persistence` — N/A: the tool persists nothing (reads an LCOV file, writes
  HTML); no drift/sembast/UnitOfWork surface, so no divergence to record.
- `07-builders` — N/A: no codegen, no `build_runner`, no builders (the banned
  list is respected).
- `08-flutter-ring` — N/A: pure Dart CLI, zero Flutter/Riverpod.
- `12-sources` — bibliography; nothing to conform to.

## Project hygiene (not a bible rule)

- [ ] **No `.gitattributes`.** Nothing pins line endings. Add
  `* text=auto eol=lf` if the repo is to stay LF-only across Windows/macOS/Linux
  checkouts (verified 2026-09-24: every tracked file is `i/lf w/lf` per
  `git ls-files --eol`, so adding the rule would be a no-op today).
