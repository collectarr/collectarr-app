import 'package:collectarr_app/ui/theme/theme_palette.dart';
import 'package:collectarr_app/ui/theme/theme_primitives.dart';
import 'package:flutter/material.dart';

ThemeData buildAppShellTheme({
  AppThemePalette palette = kDefaultAppThemePalette,
}) {
  final base = palette.isDark
      ? ThemeData.dark(useMaterial3: true)
      : ThemeData.light(useMaterial3: true);
  final textColor = palette.textPrimary;
  return applySharedSurfaceTheme(
    base,
    palette,
    compact: true,
    includeCanvasColor: true,
    includeDropdownInputDecoration: false,
    inputDecorationTheme: buildAppInputDecorationTheme(
      palette,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      labelStyle: TextStyle(color: palette.textMuted),
      hintStyle: TextStyle(color: palette.textMuted),
    ),
  ).copyWith(
    extensions: [palette],
    appBarTheme: AppBarTheme(
      backgroundColor: palette.topBar,
      foregroundColor: textColor,
      elevation: 0,
      toolbarHeight: 42,
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: palette.toolbar,
      indicatorColor: palette.selection,
      height: 58,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      iconTheme: WidgetStatePropertyAll(
        IconThemeData(color: textColor, size: 20),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: palette.accent,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: palette.panel,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: palette.accent),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? palette.selection
              : palette.toolbar;
        }),
        foregroundColor: WidgetStatePropertyAll(textColor),
        side: WidgetStatePropertyAll(BorderSide(color: palette.divider)),
        visualDensity: VisualDensity.compact,
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      dividerColor: palette.divider,
      indicatorColor: palette.accent,
      labelColor: textColor,
      unselectedLabelColor: palette.textMuted,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),
    listTileTheme: ListTileThemeData(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      iconColor: textColor,
      textColor: textColor,
    ),
    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(palette.toolbar),
      dataRowColor: WidgetStatePropertyAll(palette.panel),
      dividerThickness: 1,
      headingTextStyle: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w800,
      ),
      dataTextStyle: TextStyle(color: textColor),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: palette.panelRaised,
        border: Border.all(color: palette.divider),
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: TextStyle(color: textColor, fontSize: 12),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: palette.panelRaised,
      contentTextStyle: TextStyle(color: textColor),
    ),
  );
}
