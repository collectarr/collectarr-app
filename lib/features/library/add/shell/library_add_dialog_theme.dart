import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_dialog_tokens.dart';
import 'package:flutter/material.dart';

/// Build a themed [ThemeData] for add dialogs with the given accent color.
ThemeData libraryAddDialogTheme(
  Color accent, {
  AppThemePalette palette = kDefaultAppThemePalette,
}) {
  final base = buildLibraryDialogTheme(palette: palette);
  final actionAccent = libraryAccentActionColor(accent);
  final scheme = base.colorScheme.copyWith(
    primary: accent,
    onPrimary: appContrastingTextColor(accent),
    secondary: accent,
    onSecondary: appContrastingTextColor(accent),
  );
  return base.copyWith(
    colorScheme: scheme,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: actionAccent,
        foregroundColor: appContrastingTextColor(actionAccent),
        shape: kLibraryDialogFooterButtonShape,
        visualDensity: VisualDensity.compact,
      ),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: accent),
      ),
    ),
    datePickerTheme: buildAppDatePickerTheme(
      palette: palette,
      accent: accent,
      surface: palette.panel,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: accent),
  );
}

/// Filled button style used in add dialog bottom bars.
ButtonStyle libraryAddFilledButtonStyle([Color accent = kAppAccent]) {
  final actionAccent = libraryAccentActionColor(accent);
  return FilledButton.styleFrom(
    backgroundColor: actionAccent,
    foregroundColor: appContrastingTextColor(actionAccent),
    minimumSize: const Size(0, kLibraryDialogFooterButtonHeight),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    shape: kLibraryDialogFooterButtonShape,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    textStyle: const TextStyle(fontWeight: FontWeight.w600),
  );
}
