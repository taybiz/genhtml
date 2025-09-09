import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

/// Utility functions for version management.
class VersionUtils {
  /// Gets the version from pubspec.yaml file.
  ///
  /// This function reads the pubspec.yaml file from the project root and
  /// extracts the version field. It handles various error conditions gracefully.
  ///
  /// Returns the version string as found in pubspec.yaml (e.g., "1.0.0").
  ///
  /// Throws [VersionException] if:
  /// - The pubspec.yaml file cannot be found
  /// - The YAML content is malformed
  /// - The version field is missing or invalid
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final version = await VersionUtils.getVersionFromPubspec();
  ///   print('Current version: $version');
  /// } catch (e) {
  ///   print('Error getting version: $e');
  /// }
  /// ```
  static Future<String> getVersionFromPubspec() async {
    try {
      // Find the project root by looking for pubspec.yaml
      final pubspecPath = await _findPubspecPath();

      // Read the pubspec.yaml file
      final pubspecFile = File(pubspecPath);
      if (!await pubspecFile.exists()) {
        throw VersionException('pubspec.yaml file not found at: $pubspecPath');
      }

      final content = await pubspecFile.readAsString();

      // Parse the YAML content
      final YamlMap yamlMap;
      try {
        yamlMap = loadYaml(content) as YamlMap;
      } catch (e) {
        throw VersionException(
          'Failed to parse pubspec.yaml: Invalid YAML format - $e',
        );
      }

      // Extract the version field
      final version = yamlMap['version'];
      if (version == null) {
        throw VersionException('Version field not found in pubspec.yaml');
      }

      if (version is! String) {
        throw VersionException(
          'Version field must be a string, found: ${version.runtimeType}',
        );
      }

      if (version.trim().isEmpty) {
        throw VersionException('Version field cannot be empty');
      }

      return version.trim();
    } catch (e) {
      if (e is VersionException) {
        rethrow;
      }
      throw VersionException('Unexpected error reading version: $e');
    }
  }

  /// Finds the path to pubspec.yaml by searching up the directory tree.
  ///
  /// This function starts from the current working directory and searches
  /// upward until it finds a pubspec.yaml file or reaches the root directory.
  ///
  /// Returns the full path to the pubspec.yaml file.
  ///
  /// Throws [VersionException] if pubspec.yaml cannot be found.
  static Future<String> _findPubspecPath() async {
    var currentDir = Directory.current;

    while (true) {
      final pubspecPath = path.join(currentDir.path, 'pubspec.yaml');
      final pubspecFile = File(pubspecPath);

      if (await pubspecFile.exists()) {
        return pubspecPath;
      }

      // Check if we've reached the root directory
      final parentDir = currentDir.parent;
      if (parentDir.path == currentDir.path) {
        // We've reached the root directory
        break;
      }

      currentDir = parentDir;
    }

    throw VersionException(
      'pubspec.yaml not found in current directory or any parent directory',
    );
  }
}

/// Exception thrown when version-related operations fail.
class VersionException implements Exception {
  /// The error message describing what went wrong.
  final String message;

  /// Creates a new [VersionException] with the given [message].
  const VersionException(this.message);

  @override
  String toString() => 'VersionException: $message';
}
