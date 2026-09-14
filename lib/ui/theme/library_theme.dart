import 'package:collectarr_app/ui/theme/theme_palette.dart';
import 'package:collectarr_app/ui/theme/theme_primitives.dart';
import 'package:flutter/material.dart';

ThemeData buildLibraryTheme({
  AppThemePalette palette = kDefaultAppThemePalette,
}) {
  final base = palette.isDark
      ? ThemeData.dark(useMaterial3: true)
      : ThemeData.light(useMaterial3: true);
  return applySharedSurfaceTheme(
    base,
    palette,
    compact: false,
    includeCanvasColor: false,
    includeDropdownInputDecoration: true,
    dropdownInputFillColor: palette.field,
  ).copyWith(extensions: [palette]);
}

ThemeData buildLibraryDialogTheme({
  AppThemePalette palette = kDefaultAppThemePalette,
}) {
  return buildLibraryTheme(palette: palette).copyWith(
    inputDecorationTheme: buildAppInputDecorationTheme(
      palette,
      fillColor: palette.isDark ? kAppFieldDark : palette.field,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
    ),
  );
}

/// Default cached themes; callers with a custom palette should use the
/// theme builders above.
final ThemeData kLibraryTheme = buildLibraryTheme();
final ThemeData kLibraryDialogTheme = buildLibraryDialogTheme();
