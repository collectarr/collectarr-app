import 'package:flutter/material.dart';

/// Semantic text roles for Library UI.
extension LibraryTextTheme on TextTheme {
  /// Panel and dialog title styling (prominent header).
  TextStyle get panelTitle => (titleMedium ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
      );

  /// Form section title styling (structured form segment headers).
  TextStyle get sectionTitle => (titleSmall ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.05,
      );

  /// Metadata field labels, key-value captions, and input field hints/headers.
  TextStyle get metadataLabel => (labelMedium ?? const TextStyle()).copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.05,
      );

  /// Labels attached to editable fields and controls.
  TextStyle get fieldLabel => metadataLabel;

  /// Text shown inside editable controls and their selected values.
  TextStyle get controlText => (bodyMedium ?? const TextStyle()).copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

  /// Supporting, explanatory, helper, or footnote text.
  TextStyle get supportingText => (bodySmall ?? const TextStyle()).copyWith(
        fontSize: 13,
        letterSpacing: 0.0,
      );

  /// Informational copy, validation messages, and secondary explanations.
  TextStyle get informationalText => supportingText;

  /// Table column headers and uppercase badge / metric labels.
  TextStyle get tableHeader => (labelSmall ?? const TextStyle()).copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );

  /// Add-dialog title and other prominent Library chrome labels.
  TextStyle get libraryDialogTitle =>
      (titleMedium ?? const TextStyle()).copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
      );

  /// Detail-page title used by compact and sheet presentations.
  TextStyle get libraryDetailTitle =>
      (titleMedium ?? const TextStyle()).copyWith(fontSize: 16);

  /// Standard Library body/result text.
  TextStyle get libraryBody =>
      (bodyMedium ?? const TextStyle()).copyWith(fontSize: 14);

  /// Metadata, rating, and secondary action text.
  TextStyle get libraryMeta =>
      (labelMedium ?? const TextStyle()).copyWith(fontSize: 13);

  /// Compact captions, hosts, dates, and source labels.
  TextStyle get libraryCaption =>
      (labelSmall ?? const TextStyle()).copyWith(fontSize: 13);

  /// Title fallback for the older panel chrome implementation.
  TextStyle get libraryChromeTitle =>
      (bodyMedium ?? const TextStyle()).copyWith(fontSize: 14);
}

/// Convenience getter on [BuildContext] to access [LibraryTextTheme].
extension LibraryBuildContextTextTheme on BuildContext {
  TextTheme get libraryTextTheme => Theme.of(this).textTheme;
}
