#!/usr/bin/env dart

import 'dart:io';
import 'package:yaml/yaml.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart scripts/create_release.dart <version>');
    print('Example: dart scripts/create_release.dart 1.0.1');
    exit(1);
  }

  final version = args[0];
  
  // Validate version format (basic semver check)
  final versionRegex = RegExp(r'^\d+\.\d+\.\d+(-[a-zA-Z0-9.-]+)?$');
  if (!versionRegex.hasMatch(version)) {
    print('Error: Invalid version format. Use semantic versioning (e.g., 1.0.1)');
    exit(1);
  }

  print('Creating release for version: $version');

  // Update pubspec.yaml
  await updatePubspecVersion(version);
  
  // Update bin/genhtml.dart version
  await updateBinaryVersion(version);
  
  // Create git tag and push
  await createGitTag(version);
  
  print('✅ Release $version created successfully!');
  print('');
  print('The GitHub Actions workflow will now:');
  print('1. Build binaries for all platforms');
  print('2. Run tests on all platforms');
  print('3. Create a GitHub release');
  print('4. Attach all binaries to the release');
  print('');
  print('Check the Actions tab in your GitHub repository to monitor progress.');
}

Future<void> updatePubspecVersion(String version) async {
  print('📝 Updating pubspec.yaml version...');
  
  final pubspecFile = File('pubspec.yaml');
  if (!await pubspecFile.exists()) {
    print('Error: pubspec.yaml not found');
    exit(1);
  }
  
  final content = await pubspecFile.readAsString();
  final updatedContent = content.replaceFirst(
    RegExp(r'^version:\s+.*$', multiLine: true),
    'version: $version',
  );
  
  await pubspecFile.writeAsString(updatedContent);
  print('✅ Updated pubspec.yaml');
}

Future<void> updateBinaryVersion(String version) async {
  print('📝 Updating bin/genhtml.dart version...');
  
  final binaryFile = File('bin/genhtml.dart');
  if (!await binaryFile.exists()) {
    print('Error: bin/genhtml.dart not found');
    exit(1);
  }
  
  final content = await binaryFile.readAsString();
  final updatedContent = content.replaceFirst(
    RegExp(r'^const String version = ".*";$', multiLine: true),
    'const String version = "$version";',
  );
  
  await binaryFile.writeAsString(updatedContent);
  print('✅ Updated bin/genhtml.dart');
}

Future<void> createGitTag(String version) async {
  print('🏷️  Creating git tag and pushing...');
  
  // Check if we're in a git repository
  final gitDir = Directory('.git');
  if (!await gitDir.exists()) {
    print('Error: Not in a git repository');
    exit(1);
  }
  
  // Check for uncommitted changes
  final statusResult = await Process.run('git', ['status', '--porcelain']);
  if (statusResult.stdout.toString().trim().isNotEmpty) {
    print('📝 Committing version changes...');
    await Process.run('git', ['add', 'pubspec.yaml', 'bin/genhtml.dart']);
    await Process.run('git', ['commit', '-m', 'Bump version to $version']);
  }
  
  // Create and push tag
  final tagName = 'v$version';
  
  // Check if tag already exists
  final tagCheckResult = await Process.run('git', ['tag', '-l', tagName]);
  if (tagCheckResult.stdout.toString().trim().isNotEmpty) {
    print('Error: Tag $tagName already exists');
    exit(1);
  }
  
  final tagResult = await Process.run('git', ['tag', '-a', tagName, '-m', 'Release $version']);
  if (tagResult.exitCode != 0) {
    print('Error creating tag: ${tagResult.stderr}');
    exit(1);
  }
  
  final pushResult = await Process.run('git', ['push', 'origin', tagName]);
  if (pushResult.exitCode != 0) {
    print('Error pushing tag: ${pushResult.stderr}');
    exit(1);
  }
  
  // Also push the version commit
  final pushCommitResult = await Process.run('git', ['push']);
  if (pushCommitResult.exitCode != 0) {
    print('Warning: Could not push version commit: ${pushCommitResult.stderr}');
  }
  
  print('✅ Created and pushed tag: $tagName');
}