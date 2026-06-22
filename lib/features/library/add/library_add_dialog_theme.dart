import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_dialog_tokens.dart';
import 'package:flutter/material.dart';

/// Build a themed [ThemeData] for add dialogs with the given accent color.
ThemeData libraryAddDialogTheme(
  Color accent, {
  AppThemePalette palette = kDefaultAppThemePalette,
}) {
  final base = buildLibraryDialogTheme(palette: palette);
  final scheme = base.colorScheme.copyWith(
    primary: accent,
    secondary: accent,
  );
  return base.copyWith(
    colorScheme: scheme,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        foregroundColor:
            ThemeData.estimateBrightnessForColor(accent) == Brightness.dark
                ? Colors.white
                : palette.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
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
  final foreground =
      ThemeData.estimateBrightnessForColor(accent) == Brightness.dark
          ? Colors.white
          : kDefaultAppThemePalette.textPrimary;
  return FilledButton.styleFrom(
    backgroundColor: accent,
    foregroundColor: foreground,
    minimumSize: const Size(0, kLibraryDialogFooterButtonHeight),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    shape: kLibraryDialogFooterButtonShape,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    textStyle: const TextStyle(fontWeight: FontWeight.w900),
  );
}
