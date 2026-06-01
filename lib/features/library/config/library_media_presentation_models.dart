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
    this.groupModeDefinitions = const [],
    this.sortColumnDefinitions = const [],
    this.groupModes = const [
      LibraryGroupMode.series,
      LibraryGroupMode.title,
      LibraryGroupMode.publisher,
      LibraryGroupMode.year,
      LibraryGroupMode.location,
      LibraryGroupMode.ownership,
    ],
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
    return _defaultLibraryGroupModeDefinition(mode, groupLabels);
  }

  LibrarySortColumnDefinition sortColumnDefinitionFor(
    LibrarySortColumn column,
  ) {
    for (final definition in sortColumnDefinitions) {
      if (definition.column == column) {
        return definition;
      }
    }
    return _defaultLibrarySortColumnDefinition(column, groupLabels);
  }
}

LibraryGroupModeDefinition _defaultLibraryGroupModeDefinition(
  LibraryGroupMode mode,
  LibraryMediaGroupLabels labels,
) {
  return switch (mode) {
    LibraryGroupMode.series => LibraryGroupModeDefinition(
        mode: mode,
        label: labels.series,
        sidebarTitle: labels.seriesPlural,
        icon: Icons.collections_bookmark_outlined,
      ),
    LibraryGroupMode.storyArc => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.storyArc,
        label: 'Story Arc',
        sidebarTitle: 'Story Arcs',
        icon: Icons.auto_stories_outlined,
        supportsBucketManagement: true,
      ),
    LibraryGroupMode.character => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.character,
        label: 'Character',
        sidebarTitle: 'Characters',
        icon: Icons.groups_2_outlined,
        supportsBucketManagement: true,
      ),
    LibraryGroupMode.title => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.title,
        label: 'Title',
        sidebarTitle: 'Titles',
        icon: Icons.sort_by_alpha,
      ),
    LibraryGroupMode.publisher => LibraryGroupModeDefinition(
        mode: mode,
        label: labels.publisherMode,
        sidebarTitle: labels.publisherPlural,
        icon: Icons.business_outlined,
        supportsBucketManagement: true,
      ),
    LibraryGroupMode.year => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.year,
        label: 'Year',
        sidebarTitle: 'Years',
        icon: Icons.calendar_today_outlined,
      ),
    LibraryGroupMode.audienceRating => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.audienceRating,
        label: 'Audience Rating',
        sidebarTitle: 'Audience Ratings',
        icon: Icons.star_half_outlined,
        supportsBucketManagement: true,
      ),
    LibraryGroupMode.color => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.color,
        label: 'Color',
        sidebarTitle: 'Colors',
        icon: Icons.palette_outlined,
      ),
    LibraryGroupMode.genre => LibraryGroupModeDefinition(
        mode: mode,
        label: labels.genre,
        sidebarTitle: labels.genrePlural,
        icon: Icons.theater_comedy_outlined,
        supportsBucketManagement: true,
      ),
    LibraryGroupMode.country => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.country,
        label: 'Country',
        sidebarTitle: 'Countries',
        icon: Icons.flag_outlined,
        supportsBucketManagement: true,
      ),
    LibraryGroupMode.language => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.language,
        label: 'Language',
        sidebarTitle: 'Languages',
        icon: Icons.translate_outlined,
        supportsBucketManagement: true,
      ),
    LibraryGroupMode.ageRating => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.ageRating,
        label: 'Age Rating',
        sidebarTitle: 'Age Ratings',
        icon: Icons.shield_outlined,
        supportsBucketManagement: true,
      ),
    LibraryGroupMode.movieOrTvSeries => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.movieOrTvSeries,
        label: 'Movie / TV Series',
        sidebarTitle: 'Movie / TV Series',
        icon: Icons.movie_outlined,
      ),
    LibraryGroupMode.releaseDate => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.releaseDate,
        label: 'Release Date',
        sidebarTitle: 'Release Dates',
        icon: Icons.event_outlined,
      ),
    LibraryGroupMode.releaseMonth => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.releaseMonth,
        label: 'Release Month',
        sidebarTitle: 'Release Months',
        icon: Icons.event_outlined,
      ),
    LibraryGroupMode.releaseYear => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.releaseYear,
        label: 'Release Year',
        sidebarTitle: 'Release Years',
        icon: Icons.event_outlined,
      ),
    LibraryGroupMode.audioTracks => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.audioTracks,
        label: 'Audio Tracks',
        sidebarTitle: 'Audio Tracks',
        icon: Icons.audiotrack_outlined,
      ),
    LibraryGroupMode.boxSet => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.boxSet,
        label: 'Box Set',
        sidebarTitle: 'Box Sets',
        icon: Icons.inventory_2_outlined,
      ),
    LibraryGroupMode.distributor => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.distributor,
        label: 'Distributor',
        sidebarTitle: 'Distributors',
        icon: Icons.local_shipping_outlined,
      ),
    LibraryGroupMode.editionReleaseDate => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.editionReleaseDate,
        label: 'Edition Release Date',
        sidebarTitle: 'Edition Release Dates',
        icon: Icons.event_outlined,
      ),
    LibraryGroupMode.editionReleaseMonth => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.editionReleaseMonth,
        label: 'Edition Release Month',
        sidebarTitle: 'Edition Release Months',
        icon: Icons.event_outlined,
      ),
    LibraryGroupMode.editionReleaseYear => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.editionReleaseYear,
        label: 'Edition Release Year',
        sidebarTitle: 'Edition Release Years',
        icon: Icons.event_outlined,
      ),
    LibraryGroupMode.extras => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.extras,
        label: 'Extras',
        sidebarTitle: 'Extras',
        icon: Icons.featured_play_list_outlined,
      ),
    LibraryGroupMode.format => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.format,
        label: 'Format',
        sidebarTitle: 'Formats',
        icon: Icons.album_outlined,
      ),
    LibraryGroupMode.hdr => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.hdr,
        label: 'HDR',
        sidebarTitle: 'HDR',
        icon: Icons.hdr_strong_outlined,
      ),
    LibraryGroupMode.layers => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.layers,
        label: 'Layers',
        sidebarTitle: 'Layers',
        icon: Icons.layers_outlined,
      ),
    LibraryGroupMode.packaging => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.packaging,
        label: 'Packaging',
        sidebarTitle: 'Packaging',
        icon: Icons.inbox_outlined,
      ),
    LibraryGroupMode.regions => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.regions,
        label: 'Regions',
        sidebarTitle: 'Regions',
        icon: Icons.public_outlined,
      ),
    LibraryGroupMode.screenRatios => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.screenRatios,
        label: 'Screen Ratios',
        sidebarTitle: 'Screen Ratios',
        icon: Icons.aspect_ratio_outlined,
      ),
    LibraryGroupMode.subtitles => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.subtitles,
        label: 'Subtitles',
        sidebarTitle: 'Subtitles',
        icon: Icons.subtitles_outlined,
      ),
    LibraryGroupMode.actor => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.actor,
        label: 'Actor',
        sidebarTitle: 'Actors',
        icon: Icons.theater_comedy_outlined,
        supportsBucketManagement: true,
      ),
    LibraryGroupMode.director => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.director,
        label: 'Director',
        sidebarTitle: 'Directors',
        icon: Icons.movie_creation_outlined,
        supportsBucketManagement: true,
      ),
    LibraryGroupMode.musician => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.musician,
        label: 'Musician',
        sidebarTitle: 'Musicians',
        icon: Icons.music_note_outlined,
        supportsBucketManagement: true,
      ),
    LibraryGroupMode.photography => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.photography,
        label: 'Photography',
        sidebarTitle: 'Photography',
        icon: Icons.camera_alt_outlined,
        supportsBucketManagement: true,
      ),
    LibraryGroupMode.producer => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.producer,
        label: 'Producer',
        sidebarTitle: 'Producers',
        icon: Icons.groups_outlined,
        supportsBucketManagement: true,
      ),
    LibraryGroupMode.creator => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.creator,
        label: 'Creator',
        sidebarTitle: 'Creators',
        icon: Icons.draw_outlined,
        supportsBucketManagement: true,
      ),
    LibraryGroupMode.writer => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.writer,
        label: 'Writer',
        sidebarTitle: 'Writers',
        icon: Icons.edit_note_outlined,
        supportsBucketManagement: true,
      ),
    LibraryGroupMode.artist => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.artist,
        label: 'Artist',
        sidebarTitle: 'Artists',
        icon: Icons.brush_outlined,
        supportsBucketManagement: true,
      ),
    LibraryGroupMode.penciller => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.penciller,
        label: 'Penciller',
        sidebarTitle: 'Pencillers',
        icon: Icons.edit_outlined,
        supportsBucketManagement: true,
      ),
    LibraryGroupMode.colorist => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.colorist,
        label: 'Colorist',
        sidebarTitle: 'Colorists',
        icon: Icons.format_color_fill_outlined,
        supportsBucketManagement: true,
      ),
    LibraryGroupMode.letterer => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.letterer,
        label: 'Letterer',
        sidebarTitle: 'Letterers',
        icon: Icons.text_fields_outlined,
        supportsBucketManagement: true,
      ),
    LibraryGroupMode.coverArtist => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.coverArtist,
        label: 'Cover Artist',
        sidebarTitle: 'Cover Artists',
        icon: Icons.image_outlined,
        supportsBucketManagement: true,
      ),
    LibraryGroupMode.editor => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.editor,
        label: 'Editor',
        sidebarTitle: 'Editors',
        icon: Icons.fact_check_outlined,
        supportsBucketManagement: true,
      ),
    LibraryGroupMode.location => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.location,
        label: 'Location',
        sidebarTitle: 'Locations',
        icon: Icons.place_outlined,
      ),
    LibraryGroupMode.ownership => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.ownership,
        label: 'Ownership',
        sidebarTitle: 'Ownership',
        icon: Icons.inventory_2_outlined,
      ),
    LibraryGroupMode.addedDate => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.addedDate,
        label: 'Added Date',
        sidebarTitle: 'Added Dates',
        icon: Icons.add_task_outlined,
      ),
    LibraryGroupMode.addedMonth => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.addedMonth,
        label: 'Added Month',
        sidebarTitle: 'Added Months',
        icon: Icons.add_task_outlined,
      ),
    LibraryGroupMode.addedYear => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.addedYear,
        label: 'Added Year',
        sidebarTitle: 'Added Years',
        icon: Icons.add_task_outlined,
      ),
    LibraryGroupMode.collectionStatus => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.collectionStatus,
        label: 'Collection Status',
        sidebarTitle: 'Collection Status',
        icon: Icons.stacked_bar_chart_outlined,
      ),
    LibraryGroupMode.grade => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.grade,
        label: 'Grade',
        sidebarTitle: 'Grades',
        icon: Icons.verified_outlined,
      ),
    LibraryGroupMode.condition => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.condition,
        label: 'Condition',
        sidebarTitle: 'Conditions',
        icon: Icons.rule_outlined,
      ),
    LibraryGroupMode.imageType => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.imageType,
        label: 'Image Type',
        sidebarTitle: 'Image Types',
        icon: Icons.image_search_outlined,
      ),
    LibraryGroupMode.modifiedDate => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.modifiedDate,
        label: 'Modified Date',
        sidebarTitle: 'Modified Dates',
        icon: Icons.update_outlined,
      ),
    LibraryGroupMode.modifiedMonth => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.modifiedMonth,
        label: 'Modified Month',
        sidebarTitle: 'Modified Months',
        icon: Icons.update_outlined,
      ),
    LibraryGroupMode.myRating => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.myRating,
        label: 'My Rating',
        sidebarTitle: 'My Ratings',
        icon: Icons.star_outline,
      ),
    LibraryGroupMode.owner => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.owner,
        label: 'Owner',
        sidebarTitle: 'Owners',
        icon: Icons.person_outline,
      ),
    LibraryGroupMode.purchaseDate => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.purchaseDate,
        label: 'Purchase Date',
        sidebarTitle: 'Purchase Dates',
        icon: Icons.shopping_bag_outlined,
      ),
    LibraryGroupMode.purchaseMonth => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.purchaseMonth,
        label: 'Purchase Month',
        sidebarTitle: 'Purchase Months',
        icon: Icons.shopping_bag_outlined,
      ),
    LibraryGroupMode.purchaseYear => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.purchaseYear,
        label: 'Purchase Year',
        sidebarTitle: 'Purchase Years',
        icon: Icons.shopping_bag_outlined,
      ),
    LibraryGroupMode.purchaseStore => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.purchaseStore,
        label: 'Purchase Store',
        sidebarTitle: 'Purchase Stores',
        icon: Icons.storefront_outlined,
      ),
    LibraryGroupMode.storageDevice => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.storageDevice,
        label: 'Storage Device',
        sidebarTitle: 'Storage Devices',
        icon: Icons.sd_storage_outlined,
      ),
    LibraryGroupMode.tags => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.tags,
        label: 'Tags',
        sidebarTitle: 'Tags',
        icon: Icons.sell_outlined,
      ),
    LibraryGroupMode.watchDate => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.watchDate,
        label: 'Watch Date',
        sidebarTitle: 'Watch Dates',
        icon: Icons.play_circle_outline,
      ),
    LibraryGroupMode.watchMonth => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.watchMonth,
        label: 'Watch Month',
        sidebarTitle: 'Watch Months',
        icon: Icons.play_circle_outline,
      ),
    LibraryGroupMode.watchYear => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.watchYear,
        label: 'Watch Year',
        sidebarTitle: 'Watch Years',
        icon: Icons.play_circle_outline,
      ),
    LibraryGroupMode.watched => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.watched,
        label: 'Watched',
        sidebarTitle: 'Watched',
        icon: Icons.visibility_outlined,
      ),
    LibraryGroupMode.watchedWhere => const LibraryGroupModeDefinition(
        mode: LibraryGroupMode.watchedWhere,
        label: 'Watched Where',
        sidebarTitle: 'Watched Where',
        icon: Icons.tv_outlined,
      ),
  };
}

LibrarySortColumnDefinition _defaultLibrarySortColumnDefinition(
  LibrarySortColumn column,
  LibraryMediaGroupLabels labels,
) {
  return switch (column) {
    LibrarySortColumn.status => const LibrarySortColumnDefinition(
        column: LibrarySortColumn.status,
        label: 'Status',
      ),
    LibrarySortColumn.title => const LibrarySortColumnDefinition(
        column: LibrarySortColumn.title,
        label: 'Title',
      ),
    LibrarySortColumn.series => LibrarySortColumnDefinition(
        column: column,
        label: labels.series,
      ),
    LibrarySortColumn.issue => const LibrarySortColumnDefinition(
        column: LibrarySortColumn.issue,
        label: 'Issue / number',
      ),
    LibrarySortColumn.storyArc => const LibrarySortColumnDefinition(
        column: LibrarySortColumn.storyArc,
        label: 'Story arc',
      ),
    LibrarySortColumn.variant => const LibrarySortColumnDefinition(
        column: LibrarySortColumn.variant,
        label: 'Variant',
      ),
    LibrarySortColumn.publisher => LibrarySortColumnDefinition(
        column: column,
        label: labels.publisher,
      ),
    LibrarySortColumn.releaseDate => const LibrarySortColumnDefinition(
        column: LibrarySortColumn.releaseDate,
        label: 'Release date',
        defaultAscending: false,
      ),
    LibrarySortColumn.barcode => const LibrarySortColumnDefinition(
        column: LibrarySortColumn.barcode,
        label: 'Barcode',
        group: LibrarySortFieldGroup.edition,
      ),
    LibrarySortColumn.grade => const LibrarySortColumnDefinition(
        column: LibrarySortColumn.grade,
        label: 'Grade',
        group: LibrarySortFieldGroup.value,
      ),
    LibrarySortColumn.rawOrSlabbed => const LibrarySortColumnDefinition(
        column: LibrarySortColumn.rawOrSlabbed,
        label: 'Raw / slabbed',
        group: LibrarySortFieldGroup.edition,
      ),
    LibrarySortColumn.gradingCompany => const LibrarySortColumnDefinition(
        column: LibrarySortColumn.gradingCompany,
        label: 'Grading company',
        group: LibrarySortFieldGroup.edition,
      ),
    LibrarySortColumn.condition => const LibrarySortColumnDefinition(
        column: LibrarySortColumn.condition,
        label: 'Condition',
        group: LibrarySortFieldGroup.value,
      ),
    LibrarySortColumn.price => const LibrarySortColumnDefinition(
        column: LibrarySortColumn.price,
        label: 'Purchase price',
        group: LibrarySortFieldGroup.value,
      ),
    LibrarySortColumn.location => const LibrarySortColumnDefinition(
        column: LibrarySortColumn.location,
        label: 'Storage box',
        group: LibrarySortFieldGroup.personal,
      ),
    LibrarySortColumn.collectionStatus => const LibrarySortColumnDefinition(
        column: LibrarySortColumn.collectionStatus,
        label: 'Collection status',
        group: LibrarySortFieldGroup.personal,
      ),
    LibrarySortColumn.wishlist => const LibrarySortColumnDefinition(
        column: LibrarySortColumn.wishlist,
        label: 'Wishlist',
        group: LibrarySortFieldGroup.personal,
      ),
    LibrarySortColumn.keyComic => const LibrarySortColumnDefinition(
        column: LibrarySortColumn.keyComic,
        label: 'Key comic',
      ),
    LibrarySortColumn.updated => const LibrarySortColumnDefinition(
        column: LibrarySortColumn.updated,
        label: 'Updated',
        group: LibrarySortFieldGroup.personal,
        defaultAscending: false,
      ),
    LibrarySortColumn.country => const LibrarySortColumnDefinition(
        column: LibrarySortColumn.country,
        label: 'Country',
      ),
    LibrarySortColumn.language => const LibrarySortColumnDefinition(
        column: LibrarySortColumn.language,
        label: 'Language',
      ),
    LibrarySortColumn.pageCount => const LibrarySortColumnDefinition(
        column: LibrarySortColumn.pageCount,
        label: 'Page count',
        group: LibrarySortFieldGroup.edition,
      ),
    LibrarySortColumn.ageRating => const LibrarySortColumnDefinition(
        column: LibrarySortColumn.ageRating,
        label: 'Age rating',
      ),
    LibrarySortColumn.imprint => const LibrarySortColumnDefinition(
        column: LibrarySortColumn.imprint,
        label: 'Imprint',
      ),
  };
}