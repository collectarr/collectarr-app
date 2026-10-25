import 'package:collectarr_app/features/library/ui/library_metrics.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Shared edit-dialog building blocks used across library edit dialogs.
// ---------------------------------------------------------------------------

const Color kEditAccent = kAppAccent;
const Color kEditPanelRaised = kAppPanelRaised;
const Color kEditDivider = kAppDivider;
const Color kEditTextMuted = kAppTextMuted;

/// Style size whose floating label (scaled to 75%) paints at 13 px.
const double kEditFloatingLabelStyleSize = 13 / 0.75;
const Color kEditChartBar = kAppAccentLight;

/// Saved CLZ editor surfaces, scoped to dialogs rather than the workspace.
AppThemePalette libraryEditPalette(AppThemePalette palette) => palette.isDark
    ? palette.copyWith(
        panel: const Color(0xFF262626),
        panelRaised: const Color(0xFF383838),
        surfaceBright: const Color(0xFF383838),
        surface: const Color(0xFF444444),
        field: const Color(0xFF444444),
        toolbar: const Color(0xFF383838),
        divider: const Color(0xFF606060),
      )
    : palette.copyWith(
        panel: const Color(0xFFF6F6F6),
        panelRaised: Colors.white,
        surfaceBright: Colors.white,
        field: Colors.white,
        toolbar: Colors.white,
        divider: const Color(0xFFDDDDDD),
      );

/// Theme preset for edit dialogs – resolves from [palette] for light/dark.
ThemeData editDialogTheme({
  Color? seedColor,
  AppThemePalette palette = kDefaultAppThemePalette,
  bool compactDesktop = false,
}) {
  palette = libraryEditPalette(palette);
  final accent = seedColor ?? palette.accent;
  palette = palette.copyWith(
      accent: accent,
      selection:
          Color.alphaBlend(accent.withValues(alpha: 0.22), palette.panel));
  final base = palette.isDark
      ? ThemeData.dark(useMaterial3: true)
      : ThemeData.light(useMaterial3: true);
  return base.copyWith(
    extensions: [palette],
    // The reference has no press ripples anywhere.
    splashFactory: NoSplash.splashFactory,
    visualDensity: VisualDensity.standard,
    tooltipTheme: buildAppTooltipTheme(palette),
    canvasColor: palette.panel,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      brightness: palette.brightness,
      surface: palette.panel,
    ).copyWith(
      primary: accent,
      onPrimary: appContrastingTextColor(accent),
    ),
    textSelectionTheme: buildAppTextSelectionTheme(palette),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.panel,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: palette.panelRaised,
      surfaceTintColor: Colors.transparent,
      textStyle: buildAppPopupMenuTheme(palette).textStyle,
      mouseCursor: appClickableMouseCursor,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: kAppMenuBorderRadius,
        side: BorderSide(color: palette.divider),
      ),
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(palette.panelRaised),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: kAppMenuBorderRadius,
            side: BorderSide(color: palette.divider),
          ),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.isDark ? const Color(0xFF444444) : palette.field,
      isDense: true,
      // Outline and fill follow the content height, so the padding makes
      // the 34 px reference field; the constraint alone does not.
      contentPadding: EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 7,
      ),
      constraints: const BoxConstraints(
        minHeight: LibraryMetrics.defaultFieldHeight,
      ),
      floatingLabelBehavior: compactDesktop
          ? FloatingLabelBehavior.always
          : FloatingLabelBehavior.auto,
      // A floating label is painted at 75% of its style size, so the style is
      // enlarged to draw the reference's 13 px label.
      labelStyle: TextStyle(
        color: palette.textPrimary.withValues(alpha: 0.7),
        fontSize: compactDesktop ? kEditFloatingLabelStyleSize : 13,
        fontWeight: kAppBoldFontWeight,
      ),
      floatingLabelStyle: TextStyle(
        color: palette.textPrimary.withValues(alpha: 0.7),
        fontSize: compactDesktop ? kEditFloatingLabelStyleSize : 13,
        fontWeight: kAppBoldFontWeight,
      ),
      hintStyle: TextStyle(
        color: palette.textMuted.withValues(alpha: 0.7),
        fontSize: compactDesktop ? 13 : null,
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: palette.divider),
        borderRadius: BorderRadius.circular(kAppInputBorderRadius),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: palette.divider),
        borderRadius: BorderRadius.circular(kAppInputBorderRadius),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: palette.utilityAction, width: 2),
        borderRadius: BorderRadius.circular(kAppInputBorderRadius),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ).copyWith(mouseCursor: WidgetStateMouseCursor.clickable),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ).copyWith(mouseCursor: WidgetStateMouseCursor.clickable),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ).copyWith(mouseCursor: WidgetStateMouseCursor.clickable),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ).copyWith(mouseCursor: WidgetStateMouseCursor.clickable),
    ),
    iconButtonTheme: const IconButtonThemeData(
      style: ButtonStyle(mouseCursor: WidgetStateMouseCursor.clickable),
    ),
    textTheme: base.textTheme
        .copyWith(
          bodyLarge: base.textTheme.bodyLarge?.copyWith(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: kAppNormalFontWeight,
              letterSpacing: 0),
          bodyMedium: base.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: kAppNormalFontWeight,
              letterSpacing: 0),
          labelLarge: base.textTheme.labelLarge?.copyWith(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: kAppNormalFontWeight,
              letterSpacing: 0),
        )
        .apply(
          fontFamily: appFontFamily,
          fontFamilyFallback: kAppFontFamilyFallback,
          bodyColor: palette.textPrimary,
          displayColor: palette.textPrimary,
        ),
    datePickerTheme: buildAppDatePickerTheme(
      palette: palette,
      accent: accent,
      surface: palette.panel,
    ),
  );
}

// ---------------------------------------------------------------------------
// Tab shell – scrollable content with optional cover sidebar
// ---------------------------------------------------------------------------
