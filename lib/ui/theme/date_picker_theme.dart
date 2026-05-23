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
  final hoverFill = resolvedAccent.withValues(alpha: 0.14);
  final headerBackground = Color.alphaBlend(
    resolvedAccent.withValues(alpha: 0.24),
    palette.panelRaised,
  );
  final dialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
    side: BorderSide(color: palette.divider),
  );
  final dayShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  );
  return DatePickerThemeData(
    backgroundColor: resolvedSurface,
    surfaceTintColor: Colors.transparent,
    elevation: 20,
    shadowColor: Colors.black.withValues(alpha: 0.42),
    shape: dialogShape,
    headerBackgroundColor: headerBackground,
    headerForegroundColor: Colors.white,
    headerHeadlineStyle: const TextStyle(
      color: Colors.white,
      fontSize: 28,
      fontWeight: FontWeight.w900,
      letterSpacing: -0.4,
    ),
    headerHelpStyle: TextStyle(
      color: Colors.white.withValues(alpha: 0.72),
      fontSize: 12,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.8,
    ),
    dividerColor: palette.divider,
    weekdayStyle: TextStyle(
      color: palette.textMuted,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.8,
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
      if (states.contains(WidgetState.focused)) {
        return resolvedAccent.withValues(alpha: 0.22);
      }
      if (states.contains(WidgetState.hovered)) {
        return selectedFill;
      }
      return Colors.transparent;
    }),
    dayOverlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white.withValues(alpha: 0.10);
      }
      if (states.contains(WidgetState.focused) ||
          states.contains(WidgetState.hovered) ||
          states.contains(WidgetState.pressed)) {
        return hoverFill;
      }
      return Colors.transparent;
    }),
    dayShape: WidgetStatePropertyAll(dayShape),
    todayForegroundColor: const WidgetStatePropertyAll(Colors.white),
    todayBackgroundColor: WidgetStatePropertyAll(
      resolvedAccent.withValues(alpha: 0.16),
    ),
    todayBorder: BorderSide(color: resolvedAccent),
    yearForegroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return Colors.white.withValues(alpha: 0.88);
    }),
    yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return resolvedAccent;
      }
      if (states.contains(WidgetState.focused)) {
        return resolvedAccent.withValues(alpha: 0.20);
      }
      if (states.contains(WidgetState.hovered)) {
        return selectedFill;
      }
      return Colors.transparent;
    }),
    yearOverlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white.withValues(alpha: 0.08);
      }
      if (states.contains(WidgetState.hovered) ||
          states.contains(WidgetState.focused) ||
          states.contains(WidgetState.pressed)) {
        return hoverFill;
      }
      return Colors.transparent;
    }),
    yearShape: WidgetStatePropertyAll(dayShape),
    rangePickerBackgroundColor: resolvedSurface,
    rangePickerSurfaceTintColor: Colors.transparent,
    rangePickerElevation: 20,
    rangePickerShadowColor: Colors.black.withValues(alpha: 0.42),
    rangePickerShape: dialogShape,
    rangePickerHeaderBackgroundColor: headerBackground,
    rangePickerHeaderForegroundColor: Colors.white,
    rangePickerHeaderHeadlineStyle: const TextStyle(
      color: Colors.white,
      fontSize: 28,
      fontWeight: FontWeight.w900,
      letterSpacing: -0.4,
    ),
    rangePickerHeaderHelpStyle: TextStyle(
      color: Colors.white.withValues(alpha: 0.72),
      fontSize: 12,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.8,
    ),
    rangeSelectionBackgroundColor: selectedFill,
    rangeSelectionOverlayColor: WidgetStatePropertyAll(hoverFill),
    cancelButtonStyle: TextButton.styleFrom(
      foregroundColor: Colors.white.withValues(alpha: 0.78),
      textStyle: const TextStyle(fontWeight: FontWeight.w800),
    ),
    confirmButtonStyle: FilledButton.styleFrom(
      backgroundColor: resolvedAccent,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontWeight: FontWeight.w800),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
