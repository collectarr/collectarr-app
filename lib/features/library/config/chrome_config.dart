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
    this.menuAddsManually = false,
  });

  final bool canScanCover;
  final bool supportsTracking;
  final List<LibraryAddKindFilterOption> kindFilterOptions;
  final Set<LibraryAddSearchScope> defaultKindFilters;

  /// A fixed "Confirm your selection" sheet, centred at the bottom, for kinds
  /// whose preview is short; null spans the dialog at 65 % of its height.
  final Size? confirmSheetSize;

  /// The main menu offers "Add ... Manually" beside "Add ... from Core", as
  /// the reference Comics menu does.
  final bool menuAddsManually;
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
