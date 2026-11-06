import 'package:flutter/widgets.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';

@immutable
class LibraryAddSearchScope {
  const LibraryAddSearchScope({
    required this.kind,
    required this.catalogValue,
  });

  final CatalogMediaKind kind;
  final String catalogValue;

  @override
  bool operator ==(Object other) =>
      other is LibraryAddSearchScope &&
      other.kind == kind &&
      other.catalogValue == catalogValue;

  @override
  int get hashCode => Object.hash(kind, catalogValue);
}

class LibraryEditChromeConfig {
  const LibraryEditChromeConfig({
    this.titleUsesItemTitle = false,
    this.showsIssueBadge = false,
    this.showsPhysicalFormatBadge = false,
  });

  final bool titleUsesItemTitle;
  final bool showsIssueBadge;
  final bool showsPhysicalFormatBadge;
}

class LibraryAddChromeConfig {
  const LibraryAddChromeConfig({
    this.canScanCover = true,
    this.supportsTracking = true,
    this.kindFilterOptions = const [],
    this.defaultKindFilters = const {},
    this.confirmSheetSize,
    this.dialogTitle,
    this.plainManualAdd = false,
    this.resultTickBoxes = true,
  });

  final bool canScanCover;
  final bool supportsTracking;
  final List<LibraryAddKindFilterOption> kindFilterOptions;
  final Set<LibraryAddSearchScope> defaultKindFilters;

  /// A fixed "Confirm your selection" sheet, centred at the bottom, for kinds
  /// whose preview is short; null spans the dialog at 65 % of its height.
  final Size? confirmSheetSize;

  /// Replaces the dialog's default "Add ... By:" title.
  final String? dialogTitle;

  /// Add Manually as in the reference: titled "Add game manually", starting
  /// empty rather than from the search text, with Cancel and Add buttons.
  final bool plainManualAdd;

  /// Whether search result rows offer a tick box; without one a row opens
  /// the confirm sheet and adds a single item.
  final bool resultTickBoxes;
}

class LibraryAddKindFilterOption {
  const LibraryAddKindFilterOption({
    required this.scope,
    required this.label,
    required this.icon,
  });

  final LibraryAddSearchScope scope;
  final String label;
  final IconData icon;
}
