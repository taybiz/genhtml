import 'dart:io';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;
import '../version_utils.dart';
import '../test_utils.dart';

void main() {
  group('VersionUtils Tests', () {
    late Directory tempDir;
    late String originalWorkingDir;

    setUp(() async {
      tempDir = await TestUtils.createTempDirectory('version_test_');
      originalWorkingDir = Directory.current.path;
    });

    tearDown(() async {
      // Restore original working directory
      Directory.current = originalWorkingDir;
      await TestUtils.cleanupTempDirectory(tempDir);
    });

    group('getVersionFromPubspec', () {
      test(
        'should successfully read version from valid pubspec.yaml',
        () async {
          // Create a valid pubspec.yaml in temp directory
          final pubspecContent = '''
name: test_package
description: A test package
version: 2.1.0
environment:
  sdk: ^3.0.0
''';
          final pubspecFile = File(path.join(tempDir.path, 'pubspec.yaml'));
          await pubspecFile.writeAsString(pubspecContent);

          // Change to temp directory
          Directory.current = tempDir.path;

          final version = await VersionUtils.getVersionFromPubspec();
          expect(version, equals('2.1.0'));
        },
      );

      test('should handle version with build metadata', () async {
        final pubspecContent = '''
name: test_package
version: 1.0.0+build.123
''';
        final pubspecFile = File(path.join(tempDir.path, 'pubspec.yaml'));
        await pubspecFile.writeAsString(pubspecContent);

        Directory.current = tempDir.path;

        final version = await VersionUtils.getVersionFromPubspec();
        expect(version, equals('1.0.0+build.123'));
      });

      test('should handle version with pre-release identifier', () async {
        final pubspecContent = '''
name: test_package
version: 1.0.0-rc1
''';
        final pubspecFile = File(path.join(tempDir.path, 'pubspec.yaml'));
        await pubspecFile.writeAsString(pubspecContent);

        Directory.current = tempDir.path;

        final version = await VersionUtils.getVersionFromPubspec();
        expect(version, equals('1.0.0-rc1'));
      });

      test('should trim whitespace from version', () async {
        final pubspecContent = '''
name: test_package
version:   1.0.0   
''';
        final pubspecFile = File(path.join(tempDir.path, 'pubspec.yaml'));
        await pubspecFile.writeAsString(pubspecContent);

        Directory.current = tempDir.path;

        final version = await VersionUtils.getVersionFromPubspec();
        expect(version, equals('1.0.0'));
      });

      test('should find pubspec.yaml in parent directory', () async {
        // Create pubspec.yaml in temp directory
        final pubspecContent = '''
name: test_package
version: 1.5.0
''';
        final pubspecFile = File(path.join(tempDir.path, 'pubspec.yaml'));
        await pubspecFile.writeAsString(pubspecContent);

        // Create a subdirectory and change to it
        final subDir = Directory(path.join(tempDir.path, 'subdir'));
        await subDir.create();
        Directory.current = subDir.path;

        final version = await VersionUtils.getVersionFromPubspec();
        expect(version, equals('1.5.0'));
      });

      test('should find pubspec.yaml multiple levels up', () async {
        // Create pubspec.yaml in temp directory
        final pubspecContent = '''
name: test_package
version: 3.2.1
''';
        final pubspecFile = File(path.join(tempDir.path, 'pubspec.yaml'));
        await pubspecFile.writeAsString(pubspecContent);

        // Create nested subdirectories and change to the deepest one
        final deepDir = Directory(
          path.join(tempDir.path, 'level1', 'level2', 'level3'),
        );
        await deepDir.create(recursive: true);
        Directory.current = deepDir.path;

        final version = await VersionUtils.getVersionFromPubspec();
        expect(version, equals('3.2.1'));
      });

      test(
        'should throw VersionException when pubspec.yaml not found',
        () async {
          // Change to temp directory without pubspec.yaml
          Directory.current = tempDir.path;

          expect(
            () async => await VersionUtils.getVersionFromPubspec(),
            throwsA(
              isA<VersionException>().having(
                (e) => e.message,
                'message',
                contains('pubspec.yaml not found'),
              ),
            ),
          );
        },
      );

      test('should throw VersionException for malformed YAML', () async {
        final malformedContent = '''
name: test_package
version: 1.0.0
  invalid_indentation: true
malformed yaml content [
''';
        final pubspecFile = File(path.join(tempDir.path, 'pubspec.yaml'));
        await pubspecFile.writeAsString(malformedContent);

        Directory.current = tempDir.path;

        expect(
          () async => await VersionUtils.getVersionFromPubspec(),
          throwsA(
            isA<VersionException>().having(
              (e) => e.message,
              'message',
              contains('Failed to parse pubspec.yaml: Invalid YAML format'),
            ),
          ),
        );
      });

      test(
        'should throw VersionException when version field is missing',
        () async {
          final pubspecContent = '''
name: test_package
description: A test package without version
environment:
  sdk: ^3.0.0
''';
          final pubspecFile = File(path.join(tempDir.path, 'pubspec.yaml'));
          await pubspecFile.writeAsString(pubspecContent);

          Directory.current = tempDir.path;

          expect(
            () async => await VersionUtils.getVersionFromPubspec(),
            throwsA(
              isA<VersionException>().having(
                (e) => e.message,
                'message',
                equals('Version field not found in pubspec.yaml'),
              ),
            ),
          );
        },
      );

      test(
        'should throw VersionException when version is not a string',
        () async {
          final pubspecContent = '''
name: test_package
version: 123
''';
          final pubspecFile = File(path.join(tempDir.path, 'pubspec.yaml'));
          await pubspecFile.writeAsString(pubspecContent);

          Directory.current = tempDir.path;

          expect(
            () async => await VersionUtils.getVersionFromPubspec(),
            throwsA(
              isA<VersionException>().having(
                (e) => e.message,
                'message',
                contains('Version field must be a string, found: int'),
              ),
            ),
          );
        },
      );

      test(
        'should throw VersionException when version is empty string',
        () async {
          final pubspecContent = '''
name: test_package
version: ""
''';
          final pubspecFile = File(path.join(tempDir.path, 'pubspec.yaml'));
          await pubspecFile.writeAsString(pubspecContent);

          Directory.current = tempDir.path;

          expect(
            () async => await VersionUtils.getVersionFromPubspec(),
            throwsA(
              isA<VersionException>().having(
                (e) => e.message,
                'message',
                equals('Version field cannot be empty'),
              ),
            ),
          );
        },
      );

      test(
        'should throw VersionException when version is whitespace only',
        () async {
          final pubspecContent = '''
name: test_package
version: "   "
''';
          final pubspecFile = File(path.join(tempDir.path, 'pubspec.yaml'));
          await pubspecFile.writeAsString(pubspecContent);

          Directory.current = tempDir.path;

          expect(
            () async => await VersionUtils.getVersionFromPubspec(),
            throwsA(
              isA<VersionException>().having(
                (e) => e.message,
                'message',
                equals('Version field cannot be empty'),
              ),
            ),
          );
        },
      );

      test('should work from project root directory', () async {
        // This test uses the actual project's pubspec.yaml
        Directory.current = originalWorkingDir;

        final version = await VersionUtils.getVersionFromPubspec();
        expect(version, isNotEmpty);
        expect(version, matches(RegExp(r'^\d+\.\d+\.\d+.*')));
      });
    });

    group('VersionException', () {
      test('should create exception with message', () {
        const message = 'Test error message';
        final exception = VersionException(message);

        expect(exception.message, equals(message));
        expect(exception.toString(), equals('VersionException: $message'));
      });

      test('should be throwable and catchable', () {
        const message = 'Test exception';

        expect(
          () => throw VersionException(message),
          throwsA(
            isA<VersionException>().having(
              (e) => e.message,
              'message',
              equals(message),
            ),
          ),
        );
      });
    });
  });
}
