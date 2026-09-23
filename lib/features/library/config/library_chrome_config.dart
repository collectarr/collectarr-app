import 'package:flutter/widgets.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';

@immutable
class LibraryAddSearchScope {
  const LibraryAddSearchScope({
    required this.kind,
    required this.providerValue,
  });

  final CatalogMediaKind kind;
  final String providerValue;

  @override
  bool operator ==(Object other) =>
      other is LibraryAddSearchScope &&
      other.kind == kind &&
      other.providerValue == providerValue;

  @override
  int get hashCode => Object.hash(kind, providerValue);
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
    this.mediaReferenceLabel = 'Media',
    this.trackScopeSummary =
        'Tracking stays item-centric here. Edition and bundle scope are only available for owned or wishlist entries.',
    this.mediaReferenceHelperLabel = 'Track or save the canonical item itself.',
    this.editionReferenceHelperLabel =
        'Attach ownership to a specific edition. Pick a variant only if you want one exact physical version.',
    this.kindFilterOptions = const [],
    this.defaultKindFilters = const {},
  });

  final bool canScanCover;
  final String mediaReferenceLabel;
  final String trackScopeSummary;
  final String mediaReferenceHelperLabel;
  final String editionReferenceHelperLabel;
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
