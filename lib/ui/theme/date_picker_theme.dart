import 'package:collectarr_app/ui/theme/theme_palette.dart';
import 'package:flutter/material.dart';

DatePickerThemeData buildAppDatePickerTheme({
  AppThemePalette palette = kDefaultAppThemePalette,
  Color? accent,
  Color? surface,
}) {
  final resolvedAccent = accent ?? palette.accent;
  final resolvedSurface = surface ?? palette.panel;
  final selectedFill = resolvedAccent.withValues(alpha: 0.22);
  return DatePickerThemeData(
    backgroundColor: resolvedSurface,
    surfaceTintColor: Colors.transparent,
    elevation: 16,
    shape: RoundedRectangleBorder(
      borderRadius: palette.menuBorderRadius,
      side: BorderSide(color: palette.divider),
    ),
    headerBackgroundColor: resolvedAccent,
    headerForegroundColor: Colors.white,
    dividerColor: palette.divider,
    weekdayStyle: TextStyle(
      color: palette.textMuted,
      fontWeight: FontWeight.w700,
    ),
    dayStyle: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
    ),
    yearStyle: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
    ),
    dayForegroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return Colors.white.withValues(alpha: 0.32);
      }
      return Colors.white;
    }),
    dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return resolvedAccent;
      }
      if (states.contains(WidgetState.hovered)) {
        return selectedFill;
      }
      return Colors.transparent;
    }),
    todayForegroundColor: const WidgetStatePropertyAll(Colors.white),
    todayBorder: BorderSide(color: resolvedAccent),
    yearForegroundColor: const WidgetStatePropertyAll(Colors.white),
    yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return resolvedAccent;
      }
      if (states.contains(WidgetState.hovered)) {
        return selectedFill;
      }
      return Colors.transparent;
    }),
    rangePickerBackgroundColor: resolvedSurface,
    rangePickerSurfaceTintColor: Colors.transparent,
    rangePickerHeaderBackgroundColor: resolvedAccent,
    rangePickerHeaderForegroundColor: Colors.white,
    rangeSelectionBackgroundColor: selectedFill,
  );
}
