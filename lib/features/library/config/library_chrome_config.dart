import 'package:flutter/widgets.dart';

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
  final Set<String> defaultVideoKindFilters;
}

class LibraryAddVideoKindFilterOption {
  const LibraryAddVideoKindFilterOption({
    required this.kind,
    required this.label,
    required this.icon,
  });

  final String kind;
  final String label;
  final IconData icon;
}
