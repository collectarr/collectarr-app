import 'package:flutter/widgets.dart';

const String _fontPackage = 'font_awesome_flutter';
const String _solid = 'FontAwesomeSolid';
const String _regular = 'FontAwesomeRegular';

/// Central catalog of icons for the Collectarr app matching CLZ Web parity.
///
/// Exposes native [IconData] instances so all widgets across the codebase
/// can consume standard [Icon] widgets with compile-time constants.
abstract final class AppIcons {
  static const String appLogoPng = 'web/icons/Icon-maskable-192.png';
  static const IconData eye =
      IconData(0xf06e, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData eyeSlash =
      IconData(0xf070, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData collectionStatusAll =
      IconData(0xf187, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData collectionStatusForSale =
      IconData(0x24, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData collectionStatusWishList =
      IconData(0xf328, fontFamily: _regular, fontPackage: _fontPackage);
  static const IconData collectionStatusOnOrder =
      IconData(0xf07a, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData collectionStatusSold =
      IconData(0xf0e3, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData spinner =
      IconData(0xf1ce, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData minus =
      IconData(0xf068, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData coverIndicator =
      IconData(0xf111, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData collect =
      IconData(0xf055, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData unlink =
      IconData(0xf127, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData smartLists =
      IconData(0xf0b0, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData readingQueue =
      IconData(0xf02e, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData barcode =
      IconData(0xf02a, fontFamily: _solid, fontPackage: _fontPackage);
  static const String barcodeScanSvg = 'assets/icons/barcode-scan.svg';
  static const IconData compactDisc =
      IconData(0xf51f, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData book =
      IconData(0xf02d, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData tvScreen =
      IconData(0xf26c, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData film =
      IconData(0xf008, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData gamepad =
      IconData(0xf11b, fontFamily: _solid, fontPackage: _fontPackage);
  static const String collectionGamesSvg = 'assets/icons/collection-games.svg';
  static const String collectionHardwareSvg =
      'assets/icons/collection-hardware.svg';
  static const String collectionToysSvg = 'assets/icons/collection-toys.svg';
  static const String librarySwitcherSvg = 'assets/icons/library-switcher.svg';
  static const IconData bookOpen =
      IconData(0xf518, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData bookReader =
      IconData(0xf5da, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData photoFilm =
      IconData(0xf87c, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData dice =
      IconData(0xf522, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData camera =
      IconData(0xf030, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData warning =
      IconData(0xf071, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData circleExclamation =
      IconData(0xf06a, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData location =
      IconData(0xf3c5, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData sync =
      IconData(0xf2f1, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData tags =
      IconData(0xf02c, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData palette =
      IconData(0xf53f, fontFamily: _solid, fontPackage: _fontPackage);
  // --- Navigation & Drawer ---
  static const String communitySvg = 'assets/icons/community.svg';
  static const IconData contactSupport =
      IconData(0xf0e0, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData whatsNew =
      IconData(0xf059, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData userManual =
      IconData(0xf15c, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData menu =
      IconData(0xf0c9, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData add =
      IconData(0x2b, fontFamily: _solid, fontPackage: _fontPackage);
  static const String pickListManageSvg = 'assets/icons/pick-list-manage.svg';
  static const IconData folderOpen =
      IconData(0xf07c, fontFamily: _solid, fontPackage: _fontPackage);
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
      IconData(0xf24d, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData loans =
      IconData(0xf017, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData calendar =
      IconData(0xf073, fontFamily: _regular, fontPackage: _fontPackage);
  static const IconData admin =
      IconData(0xf3ed, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData customFieldPerson =
      IconData(0xf007, fontFamily: _regular, fontPackage: _fontPackage);
  static const IconData chevronUp =
      IconData(0xf106, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData customFieldHelp =
      IconData(0xf15c, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData customFieldDrag =
      IconData(0xf0c9, fontFamily: _solid, fontPackage: _fontPackage);
  static const String customFieldTextSvg = 'assets/icons/custom-field-text.svg';
  static const IconData customFieldDate =
      IconData(0xf133, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData customFieldText =
      IconData(0xf031, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData customFieldTextArea =
      IconData(0xf034, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData customFieldToggle =
      IconData(0xf205, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData customFieldCurrency =
      IconData(0xf3d1, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData customFieldPercentage =
      IconData(0x25, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData customFieldWeight =
      IconData(0xf5cd, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData customFieldSize =
      IconData(0xf546, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData customFieldPickList =
      IconData(0xf0ca, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData customFieldMultiPickList =
      IconData(0xf0ae, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData customFieldFixedList =
      IconData(0xf150, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData customFieldDuration =
      IconData(0xf017, fontFamily: _solid, fontPackage: _fontPackage);
  static const String customFieldsSvg = 'assets/icons/custom-fields.svg';
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
      IconData(0xf1f8, fontFamily: _solid, fontPackage: _fontPackage);
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

  static const IconData duplicateAction =
      IconData(0xf24d, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData removeAction =
      IconData(0xf1f8, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData loanAction =
      IconData(0xf017, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData moveCollection =
      IconData(0xf1c0, fontFamily: _solid, fontPackage: _fontPackage);
  // --- Selection & Toolbar Actions ---
  static const IconData selectAll =
      IconData(0xf14a, fontFamily: _regular, fontPackage: _fontPackage);
  static const IconData selectNone =
      IconData(0xf0c8, fontFamily: _regular, fontPackage: _fontPackage);
  static const IconData edit =
      IconData(0xf044, fontFamily: _regular, fontPackage: _fontPackage);
  static const IconData inlineEdit =
      IconData(0xf303, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData more =
      IconData(0xf142, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData caretDown =
      IconData(0xf0d7, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData caretUp =
      IconData(0xf0d8, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData delete =
      IconData(0xf2ed, fontFamily: _regular, fontPackage: _fontPackage);
  static const IconData merge =
      IconData(0xf066, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData updateFromCore =
      IconData(0xf0ed, fontFamily: _solid, fontPackage: _fontPackage);

  // --- Sorting & View Controls ---
  static const IconData check =
      IconData(0xf00c, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData toolbarTools =
      IconData(0xf1de, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData columns =
      IconData(0xf0db, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData windowMaximize =
      IconData(0xf2d0, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData windowRestore =
      IconData(0xf2d2, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData sortAscending =
      IconData(0xf30c, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData sortDescending =
      IconData(0xf309, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData sortAlpha =
      IconData(0xf15d, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData sortCount =
      IconData(0xf160, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData viewList =
      IconData(0xf0c9, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData viewHorizontalCards =
      IconData(0xf03a, fontFamily: _solid, fontPackage: _fontPackage);
  static const String viewCoversSvg = 'assets/icons/view-covers.svg';
  static const String viewShelvesSvg = 'assets/icons/view-shelves.svg';
  static const String viewVerticalCardsSvg = 'assets/icons/cards-black.svg';

  // --- Cover Actions ---
  static const IconData findOnline =
      IconData(0xf002, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData upload =
      IconData(0xf093, fontFamily: _solid, fontPackage: _fontPackage);

  // --- Settings sections ---
  static const IconData plug =
      IconData(0xf1e6, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData layerGroup =
      IconData(0xf5fd, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData clipboardCheck =
      IconData(0xf46c, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData database =
      IconData(0xf1c0, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData user =
      IconData(0xf007, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData logout =
      IconData(0xf2f5, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData login =
      IconData(0xf2f6, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData bug =
      IconData(0xf188, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData appUpdate =
      IconData(0xf0ab, fontFamily: _solid, fontPackage: _fontPackage);

  static const IconData paperPlane =
      IconData(0xf1d8, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData history =
      IconData(0xf1da, fontFamily: _solid, fontPackage: _fontPackage);

  // --- Rating ---
  static const IconData star =
      IconData(0xf005, fontFamily: _solid, fontPackage: _fontPackage);

  // --- Search ---
  static const IconData search =
      IconData(0xf002, fontFamily: _solid, fontPackage: _fontPackage);

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
  // Earth, as the reference's Links tab.
  static const IconData tabLinks =
      IconData(0xf57d, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData tabValue =
      IconData(0x24, fontFamily: _solid, fontPackage: _fontPackage);
  // Regular, as the reference's Description tab.
  static const IconData tabDescription =
      IconData(0xf15c, fontFamily: _regular, fontPackage: _fontPackage);
  static const IconData lock =
      IconData(0xf023, fontFamily: _solid, fontPackage: _fontPackage);
  static const IconData lockOpen =
      IconData(0xf3c1, fontFamily: _solid, fontPackage: _fontPackage);
}
