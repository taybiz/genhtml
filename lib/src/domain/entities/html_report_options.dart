import 'package:equatable/equatable.dart';

/// Configuration for an HTML coverage report.
///
/// A value object: two options are equal when every field is equal, so an
/// options instance can be compared and reused as a `const` default.
class HtmlReportOptions extends Equatable {
  /// Creates report options.
  const HtmlReportOptions({
    this.title = 'LCOV - Code Coverage Report',
    this.showBranches = true,
    this.showFunctions = true,
  });

  /// Title rendered in the report header and the `<title>` element.
  final String title;

  /// Whether branch coverage columns and rows are rendered.
  final bool showBranches;

  /// Whether function coverage columns and rows are rendered.
  final bool showFunctions;

  /// Returns a copy with the given fields replaced.
  HtmlReportOptions copyWith({
    String? title,
    bool? showBranches,
    bool? showFunctions,
  }) {
    return HtmlReportOptions(
      title: title ?? this.title,
      showBranches: showBranches ?? this.showBranches,
      showFunctions: showFunctions ?? this.showFunctions,
    );
  }

  @override
  List<Object?> get props => [title, showBranches, showFunctions];

  @override
  String toString() =>
      'HtmlReportOptions(title: "$title", showBranches: $showBranches, '
      'showFunctions: $showFunctions)';
}
