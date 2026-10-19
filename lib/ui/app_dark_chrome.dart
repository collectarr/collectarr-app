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
    final theme = buildLibraryAccentTheme(
        buildAppShellTheme(palette: darkPalette), accent);
    return Theme(
      data: theme,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: darkPalette.textPrimary),
        child: IconTheme.merge(
          data: IconThemeData(color: darkPalette.textPrimary),
          child: child,
        ),
      ),
    );
  }
}
