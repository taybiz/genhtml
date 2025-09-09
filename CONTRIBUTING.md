# Contributing to genhtml for Windows

Thank you for your interest in contributing to genhtml for Windows! This document provides guidelines and information for contributors.

## 🎯 **Project Overview**

genhtml for Windows is a native Windows implementation of the Linux genhtml tool for generating HTML coverage reports from LCOV trace files. Our goal is to provide a drop-in replacement that works seamlessly on Windows without requiring WSL, Cygwin, or other compatibility layers.

## 🚀 **Getting Started**

### Prerequisites

- [Dart SDK](https://dart.dev/get-dart) 3.9.2 or later
- Windows 10 or later
- Git for version control

### Development Setup

1. **Fork and Clone**
   ```bash
   git clone https://github.com/your-username/genhtml-dart.git
   cd genhtml-dart
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

### Writing Tests

When adding new functionality:

1. **Add Unit Tests**: Test the component in isolation
2. **Add Integration Tests**: Test the complete workflow
3. **Add Test Fixtures**: Include realistic test data if needed
4. **Update Test Documentation**: Keep test README current

Example test structure:
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
      expect(actual, equals(expected));
    });
  });
}
```

## 📝 **Code Style**

### Dart Style Guidelines

We follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style):

- Use `dart format .` to format code
- Run `dart analyze` to check for issues
- Follow naming conventions (camelCase for variables, PascalCase for classes)
- Write clear, descriptive variable and function names

### Code Quality

- **Type Safety**: Use strong typing and null safety
- **Documentation**: Add dartdoc comments for public APIs
- **Error Handling**: Provide clear error messages and proper exception handling
- **Performance**: Consider performance implications, especially for large files

### Example Code Style

```dart
/// Parses LCOV content and returns coverage data.
/// 
/// Throws [LcovParseException] if the content is invalid.
static CoverageData parse(String lcovContent, {String? title}) {
  // Validate input
  if (lcovContent.isEmpty) {
    throw LcovParseException('LCOV content cannot be empty');
  }
  
  // Implementation...
  return CoverageData.fromSourceFiles(sourceFiles, title: title);
}
```

## 🏗️ **Architecture**

### Project Structure

```
genhtml/
├── bin/genhtml.dart           # CLI entry point
├── lib/
│   ├── genhtml.dart          # Main library exports
│   └── src/
│       ├── models/           # Data structures
│       ├── parsers/          # LCOV parsing
│       ├── generators/       # HTML generation
│       └── utils/            # Utilities
└── test/                     # Test suite
```

### Key Principles

- **Separation of Concerns**: Each component has a single responsibility
- **Testability**: All components should be easily testable
- **Windows Compatibility**: Ensure all code works on Windows
- **Performance**: Optimize for large projects and files
- **Error Handling**: Provide clear, actionable error messages

## 🐛 **Bug Reports**

### Before Reporting

1. Check existing [issues](https://github.com/staylorx/genhtml-dart/issues)
2. Verify the bug with the latest version
3. Test with minimal reproduction case

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
- genhtml version: 1.0.0
- Dart SDK: 3.9.2

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
5. **Run all tests** and ensure they pass
6. **Format code** with `dart format .`
7. **Analyze code** with `dart analyze`

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
- [ ] Code formatted with `dart format`
- [ ] No warnings from `dart analyze`
- [ ] Documentation updated
- [ ] CHANGELOG.md updated (if needed)
```

## 📚 **Documentation**

### Types of Documentation

- **README.md**: User-facing documentation
- **CHANGELOG.md**: Version history and changes
- **Code Comments**: Inline documentation for complex logic
- **API Documentation**: Dartdoc comments for public APIs

### Documentation Standards

- Use clear, concise language
- Provide examples where helpful
- Keep documentation up-to-date with code changes
- Use proper markdown formatting

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