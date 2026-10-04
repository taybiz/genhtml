# Backlog

Tracked issues, build problems, and standards divergences for `genhtml`.

Items under **Build problems** were observed during a real build/analyze/test
run on the Windows lane. Items under **Deviations** compare the code against
the Dart/Flutter Bible (<https://github.com/taybiz/dart-flutter-bible>,
`docs/01`-`docs/12`). A deviation is a place the code differs from the bible
where the bible might itself be wrong, so each one is flagged for later review
rather than "fixed" on sight.

**Resolved items are removed from this file and recorded as decisions in
`CHANGELOG.md`** (Keep a Changelog `[Unreleased]`). The 2026-10-04 pass cleared:
the whole-package `dart test` flake, the unused `io` dev dependency, `dart
format` drift, the missing `1.0.1` changelog entry, the dead `repository:` /
README links, the stale `memory-bank/projectBrief.md`, undocumented public
members, the error-style declaration, the SDK/CI pin pairing, the analysis
gate, `equatable`, the failure-as-a-value functional core, the proportional
clean-architecture breakout, the `CONTRIBUTING.md` rule/sample strip + D.R.Y.
doctrine links, and the missing `.gitattributes`.

Last full audit: 2026-10-04 (Dart 3.13.1, Windows x64).

## Build problems

- [ ] **Stale dependency set (informational).** `dart pub get` reports ~25
  packages with newer versions incompatible with current constraints
  (`analyzer`, `test`, `coverage`, `vm_service`, ...). No action required now;
  revisit when bumping the SDK constraint.

## Deviations

- [ ] **Deviation: multiple classes per file.** The bible is one class per file
  (§3 Package rules). Remaining multi-class files:
  `lib/src/utils/coverage_calculator.dart` (`CoverageCalculator` +
  `CoverageLevel` + `CoverageStatistics` + the `DoubleExtension` helper) and
  `lib/src/utils/file_utils.dart` is single-class but `lib/src/domain/
  validation.dart` mixes an `abstract final class Validation` with static
  helpers (single class, accepted). Split the `coverage_calculator` units if
  the file grows; today the grouping is cohesive and the CLI is small.
- [ ] **Deviation: tests use `package:test` + `expect`; bible mandates shouldly
  and Given/When/Then.** No `shouldly` or `mocktail` anywhere in `pubspec.yaml`
  or `test/`. §6 requires `x.should.be(...)` (never `expect()`),
  Given/When/Then test names, and mocktail at usecase seams. (Not in scope for
  the 2026-10-04 pass, which touched the functional core and gate only.)
- [ ] **Deviation: no architecture/boundary test.** There is no
  `dart_arch_test` (or equivalent resolved-import-graph) test asserting inward
  dependencies / cycle-free. The bible lists this as a CI hard gate (§2, §9
  step 7). The `domain/ datasources/` split now gives it a seam to attach to —
  worth adding next.
- [ ] **Deviation: dev-dependency stack does not match the bible.** Missing
  `shouldly`, `mocktail`, and `dart_arch_test`. (`fpdart` and `equatable` are
  now present; the unused `io` dep is gone.)
- [ ] **Deviation: the CLI is built on `ArgParser`, not `CommandRunner`.**
  §3 ("CLI (`thing_cli`): `CommandRunner` + composition root in `bin/`") is the
  bible's CLI convention; `bin/genhtml.dart` parses with `ArgParser` directly.
  (Counter-argument: genhtml has to clone the Linux `genhtml` flag surface as a
  single flat command, so `CommandRunner` subcommands buy nothing here.)
- [ ] **Deviation (flagged question): license is Apache-2.0, the compact bible
  blob records MIT.** `LICENSE` is Apache License 2.0 (the README badge agrees)
  while `docs/00-compact.md`'s DECISIONS list reads "License: MIT". That line
  is arguably about the bible repo itself, and the human change record
  (`docs/11-decisions.md`) contains no license decision — so the compact blob
  may be over-reaching. Flagged for review: either doctrine should say the
  license is per-project, or the blob should be corrected. **Do not relicense
  on the strength of this item alone.**

## Bible section coverage (last audit, 2026-10-04)

Compared against `docs/01`-`docs/12` of taybiz/dart-flutter-bible
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

- [x] **`.gitattributes` added** (`* text=auto eol=lf`; Windows scripts
  `eol=crlf`; binaries binary) and the index renormalized, so a checkout cannot
  drift line endings across Windows/macOS/Linux.
