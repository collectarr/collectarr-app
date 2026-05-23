import 'package:collectarr_app/ui/theme/theme_palette.dart';
import 'package:collectarr_app/ui/theme/theme_primitives.dart';
import 'package:flutter/material.dart';

ThemeData buildLibraryTheme({
  AppThemePalette palette = kDefaultAppThemePalette,
}) {
  final base = ThemeData.dark(useMaterial3: true);
  return applySharedSurfaceTheme(
    base,
    palette,
    compact: false,
    includeCanvasColor: false,
    includeDropdownInputDecoration: true,
    dropdownInputFillColor: palette.field,
  );
}

ThemeData buildLibraryDialogTheme({
  AppThemePalette palette = kDefaultAppThemePalette,
}) {
  return kLibraryTheme.copyWith(
    inputDecorationTheme: buildAppInputDecorationTheme(
      palette,
      fillColor: const Color(0xFF111111),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
    ),
  );
}

final ThemeData kLibraryTheme = buildLibraryTheme();
final ThemeData kLibraryDialogTheme = buildLibraryDialogTheme();
