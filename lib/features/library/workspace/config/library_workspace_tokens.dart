import 'package:collectarr_app/ui/app_dark_chrome.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';

// Shared paint for the folder panel and the collection browsing surface.
Color libraryWorkspaceBackgroundColor(BuildContext context) =>
    appPalette(context).panel;

// Behind covers, cards and flow. Lists use the skin's content surface;
// Shelves get their background from the shelf style.
Color libraryViewBackgroundColor(BuildContext context) =>
    appPalette(context).isDark
        ? const Color(0xFF131313)
        : appPalette(context).canvas;

// Toolbars, pane headers and draggers stay dark in both themes; wrap their
// controls in AppDarkChrome.
Color libraryWorkspaceToolbarColor(BuildContext context) => kAppToolbar;

Color libraryWorkspacePaneDividerColor(BuildContext context) =>
    const Color(0xff262626);

Border libraryWorkspaceToolbarBorder(BuildContext context) => Border(
      top: const BorderSide(color: kAppDivider),
      bottom: BorderSide(color: libraryWorkspacePaneDividerColor(context)),
    );

const kLibraryToolbarCompactDropdownSize = 28.0;
const kLibraryToolbarCompactDropdownWidth = 38.0;
const kLibraryToolbarBandHeight = 38.0;
const kLibraryToolbarControlHeight = 28.0;

/// The reference rounds every toolbar hover slightly.
const kLibraryToolbarHoverRadius = BorderRadius.all(Radius.circular(4));
const kLibraryToolbarTextDropdownHeight = 30.0;
const kLibraryToolbarPopupItemHeight = 32.0;
const kLibraryToolbarPopupSectionHeaderHeight = 20.0;
const kLibraryDenseControlHeight = 32.0;
const kLibraryCardTitleColor = Colors.white;
const kLibraryCardTitleIdle = Color(0xFFEBEBEB);
const kLibraryCardDetailIdle = Color(0xFF9E9E9E);

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
      LibraryWorkspaceDensityPreset.compact => 26.0,
      LibraryWorkspaceDensityPreset.ultraCompact => 26.0,
    };
  }

  double get tableRowHeight {
    return switch (this) {
      LibraryWorkspaceDensityPreset.comfortable => 32.0,
      LibraryWorkspaceDensityPreset.compact => 26.0,
      LibraryWorkspaceDensityPreset.ultraCompact => 22.0,
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

// Toolbar popups follow the content skin: the reference light skin opens
// white menus (#DDD border and hover, #333 text) from its dark toolbars.
AppThemePalette _toolbarMenuPalette(BuildContext context) =>
    AppDarkChrome.overLightContent(context)
        ? kLightAppThemePalette
        : appPalette(context);
Color libraryToolbarMenuSurface(BuildContext context) =>
    _toolbarMenuPalette(context).isDark
        ? const Color(0xff444444)
        : _toolbarMenuPalette(context).panelRaised;
Color libraryToolbarMenuBorder(BuildContext context) =>
    _toolbarMenuPalette(context).isDark
        ? const Color(0xff666666)
        : _toolbarMenuPalette(context).divider;

Color libraryToolbarMenuText(BuildContext context) =>
    _toolbarMenuPalette(context).textPrimary;
Color libraryToolbarMenuMutedText(BuildContext context) =>
    _toolbarMenuPalette(context).textMuted;
Color libraryToolbarMenuHover(BuildContext context) =>
    _toolbarMenuPalette(context).isDark
        ? const Color(0xff464950)
        : _toolbarMenuPalette(context).badgeBackground;
Color libraryToolbarControlSurface(BuildContext context) =>
    libraryWorkspaceToolbarColor(context);
Color libraryToolbarControlBorder(BuildContext context) =>
    appPalette(context).divider;
Color libraryToolbarControlHover(BuildContext context) =>
    appPalette(context).isDark
        ? const Color(0xff464950)
        : appPalette(context).panelRaised;

// The reference light list: white headings that turn #EEE when sorted, #DDD
// column rules, #F9F9F9 first-row stripes and a #F3F3F3 row hover.
Color libraryWorkspaceTableHeaderColor(BuildContext context) =>
    appPalette(context).isDark
        ? const Color(0xff464950)
        : appPalette(context).panelRaised;
Color libraryWorkspaceTableSortedHeaderColor(BuildContext context) =>
    appPalette(context).isDark
        ? libraryWorkspacePaneDividerColor(context)
        : appPalette(context).surface;
Color libraryWorkspaceTableDividerColor(BuildContext context) =>
    appPalette(context).isDark
        ? libraryWorkspacePaneDividerColor(context)
        : appPalette(context).divider;
Color libraryWorkspaceTableEvenRowColor(BuildContext context) =>
    appPalette(context).isDark
        ? appPalette(context).tableEvenRow
        : const Color(0xfff9f9f9);
Color libraryWorkspaceTableOddRowColor(BuildContext context) =>
    appPalette(context).isDark
        ? appPalette(context).tableOddRow
        : appPalette(context).panelRaised;
Color libraryWorkspaceTableHoverColor(BuildContext context) =>
    appPalette(context).isDark
        ? appPalette(context).surfaceBright
        : const Color(0xfff3f3f3);

Color libraryWorkspaceSelectionBackground(BuildContext context) =>
    appPalette(context).utilityAction;

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

Color librarySelectionToolbarSecondaryAction(BuildContext context) =>
    Color.alphaBlend(
      appPalette(context).textPrimary.withValues(
            alpha: appPalette(context).isDark ? 0.12 : 0.08,
          ),
      librarySelectionToolbarSurface(context),
    );

Color libraryToolbarControlText(BuildContext context) =>
    appPalette(context).textPrimary;

Color libraryToolbarControlMutedText(BuildContext context) =>
    appPalette(context).textMuted;
