import 'dart:io';

/// Utility class for input validation and error checking.
class Validation {
  /// Validates that a file exists and is readable
  static Future<ValidationResult> validateInputFile(String filePath) async {
    if (filePath.isEmpty) {
      return ValidationResult.error('File path cannot be empty');
    }

    final file = File(filePath);

    if (!await file.exists()) {
      return ValidationResult.error('File does not exist: $filePath');
    }

    try {
      await file.readAsString();
      return ValidationResult.success();
    } catch (e) {
      return ValidationResult.error('Cannot read file: $filePath - $e');
    }
  }

  /// Validates that a directory exists and is writable
  static Future<ValidationResult> validateOutputDirectory(
    String dirPath,
  ) async {
    if (dirPath.isEmpty) {
      return ValidationResult.error('Directory path cannot be empty');
    }

    final dir = Directory(dirPath);

    // If directory doesn't exist, try to create it
    if (!await dir.exists()) {
      try {
        await dir.create(recursive: true);
      } catch (e) {
        return ValidationResult.error(
          'Cannot create output directory: $dirPath - $e',
        );
      }
    }

    // Test if we can write to the directory
    try {
      final testFile = File('${dir.path}/.genhtml_test');
      await testFile.writeAsString('test');
      await testFile.delete();
      return ValidationResult.success();
    } catch (e) {
      return ValidationResult.error(
        'Cannot write to output directory: $dirPath - $e',
      );
    }
  }

  /// Validates LCOV file format
  static ValidationResult validateLcovFormat(String content) {
    if (content.isEmpty) {
      return ValidationResult.error('LCOV content is empty');
    }

    final lines = content.split('\n');
    bool hasSourceFile = false;
    bool hasEndRecord = false;

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      if (trimmedLine.startsWith('SF:')) {
        hasSourceFile = true;
      } else if (trimmedLine == 'end_of_record') {
        hasEndRecord = true;
      } else if (trimmedLine.startsWith('TN:')) {
        // Test name - valid but optional
      } else if (trimmedLine.startsWith('FN:') ||
          trimmedLine.startsWith('FNDA:') ||
          trimmedLine.startsWith('FNF:') ||
          trimmedLine.startsWith('FNH:') ||
          trimmedLine.startsWith('DA:') ||
          trimmedLine.startsWith('LF:') ||
          trimmedLine.startsWith('LH:') ||
          trimmedLine.startsWith('BRDA:') ||
          trimmedLine.startsWith('BRF:') ||
          trimmedLine.startsWith('BRH:')) {
        // Valid LCOV record types
      } else {
        return ValidationResult.warning(
          'Unknown LCOV record type: $trimmedLine',
        );
      }
    }

    if (!hasSourceFile) {
      return ValidationResult.error(
        'LCOV file must contain at least one SF: record',
      );
    }

    if (!hasEndRecord) {
      return ValidationResult.error('LCOV file must end with end_of_record');
    }

    return ValidationResult.success();
  }

  /// Validates coverage threshold values
  static ValidationResult validateCoverageThreshold(double threshold) {
    if (threshold < 0.0 || threshold > 100.0) {
      return ValidationResult.error(
        'Coverage threshold must be between 0.0 and 100.0',
      );
    }
    return ValidationResult.success();
  }

  /// Validates that a string is a valid file path
  static ValidationResult validateFilePath(String path) {
    if (path.isEmpty) {
      return ValidationResult.error('File path cannot be empty');
    }

    // Check for invalid characters (basic validation)
    final invalidChars = ['<', '>', ':', '"', '|', '?', '*'];
    for (final char in invalidChars) {
      if (path.contains(char)) {
        return ValidationResult.error(
          'File path contains invalid character: $char',
        );
      }
    }

    return ValidationResult.success();
  }

  /// Validates that a string is a valid HTML title
  static ValidationResult validateHtmlTitle(String title) {
    if (title.isEmpty) {
      return ValidationResult.warning('HTML title is empty');
    }

    if (title.length > 200) {
      return ValidationResult.warning(
        'HTML title is very long (${title.length} characters)',
      );
    }

    // Check for HTML-unsafe characters
    if (title.contains('<') || title.contains('>')) {
      return ValidationResult.error('HTML title contains unsafe characters');
    }

    return ValidationResult.success();
  }

  /// Validates command line arguments
  static ValidationResult validateCommandLineArgs(List<String> args) {
    if (args.isEmpty) {
      return ValidationResult.error('No input file specified');
    }

    // Basic validation - more specific validation should be done by argument parser
    for (final arg in args) {
      if (arg.trim().isEmpty) {
        return ValidationResult.warning('Empty argument found');
      }
    }

    return ValidationResult.success();
  }
}

/// Represents the result of a validation operation.
class ValidationResult {
  /// Whether the validation was successful
  final bool isValid;

  /// The validation message (error or warning description)
  final String? message;

  /// The severity level of the result
  final ValidationSeverity severity;

  const ValidationResult._({
    required this.isValid,
    this.message,
    required this.severity,
  });

  /// Creates a successful validation result
  factory ValidationResult.success([String? message]) {
    return ValidationResult._(
      isValid: true,
      message: message,
      severity: ValidationSeverity.success,
    );
  }

  /// Creates an error validation result
  factory ValidationResult.error(String message) {
    return ValidationResult._(
      isValid: false,
      message: message,
      severity: ValidationSeverity.error,
    );
  }

  /// Creates a warning validation result (valid but with concerns)
  factory ValidationResult.warning(String message) {
    return ValidationResult._(
      isValid: true,
      message: message,
      severity: ValidationSeverity.warning,
    );
  }

  /// Whether this result represents an error
  bool get isError => severity == ValidationSeverity.error;

  /// Whether this result represents a warning
  bool get isWarning => severity == ValidationSeverity.warning;

  /// Whether this result represents success
  bool get isSuccess => severity == ValidationSeverity.success;

  @override
  String toString() {
    final severityStr = severity.toString().split('.').last.toUpperCase();
    return message != null ? '$severityStr: $message' : severityStr;
  }
}

/// Severity levels for validation results.
enum ValidationSeverity { success, warning, error }
