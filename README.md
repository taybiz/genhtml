# genhtml for Windows

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/staylorx/genhtml-dart)
[![License](https://img.shields.io/badge/license-Apache%202.0-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows-lightgrey.svg)](https://www.microsoft.com/windows)

A **Windows-native implementation** of the Linux `genhtml` tool for generating HTML coverage reports from LCOV trace files. This tool provides a **drop-in replacement** for the standard genhtml command, specifically designed for Windows developers who need coverage report generation without Linux compatibility layers.

## 🎯 **Why genhtml for Windows?**

When working with code coverage on Windows, AI assistants and development tools often suggest using `genhtml` - but this tool isn't natively available on Windows without jumping through hoops like WSL or Cygwin. This project solves that problem by providing a **native Windows executable** that's fully compatible with the Linux genhtml interface.

## ✨ **Features**

- 🪟 **Native Windows Support** - No WSL, Cygwin, or Linux compatibility layers required
- 🔄 **Drop-in Replacement** - Compatible command-line interface with Linux genhtml
- 📊 **Complete LCOV Support** - Handles all standard LCOV trace file formats
- 🎨 **Professional HTML Reports** - Clean, modern, and accessible coverage reports
- 📈 **Coverage Metrics** - Line, function, and branch coverage with configurable thresholds
- ⚡ **Standalone Executable** - Single `.exe` file for easy distribution
- 🧪 **Thoroughly Tested** - Comprehensive test suite with 63+ passing tests
- 🎛️ **Flexible Configuration** - Extensive command-line options for customization

## 🚀 **Quick Start**

### Option 1: Download Pre-compiled Executable

1. Download `genhtml.exe` from the [releases page](https://github.com/staylorx/genhtml-dart/releases)
2. Place it in your PATH or project directory
3. Run: `genhtml.exe coverage.info`

### Option 2: Compile from Source

```bash
# Clone the repository
git clone https://github.com/staylorx/genhtml-dart.git
cd genhtml-dart

# Install dependencies
dart pub get

# Compile to standalone executable
dart compile exe bin/genhtml.dart -o genhtml.exe

# Use the executable
.\genhtml.exe coverage.info
```

## 📖 **Usage**

### Basic Usage

```bash
# Generate HTML report from LCOV file
genhtml.exe coverage.info

# Specify output directory and title
genhtml.exe coverage.info -o html_report --title "My Project Coverage"

# Set coverage thresholds
genhtml.exe coverage.info --line-threshold 80 --function-threshold 90
```

### Command-Line Options

| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--help` | `-h` | Show help information | |
| `--version` | | Show version information | |
| `--verbose` | `-v` | Show detailed output | |
| `--quiet` | `-q` | Suppress all output except errors | |
| `--output-directory` | `-o` | Output directory for HTML files | `coverage_html` |
| `--title` | `-t` | Title for the coverage report | `LCOV - Code Coverage Report` |
| `--show-branches` | | Show branch coverage information | `true` |
| `--show-functions` | | Show function coverage information | `true` |
| `--line-threshold` | | Line coverage threshold (0-100) | `0` |
| `--function-threshold` | | Function coverage threshold (0-100) | `0` |
| `--branch-threshold` | | Branch coverage threshold (0-100) | `0` |
| `--no-sort` | | Don't sort files by coverage percentage | |

## 💡 **Usage Examples**

### Basic Coverage Report

```bash
# Generate basic HTML coverage report
genhtml.exe coverage.info
```

This creates a `coverage_html/` directory with:
- `index.html` - Main coverage summary
- Individual source file HTML pages with line-by-line coverage

### Custom Output Directory

```bash
# Generate report in custom directory
genhtml.exe coverage.info -o my_coverage_report --title "Project Alpha Coverage"
```

### Coverage Thresholds

```bash
# Fail build if coverage is below thresholds
genhtml.exe coverage.info --line-threshold 85 --function-threshold 90
# Exit code 1 if thresholds not met, 0 if passed
```

### CI/CD Integration

```bash
# Generate report with minimal output for CI
genhtml.exe coverage.info --quiet -o coverage_html
if %ERRORLEVEL% NEQ 0 (
    echo Coverage thresholds not met
    exit /b 1
)
```

### Dart/Flutter Projects

```bash
# Generate coverage for Dart project
dart test --coverage=coverage
dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --packages=.dart_tool/package_config.json --report-on=lib
genhtml.exe coverage/lcov.info -o coverage/html --title "My Dart Project"
```

## 🏗️ **Project Architecture**

### Core Components

```
genhtml/
├── bin/genhtml.dart           # CLI entry point and argument parsing
├── lib/
│   ├── genhtml.dart          # Main library exports
│   └── src/
│       ├── models/           # Data structures for coverage data
│       │   ├── coverage_data.dart
│       │   ├── source_file.dart
│       │   ├── line_coverage.dart
│       │   ├── function_coverage.dart
│       │   └── branch_coverage.dart
│       ├── parsers/          # LCOV file parsing
│       │   └── lcov_parser.dart
│       ├── generators/       # HTML report generation
│       │   ├── html_generator.dart
│       │   └── css_generator.dart
│       └── utils/            # Utilities and validation
│           ├── coverage_calculator.dart
│           ├── file_utils.dart
│           └── validation.dart
└── test/                     # Comprehensive test suite
    ├── unit/                 # Unit tests
    ├── integration/          # Integration tests
    └── fixtures/             # Test data files
```

### Key Features

- **LCOV Parser**: Robust parsing of all LCOV record types (SF, FN, FNDA, DA, BRDA, etc.)
- **HTML Generator**: Professional HTML reports with CSS styling and navigation
- **Validation Framework**: Comprehensive input validation and error handling
- **Coverage Calculator**: Accurate percentage calculations and threshold checking
- **File Utilities**: Cross-platform file operations optimized for Windows

## 🧪 **Testing**

The project includes a comprehensive test suite with 63+ tests covering:

```bash
# Run all tests
dart test

# Run tests with coverage
dart test --coverage=coverage

# Run specific test categories
dart test test/unit/          # Unit tests only
dart test test/integration/   # Integration tests only

# Generate coverage report for the project itself
dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --packages=.dart_tool/package_config.json --report-on=lib
genhtml.exe coverage/lcov.info -o coverage/html
```

### Test Coverage

- **Unit Tests**: Individual component testing (parsers, generators, utilities)
- **Integration Tests**: End-to-end CLI workflow testing
- **Fixture Tests**: Real-world LCOV file scenarios
- **Edge Case Tests**: Error handling and boundary conditions

## 📊 **Performance & Requirements**

### System Requirements

- **Operating System**: Windows 10 or later
- **Architecture**: x64 (64-bit)
- **Memory**: Minimum 100MB RAM for typical projects
- **Disk Space**: ~15MB for executable + output space

### Performance Characteristics

- **Small Projects** (< 100 files): < 1 second
- **Medium Projects** (100-1000 files): 1-5 seconds  
- **Large Projects** (1000+ files): 5-30 seconds
- **Memory Usage**: ~50MB base + ~1MB per 100 source files

### Scalability

The tool efficiently handles:
- ✅ Projects with 10,000+ source files
- ✅ LCOV files up to 100MB+
- ✅ Complex branch coverage scenarios
- ✅ Unicode file paths and content

## 🔧 **Compilation & Distribution**

### Building from Source

```bash
# Install Dart SDK (https://dart.dev/get-dart)
# Clone and setup
git clone https://github.com/staylorx/genhtml-dart.git
cd genhtml-dart
dart pub get

# Run tests to verify
dart test

# Compile to executable
dart compile exe bin/genhtml.dart -o genhtml.exe
```

### Distribution Options

1. **Standalone Executable**: Single `genhtml.exe` file (~15MB)
2. **Dart Package**: Install via `dart pub global activate`
3. **Source Distribution**: Clone and compile locally

### Adding to PATH

```batch
# Add to system PATH (Windows)
setx PATH "%PATH%;C:\path\to\genhtml"

# Or add to project directory and use relative path
.\genhtml.exe coverage.info
```

## 🐛 **Troubleshooting**

### Common Issues

**Issue**: `genhtml.exe` not recognized as command
```bash
# Solution: Add to PATH or use full path
C:\path\to\genhtml.exe coverage.info
```

**Issue**: Permission denied when writing output
```bash
# Solution: Run as administrator or check directory permissions
# Ensure output directory is writable
```

**Issue**: LCOV file not found
```bash
# Solution: Check file path and ensure file exists
dir coverage.info  # Verify file exists
genhtml.exe .\coverage\lcov.info  # Use relative path
```

**Issue**: Invalid LCOV format error
```bash
# Solution: Verify LCOV file format
# Ensure file contains SF: records and ends with end_of_record
```

### Debug Mode

```bash
# Enable verbose output for debugging
genhtml.exe coverage.info --verbose

# Check version and help
genhtml.exe --version
genhtml.exe --help
```

### Getting Help

- 📖 Check this README for common solutions
- 🐛 [Open an issue](https://github.com/staylorx/genhtml-dart/issues) for bugs
- 💡 [Request features](https://github.com/staylorx/genhtml-dart/issues) for enhancements
- 📧 Contact maintainers for support

## 🤝 **Contributing**

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

```bash
git clone https://github.com/staylorx/genhtml-dart.git
cd genhtml-dart
dart pub get
dart test  # Ensure all tests pass
```

### Code Style

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Run `dart format .` before committing
- Ensure `dart analyze` passes without warnings
- Add tests for new functionality

## 📄 **License**

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🙏 **Acknowledgments**

- Inspired by the original Linux `genhtml` tool from the LCOV project
- Built with the [Dart programming language](https://dart.dev/)
- Designed specifically for Windows developers who need native coverage tools

---

*No more "genhtml not found" errors in your Windows development workflow!*