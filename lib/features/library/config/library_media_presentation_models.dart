import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_widgets.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LibraryMediaSearchFieldLabels {
  const LibraryMediaSearchFieldLabels({
    required this.queryHint,
    required this.emptySearchMessage,
    required this.seriesHint,
    required this.numberHint,
    required this.publisherHint,
  });

  final String queryHint;
  final String emptySearchMessage;
  final String seriesHint;
  final String numberHint;
  final String publisherHint;
}

class LibraryMediaFilterLabels {
  const LibraryMediaFilterLabels({
    required this.series,
    required this.anySeries,
    required this.publisher,
    required this.anyPublisher,
    this.year = 'Year',
    this.anyYear = 'Any year',
  });

  final String series;
  final String anySeries;
  final String publisher;
  final String anyPublisher;
  final String year;
  final String anyYear;
}

class LibraryMediaGroupLabels {
  const LibraryMediaGroupLabels({
    required this.series,
    required this.seriesPlural,
    required this.unknownSeries,
    required this.publisher,
    required this.publisherPlural,
    required this.unknownPublisher,
    String? publisherMode,
    this.genre = 'Genre',
    this.genrePlural = 'Genres',
  }) : publisherMode = publisherMode ?? publisher;

  final String series;
  final String seriesPlural;
  final String unknownSeries;
  final String publisher;
  final String publisherPlural;
  final String unknownPublisher;
  final String publisherMode;
  final String genre;
  final String genrePlural;
}

class LibraryMediaPreviewLabels {
  const LibraryMediaPreviewLabels({
    required this.series,
    required this.itemCount,
  });

  final String series;
  final String itemCount;
}

class LibraryMediaStatsLabels {
  const LibraryMediaStatsLabels({
    this.topSeries = 'Top Series',
    this.topPublisher = 'Top Publishers',
  });

  final String topSeries;
  final String topPublisher;
}

enum LibrarySortFieldGroup { main, value, edition, personal }

class LibraryGroupModeDefinition {
  const LibraryGroupModeDefinition({
    required this.mode,
    required this.label,
    required this.sidebarTitle,
    required this.icon,
    this.supportsBucketManagement = false,
    this.bucketManagerListLabel,
  });

  final LibraryGroupMode mode;
  final String label;
  final String sidebarTitle;
  final IconData icon;
  final bool supportsBucketManagement;
  final String? bucketManagerListLabel;

  String get resolvedBucketManagerListLabel =>
      bucketManagerListLabel ?? '$label list';
}

class LibrarySortColumnDefinition {
  const LibrarySortColumnDefinition({
    required this.column,
    required this.label,
    this.group = LibrarySortFieldGroup.main,
    this.defaultAscending = true,
  });

  final LibrarySortColumn column;
  final String label;
  final LibrarySortFieldGroup group;
  final bool defaultAscending;
}

class LibraryFilterOptionLabels {
  const LibraryFilterOptionLabels({
    this.ownershipAll = 'All items',
    this.ownershipOwned = 'Owned only',
    this.ownershipWishlist = 'Wishlist only',
    this.ownershipMissingGrade = 'Missing grade',
    this.ownershipForSale = 'For sale',
    this.ownershipOnOrder = 'On order',
    this.trackingAny = 'Any tracking status',
    this.trackingNotTracked = 'Not tracked',
    this.loanAny = 'Any loan status',
    this.loanOnLoan = 'Currently on loan',
    this.loanAvailable = 'Available locally',
    this.dateUpdated = 'Updated',
    this.datePurchased = 'Purchased',
    this.dateStarted = 'Started',
    this.dateFinished = 'Finished',
  });

  final String ownershipAll;
  final String ownershipOwned;
  final String ownershipWishlist;
  final String ownershipMissingGrade;
  final String ownershipForSale;
  final String ownershipOnOrder;
  final String trackingAny;
  final String trackingNotTracked;
  final String loanAny;
  final String loanOnLoan;
  final String loanAvailable;
  final String dateUpdated;
  final String datePurchased;
  final String dateStarted;
  final String dateFinished;
}

class LibraryReferenceLabels {
  const LibraryReferenceLabels({
    this.itemScope = 'Media',
    this.editionScope = 'Edition',
    this.variantScope = 'Physical release',
    this.bundleScope = 'Bundle',
    this.bundleHierarchy = 'Bundle release',
    this.editionHierarchy = 'Edition',
    this.variantHierarchy = 'Physical',
  });

  final String itemScope;
  final String editionScope;
  final String variantScope;
  final String bundleScope;
  final String bundleHierarchy;
  final String editionHierarchy;
  final String variantHierarchy;

  String get ownedAsItem => 'Owned as ${itemScope.toLowerCase()}';
  String get ownedAsEdition => 'Owned as ${editionScope.toLowerCase()}';
  String get ownedAsVariant => 'Owned as ${variantScope.toLowerCase()}';
  String get ownedAsBundle => 'Owned as ${bundleScope.toLowerCase()}';
  String get wishlistedAsItem => 'Wishlisted as ${itemScope.toLowerCase()}';
  String get wishlistedAsEdition =>
      'Wishlisted as ${editionScope.toLowerCase()}';
  String get wishlistedAsVariant =>
      'Wishlisted as ${variantScope.toLowerCase()}';
  String get wishlistedAsBundle =>
      'Wishlisted as ${bundleScope.toLowerCase()}';
}

class LibraryStatusLabels {
  const LibraryStatusLabels({
    this.owned = 'Owned',
    this.tracked = 'Tracked',
    this.wishlist = 'Wishlist',
    this.localCatalog = 'Local catalog',
  });

  final String owned;
  final String tracked;
  final String wishlist;
  final String localCatalog;
}

class LibraryAddSearchResultDisplay {
  const LibraryAddSearchResultDisplay({
    required this.title,
    required this.secondaryLine,
    required this.detailLine,
  });

  final String title;
  final String? secondaryLine;
  final String? detailLine;
}

class LibrarySortFavorite {
  const LibrarySortFavorite({
    required this.id,
    required this.label,
    required this.icon,
    required this.rules,
  });

  final String id;
  final String label;
  final IconData icon;
  final List<LibrarySortRule> rules;
}

const defaultLibrarySortFavorites = [
  LibrarySortFavorite(
    id: 'title_asc',
    label: 'Title A-Z',
    icon: Icons.sort_by_alpha,
    rules: [
      LibrarySortRule(column: LibrarySortColumn.title, ascending: true),
    ],
  ),
  LibrarySortFavorite(
    id: 'release_latest',
    label: 'Latest release',
    icon: Icons.event,
    rules: [
      LibrarySortRule(column: LibrarySortColumn.releaseDate, ascending: false),
      LibrarySortRule(column: LibrarySortColumn.title, ascending: true),
    ],
  ),
  LibrarySortFavorite(
    id: 'recent',
    label: 'Recently added',
    icon: Icons.update,
    rules: [
      LibrarySortRule(column: LibrarySortColumn.updated, ascending: false),
      LibrarySortRule(column: LibrarySortColumn.title, ascending: true),
    ],
  ),
  LibrarySortFavorite(
    id: 'value_desc',
    label: 'Value high to low',
    icon: Icons.attach_money,
    rules: [
      LibrarySortRule(column: LibrarySortColumn.price, ascending: false),
      LibrarySortRule(column: LibrarySortColumn.title, ascending: true),
    ],
  ),
];

const defaultLibraryColumnFavorites = [
  LibraryTableColumnPreset(
    label: 'Essential',
    columns: {
      LibraryTableColumn.status,
      LibraryTableColumn.title,
      LibraryTableColumn.publisher,
      LibraryTableColumn.releaseDate,
      LibraryTableColumn.updated,
    },
  ),
  LibraryTableColumnPreset(
    label: 'Collection',
    columns: {
      LibraryTableColumn.status,
      LibraryTableColumn.title,
      LibraryTableColumn.condition,
      LibraryTableColumn.grade,
      LibraryTableColumn.price,
      LibraryTableColumn.wishlist,
      LibraryTableColumn.updated,
    },
  ),
  LibraryTableColumnPreset(
    label: 'Reference',
    columns: {
      LibraryTableColumn.status,
      LibraryTableColumn.title,
      LibraryTableColumn.variant,
      LibraryTableColumn.publisher,
      LibraryTableColumn.releaseDate,
      LibraryTableColumn.barcode,
      LibraryTableColumn.updated,
    },
  ),
];

const kSharedSortColumnDefinitionsWithoutSeriesPublisher = [
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.status,
    label: 'Status',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.title,
    label: 'Title',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.issue,
    label: 'Issue / number',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.storyArc,
    label: 'Story arc',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.variant,
    label: 'Variant',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.format,
    label: 'Format',
    group: LibrarySortFieldGroup.edition,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.releaseDate,
    label: 'Release date',
    defaultAscending: false,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.barcode,
    label: 'Barcode',
    group: LibrarySortFieldGroup.edition,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.grade,
    label: 'Grade',
    group: LibrarySortFieldGroup.value,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.condition,
    label: 'Condition',
    group: LibrarySortFieldGroup.value,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.price,
    label: 'Purchase price',
    group: LibrarySortFieldGroup.value,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.location,
    label: 'Storage box',
    group: LibrarySortFieldGroup.personal,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.collectionStatus,
    label: 'Collection status',
    group: LibrarySortFieldGroup.personal,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.wishlist,
    label: 'Wishlist',
    group: LibrarySortFieldGroup.personal,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.added,
    label: 'Added date',
    group: LibrarySortFieldGroup.personal,
    defaultAscending: false,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.updated,
    label: 'Updated',
    group: LibrarySortFieldGroup.personal,
    defaultAscending: false,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.country,
    label: 'Country',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.language,
    label: 'Language',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.pageCount,
    label: 'Page count',
    group: LibrarySortFieldGroup.edition,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.ageRating,
    label: 'Age rating',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.imprint,
    label: 'Imprint',
  ),
];

const kSharedComicOnlySortColumnDefinitions = [
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.rawOrSlabbed,
    label: 'Raw / slabbed',
    group: LibrarySortFieldGroup.edition,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.gradingCompany,
    label: 'Grading company',
    group: LibrarySortFieldGroup.edition,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.keyComic,
    label: 'Key comic',
  ),
];

class LibraryMetadataPresentation {
  const LibraryMetadataPresentation({
    required this.identityFacts,
    required this.contextFacts,
    required this.creators,
    required this.characters,
    required this.storyArcs,
    required this.genres,
  });

  final List<LibraryInspectorFactData> identityFacts;
  final List<LibraryInspectorFactData> contextFacts;
  final List<Map<String, dynamic>> creators;
  final List<String> characters;
  final List<String> storyArcs;
  final List<String> genres;

  List<LibraryInspectorFactData> get allFacts => [
        ...identityFacts,
        ...contextFacts,
      ];

  bool get hasCredits =>
      creators.isNotEmpty || characters.isNotEmpty || storyArcs.isNotEmpty;
}

typedef LibraryMetadataFactTapResolver = VoidCallback? Function(String? value);

abstract class LibraryMediaPresentationBuilder {
  const LibraryMediaPresentationBuilder();

  LibraryAddSearchResultDisplay? buildSearchResultDisplay({
    required LibraryMetadataItem item,
  }) {
    return null;
  }

  Widget? buildAddPreviewPane({
    required BuildContext context,
    required Color accent,
    required String singularLabel,
    required MediaEditFields mediaFields,
    required ReleaseEditFields releaseFields,
    required LibraryMediaPreviewLabels previewLabels,
    required LibraryMetadataItem? item,
    required ProviderCandidate? candidate,
    required AdminProviderPreview? preview,
    required bool isFetchingPreview,
    required String providerLabel,
  }) {
    return null;
  }

  LibraryMetadataPresentation buildMetadataPresentation({
    required String singularLabel,
    required MediaEditFields mediaFields,
    required ReleaseEditFields releaseFields,
    required LibraryWorkspaceEntry entry,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  });

  List<Widget> buildInspectorSections({
    required BuildContext context,
    required LibraryWorkspaceEntry entry,
    required Color accent,
  }) {
    return const [];
  }

  Widget buildDetailIdentitySection({
    required BuildContext context,
    required String singularLabel,
    required MediaEditFields mediaFields,
    required ReleaseEditFields releaseFields,
    required LibraryWorkspaceEntry entry,
    required Color accent,
    ValueChanged<String>? onFilterByValue,
  }) {
    final presentation = buildMetadataPresentation(
      singularLabel: singularLabel,
      mediaFields: mediaFields,
      releaseFields: releaseFields,
      entry: entry,
      includeIdentityFacts: true,
      tapFor: _tapResolver(onFilterByValue),
    );
    final series = entry.series;
    final identityFacts = presentation.identityFacts.map((fact) {
      if (fact.label == 'Series' &&
          series?.seriesId != null &&
          series!.seriesId!.trim().isNotEmpty &&
          series.seriesTitle != null &&
          series.seriesTitle!.trim().isNotEmpty) {
        return LibraryInspectorFactData(
          fact.label,
          fact.value,
          onTap: () => context.push(
            '/series/${Uri.encodeComponent(series.seriesId!)}?title=${Uri.encodeQueryComponent(series.seriesTitle!)}',
          ),
        );
      }
      return fact;
    }).toList(growable: false);
    return LibraryInspectorSection(
      title: 'Catalog identity',
      accentColor: accent,
      children: [
        LibraryInspectorFactGrid(facts: identityFacts),
      ],
    );
  }

  Widget buildDetailContextSection({
    required BuildContext context,
    required String singularLabel,
    required MediaEditFields mediaFields,
    required ReleaseEditFields releaseFields,
    required LibraryWorkspaceEntry entry,
    required Color accent,
    ValueChanged<String>? onFilterByValue,
  }) {
    final presentation = buildMetadataPresentation(
      singularLabel: singularLabel,
      mediaFields: mediaFields,
      releaseFields: releaseFields,
      entry: entry,
      includeIdentityFacts: false,
      tapFor: _tapResolver(onFilterByValue),
    );
    return LibraryInspectorSection(
      title: 'Catalog context',
      accentColor: accent,
      children: [
        LibraryInspectorFactGrid(facts: presentation.contextFacts),
        if (presentation.genres.isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryInspectorChipWrap(
            label: 'Genres',
            values: presentation.genres,
            onValueTap: onFilterByValue,
          ),
        ],
      ],
    );
  }

  Widget buildDetailCreditsSection({
    required BuildContext context,
    required String singularLabel,
    required MediaEditFields mediaFields,
    required ReleaseEditFields releaseFields,
    required LibraryWorkspaceEntry entry,
    required Color accent,
    ValueChanged<String>? onFilterByValue,
  }) {
    final presentation = buildMetadataPresentation(
      singularLabel: singularLabel,
      mediaFields: mediaFields,
      releaseFields: releaseFields,
      entry: entry,
      includeIdentityFacts: false,
      tapFor: _tapResolver(onFilterByValue),
    );
    if (!presentation.hasCredits) {
      return const SizedBox.shrink();
    }
    return LibraryInspectorSection(
      title: 'Credits & Discovery',
      accentColor: accent,
      children: [
        if (presentation.creators.isNotEmpty)
          LibraryMetadataCreditsList(
            title: 'Creators',
            credits: presentation.creators,
            onValueTap: (value) => context.push(
              '/creator/${Uri.encodeComponent(value)}',
            ),
          ),
        if (presentation.characters.isNotEmpty) ...[
          if (presentation.creators.isNotEmpty) const SizedBox(height: 8),
          LibraryInspectorChipWrap(
            label: 'Characters',
            values: presentation.characters,
            onValueTap: (value) => context.push(
              '/character/${Uri.encodeComponent(value)}',
            ),
          ),
        ],
        if (presentation.storyArcs.isNotEmpty) ...[
          if (presentation.creators.isNotEmpty ||
              presentation.characters.isNotEmpty)
            const SizedBox(height: 8),
          LibraryInspectorChipWrap(
            label: 'Story Arcs',
            values: presentation.storyArcs,
            onValueTap: (value) => context.push(
              '/story-arc/${Uri.encodeComponent(value)}',
            ),
          ),
        ],
      ],
    );
  }

  static LibraryMetadataFactTapResolver _tapResolver(
    ValueChanged<String>? onFilterByValue,
  ) {
    return (String? value) {
      if (onFilterByValue == null || value == null || value.trim().isEmpty) {
        return null;
      }
      return () => onFilterByValue(value.trim());
    };
  }
}

class LibraryMediaPresentation {
  const LibraryMediaPresentation({
    required this.searchFieldLabels,
    required this.filterLabels,
    required this.groupLabels,
    required this.builder,
    this.defaultVisibleColumns = const {
      LibraryTableColumn.status,
      LibraryTableColumn.cover,
      LibraryTableColumn.title,
      LibraryTableColumn.publisher,
      LibraryTableColumn.releaseDate,
      LibraryTableColumn.barcode,
      LibraryTableColumn.condition,
      LibraryTableColumn.price,
      LibraryTableColumn.location,
      LibraryTableColumn.wishlist,
      LibraryTableColumn.updated,
    },
    this.previewLabels = const LibraryMediaPreviewLabels(
      series: 'Series',
      itemCount: 'Items',
    ),
    this.statsLabels = const LibraryMediaStatsLabels(),
    this.usesTreeProviderCandidates = false,
    this.externalFacetBucketModes = const [],
    this.supportsSeriesIssueJump = false,
    this.compactBucketIcon = Icons.folder,
    this.emptyStateProviderSummarySuffix = '',
    this.sortFavorites = defaultLibrarySortFavorites,
    this.columnFavorites = defaultLibraryColumnFavorites,
    this.filterOptionLabels = const LibraryFilterOptionLabels(),
    this.referenceLabels = const LibraryReferenceLabels(),
    this.statusLabels = const LibraryStatusLabels(),
    required this.sortColumnDefinitions,
    required this.groupModeDefinitions,
    required this.groupModes,
  });

  final LibraryMediaSearchFieldLabels searchFieldLabels;
  final LibraryMediaFilterLabels filterLabels;
  final LibraryMediaGroupLabels groupLabels;
  final LibraryMediaPresentationBuilder builder;
  final Set<LibraryTableColumn> defaultVisibleColumns;
  final LibraryMediaPreviewLabels previewLabels;
  final LibraryMediaStatsLabels statsLabels;
  final bool usesTreeProviderCandidates;
  final List<LibraryGroupMode> externalFacetBucketModes;
  final bool supportsSeriesIssueJump;
  final IconData compactBucketIcon;
  final String emptyStateProviderSummarySuffix;
  final List<LibrarySortFavorite> sortFavorites;
  final List<LibraryTableColumnPreset> columnFavorites;
  final LibraryFilterOptionLabels filterOptionLabels;
  final LibraryReferenceLabels referenceLabels;
  final LibraryStatusLabels statusLabels;
  final List<LibraryGroupModeDefinition> groupModeDefinitions;
  final List<LibrarySortColumnDefinition> sortColumnDefinitions;
  final List<LibraryGroupMode> groupModes;

  LibraryGroupModeDefinition groupModeDefinitionFor(LibraryGroupMode mode) {
    for (final definition in groupModeDefinitions) {
      if (definition.mode == mode) {
        return definition;
      }
    }
    throw StateError(
      'Missing group mode definition for $mode. '
      'Ensure groupModeDefinitions declares every mode from groupModes.',
    );
  }

  LibrarySortColumnDefinition sortColumnDefinitionFor(
    LibrarySortColumn column,
  ) {
    for (final definition in sortColumnDefinitions) {
      if (definition.column == column) {
        return definition;
      }
    }
    throw StateError(
      'Missing sort column definition for $column. '
      'Ensure sortColumnDefinitions declares every available sort column.',
    );
  }
}
