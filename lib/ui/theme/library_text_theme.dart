import 'package:flutter/material.dart';

/// Semantic text style aliases for Library UI.
///
/// These styles map directly to standard [TextTheme] tokens with semantic
/// weights and letter spacing, avoiding scattered hardcoded `TextStyle(fontSize: ...)`.
extension LibraryTextTheme on TextTheme {
  /// Panel and dialog title styling (prominent header).
  TextStyle get panelTitle => (titleMedium ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.1,
      );

  /// Form section title styling (structured form segment headers).
  TextStyle get sectionTitle => (titleSmall ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.05,
      );

  /// Metadata field labels, key-value captions, and input field hints/headers.
  TextStyle get metadataLabel => (labelMedium ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.05,
      );

  /// Supporting, explanatory, helper, or footnote text.
  TextStyle get supportingText => (bodySmall ?? const TextStyle()).copyWith(
        letterSpacing: 0.0,
      );

  /// Table column headers and uppercase badge / metric labels.
  TextStyle get tableHeader => (labelSmall ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
      );
}

/// Convenience getter on [BuildContext] to access [LibraryTextTheme].
extension LibraryBuildContextTextTheme on BuildContext {
  TextTheme get libraryTextTheme => Theme.of(this).textTheme;
}
