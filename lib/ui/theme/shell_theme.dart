import 'package:collectarr_app/ui/theme/theme_palette.dart';
import 'package:collectarr_app/ui/theme/theme_primitives.dart';
import 'package:flutter/material.dart';

ThemeData buildAppShellTheme({
  AppThemePalette palette = kDefaultAppThemePalette,
}) {
  final base = ThemeData.dark(useMaterial3: true);
  return applySharedSurfaceTheme(
    base,
    palette,
    compact: true,
    includeCanvasColor: true,
    includeDropdownInputDecoration: false,
    inputDecorationTheme: buildAppInputDecorationTheme(
      palette,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      labelStyle: TextStyle(color: palette.textMuted),
      hintStyle: TextStyle(color: palette.textMuted),
    ),
  ).copyWith(
    appBarTheme: AppBarTheme(
      backgroundColor: palette.topBar,
      foregroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 42,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: palette.toolbar,
      indicatorColor: palette.selection,
      height: 58,
      labelTextStyle: const WidgetStatePropertyAll(
        TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      iconTheme: const WidgetStatePropertyAll(
        IconThemeData(color: Colors.white, size: 20),
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
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
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
      labelColor: Colors.white,
      unselectedLabelColor: palette.textMuted,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),
    listTileTheme: const ListTileThemeData(
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 10),
      iconColor: Colors.white,
      textColor: Colors.white,
    ),
    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(palette.toolbar),
      dataRowColor: WidgetStatePropertyAll(palette.panel),
      dividerThickness: 1,
      headingTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
      ),
      dataTextStyle: const TextStyle(color: Colors.white),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: palette.panelRaised,
        border: Border.all(color: palette.divider),
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: const TextStyle(color: Colors.white, fontSize: 12),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: palette.panelRaised,
      contentTextStyle: const TextStyle(color: Colors.white),
    ),
  );
}
