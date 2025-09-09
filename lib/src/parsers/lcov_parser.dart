import 'dart:io';

import '../models/coverage_data.dart';
import '../models/source_file.dart';
import '../models/line_coverage.dart';
import '../models/function_coverage.dart';
import '../models/branch_coverage.dart';
import '../utils/validation.dart';

/// Parser for LCOV trace files (.info format).
///
/// Supports all standard LCOV record types:
/// - TN: Test name
/// - SF: Source file
/// - FN: Function name
/// - FNDA: Function data
/// - FNF: Functions found
/// - FNH: Functions hit
/// - DA: Line data
/// - LF: Lines found
/// - LH: Lines hit
/// - BRDA: Branch data
/// - BRF: Branches found
/// - BRH: Branches hit
/// - end_of_record: End of record marker
class LcovParser {
  /// Parses LCOV content from a string and returns coverage data
  static CoverageData parse(String lcovContent, {String? title}) {
    // Validate LCOV format first
    final validationResult = Validation.validateLcovFormat(lcovContent);
    if (!validationResult.isValid) {
      throw LcovParseException(
        'Invalid LCOV format: ${validationResult.message}',
      );
    }

    final sourceFiles = <SourceFile>[];
    final lines = lcovContent.split('\n');

    SourceFileBuilder? currentFile;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      try {
        if (line.startsWith('TN:')) {
          // Test name - we can ignore this for now
          continue;
        } else if (line.startsWith('SF:')) {
          // Start of a new source file
          if (currentFile != null) {
            sourceFiles.add(currentFile.build());
          }
          final filePath = line.substring(3); // Remove 'SF:' prefix
          currentFile = SourceFileBuilder(filePath);
        } else if (line.startsWith('FN:')) {
          // Function name
          if (currentFile == null) {
            throw LcovParseException(
              'FN record found before SF record at line ${i + 1}',
            );
          }
          currentFile.addFunctionName(line);
        } else if (line.startsWith('FNDA:')) {
          // Function data
          if (currentFile == null) {
            throw LcovParseException(
              'FNDA record found before SF record at line ${i + 1}',
            );
          }
          currentFile.addFunctionData(line);
        } else if (line.startsWith('FNF:')) {
          // Functions found - we can validate this against our count
          if (currentFile == null) {
            throw LcovParseException(
              'FNF record found before SF record at line ${i + 1}',
            );
          }
          final count = int.tryParse(line.substring(4));
          if (count == null) {
            throw LcovParseException(
              'Invalid FNF format at line ${i + 1}: $line',
            );
          }
          currentFile.setFunctionsFound(count);
        } else if (line.startsWith('FNH:')) {
          // Functions hit - we can validate this against our count
          if (currentFile == null) {
            throw LcovParseException(
              'FNH record found before SF record at line ${i + 1}',
            );
          }
          final count = int.tryParse(line.substring(4));
          if (count == null) {
            throw LcovParseException(
              'Invalid FNH format at line ${i + 1}: $line',
            );
          }
          currentFile.setFunctionsHit(count);
        } else if (line.startsWith('DA:')) {
          // Line data
          if (currentFile == null) {
            throw LcovParseException(
              'DA record found before SF record at line ${i + 1}',
            );
          }
          currentFile.addLineData(line);
        } else if (line.startsWith('LF:')) {
          // Lines found - we can validate this against our count
          if (currentFile == null) {
            throw LcovParseException(
              'LF record found before SF record at line ${i + 1}',
            );
          }
          final count = int.tryParse(line.substring(3));
          if (count == null) {
            throw LcovParseException(
              'Invalid LF format at line ${i + 1}: $line',
            );
          }
          currentFile.setLinesFound(count);
        } else if (line.startsWith('LH:')) {
          // Lines hit - we can validate this against our count
          if (currentFile == null) {
            throw LcovParseException(
              'LH record found before SF record at line ${i + 1}',
            );
          }
          final count = int.tryParse(line.substring(3));
          if (count == null) {
            throw LcovParseException(
              'Invalid LH format at line ${i + 1}: $line',
            );
          }
          currentFile.setLinesHit(count);
        } else if (line.startsWith('BRDA:')) {
          // Branch data
          if (currentFile == null) {
            throw LcovParseException(
              'BRDA record found before SF record at line ${i + 1}',
            );
          }
          currentFile.addBranchData(line);
        } else if (line.startsWith('BRF:')) {
          // Branches found - we can validate this against our count
          if (currentFile == null) {
            throw LcovParseException(
              'BRF record found before SF record at line ${i + 1}',
            );
          }
          final count = int.tryParse(line.substring(4));
          if (count == null) {
            throw LcovParseException(
              'Invalid BRF format at line ${i + 1}: $line',
            );
          }
          currentFile.setBranchesFound(count);
        } else if (line.startsWith('BRH:')) {
          // Branches hit - we can validate this against our count
          if (currentFile == null) {
            throw LcovParseException(
              'BRH record found before SF record at line ${i + 1}',
            );
          }
          final count = int.tryParse(line.substring(4));
          if (count == null) {
            throw LcovParseException(
              'Invalid BRH format at line ${i + 1}: $line',
            );
          }
          currentFile.setBranchesHit(count);
        } else if (line == 'end_of_record') {
          // End of current record
          if (currentFile != null) {
            sourceFiles.add(currentFile.build());
            currentFile = null;
          }
        } else {
          // Unknown record type - log warning but continue
          // This allows for future LCOV extensions
        }
      } catch (e) {
        throw LcovParseException('Error parsing line ${i + 1}: "$line" - $e');
      }
    }

    // Handle case where file doesn't end with end_of_record
    if (currentFile != null) {
      sourceFiles.add(currentFile.build());
    }

    return CoverageData.fromSourceFiles(sourceFiles, title: title);
  }

  /// Parses LCOV content from a file and returns coverage data
  static Future<CoverageData> parseFile(
    String filePath, {
    String? title,
  }) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      return parse(content, title: title);
    } catch (e) {
      throw LcovParseException('Failed to parse LCOV file "$filePath": $e');
    }
  }
}

/// Builder class to construct SourceFile objects during parsing
class SourceFileBuilder {
  final String path;
  final List<LineCoverage> _lines = [];
  final Map<String, String> _functionNames = {}; // line -> name
  final Map<String, int> _functionHits = {}; // name -> hits
  final List<BranchCoverage> _branches = [];

  // Validation counters
  int? _functionsFound;
  int? _functionsHit;
  int? _linesFound;
  int? _linesHit;
  int? _branchesFound;
  int? _branchesHit;

  SourceFileBuilder(this.path);

  void addFunctionName(String fnLine) {
    // Parse FN:line_number,function_name
    final data = fnLine.substring(3);
    final parts = data.split(',');
    if (parts.length != 2) {
      throw ArgumentError('Invalid FN format: $fnLine');
    }

    final lineNumber = int.tryParse(parts[0]);
    if (lineNumber == null) {
      throw ArgumentError('Invalid FN format: $fnLine');
    }

    _functionNames[parts[0]] = parts[1];
  }

  void addFunctionData(String fndaLine) {
    // Parse FNDA:hit_count,function_name
    final data = fndaLine.substring(5);
    final parts = data.split(',');
    if (parts.length != 2) {
      throw ArgumentError('Invalid FNDA format: $fndaLine');
    }

    final hitCount = int.tryParse(parts[0]);
    if (hitCount == null) {
      throw ArgumentError('Invalid FNDA format: $fndaLine');
    }

    _functionHits[parts[1]] = hitCount;
  }

  void addLineData(String daLine) {
    try {
      _lines.add(LineCoverage.fromLcovData(daLine));
    } catch (e) {
      throw ArgumentError('Invalid DA format: $daLine - $e');
    }
  }

  void addBranchData(String brdaLine) {
    try {
      _branches.add(BranchCoverage.fromLcovData(brdaLine));
    } catch (e) {
      throw ArgumentError('Invalid BRDA format: $brdaLine - $e');
    }
  }

  void setFunctionsFound(int count) => _functionsFound = count;
  void setFunctionsHit(int count) => _functionsHit = count;
  void setLinesFound(int count) => _linesFound = count;
  void setLinesHit(int count) => _linesHit = count;
  void setBranchesFound(int count) => _branchesFound = count;
  void setBranchesHit(int count) => _branchesHit = count;

  SourceFile build() {
    // Build function coverage objects
    final functions = <FunctionCoverage>[];
    for (final entry in _functionNames.entries) {
      final lineNumber = int.parse(entry.key);
      final functionName = entry.value;
      final hitCount = _functionHits[functionName] ?? 0;

      functions.add(
        FunctionCoverage.create(
          lineNumber: lineNumber,
          functionName: functionName,
          hitCount: hitCount,
        ),
      );
    }

    // Sort collections by line number for consistency
    _lines.sort((a, b) => a.lineNumber.compareTo(b.lineNumber));
    functions.sort((a, b) => a.lineNumber.compareTo(b.lineNumber));
    _branches.sort((a, b) => a.lineNumber.compareTo(b.lineNumber));

    final sourceFile = SourceFile(
      path: path,
      lines: _lines,
      functions: functions,
      branches: _branches,
    );

    // Validate counts if provided
    _validateCounts(sourceFile);

    return sourceFile;
  }

  void _validateCounts(SourceFile sourceFile) {
    if (_linesFound != null && sourceFile.totalLines != _linesFound) {
      throw LcovParseException(
        'Line count mismatch for $path: expected $_linesFound, got ${sourceFile.totalLines}',
      );
    }

    if (_linesHit != null && sourceFile.hitLines != _linesHit) {
      throw LcovParseException(
        'Hit line count mismatch for $path: expected $_linesHit, got ${sourceFile.hitLines}',
      );
    }

    if (_functionsFound != null &&
        sourceFile.totalFunctions != _functionsFound) {
      throw LcovParseException(
        'Function count mismatch for $path: expected $_functionsFound, got ${sourceFile.totalFunctions}',
      );
    }

    if (_functionsHit != null && sourceFile.hitFunctions != _functionsHit) {
      throw LcovParseException(
        'Hit function count mismatch for $path: expected $_functionsHit, got ${sourceFile.hitFunctions}',
      );
    }

    // For branches, only validate if we have BRDA records
    // Some LCOV files report BRF/BRH counts without individual BRDA records
    if (_branchesFound != null &&
        _branches.isNotEmpty &&
        sourceFile.totalBranches != _branchesFound) {
      throw LcovParseException(
        'Branch count mismatch for $path: expected $_branchesFound, got ${sourceFile.totalBranches}',
      );
    }

    if (_branchesHit != null &&
        _branches.isNotEmpty &&
        sourceFile.hitBranches != _branchesHit) {
      throw LcovParseException(
        'Hit branch count mismatch for $path: expected $_branchesHit, got ${sourceFile.hitBranches}',
      );
    }
  }
}

/// Exception thrown when LCOV parsing fails
class LcovParseException implements Exception {
  final String message;

  const LcovParseException(this.message);

  @override
  String toString() => 'LcovParseException: $message';
}
