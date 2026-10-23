import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Paints [child] with the dark skin in both themes.
///
/// The light theme lightens only content areas; toolbars, pane headers,
/// draggers and collection tabs stay dark, as in the reference. The current
/// kind accent carries over.
class AppDarkChrome extends StatelessWidget {
  const AppDarkChrome({super.key, this.accent, required this.child});

  /// Overrides the scope's kind accent.
  final Color? accent;
  final Widget child;

  /// Whether [context] is dark chrome over light content. The reference
  /// light skin keeps its search fields white inside dark toolbars.
  static bool overLightContent(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_OverLightContent>() != null;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    if (palette.isDark) return child;
    final accent = this.accent ??
        LibraryAccentScope.accentOf(context, fallback: palette.accent);
    final darkPalette = kDefaultAppThemePalette.copyWith(
      accent: accent,
      selection: Color.alphaBlend(
          accent.withValues(alpha: 0.22), kDefaultAppThemePalette.panel),
    );
    final darkTheme = buildLibraryAccentTheme(
        buildAppShellTheme(palette: darkPalette), accent);
    // Popups opened from the dark chrome follow the light content, as the
    // reference's white toolbar menus do.
    final ink = palette.textPrimary;
    final itemText = WidgetStatePropertyAll(
        (darkTheme.textTheme.bodyMedium ?? const TextStyle())
            .copyWith(color: ink));
    final theme = darkTheme.copyWith(
      popupMenuTheme: darkTheme.popupMenuTheme.copyWith(
        color: palette.panelRaised,
        surfaceTintColor: Colors.transparent,
        textStyle: TextStyle(color: ink),
        labelTextStyle: itemText,
        iconColor: ink,
      ),
      menuButtonTheme: MenuButtonThemeData(
        style:
            (darkTheme.menuButtonTheme.style ?? const ButtonStyle()).copyWith(
          foregroundColor: WidgetStatePropertyAll(ink),
          iconColor: WidgetStatePropertyAll(ink),
          textStyle: itemText,
        ),
      ),
    );
    return Theme(
      data: theme,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: darkPalette.textPrimary),
        child: IconTheme.merge(
          data: IconThemeData(color: darkPalette.textPrimary),
          child: _OverLightContent(child: child),
        ),
      ),
    );
  }
}

// An InheritedTheme, so popups opened from the chrome still know that the
// content is light.
class _OverLightContent extends InheritedTheme {
  const _OverLightContent({required super.child});

  @override
  Widget wrap(BuildContext context, Widget child) =>
      _OverLightContent(child: child);

  @override
  bool updateShouldNotify(_OverLightContent oldWidget) => false;
}
