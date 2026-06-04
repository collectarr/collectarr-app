import 'package:collectarr_app/ui/theme/date_picker_theme.dart';
import 'package:collectarr_app/ui/theme/theme_palette.dart';
import 'package:flutter/material.dart';

const String kClzPrimaryFontFamily = 'Gilroy';
const List<String> kClzFontFallback = ['Segoe UI', 'Roboto'];

ColorScheme buildAppColorScheme(AppThemePalette palette) {
  final base = ColorScheme.fromSeed(
    seedColor: palette.accent,
    brightness: palette.brightness,
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
    surfaceContainerHighest: palette.surfaceBright,
    outline: palette.divider,
    outlineVariant:
        palette.isDark ? const Color(0xFF373737) : const Color(0xFFD0D0D0),
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
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(color: palette.divider),
    ),
    titleTextStyle: TextStyle(
      color: palette.textPrimary,
      fontSize: 18,
      fontWeight: FontWeight.w900,
    ),
    contentTextStyle: TextStyle(color: palette.textPrimary),
  );
}

PopupMenuThemeData buildAppPopupMenuTheme(AppThemePalette palette) {
  return PopupMenuThemeData(
    color: palette.panelRaised,
    surfaceTintColor: Colors.transparent,
    textStyle: TextStyle(color: palette.textPrimary),
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
    textStyle: TextStyle(color: palette.textPrimary),
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
      foregroundColor: palette.textPrimary,
      side: BorderSide(color: palette.divider),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      visualDensity: VisualDensity.compact,
    ),
  );
}

IconButtonThemeData buildAppIconButtonTheme(
    {bool compact = false, AppThemePalette palette = kDefaultAppThemePalette}) {
  final hoverOverlay = Color.alphaBlend(
    palette.accent.withValues(alpha: palette.isDark ? 0.24 : 0.14),
    palette.surfaceSubtle,
  );
  final pressedOverlay = Color.alphaBlend(
    palette.accent.withValues(alpha: palette.isDark ? 0.30 : 0.18),
    palette.surfaceSubtle,
  );
  return IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: palette.textPrimary,
      backgroundColor:
          palette.isDark ? const Color(0xFF343434) : palette.surfaceSubtle,
      disabledForegroundColor: palette.isDark
          ? const Color(0xFF777777)
          : palette.textMuted.withValues(alpha: 0.7),
      disabledBackgroundColor:
          palette.isDark ? const Color(0xFF252525) : palette.toolbar,
      hoverColor: hoverOverlay,
      highlightColor: pressedOverlay,
      overlayColor: pressedOverlay,
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
    textStyle: WidgetStatePropertyAll(TextStyle(color: palette.textPrimary)),
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
    backgroundColor:
        palette.isDark ? const Color(0xFF343434) : palette.surfaceSubtle,
    selectedColor: palette.selection,
    labelStyle: TextStyle(color: palette.textPrimary),
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
    iconButtonTheme:
        buildAppIconButtonTheme(compact: compact, palette: palette),
    inputDecorationTheme:
        inputDecorationTheme ?? buildAppInputDecorationTheme(palette),
    searchBarTheme: buildAppSearchBarTheme(palette),
    chipTheme: buildAppChipTheme(base, palette),
    datePickerTheme: buildAppDatePickerTheme(palette: palette),
    textTheme: base.textTheme
        .apply(
          fontFamily: kClzPrimaryFontFamily,
          fontFamilyFallback: kClzFontFallback,
          bodyColor: palette.textPrimary,
          displayColor: palette.textPrimary,
        )
        .copyWith(
          titleLarge: base.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
          titleMedium: base.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.1,
          ),
          titleSmall: base.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.05,
          ),
          bodyLarge: base.textTheme.bodyLarge?.copyWith(
            fontSize: 15,
            height: 1.35,
          ),
          bodyMedium: base.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            height: 1.3,
          ),
          bodySmall: base.textTheme.bodySmall?.copyWith(
            fontSize: 13,
            height: 1.25,
          ),
          labelLarge: base.textTheme.labelLarge?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.15,
          ),
          labelMedium: base.textTheme.labelMedium?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.05,
          ),
          labelSmall: base.textTheme.labelSmall?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.04,
          ),
        ),
  );
}
