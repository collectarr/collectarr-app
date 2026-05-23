import 'package:flutter/material.dart';

@immutable
class AppThemePalette {
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
