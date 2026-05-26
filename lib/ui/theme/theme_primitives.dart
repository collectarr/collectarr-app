import 'package:collectarr_app/ui/theme/date_picker_theme.dart';
import 'package:collectarr_app/ui/theme/theme_palette.dart';
import 'package:flutter/material.dart';

ColorScheme buildAppColorScheme(AppThemePalette palette) {
  final base = ColorScheme.fromSeed(
    seedColor: palette.accent,
    brightness: Brightness.dark,
    surface: palette.panel,
  );
  return base.copyWith(
    primary: palette.accent,
    secondary: palette.highlight,
    surface: palette.panel,
    surfaceContainerLowest: palette.canvas,
    surfaceContainerLow: palette.panel,
    surfaceContainer: palette.toolbar,
    surfaceContainerHigh: palette.panelRaised,
    surfaceContainerHighest: kAppSurfaceBright,
    outline: palette.divider,
    outlineVariant: const Color(0xFF373737),
  );
}

InputDecorationTheme buildAppInputDecorationTheme(
  AppThemePalette palette, {
  Color? fillColor,
  EdgeInsetsGeometry? contentPadding,
  TextStyle? labelStyle,
  TextStyle? hintStyle,
}) {
  return InputDecorationTheme(
    filled: true,
    fillColor: fillColor ?? palette.field,
    isDense: true,
    contentPadding: contentPadding,
    labelStyle: labelStyle,
    hintStyle: hintStyle,
    border: OutlineInputBorder(
      borderSide: BorderSide(color: palette.divider),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: palette.divider),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: palette.accent),
    ),
  );
}

DialogThemeData buildAppDialogTheme(AppThemePalette palette) {
  return DialogThemeData(
    backgroundColor: palette.panel,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
      side: BorderSide(color: palette.divider),
    ),
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w900,
    ),
    contentTextStyle: const TextStyle(color: Colors.white),
  );
}

PopupMenuThemeData buildAppPopupMenuTheme(AppThemePalette palette) {
  return PopupMenuThemeData(
    color: palette.panelRaised,
    surfaceTintColor: Colors.transparent,
    textStyle: const TextStyle(color: Colors.white),
    elevation: 12,
    shape: RoundedRectangleBorder(
      borderRadius: palette.menuBorderRadius,
      side: BorderSide(color: palette.divider),
    ),
  );
}

MenuThemeData buildAppMenuTheme(AppThemePalette palette) {
  return MenuThemeData(
    style: MenuStyle(
      backgroundColor: WidgetStatePropertyAll(palette.panelRaised),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: palette.menuBorderRadius,
          side: BorderSide(color: palette.divider),
        ),
      ),
    ),
  );
}

DropdownMenuThemeData buildAppDropdownMenuTheme(
  AppThemePalette palette, {
  bool includeInputDecoration = false,
  Color? inputFillColor,
}) {
  return DropdownMenuThemeData(
    textStyle: const TextStyle(color: Colors.white),
    menuStyle: MenuStyle(
      backgroundColor: WidgetStatePropertyAll(palette.panelRaised),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      elevation: const WidgetStatePropertyAll(12),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: palette.menuBorderRadius,
          side: BorderSide(color: palette.divider),
        ),
      ),
    ),
    inputDecorationTheme: includeInputDecoration
        ? buildAppInputDecorationTheme(
            palette,
            fillColor: inputFillColor,
          )
        : null,
  );
}

FilledButtonThemeData buildAppFilledButtonTheme(AppThemePalette palette) {
  return FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: palette.accent,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      visualDensity: VisualDensity.compact,
    ),
  );
}

OutlinedButtonThemeData buildAppOutlinedButtonTheme(AppThemePalette palette) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: BorderSide(color: palette.divider),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      visualDensity: VisualDensity.compact,
    ),
  );
}

IconButtonThemeData buildAppIconButtonTheme({bool compact = false}) {
  return IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: const Color(0xFF343434),
      disabledForegroundColor: const Color(0xFF777777),
      disabledBackgroundColor: const Color(0xFF252525),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      visualDensity: compact ? VisualDensity.compact : null,
    ),
  );
}

SearchBarThemeData buildAppSearchBarTheme(AppThemePalette palette) {
  return SearchBarThemeData(
    backgroundColor: WidgetStatePropertyAll(palette.field),
    hintStyle: WidgetStatePropertyAll(
      TextStyle(color: palette.textMuted),
    ),
    textStyle: const WidgetStatePropertyAll(TextStyle(color: Colors.white)),
    elevation: const WidgetStatePropertyAll(0),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        side: BorderSide(color: palette.divider),
        borderRadius: BorderRadius.circular(3),
      ),
    ),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 10),
    ),
  );
}

ChipThemeData buildAppChipTheme(ThemeData base, AppThemePalette palette) {
  return base.chipTheme.copyWith(
    backgroundColor: const Color(0xFF343434),
    selectedColor: palette.selection,
    labelStyle: const TextStyle(color: Colors.white),
    side: BorderSide(color: palette.divider),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
  );
}

ThemeData applySharedSurfaceTheme(
  ThemeData base,
  AppThemePalette palette, {
  required bool compact,
  required bool includeCanvasColor,
  required bool includeDropdownInputDecoration,
  Color? dropdownInputFillColor,
  InputDecorationTheme? inputDecorationTheme,
}) {
  return base.copyWith(
    visualDensity: compact ? VisualDensity.compact : null,
    colorScheme: buildAppColorScheme(palette),
    scaffoldBackgroundColor: palette.canvas,
    canvasColor: includeCanvasColor ? palette.canvas : palette.panelRaised,
    dividerTheme: DividerThemeData(
      color: palette.divider,
      thickness: 1,
      space: compact ? null : 1,
    ),
    dialogTheme: buildAppDialogTheme(palette),
    popupMenuTheme: buildAppPopupMenuTheme(palette),
    menuTheme: buildAppMenuTheme(palette),
    dropdownMenuTheme: buildAppDropdownMenuTheme(
      palette,
      includeInputDecoration: includeDropdownInputDecoration,
      inputFillColor: dropdownInputFillColor,
    ),
    filledButtonTheme: buildAppFilledButtonTheme(palette),
    outlinedButtonTheme: buildAppOutlinedButtonTheme(palette),
    iconButtonTheme: buildAppIconButtonTheme(compact: compact),
    inputDecorationTheme:
        inputDecorationTheme ?? buildAppInputDecorationTheme(palette),
    searchBarTheme: buildAppSearchBarTheme(palette),
    chipTheme: buildAppChipTheme(base, palette),
    datePickerTheme: buildAppDatePickerTheme(palette: palette),
    textTheme: base.textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
  );
}
