import 'package:flutter/widgets.dart';

const String _fontPackage = 'font_awesome_flutter';
const String _solid = 'FontAwesomeSolid';
const String _regular = 'FontAwesomeRegular';

/// Central catalog of icons for the Collectarr app matching CLZ Web parity.
///
/// Exposes native [IconData] instances so all widgets across the codebase
/// can consume standard [Icon] widgets with compile-time constants.
abstract final class AppIcons {
  // --- Navigation & Drawer ---
  static const IconData menu =
      IconData(0xf0c9, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData add =
      IconData(0x2b, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData pickLists =
      IconData(0xf022, fontFamily: _regular, fontPackage: _fontPackage);
  static const IconData collections =
      IconData(0xf51e, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData libraries =
      IconData(0xf009, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData print =
      IconData(0xf02f, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData statistics =
      IconData(0xe0e3, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData duplicates =
      IconData(0xf24d, fontFamily: _regular, fontPackage: _fontPackage);
  static const IconData loans =
      IconData(0xf017, fontFamily: _regular, fontPackage: _fontPackage);
  static const IconData calendar =
      IconData(0xf073, fontFamily: _regular, fontPackage: _fontPackage);
  static const IconData admin =
      IconData(0xf3ed, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData customFields =
      IconData(0xf044, fontFamily: _regular, fontPackage: _fontPackage);
  static const IconData cloudSharing =
      IconData(0xf1e0, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData prefill =
      IconData(0xf573, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData settings =
      IconData(0xf013, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData reassignIndex =
      IconData(0xf162, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData backupRestore =
      IconData(0xf0a0, fontFamily: _regular, fontPackage: _fontPackage);
  static const IconData clearDatabase =
      IconData(0xf2ed, fontFamily: _regular, fontPackage: _fontPackage);
  static const IconData transferFieldData =
      IconData(0xe4c0, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData exportCsv =
      IconData(0xf56e, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData exportXml =
      IconData(0xf56e, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData importData =
      IconData(0xf56f, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData link =
      IconData(0xf0c1, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData keyboard =
      IconData(0xf11c, fontFamily: _regular, fontPackage: _fontPackage);

  // --- Controls & Dialogs ---
  static const IconData chevronDown =
      IconData(0xf078, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData chevronLeft =
      IconData(0xf053, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData chevronRight =
      IconData(0xf054, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData caretLeft =
      IconData(0xf0d9, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData caretRight =
      IconData(0xf0da, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData close =
      IconData(0xf00d, fontFamily: _solid, fontPackage: _fontPackage);

  // --- Selection & Toolbar Actions ---
  static const IconData selectAll =
      IconData(0xf14a, fontFamily: _regular, fontPackage: _fontPackage);
  static const IconData selectNone =
      IconData(0xf0c8, fontFamily: _regular, fontPackage: _fontPackage);
  static const IconData edit =
      IconData(0xf044, fontFamily: _regular, fontPackage: _fontPackage);
  static const IconData delete =
      IconData(0xf2ed, fontFamily: _regular, fontPackage: _fontPackage);
  static const IconData merge =
      IconData(0xf066, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData updateFromCore =
      IconData(0xf0ed, fontFamily: _solid, fontPackage: _fontPackage);

  // --- Sorting & View Controls ---
  static const IconData sortAlpha =
      IconData(0xf15d, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData sortCount =
      IconData(0xf160, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData viewList =
      IconData(0xf0c9, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData viewHorizontalCards =
      IconData(0xf03a, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData viewCovers =
      IconData(0xf00a, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData viewShelves =
      IconData(0xf468, fontFamily: _solid, fontPackage: _fontPackage);
  static const String viewVerticalCardsSvg = 'assets/icons/cards-black.svg';

  // --- Search Scope Targets ---
  static const IconData searchAll =
      IconData(0xf1c0, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData searchMedia =
      IconData(0xf51f, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData searchTracks =
      IconData(0xf001, fontFamily: _solid, fontPackage: _fontPackage);

  // --- Edit Dialog Tabs ---
  static const IconData tabMain =
      IconData(0xf001, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData tabDetails =
      IconData(0xf05a, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData tabCredits =
      IconData(0xf500, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData tabTracks =
      IconData(0xf0cb, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData tabPersonal =
      IconData(0xf007, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData tabCustomFields =
      IconData(0xf044, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData tabCovers =
      IconData(0xf030, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData tabImages =
      IconData(0xf03e, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData tabLinks =
      IconData(0xf0c1, fontFamily: _solid, fontPackage: _fontPackage);
}
