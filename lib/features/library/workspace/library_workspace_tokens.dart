import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

const kLibraryToolbarCompactDropdownSize = 30.0;
const kLibraryToolbarCompactDropdownWidth = 40.0;
const kLibraryToolbarTextDropdownHeight = 36.0;

Color libraryToolbarMenuSurface(BuildContext context) => Color.alphaBlend(
  Colors.black.withValues(alpha: 0.08),
  appPalette(context).panelRaised,
);

Color libraryToolbarMenuBorder(BuildContext context) =>
    appPalette(context).divider.withValues(alpha: 0.95);

Color libraryToolbarMenuText(BuildContext context) => appPalette(context).textPrimary;

Color libraryToolbarMenuMutedText(BuildContext context) =>
    appPalette(context).textMuted;

Color libraryToolbarMenuHover(BuildContext context) => Color.alphaBlend(
  Colors.white.withValues(alpha: 0.05),
  appPalette(context).surfaceSubtle,
);

Color libraryToolbarControlSurface(BuildContext context) => Color.alphaBlend(
  Colors.white.withValues(alpha: 0.03),
  appPalette(context).toolbar,
);

Color libraryToolbarControlBorder(BuildContext context) =>
    appPalette(context).divider.withValues(alpha: 0.75);

Color libraryToolbarControlHover(BuildContext context) =>
    appPalette(context).surfaceSubtle.withValues(alpha: 0.45);

Color libraryToolbarControlText(BuildContext context) => appPalette(context).textPrimary;

Color libraryToolbarControlMutedText(BuildContext context) =>
    appPalette(context).textMuted;
