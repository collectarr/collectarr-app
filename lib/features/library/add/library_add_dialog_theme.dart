import 'package:collectarr_app/ui/clz_style.dart';
import 'package:flutter/material.dart';

/// Build a themed [ThemeData] for add dialogs with the given accent color.
ThemeData libraryAddDialogTheme(Color accent) {
  final base = kClzAddComicDialogTheme;
  final scheme = base.colorScheme.copyWith(
    primary: accent,
    secondary: accent,
  );
  return base.copyWith(
    colorScheme: scheme,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        visualDensity: VisualDensity.compact,
      ),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: accent),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: accent),
  );
}

/// Filled button style used in add dialog bottom bars.
ButtonStyle libraryAddFilledButtonStyle([Color accent = kClzAccent]) {
  return FilledButton.styleFrom(
    backgroundColor: accent,
    foregroundColor: Colors.white,
    minimumSize: const Size(0, 36),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    textStyle: const TextStyle(fontWeight: FontWeight.w900),
  );
}
