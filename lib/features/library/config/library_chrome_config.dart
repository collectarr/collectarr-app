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
    this.kindFilterOptions = const [],
    this.defaultKindFilters = const {},
  });

  final bool canScanCover;
  final List<LibraryAddKindFilterOption> kindFilterOptions;
  final Set<LibraryAddSearchScope> defaultKindFilters;
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
