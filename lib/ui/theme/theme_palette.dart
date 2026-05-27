import 'package:flutter/material.dart';

@immutable
class AppThemePalette extends ThemeExtension<AppThemePalette> {
  const AppThemePalette({
    required this.topBar,
    required this.toolbar,
    required this.panel,
    required this.panelRaised,
    required this.canvas,
    required this.gridCanvas,
    required this.accent,
    required this.selection,
    required this.highlight,
    required this.divider,
    required this.textMuted,
    required this.tableOddRow,
    required this.tableEvenRow,
    required this.tableBottomBorder,
    required this.tableHover,
    required this.field,
    required this.menuBorderRadius,
    this.brightness = Brightness.dark,
    this.textPrimary = Colors.white,
    this.cardBackground = kAppCardBackground,
    this.cardBorder = kAppCardBorder,
    this.surface = kAppSurface,
    this.surfaceDim = kAppSurfaceDim,
    this.surfaceBright = kAppSurfaceBright,
    this.surfaceSubtle = kAppSurfaceSubtle,
    this.textSecondary = kAppTextSecondary,
    this.badgeBackground = kAppBadgeBackground,
  });

  final Color topBar;
  final Color toolbar;
  final Color panel;
  final Color panelRaised;
  final Color canvas;
  final Color gridCanvas;
  final Color accent;
  final Color selection;
  final Color highlight;
  final Color divider;
  final Color textMuted;
  final Color tableOddRow;
  final Color tableEvenRow;
  final Color tableBottomBorder;
  final Color tableHover;
  final Color field;
  final BorderRadius menuBorderRadius;
  final Brightness brightness;
  final Color textPrimary;
  final Color cardBackground;
  final Color cardBorder;
  final Color surface;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceSubtle;
  final Color textSecondary;
  final Color badgeBackground;

  bool get isDark => brightness == Brightness.dark;

  @override
  AppThemePalette copyWith({
    Color? topBar,
    Color? toolbar,
    Color? panel,
    Color? panelRaised,
    Color? canvas,
    Color? gridCanvas,
    Color? accent,
    Color? selection,
    Color? highlight,
    Color? divider,
    Color? textMuted,
    Color? tableOddRow,
    Color? tableEvenRow,
    Color? tableBottomBorder,
    Color? tableHover,
    Color? field,
    BorderRadius? menuBorderRadius,
    Brightness? brightness,
    Color? textPrimary,
    Color? cardBackground,
    Color? cardBorder,
    Color? surface,
    Color? surfaceDim,
    Color? surfaceBright,
    Color? surfaceSubtle,
    Color? textSecondary,
    Color? badgeBackground,
  }) {
    return AppThemePalette(
      topBar: topBar ?? this.topBar,
      toolbar: toolbar ?? this.toolbar,
      panel: panel ?? this.panel,
      panelRaised: panelRaised ?? this.panelRaised,
      canvas: canvas ?? this.canvas,
      gridCanvas: gridCanvas ?? this.gridCanvas,
      accent: accent ?? this.accent,
      selection: selection ?? this.selection,
      highlight: highlight ?? this.highlight,
      divider: divider ?? this.divider,
      textMuted: textMuted ?? this.textMuted,
      tableOddRow: tableOddRow ?? this.tableOddRow,
      tableEvenRow: tableEvenRow ?? this.tableEvenRow,
      tableBottomBorder: tableBottomBorder ?? this.tableBottomBorder,
      tableHover: tableHover ?? this.tableHover,
      field: field ?? this.field,
      menuBorderRadius: menuBorderRadius ?? this.menuBorderRadius,
      brightness: brightness ?? this.brightness,
      textPrimary: textPrimary ?? this.textPrimary,
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      surface: surface ?? this.surface,
      surfaceDim: surfaceDim ?? this.surfaceDim,
      surfaceBright: surfaceBright ?? this.surfaceBright,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      textSecondary: textSecondary ?? this.textSecondary,
      badgeBackground: badgeBackground ?? this.badgeBackground,
    );
  }

  @override
  AppThemePalette lerp(covariant AppThemePalette? other, double t) {
    if (other == null) return this;
    return AppThemePalette(
      topBar: Color.lerp(topBar, other.topBar, t)!,
      toolbar: Color.lerp(toolbar, other.toolbar, t)!,
      panel: Color.lerp(panel, other.panel, t)!,
      panelRaised: Color.lerp(panelRaised, other.panelRaised, t)!,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      gridCanvas: Color.lerp(gridCanvas, other.gridCanvas, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      selection: Color.lerp(selection, other.selection, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      tableOddRow: Color.lerp(tableOddRow, other.tableOddRow, t)!,
      tableEvenRow: Color.lerp(tableEvenRow, other.tableEvenRow, t)!,
      tableBottomBorder:
          Color.lerp(tableBottomBorder, other.tableBottomBorder, t)!,
      tableHover: Color.lerp(tableHover, other.tableHover, t)!,
      field: Color.lerp(field, other.field, t)!,
      menuBorderRadius:
          BorderRadius.lerp(menuBorderRadius, other.menuBorderRadius, t)!,
      brightness: t < 0.5 ? brightness : other.brightness,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceDim: Color.lerp(surfaceDim, other.surfaceDim, t)!,
      surfaceBright: Color.lerp(surfaceBright, other.surfaceBright, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      badgeBackground: Color.lerp(badgeBackground, other.badgeBackground, t)!,
    );
  }
}

const kAppTopBar = Color(0xFF4DBBD5);
const kAppToolbar = Color(0xFF2B2B2B);
const kAppPanel = Color(0xFF1D1D1D);
const kAppPanelRaised = Color(0xFF2F2F2F);
const kAppCanvas = Color(0xFF141414);
const kAppGridCanvas = Color(0xFF202020);
const kAppAccent = Color(0xFF10A8D8);
const kAppSelection = Color(0xFF075F75);
const kAppHighlight = Color(0xFFFFD400);
const kAppDivider = Color(0xFF4A4A4A);
const kAppTextMuted = Color(0xFFB8B8B8);
const kAppTableOddRow = Color(0xFF202428);
const kAppTableEvenRow = Color(0xFF181B1E);
const kAppTableBottomBorder = Color(0xFF2E2E2E);
const kAppTableHover = Color(0xFF263940);
const kAppField = Color(0xFF101010);
const kAppMenuBorderRadius = BorderRadius.all(Radius.circular(6));

// ── Extended surface & card tokens ──────────────────────────────────────────
const kAppCardBackground = Color(0xFF181818);
const kAppCardBorder = Color(0xFF363636);
const kAppSurface = Color(0xFF303030);
const kAppSurfaceDim = Color(0xFF151515);
const kAppSurfaceBright = Color(0xFF3A3A3A);
const kAppSurfaceSubtle = Color(0xFF2A2A2A);
const kAppAccentLight = Color(0xFF82DDF2);
const kAppTextSecondary = Color(0xFF9A9A9A);
const kAppBorderSubtle = Color(0xFF4B4B4B);
const kAppBadgeBackground = Color(0xFF444444);
const kAppOverdueBackground = Color(0xFF5A2100);
const kAppOverdueBorder = Color(0xFFFFA352);
const kAppOverdueText = Color(0xFFFFC47A);

// ── Standard radii ──────────────────────────────────────────────────────────
const kAppRadiusSmall = BorderRadius.all(Radius.circular(4));
const kAppRadiusMedium = BorderRadius.all(Radius.circular(8));
const kAppRadiusLarge = BorderRadius.all(Radius.circular(12));

// ── Standard animation durations ────────────────────────────────────────────
const kAppAnimFast = Duration(milliseconds: 150);
const kAppAnimNormal = Duration(milliseconds: 300);
const kAppAnimSlow = Duration(milliseconds: 450);

// ── Responsive layout breakpoints ───────────────────────────────────────────
/// Below this width the sidebar is hidden and layout enters compact mode.
const double kAppCompactBreakpoint = 640;

/// Below this width the details pane moves from right to bottom.
const double kAppSpacedBreakpoint = 860;

/// Below this width inspector and edit dialogs stack vertically.
const double kAppStackedBreakpoint = 560;

// ── Semantic status banner colors ───────────────────────────────────────────
const kAppBannerErrorBackground = Color(0xFF4A2630);
const kAppBannerErrorBorder = Color(0xFF9D5D69);
const kAppBannerErrorIcon = Color(0xFFFFB4C0);
const kAppBannerErrorText = Color(0xFFFFD9DF);
const kAppBannerInfoBackground = Color(0xFF183246);
const kAppBannerWarningBackground = Color(0xFF3F3A1A);

// ── Add-dialog & mode-bar tokens ────────────────────────────────────────────
const kAppTextBright = Color(0xFFEDEDED);
const kAppTextHint = Color(0xFF9EA9B0);
const kAppFieldDark = Color(0xFF111111);

const kDefaultAppThemePalette = AppThemePalette(
  topBar: kAppTopBar,
  toolbar: kAppToolbar,
  panel: kAppPanel,
  panelRaised: kAppPanelRaised,
  canvas: kAppCanvas,
  gridCanvas: kAppGridCanvas,
  accent: kAppAccent,
  selection: kAppSelection,
  highlight: kAppHighlight,
  divider: kAppDivider,
  textMuted: kAppTextMuted,
  tableOddRow: kAppTableOddRow,
  tableEvenRow: kAppTableEvenRow,
  tableBottomBorder: kAppTableBottomBorder,
  tableHover: kAppTableHover,
  field: kAppField,
  menuBorderRadius: kAppMenuBorderRadius,
);

const kLightAppThemePalette = AppThemePalette(
  brightness: Brightness.light,
  topBar: Color(0xFF0D8AB0),
  toolbar: Color(0xFFF0F0F0),
  panel: Color(0xFFFFFFFF),
  panelRaised: Color(0xFFF5F5F5),
  canvas: Color(0xFFF8F8F8),
  gridCanvas: Color(0xFFEFEFEF),
  accent: Color(0xFF0D8AB0),
  selection: Color(0xFFBDE5F2),
  highlight: Color(0xFFE6A800),
  divider: Color(0xFFD0D0D0),
  textMuted: Color(0xFF707070),
  tableOddRow: Color(0xFFF6F8FA),
  tableEvenRow: Color(0xFFFFFFFF),
  tableBottomBorder: Color(0xFFE0E0E0),
  tableHover: Color(0xFFE0F2F8),
  field: Color(0xFFFFFFFF),
  menuBorderRadius: kAppMenuBorderRadius,
  textPrimary: Color(0xFF1A1A1A),
  cardBackground: Color(0xFFFFFFFF),
  cardBorder: Color(0xFFD8D8D8),
  surface: Color(0xFFE8E8E8),
  surfaceDim: Color(0xFFF0F0F0),
  surfaceBright: Color(0xFFFFFFFF),
  surfaceSubtle: Color(0xFFF2F2F2),
  textSecondary: Color(0xFF808080),
  badgeBackground: Color(0xFFD0D0D0),
);

/// Resolve the active [AppThemePalette] from [context].
/// Falls back to [kDefaultAppThemePalette] when no extension is present.
AppThemePalette appPalette(BuildContext context) {
  return Theme.of(context).extension<AppThemePalette>() ??
      kDefaultAppThemePalette;
}
