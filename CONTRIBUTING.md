# Contributing to genhtml for Windows

Thank you for your interest in contributing to genhtml for Windows! This document covers how to set up, test and submit changes.

Everything else — architecture, toolchain, functional-core rules, testing style, the review checklist — is **doctrine**, and it lives in the Dart/Flutter Bible, not here. See [Doctrine](#-doctrine) below.

## 🎯 **Project Overview**

genhtml for Windows is a native Windows implementation of the Linux genhtml tool for generating HTML coverage reports from LCOV trace files. Our goal is to provide a drop-in replacement that works seamlessly on Windows without requiring WSL, Cygwin, or other compatibility layers.

## 🚀 **Getting Started**

### Prerequisites

- [Dart SDK](https://dart.dev/get-dart) — the version floor is the `environment.sdk` constraint in `pubspec.yaml` (`>=3.10.0 <4.0.0`), which the CI Dart pin follows.
- Windows 10 or later
- Git for version control

### Development Setup

1. **Fork and Clone**

   ```bash
   git clone https://github.com/taybiz/genhtml.git
   cd genhtml
   ```

2. **Install Dependencies**

   ```bash
   dart pub get
   ```

3. **Verify Setup**

   ```bash
   # Run tests to ensure everything works
   dart test

   # Run the tool to verify functionality
   dart bin/genhtml.dart --help
   ```

4. **Compile and Test Executable**

   ```bash
   dart compile exe bin/genhtml.dart -o genhtml.exe
   .\genhtml.exe --version
   ```

## 🧪 **Testing**

### Running Tests

```bash
# Run all tests
dart test

# Run with coverage
dart test --coverage=coverage

# Run specific test categories
dart test test/unit/          # Unit tests only
dart test test/integration/   # Integration tests only

# Generate coverage report
dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --packages=.dart_tool/package_config.json --report-on=lib
dart bin/genhtml.dart coverage/lcov.info -o coverage/html
```

### Test Structure

- **Unit Tests** (`test/unit/`): Test individual components in isolation
- **Integration Tests** (`test/integration/`): Test complete workflows
- **Test Fixtures** (`test/fixtures/`): Real-world LCOV test data
- **Test Utilities** (`test/test_utils.dart`): Helper functions for testing

Test *style* (Given/When/Then names, the assertion library, mocking at use-case seams) is doctrine — see the bible's §6 below. Read the existing tests and match them.

### Adding Functionality

When adding new functionality:

1. **Add Unit Tests**: Test the component in isolation
2. **Add Integration Tests**: Test the complete workflow
3. **Add Test Fixtures**: Include realistic test data if needed
4. **Update Test Documentation**: Keep the test README current

## 📚 **Doctrine**

This project follows the [Dart/Flutter Bible](https://github.com/taybiz/dart-flutter-bible). Rather than restating its rules here — a second copy is a second truth (D.R.Y.) — link to the section instead:

| Concern | Bible section |
| --- | --- |
| Architecture, the Four Laws, functional core | `docs/01-architecture`, `docs/04-functional-core` |
| Toolchain, SDK constraint, analysis gate | `docs/02-toolchain` |
| Package topology, one class per file, CLI entry | `docs/03-topology` |
| Testing style and seams | `docs/06-testing` |
| Review checklist | `docs/10-review-checklist` |

If a rule is missing from the bible, propose it there — do not fork it into this repository's docs.

This package's own error style (failures as values, not exceptions) is declared in the `lib/genhtml.dart` barrel doc comment and in the README's *Error style* section.

## 🐛 **Bug Reports**

### Before Reporting

1. Check existing [issues](https://github.com/taybiz/genhtml/issues)
2. Verify the bug with the latest version
3. Test with a minimal reproduction case

### Bug Report Template

```markdown
**Bug Description**
A clear description of the bug.

**Steps to Reproduce**
1. Run command: `genhtml.exe coverage.info`
2. Expected: HTML report generated
3. Actual: Error message displayed

**Environment**
- OS: Windows 11
- genhtml version: 1.0.1
- Dart SDK: 3.13.4

**Additional Context**
- LCOV file size: 2MB
- Number of source files: 150
- Error message: [paste full error]
```

## ✨ **Feature Requests**

### Before Requesting

1. Check if the feature exists in Linux genhtml
2. Consider if it fits the project scope
3. Look for existing feature requests

### Feature Request Template

```markdown
**Feature Description**
A clear description of the desired feature.

**Use Case**
Why is this feature needed? What problem does it solve?

**Proposed Solution**
How should this feature work?

**Alternatives Considered**
What other approaches were considered?

**Linux genhtml Compatibility**
Does Linux genhtml have this feature? How does it work there?
```

## 🔄 **Pull Requests**

### Before Submitting

1. **Fork** the repository
2. **Create a branch** for your changes
3. **Write tests** for new functionality
4. **Update documentation** as needed
5. **Run the gates** — all three must pass:
   - `dart analyze --fatal-infos --fatal-warnings` (zero diagnostics)
   - `dart format --output=none --set-exit-if-changed .`
   - `dart test`

### Pull Request Process

1. **Create Pull Request**
   - Use a descriptive title
   - Reference related issues
   - Provide clear description of changes

2. **Code Review**
   - Address reviewer feedback
   - Keep discussions constructive
   - Update code as requested

3. **Merge**
   - Squash commits if requested
   - Ensure CI passes
   - Maintainer will merge when ready

### Pull Request Template

```markdown
**Description**
Brief description of changes made.

**Related Issues**
Fixes #123, addresses #456

**Changes Made**
- Added new feature X
- Fixed bug in component Y
- Updated documentation

**Testing**
- [ ] All existing tests pass
- [ ] New tests added for new functionality
- [ ] Manual testing completed

**Checklist**
- [ ] `dart analyze --fatal-infos --fatal-warnings` is clean
- [ ] `dart format --output=none --set-exit-if-changed .` is clean
- [ ] `dart test` is green
- [ ] Documentation updated
- [ ] CHANGELOG.md updated (if needed)
```

## 📚 **Documentation**

### Types of Documentation

- **README.md**: User-facing documentation
- **CHANGELOG.md**: Version history and changes
- **Code Comments**: Inline documentation for complex logic

Documentation *standards* (dartdoc on every public member, code samples live in tests) are doctrine — see the bible.

## 🏷️ **Versioning**

We use [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.x.x): Breaking changes
- **MINOR** (x.1.x): New features, backward compatible
- **PATCH** (x.x.1): Bug fixes, backward compatible

## 📄 **License**

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.

## 🤝 **Code of Conduct**

### Our Standards

- **Be Respectful**: Treat all contributors with respect
- **Be Constructive**: Provide helpful feedback and suggestions
- **Be Collaborative**: Work together toward common goals
- **Be Patient**: Remember that everyone is learning

### Unacceptable Behavior

- Harassment or discrimination
- Trolling or insulting comments
- Personal attacks
- Publishing private information

## 🆘 **Getting Help**

- **Documentation**: Check README.md and code comments
- **Issues**: Search existing issues or create a new one
- **Discussions**: Use GitHub Discussions for questions
- **Email**: Contact maintainers for sensitive issues

## 🎉 **Recognition**

Contributors will be recognized in:
- CHANGELOG.md for significant contributions
- README.md contributors section
- Release notes for major features

Thank you for contributing to genhtml for Windows! 🚀
