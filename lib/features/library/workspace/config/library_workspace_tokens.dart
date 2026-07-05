import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';

const kLibraryToolbarCompactDropdownSize = 28.0;
const kLibraryToolbarCompactDropdownWidth = 38.0;
const kLibraryToolbarBandHeight = 38.0;
const kLibraryToolbarControlHeight = 28.0;
const kLibraryToolbarTextDropdownHeight = 30.0;
const kLibraryToolbarPopupItemHeight = 32.0;
const kLibraryToolbarPopupSectionHeaderHeight = 20.0;
const kLibraryDenseControlHeight = 32.0;

class LibraryWorkspaceDensityScope extends InheritedWidget {
  const LibraryWorkspaceDensityScope({
    super.key,
    required this.densityPreset,
    required super.child,
  });

  final LibraryWorkspaceDensityPreset densityPreset;

  static LibraryWorkspaceDensityPreset of(BuildContext context) {
    return maybeOf(context) ?? LibraryWorkspaceDensityPreset.compact;
  }

  static LibraryWorkspaceDensityPreset? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LibraryWorkspaceDensityScope>()
        ?.densityPreset;
  }

  @override
  bool updateShouldNotify(covariant LibraryWorkspaceDensityScope oldWidget) {
    return oldWidget.densityPreset != densityPreset;
  }
}

extension LibraryWorkspaceDensityPresetMetrics
    on LibraryWorkspaceDensityPreset {
  String get label {
    return switch (this) {
      LibraryWorkspaceDensityPreset.comfortable => 'Comfortable',
      LibraryWorkspaceDensityPreset.compact => 'Compact',
      LibraryWorkspaceDensityPreset.ultraCompact => 'Spreadsheet',
    };
  }

  IconData get icon {
    return switch (this) {
      LibraryWorkspaceDensityPreset.comfortable => Icons.density_medium,
      LibraryWorkspaceDensityPreset.compact => Icons.density_small,
      LibraryWorkspaceDensityPreset.ultraCompact => Icons.table_rows,
    };
  }

  String get tooltip {
    return switch (this) {
      LibraryWorkspaceDensityPreset.comfortable => 'Comfortable density',
      LibraryWorkspaceDensityPreset.compact => 'Compact density',
      LibraryWorkspaceDensityPreset.ultraCompact => 'Spreadsheet density',
    };
  }

  double get coverGridHeightFactor {
    return switch (this) {
      LibraryWorkspaceDensityPreset.comfortable => 1.62,
      LibraryWorkspaceDensityPreset.compact => 1.5,
      LibraryWorkspaceDensityPreset.ultraCompact => 1.34,
    };
  }

  double get cardScaleFactor {
    return switch (this) {
      LibraryWorkspaceDensityPreset.comfortable => 1.0,
      LibraryWorkspaceDensityPreset.compact => 0.93,
      LibraryWorkspaceDensityPreset.ultraCompact => 0.86,
    };
  }

  double get cardFlowScaleFactor {
    return switch (this) {
      LibraryWorkspaceDensityPreset.comfortable => 1.0,
      LibraryWorkspaceDensityPreset.compact => 0.96,
      LibraryWorkspaceDensityPreset.ultraCompact => 0.92,
    };
  }

  double get tableHeaderHeight {
    return switch (this) {
      LibraryWorkspaceDensityPreset.comfortable => 30.0,
      LibraryWorkspaceDensityPreset.compact => 28.0,
      LibraryWorkspaceDensityPreset.ultraCompact => 26.0,
    };
  }

  double get tableRowHeight {
    return switch (this) {
      LibraryWorkspaceDensityPreset.comfortable => 38.0,
      LibraryWorkspaceDensityPreset.compact => 34.0,
      LibraryWorkspaceDensityPreset.ultraCompact => 30.0,
    };
  }

  double get inspectorSectionSpacing {
    return switch (this) {
      LibraryWorkspaceDensityPreset.comfortable => 8.0,
      LibraryWorkspaceDensityPreset.compact => 6.0,
      LibraryWorkspaceDensityPreset.ultraCompact => 4.0,
    };
  }

  double get inspectorSectionContentTopPadding {
    return switch (this) {
      LibraryWorkspaceDensityPreset.comfortable => 6.0,
      LibraryWorkspaceDensityPreset.compact => 5.0,
      LibraryWorkspaceDensityPreset.ultraCompact => 3.0,
    };
  }

  double get inspectorSectionTitleSize {
    return switch (this) {
      LibraryWorkspaceDensityPreset.comfortable => 12.0,
      LibraryWorkspaceDensityPreset.compact => 11.5,
      LibraryWorkspaceDensityPreset.ultraCompact => 11.0,
    };
  }

  double get inspectorFactLabelSize {
    return switch (this) {
      LibraryWorkspaceDensityPreset.comfortable => 11.0,
      LibraryWorkspaceDensityPreset.compact => 10.5,
      LibraryWorkspaceDensityPreset.ultraCompact => 10.0,
    };
  }

  double get inspectorFactValueSize {
    return switch (this) {
      LibraryWorkspaceDensityPreset.comfortable => 11.0,
      LibraryWorkspaceDensityPreset.compact => 10.5,
      LibraryWorkspaceDensityPreset.ultraCompact => 10.0,
    };
  }

  EdgeInsetsGeometry get inspectorSectionPadding {
    return switch (this) {
      LibraryWorkspaceDensityPreset.comfortable =>
        const EdgeInsets.fromLTRB(10, 8, 10, 8),
      LibraryWorkspaceDensityPreset.compact =>
        const EdgeInsets.fromLTRB(9, 7, 9, 7),
      LibraryWorkspaceDensityPreset.ultraCompact =>
        const EdgeInsets.fromLTRB(8, 6, 8, 6),
    };
  }

  double get inspectorFactLabelWidth {
    return switch (this) {
      LibraryWorkspaceDensityPreset.comfortable => 104.0,
      LibraryWorkspaceDensityPreset.compact => 96.0,
      LibraryWorkspaceDensityPreset.ultraCompact => 88.0,
    };
  }

  double get inspectorOuterGap {
    return switch (this) {
      LibraryWorkspaceDensityPreset.comfortable => 8.0,
      LibraryWorkspaceDensityPreset.compact => 6.0,
      LibraryWorkspaceDensityPreset.ultraCompact => 4.0,
    };
  }
}

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
