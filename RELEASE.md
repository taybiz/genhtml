# Release Process

This document explains how to create releases with attached binaries for the genhtml project.

## Overview

The project uses GitHub Actions to automatically build binaries for multiple platforms and attach them to GitHub releases. When you create a version tag, the system will:

1. Build binaries for 6 platforms:
   - Windows (AMD64, ARM64)
   - Linux (AMD64, ARM64)
   - macOS (AMD64, ARM64)
2. Run tests on all platforms
3. Create a GitHub release
4. Attach all binaries and checksums to the release

## Creating a Release

### Method 1: Using the Release Script (Recommended)

Use the provided Dart script to automate the entire process:

```bash
# Create a new release (e.g., version 1.0.1)
dart scripts/create_release.dart 1.0.1
```

This script will:
- Update the version in `pubspec.yaml`
- Update the version in `bin/genhtml.dart`
- Commit the changes
- Create and push a git tag
- Trigger the GitHub Actions release workflow

### Method 2: Manual Process

If you prefer to do it manually:

1. **Update version numbers:**
   ```bash
   # Edit pubspec.yaml - change the version line
   version: 1.0.1
   
   # Edit bin/genhtml.dart - change the version constant
   const String version = "1.0.1";
   ```

2. **Commit and tag:**
   ```bash
   git add pubspec.yaml bin/genhtml.dart
   git commit -m "Bump version to 1.0.1"
   git tag -a v1.0.1 -m "Release 1.0.1"
   git push origin v1.0.1
   git push
   ```

### Method 3: Manual Workflow Trigger

You can also manually trigger the release workflow from GitHub:

1. Go to your repository's Actions tab
2. Select "Release" workflow
3. Click "Run workflow"
4. Enter the tag name (e.g., `v1.0.1`)
5. Click "Run workflow"

## Monitoring the Release

After creating a tag, you can monitor the release process:

1. Go to your repository's **Actions** tab
2. Look for the "Release" workflow run
3. The workflow will show progress for:
   - Building binaries on all platforms
   - Running tests
   - Creating the release
   - Uploading assets

## Release Assets

Each release will include:

- `genhtml-windows-amd64.exe` - Windows 64-bit executable
- `genhtml-windows-arm64.exe` - Windows ARM64 executable
- `genhtml-linux-amd64` - Linux 64-bit executable
- `genhtml-linux-arm64` - Linux ARM64 executable
- `genhtml-macos-amd64` - macOS Intel executable
- `genhtml-macos-arm64` - macOS Apple Silicon executable
- `checksums.txt` - SHA256 checksums for all binaries

## Using Released Binaries

Users can download the appropriate binary for their platform from the GitHub releases page:

### Windows
```cmd
# Download genhtml-windows-amd64.exe
# Place it in your PATH or run directly
genhtml-windows-amd64.exe --help
```

### Linux/macOS
```bash
# Download the appropriate binary
wget https://github.com/yourusername/genhtml-dart/releases/download/v1.0.1/genhtml-linux-amd64

# Make it executable
chmod +x genhtml-linux-amd64

# Run it
./genhtml-linux-amd64 --help

# Optionally, move to PATH
sudo mv genhtml-linux-amd64 /usr/local/bin/genhtml
```

## Troubleshooting

### Build Failures

If the build fails:
1. Check the Actions tab for error details
2. Common issues:
   - Test failures on specific platforms
   - Dart compilation errors
   - Missing dependencies

### Release Creation Failures

If release creation fails:
1. Ensure you have proper permissions (Contents: write)
2. Check that the tag doesn't already exist
3. Verify the workflow file syntax

### Cross-compilation Issues

The workflow uses Dart's built-in cross-compilation:
- Some features might not work on all target platforms
- Test thoroughly on actual target systems when possible

## Version Management

- Use semantic versioning (MAJOR.MINOR.PATCH)
- Update both `pubspec.yaml` and `bin/genhtml.dart`
- Keep versions in sync between files
- Use the release script to avoid manual errors

## Changelog

Consider maintaining a `CHANGELOG.md` file to document changes between versions. The release workflow will automatically include changelog entries in the release notes if the file exists.