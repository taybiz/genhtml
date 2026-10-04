# genhtml for Windows - Project Memory Bank

## Project Overview

**genhtml for Windows** is a native Windows implementation of the Linux `genhtml` tool for generating HTML coverage reports from LCOV trace files. It is a drop-in replacement for the standard genhtml command, designed for Windows developers who need coverage report generation without Linux compatibility layers like WSL or Cygwin.

## Current Status (v1.0.1)

- **Version**: 1.0.1 (`pubspec.yaml` and `bin/genhtml.dart` agree)
- **Status**: Production ready
- **Platform**: Windows 10+ (x64 architecture)
- **License**: Apache 2.0
- **Repository**: https://github.com/taybiz/genhtml
- **Test Status**: `dart test` green (77 passed, 2 skipped, 0 failed); the
  historical whole-package flake is fixed — see BACKLOG.md / CHANGELOG.md.

## Architecture

The package is functional-core, laid out as:

```
genhtml/
├── bin/genhtml.dart                 # CLI entry point (the one throw surface)
├── lib/
│   ├── genhtml.dart                 # Barrel + error-style declaration
│   └── src/
│       ├── domain/
│       │   ├── entities/            # Immutable entities & value objects (Equatable)
│       │   ├── failures.dart        # Sealed GenhtmlFailure hierarchy
│       │   ├── validation.dart      # Pure validation (Either)
│       │   └── usecases/            # ParseLcovUseCase, GenerateHtmlReportUseCase
│       ├── datasources/             # File I/O adapters (TaskEither + tryCatch)
│       ├── generators/              # CSS
│       └── utils/                   # Coverage arithmetic, file helpers
└── test/                            # unit/, integration/, fixtures/
```

### Error style

Consumers receive failures as values, never exceptions: fallible operations
return `Either<GenhtmlFailure, T>` or `TaskEither<GenhtmlFailure, T>`, failures
are the sealed `GenhtmlFailure` hierarchy (`ParseFailure`, `ValidationFailure`,
`IoFailure`), and `try`/`catch` is confined to the datasource adapters. The CLI
entry point is the only throw surface.

### Core components

- **ParseLcovUseCase** — pure `String → Either<GenhtmlFailure, CoverageData>`.
- **GenerateHtmlReportUseCase** — pure renderer producing the report pages.
- **LcovFileDatasource / HtmlReportDatasource** — the `dart:io` adapters.
- **Validation** — pure `Either`-returning input checks.
- **CoverageCalculator** — coverage arithmetic and formatting.

## Dependencies & Tools

### Runtime dependencies
- **args** ^2.7.0 — command-line argument parsing
- **path** ^1.8.0 — cross-platform path manipulation
- **yaml** ^3.1.0 — configuration file support
- **fpdart** ^1.1.0 — `Either` / `TaskEither` / `Option`
- **equatable** ^2.0.7 — structural equality via `props`

### Development dependencies
- **lints** ^6.0.0, **test** ^1.25.6, **coverage** ^1.6.0

### Build tools
- **Dart SDK**: floor 3.10, CI pins 3.13.4 (`environment.sdk: '>=3.10.0 <4.0.0'`)
- `dart analyze --fatal-infos --fatal-warnings`, `dart format`, `dart test`,
  `dart compile exe`.

## Quality gates

- `dart analyze --fatal-infos --fatal-warnings` → zero diagnostics
  (`public_member_api_docs` on; `todo` is an error).
- `dart format --output=none --set-exit-if-changed .`
- `dart test`

## Command-Line Interface

```bash
genhtml.exe coverage.info
genhtml.exe coverage.info -o html_report --title "My Project" --line-threshold 80
```

Supported options: `--help/-h`, `--version`, `--verbose/-v`, `--quiet/-q`,
`--output-directory/-o`, `--title/-t`, `--show-branches`, `--show-functions`,
`--line-threshold`, `--function-threshold`, `--branch-threshold`, `--no-sort`.

## Development Workflow

```bash
dart pub get
dart analyze --fatal-infos --fatal-warnings
dart format --output=none --set-exit-if-changed .
dart test
dart compile exe bin/genhtml.dart -o genhtml.exe
```

## Notes

- Doctrine (architecture, toolchain, testing style, review checklist) lives in
  the [Dart/Flutter Bible](https://github.com/taybiz/dart-flutter-bible) and is
  linked from `CONTRIBUTING.md` — it is deliberately not restated here.
- Open work and unresolved divergences are tracked in `BACKLOG.md`; resolved
  ones are recorded as decisions in `CHANGELOG.md`.
