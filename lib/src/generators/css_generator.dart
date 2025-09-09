/// Generator for CSS styles used in HTML coverage reports.
class CssGenerator {
  /// Generates the complete CSS stylesheet for coverage reports
  static String generateCss() {
    return '''
/* Reset and base styles */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: sans-serif;
  font-size: 14px;
  line-height: 1.6;
  color: #333;
  background-color: #fff;
  margin: 20px;
}

/* Header styles */
.header {
  background-color: #f0f0f0;
  padding: 10px;
  border-radius: 5px;
  margin-bottom: 20px;
}

.header h1 {
  font-size: 24px;
  margin-bottom: 5px;
}

.header p {
  font-size: 12px;
  color: #666;
}

/* Summary section */
.summary {
  margin: 20px 0;
}

.summary h2 {
  font-size: 18px;
  margin-bottom: 10px;
  color: #333;
}

/* Table styles */
.file-list {
  border-collapse: collapse;
  width: 100%;
  margin-bottom: 20px;
}

.file-list th,
.file-list td {
  border: 1px solid #ddd;
  padding: 8px;
  text-align: left;
}

.file-list th {
  background-color: #f2f2f2;
  font-weight: bold;
}

.file-list tr:hover {
  background-color: #f5f5f5;
}

/* Coverage level styles */
.coverage-high {
  background-color: #d4edda;
  color: #155724;
}

.coverage-medium {
  background-color: #fff3cd;
  color: #856404;
}

.coverage-low {
  background-color: #f8d7da;
  color: #721c24;
}

.coverage-none {
  background-color: #f5f5f5;
  color: #6c757d;
}

/* File links */
.file-link {
  color: #007bff;
  text-decoration: none;
}

.file-link:hover {
  text-decoration: underline;
}

/* Source code display */
.source-code {
  font-family: 'Courier New', monospace;
  font-size: 12px;
  line-height: 1.4;
  border: 1px solid #ddd;
  background-color: #f8f9fa;
}

.source-line {
  display: flex;
  border-bottom: 1px solid #eee;
}

.source-line:last-child {
  border-bottom: none;
}

.line-number {
  background-color: #f1f1f1;
  color: #666;
  padding: 2px 8px;
  text-align: right;
  min-width: 50px;
  border-right: 1px solid #ddd;
  user-select: none;
}

.line-hits {
  background-color: #fff;
  color: #666;
  padding: 2px 8px;
  text-align: right;
  min-width: 40px;
  border-right: 1px solid #ddd;
  font-size: 11px;
}

.line-content {
  padding: 2px 8px;
  flex: 1;
  white-space: pre;
}

/* Line coverage states */
.line-covered {
  background-color: #d4edda;
}

.line-covered .line-hits {
  background-color: #c3e6cb;
  color: #155724;
  font-weight: bold;
}

.line-uncovered {
  background-color: #f8d7da;
}

.line-uncovered .line-hits {
  background-color: #f1b0b7;
  color: #721c24;
  font-weight: bold;
}

.line-no-code {
  background-color: #f8f9fa;
}

/* Breadcrumb navigation */
.breadcrumb {
  background-color: #e9ecef;
  padding: 8px 12px;
  border-radius: 4px;
  margin-bottom: 15px;
  font-size: 13px;
}

.breadcrumb a {
  color: #007bff;
  text-decoration: none;
}

.breadcrumb a:hover {
  text-decoration: underline;
}

.breadcrumb .separator {
  margin: 0 5px;
  color: #6c757d;
}

/* Footer */
.footer {
  margin-top: 30px;
  padding-top: 15px;
  border-top: 1px solid #ddd;
  text-align: center;
  color: #666;
  font-size: 12px;
}

/* Responsive design */
@media (max-width: 768px) {
  body {
    margin: 10px;
  }
  
  .file-list th,
  .file-list td {
    padding: 6px;
    font-size: 12px;
  }
  
  .source-code {
    font-size: 11px;
  }
}

/* Print styles */
@media print {
  body {
    margin: 0;
    font-size: 12px;
  }
  
  .header {
    background-color: #f8f9fa !important;
  }
  
  .file-link {
    color: #000 !important;
  }
}
''';
  }

  /// Generates inline CSS for embedding in HTML files
  static String generateInlineCss() {
    return '<style>\n${generateCss()}\n</style>';
  }

  /// Gets the CSS class name for a coverage percentage
  static String getCoverageClass(double percentage) {
    if (percentage >= 90.0) return 'coverage-high';
    if (percentage >= 60.0) return 'coverage-medium';
    if (percentage > 0.0) return 'coverage-low';
    return 'coverage-none';
  }

  /// Gets the CSS class name for line coverage state
  static String getLineCoverageClass(int hits) {
    if (hits > 0) return 'line-covered';
    return 'line-uncovered';
  }
}
