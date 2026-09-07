import 'package:flutter/widgets.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';

enum LibraryAddVideoSearchScope {
  movie,
  collection,
  tv,
  anime;

  CatalogMediaKind get catalogKind => switch (this) {
        LibraryAddVideoSearchScope.movie ||
        LibraryAddVideoSearchScope.collection =>
          CatalogMediaKind.movie,
        LibraryAddVideoSearchScope.tv => CatalogMediaKind.tv,
        LibraryAddVideoSearchScope.anime => CatalogMediaKind.anime,
      };

  String get providerValue => name;
}

class LibraryEditChromeConfig {
  const LibraryEditChromeConfig({
    this.titleUsesItemTitle = false,
    this.synopsisLabel = 'Synopsis',
    this.showsIssueBadge = false,
    this.showsPhysicalFormatBadge = false,
  });

  final bool titleUsesItemTitle;
  final String synopsisLabel;
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
    this.videoKindFilterOptions = const [],
    this.defaultVideoKindFilters = const {},
  });

  final bool canScanCover;
  final String mediaReferenceLabel;
  final String trackScopeSummary;
  final String mediaReferenceHelperLabel;
  final String editionReferenceHelperLabel;
  final List<LibraryAddVideoKindFilterOption> videoKindFilterOptions;
  final Set<LibraryAddVideoSearchScope> defaultVideoKindFilters;
}

class LibraryAddVideoKindFilterOption {
  const LibraryAddVideoKindFilterOption({
    required this.scope,
    required this.label,
    required this.icon,
  });

  final LibraryAddVideoSearchScope scope;
  final String label;
  final IconData icon;
}
