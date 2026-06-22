import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

const kLibraryToolbarCompactDropdownSize = 28.0;
const kLibraryToolbarCompactDropdownWidth = 38.0;
const kLibraryToolbarBandHeight = 38.0;
const kLibraryToolbarControlHeight = 28.0;
const kLibraryToolbarTextDropdownHeight = 30.0;
const kLibraryToolbarPopupItemHeight = 32.0;
const kLibraryToolbarPopupSectionHeaderHeight = 20.0;
const kLibraryDenseControlHeight = 32.0;

Color libraryToolbarMenuSurface(BuildContext context) => Color.alphaBlend(
      Colors.black.withValues(alpha: 0.05),
      appPalette(context).panelRaised,
    );

Color libraryToolbarMenuBorder(BuildContext context) =>
    appPalette(context).divider.withValues(alpha: 0.95);

Color libraryToolbarMenuText(BuildContext context) =>
    appPalette(context).textPrimary;

Color libraryToolbarMenuMutedText(BuildContext context) =>
    appPalette(context).textMuted;

Color libraryToolbarMenuHover(BuildContext context) => Color.alphaBlend(
      appPalette(context).textPrimary.withValues(
            alpha: appPalette(context).isDark ? 0.14 : 0.08,
          ),
      libraryToolbarMenuSurface(context),
    );

Color libraryToolbarControlSurface(BuildContext context) => Color.alphaBlend(
      Colors.white.withValues(alpha: 0.015),
      appPalette(context).toolbar,
    );

Color libraryToolbarControlBorder(BuildContext context) =>
    appPalette(context).divider.withValues(alpha: 0.75);

Color libraryToolbarControlHover(BuildContext context) => Color.alphaBlend(
      appPalette(context).textPrimary.withValues(
            alpha: appPalette(context).isDark ? 0.12 : 0.07,
          ),
      libraryToolbarControlSurface(context),
    );

Color libraryWorkspaceSelectionBackground(
  BuildContext context, {
  required Color accentColor,
  Color? baseColor,
}) {
  final palette = appPalette(context);
  final resolvedAccent =
      accentColor == kAppAccent ? palette.accent : accentColor;
  return Color.alphaBlend(
    resolvedAccent.withValues(alpha: palette.isDark ? 0.24 : 0.14),
    baseColor ?? palette.cardBackground,
  );
}

Color librarySelectionToolbarSurface(BuildContext context) => Color.alphaBlend(
      appPalette(context).textPrimary.withValues(
            alpha: appPalette(context).isDark ? 0.07 : 0.04,
          ),
      appPalette(context).toolbar,
    );

Color librarySelectionToolbarBorder(BuildContext context) =>
    appPalette(context).divider.withValues(
          alpha: appPalette(context).isDark ? 0.92 : 0.82,
        );

Color librarySelectionToolbarPrimaryAction(BuildContext context) =>
    Color.alphaBlend(
      appPalette(context).accent.withValues(
            alpha: appPalette(context).isDark ? 0.34 : 0.18,
          ),
      librarySelectionToolbarSurface(context),
    );

Color librarySelectionToolbarSecondaryAction(BuildContext context) =>
    Color.alphaBlend(
      appPalette(context).textPrimary.withValues(
            alpha: appPalette(context).isDark ? 0.12 : 0.08,
          ),
      librarySelectionToolbarSurface(context),
    );

Color librarySelectionToolbarCountChip(BuildContext context) =>
    Color.alphaBlend(
      appPalette(context).textPrimary.withValues(
            alpha: appPalette(context).isDark ? 0.16 : 0.09,
          ),
      librarySelectionToolbarSurface(context),
    );

Color libraryToolbarControlText(BuildContext context) =>
    appPalette(context).textPrimary;

Color libraryToolbarControlMutedText(BuildContext context) =>
    appPalette(context).textMuted;
