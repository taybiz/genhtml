import 'dart:io';
import 'package:path/path.dart' as path;

/// Utility class for file system operations and path handling.
class FileUtils {
  /// Reads the contents of a file as a string
  static Future<String> readFileAsString(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('File not found', filePath);
    }
    return await file.readAsString();
  }

  /// Writes content to a file, creating directories if necessary
  static Future<void> writeStringToFile(String filePath, String content) async {
    final file = File(filePath);
    final directory = file.parent;

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    await file.writeAsString(content);
  }

  /// Ensures a directory exists, creating it if necessary
  static Future<void> ensureDirectoryExists(String dirPath) async {
    final directory = Directory(dirPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  /// Copies a file from source to destination
  static Future<void> copyFile(
    String sourcePath,
    String destinationPath,
  ) async {
    final sourceFile = File(sourcePath);
    final destinationFile = File(destinationPath);

    if (!await sourceFile.exists()) {
      throw FileSystemException('Source file not found', sourcePath);
    }

    // Ensure destination directory exists
    await ensureDirectoryExists(destinationFile.parent.path);

    await sourceFile.copy(destinationPath);
  }

  /// Deletes a file if it exists
  static Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Deletes a directory and all its contents
  static Future<void> deleteDirectory(String dirPath) async {
    final directory = Directory(dirPath);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  /// Gets the file extension from a file path
  static String getFileExtension(String filePath) {
    return path.extension(filePath);
  }

  /// Gets the filename without extension from a file path
  static String getFileNameWithoutExtension(String filePath) {
    return path.basenameWithoutExtension(filePath);
  }

  /// Gets the filename with extension from a file path
  static String getFileName(String filePath) {
    return path.basename(filePath);
  }

  /// Gets the directory path from a file path
  static String getDirectoryPath(String filePath) {
    return path.dirname(filePath);
  }

  /// Joins path components into a single path
  static String joinPaths(List<String> pathComponents) {
    return path.joinAll(pathComponents);
  }

  /// Normalizes a file path (resolves . and .. components)
  static String normalizePath(String filePath) {
    return path.normalize(filePath);
  }

  /// Converts a file path to use forward slashes (for HTML links)
  static String toForwardSlashes(String filePath) {
    return filePath.replaceAll('\\', '/');
  }

  /// Converts a file path to use the platform's path separator
  static String toPlatformPath(String filePath) {
    return filePath
        .replaceAll('/', path.separator)
        .replaceAll('\\', path.separator);
  }

  /// Checks if a file path is absolute
  static bool isAbsolutePath(String filePath) {
    return path.isAbsolute(filePath);
  }

  /// Converts a relative path to an absolute path
  static String toAbsolutePath(String filePath, [String? basePath]) {
    if (isAbsolutePath(filePath)) {
      return filePath;
    }

    basePath ??= Directory.current.path;
    return path.join(basePath, filePath);
  }

  /// Gets a relative path from one path to another
  static String getRelativePath(String from, String to) {
    return path.relative(to, from: from);
  }

  /// Sanitizes a filename by removing or replacing invalid characters
  static String sanitizeFileName(String fileName) {
    // Replace invalid characters with underscores
    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    return fileName.replaceAll(invalidChars, '_');
  }

  /// Creates a backup of a file by copying it with a .bak extension
  static Future<void> createBackup(String filePath) async {
    final backupPath = '$filePath.bak';
    await copyFile(filePath, backupPath);
  }

  /// Lists all files in a directory with optional filtering
  static Future<List<String>> listFiles(
    String dirPath, {
    bool recursive = false,
    String? pattern,
  }) async {
    final directory = Directory(dirPath);
    if (!await directory.exists()) {
      return [];
    }

    final files = <String>[];
    final entities = recursive
        ? directory.list(recursive: true)
        : directory.list();

    await for (final entity in entities) {
      if (entity is File) {
        final filePath = entity.path;
        if (pattern == null || RegExp(pattern).hasMatch(filePath)) {
          files.add(filePath);
        }
      }
    }

    return files;
  }

  /// Gets the size of a file in bytes
  static Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('File not found', filePath);
    }
    return await file.length();
  }

  /// Gets the last modified time of a file
  static Future<DateTime> getLastModified(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('File not found', filePath);
    }
    return await file.lastModified();
  }

  /// Checks if a file exists
  static Future<bool> fileExists(String filePath) async {
    return await File(filePath).exists();
  }

  /// Checks if a directory exists
  static Future<bool> directoryExists(String dirPath) async {
    return await Directory(dirPath).exists();
  }

  /// Creates a temporary file with optional content
  static Future<File> createTempFile({String? content, String? suffix}) async {
    final tempDir = Directory.systemTemp;
    final tempFile = await tempDir.createTemp('genhtml_').then((dir) {
      final fileName = 'temp${suffix ?? '.tmp'}';
      return File(path.join(dir.path, fileName));
    });

    if (content != null) {
      await tempFile.writeAsString(content);
    }

    return tempFile;
  }

  /// Creates a temporary directory
  static Future<Directory> createTempDirectory({String? prefix}) async {
    return await Directory.systemTemp.createTemp(prefix ?? 'genhtml_');
  }

  /// Resolves a path relative to the current working directory
  static String resolveFromCwd(String filePath) {
    if (isAbsolutePath(filePath)) {
      return filePath;
    }
    return path.join(Directory.current.path, filePath);
  }

  /// Gets the current working directory
  static String getCurrentDirectory() {
    return Directory.current.path;
  }

  /// Changes the current working directory
  static void setCurrentDirectory(String dirPath) {
    Directory.current = dirPath;
  }

  /// Formats file size in human-readable format
  static String formatFileSize(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double size = bytes.toDouble();
    int unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }
}
