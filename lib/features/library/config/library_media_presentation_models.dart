import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_widgets.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
export 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart'
    show LibraryGroupPresentation, LibraryGroupPresentationLabels;
import 'package:collectarr_app/features/library/details/library_detail_chip.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
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

String libraryFallbackLabelForId(String value) {
  final tokens = value
      .split('.')
      .map((segment) => segment.replaceAllMapped(
            RegExp(r'([a-z0-9])([A-Z])'),
            (match) => '${match[1]} ${match[2]}',
          ))
      .join(' ');
  if (tokens.isEmpty) {
    return value;
  }
  return tokens[0].toUpperCase() + tokens.substring(1);
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

enum LibraryFilterField {
  series,
  location,
  tag,
  publisher,
  year,
  grade,
  condition,
  country,
  language,
}

class LibraryFilterFieldDefinition {
  const LibraryFilterFieldDefinition(this.field);

  final LibraryFilterField field;
}

const defaultLibraryFilterFieldDefinitions = [
  LibraryFilterFieldDefinition(LibraryFilterField.series),
  LibraryFilterFieldDefinition(LibraryFilterField.location),
  LibraryFilterFieldDefinition(LibraryFilterField.tag),
  LibraryFilterFieldDefinition(LibraryFilterField.publisher),
  LibraryFilterFieldDefinition(LibraryFilterField.year),
  LibraryFilterFieldDefinition(LibraryFilterField.grade),
  LibraryFilterFieldDefinition(LibraryFilterField.condition),
  LibraryFilterFieldDefinition(LibraryFilterField.country),
  LibraryFilterFieldDefinition(LibraryFilterField.language),
];

class LibraryBucketLabelOverrides {
  const LibraryBucketLabelOverrides({
    this.storyArc = 'Story arc',
    this.character = 'Character',
    this.noGenre = 'No genre',
    this.unknownCountry = 'Unknown country',
    this.unknownLanguage = 'Unknown language',
    this.owned = 'Owned',
    this.wishlist = 'Wishlist',
    this.catalogOnly = 'Catalog only',
  });

  final String storyArc;
  final String character;
  final String noGenre;
  final String unknownCountry;
  final String unknownLanguage;
  final String owned;
  final String wishlist;
  final String catalogOnly;
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
  String get wishlistedAsBundle => 'Wishlisted as ${bundleScope.toLowerCase()}';
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

class LibraryBucketingContext {
  const LibraryBucketingContext({
    required this.source,
    required this.entry,
    required this.groupMode,
  });

  final ShelfEntry source;
  final LibraryWorkspaceEntry entry;
  final String groupMode;
}

class LibraryReleaseEntryRequest {
  const LibraryReleaseEntryRequest({
    required this.titleEntry,
    required this.edition,
    this.isOwned = false,
    this.isWishlisted = false,
    this.isTracked = false,
    this.referenceEditionId,
    this.referenceVariantId,
    this.referenceBundleReleaseId,
    this.editions = const <CatalogEdition>[],
    required this.updatedAt,
  });

  final LibraryWorkspaceEntry titleEntry;
  final CatalogEdition edition;
  final bool isOwned;
  final bool isWishlisted;
  final bool isTracked;
  final String? referenceEditionId;
  final String? referenceVariantId;
  final String? referenceBundleReleaseId;
  final List<CatalogEdition> editions;
  final DateTime updatedAt;
}

typedef LibraryWorkspaceEntryBuilder = LibraryWorkspaceEntry Function(
  ShelfEntry source,
);

typedef LibraryReleaseEntryBuilder = LibraryWorkspaceEntry Function(
  LibraryReleaseEntryRequest request,
);

typedef LibraryBucketLabelBuilder = String Function(
  LibraryBucketingContext context,
);



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
      LibrarySortRule(column: 'title', ascending: true),
    ],
  ),
  LibrarySortFavorite(
    id: 'release_latest',
    label: 'Latest release',
    icon: Icons.event,
    rules: [
      LibrarySortRule(column: 'release_date', ascending: false),
      LibrarySortRule(column: 'title', ascending: true),
    ],
  ),
  LibrarySortFavorite(
    id: 'recent',
    label: 'Recently added',
    icon: Icons.update,
    rules: [
      LibrarySortRule(column: 'updated', ascending: false),
      LibrarySortRule(column: 'title', ascending: true),
    ],
  ),
  LibrarySortFavorite(
    id: 'value_desc',
    label: 'Value high to low',
    icon: Icons.attach_money,
    rules: [
      LibrarySortRule(column: 'price', ascending: false),
      LibrarySortRule(column: 'title', ascending: true),
    ],
  ),
];

const defaultLibraryColumnFavorites = [
  LibraryTableColumnPreset(
    label: 'Essential',
    columns: {
      'status',
      'title',
      'publisher',
      'release_date',
      'updated',
    },
  ),
  LibraryTableColumnPreset(
    label: 'Collection',
    columns: {
      'status',
      'title',
      'condition',
      'grade',
      'price',
      'wishlist',
      'updated',
    },
  ),
  LibraryTableColumnPreset(
    label: 'Reference',
    columns: {
      'status',
      'title',
      'variant',
      'publisher',
      'release_date',
      'barcode',
      'updated',
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
    this.labels = const LibraryMetadataLabels(),
  });

  final List<LibraryDetailField> identityFacts;
  final List<LibraryDetailField> contextFacts;
  final List<Map<String, dynamic>> creators;
  final List<String> characters;
  final List<String> storyArcs;
  final List<String> genres;
  final LibraryMetadataLabels labels;

  List<LibraryDetailField> get allFacts => [
        ...identityFacts,
        ...contextFacts,
      ];

  bool get hasCredits =>
      creators.isNotEmpty || characters.isNotEmpty || storyArcs.isNotEmpty;
}

class LibraryMetadataLabels {
  const LibraryMetadataLabels({
    this.identitySectionTitle = 'Catalog identity',
    this.contextSectionTitle = 'Catalog context',
    this.creditsSectionTitle = 'Credits & Discovery',
    this.creators = 'Creators',
    this.characters = 'Characters',
    this.storyArcs = 'Story Arcs',
    this.storyArcsInline = 'Story arcs',
    this.genres = 'Genres',
  });

  final String identitySectionTitle;
  final String contextSectionTitle;
  final String creditsSectionTitle;
  final String creators;
  final String characters;
  final String storyArcs;
  final String storyArcsInline;
  final String genres;
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
    ValueChanged<String>? onFilterByValue,
  }) {
    return const [];
  }

  List<Widget> buildDetailCatalogSections({
    required BuildContext context,
    required String singularLabel,
    required MediaEditFields mediaFields,
    required ReleaseEditFields releaseFields,
    required LibraryWorkspaceEntry entry,
    required Color accent,
    ValueChanged<String>? onFilterByValue,
  }) {
    return [
      buildDetailIdentitySection(
        context: context,
        singularLabel: singularLabel,
        mediaFields: mediaFields,
        releaseFields: releaseFields,
        entry: entry,
        accent: accent,
        onFilterByValue: onFilterByValue,
      ),
      buildDetailContextSection(
        context: context,
        singularLabel: singularLabel,
        mediaFields: mediaFields,
        releaseFields: releaseFields,
        entry: entry,
        accent: accent,
        onFilterByValue: onFilterByValue,
      ),
      buildDetailCreditsSection(
        context: context,
        singularLabel: singularLabel,
        mediaFields: mediaFields,
        releaseFields: releaseFields,
        entry: entry,
        accent: accent,
        onFilterByValue: onFilterByValue,
      ),
    ];
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
        return LibraryDetailField(
          label: fact.label,
          value: fact.value,
          onTap: () => context.push(
            '/series/${Uri.encodeComponent(series.seriesId!)}?title=${Uri.encodeQueryComponent(series.seriesTitle!)}',
          ),
        );
      }
      return fact;
    }).toList(growable: false);
    return LibraryDetailSection(
      title: presentation.labels.identitySectionTitle,
      accentColor: accent,
      children: [
        LibraryDetailFieldTable(fields: identityFacts),
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
    return LibraryDetailSection(
      title: presentation.labels.contextSectionTitle,
      accentColor: accent,
      children: [
        LibraryDetailFieldTable(fields: presentation.contextFacts),
        if (presentation.genres.isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryDetailChipGroupWidget(
            label: presentation.labels.genres,
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
    return LibraryDetailSection(
      title: presentation.labels.creditsSectionTitle,
      accentColor: accent,
      children: [
        if (presentation.creators.isNotEmpty)
          LibraryMetadataCreditsList(
            title: presentation.labels.creators,
            credits: presentation.creators,
            onValueTap: (value) => context.push(
              '/creator/${Uri.encodeComponent(value)}',
            ),
          ),
        if (presentation.characters.isNotEmpty) ...[
          if (presentation.creators.isNotEmpty) const SizedBox(height: 8),
          LibraryDetailChipGroupWidget(
            label: presentation.labels.characters,
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
          LibraryDetailChipGroupWidget(
            label: presentation.labels.storyArcs,
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
    required this.workspaceEntryBuilder,
    required this.releaseEntryBuilder,
    required this.bucketLabelBuilder,
    this.previewLabels = const LibraryMediaPreviewLabels(
      series: 'Series',
      itemCount: 'Items',
    ),
    this.statsLabels = const LibraryMediaStatsLabels(),
    this.usesTreeProviderCandidates = false,
    this.externalFacetBucketIdsByMode = const {},
    this.supportsSeriesIssueJump = false,
    this.usesTrackListCard = false,
    this.showsSeasonGroupProgress = false,
    this.defaultVideoDisplayLevel,
    this.defaultVideoGrouping = VideoGroupingDefault.none,
    this.videoSeriesEntryTypes = const {},
    this.videoShelfDrilldownEntryTypes = const {},
    this.usesCompactTableLayout = false,
    this.compactBucketIcon = Icons.folder,
    this.emptyStateProviderSummarySuffix = '',
    this.sortFavorites = defaultLibrarySortFavorites,
    this.columnFavorites = defaultLibraryColumnFavorites,
    this.filterOptionLabels = const LibraryFilterOptionLabels(),
    this.filterFieldDefinitions = defaultLibraryFilterFieldDefinitions,
    this.referenceLabels = const LibraryReferenceLabels(),
    this.statusLabels = const LibraryStatusLabels(),
    this.bucketLabelOverrides = const LibraryBucketLabelOverrides(),
    this.fieldDefinitions = const [],
  });

  final LibraryMediaSearchFieldLabels searchFieldLabels;
  final LibraryMediaFilterLabels filterLabels;
  final LibraryMediaGroupLabels groupLabels;
  final LibraryMediaPresentationBuilder builder;
  final LibraryWorkspaceEntryBuilder workspaceEntryBuilder;
  final LibraryReleaseEntryBuilder releaseEntryBuilder;
  final LibraryBucketLabelBuilder bucketLabelBuilder;
  final LibraryMediaPreviewLabels previewLabels;
  final LibraryMediaStatsLabels statsLabels;
  final bool usesTreeProviderCandidates;
  final Map<String, String> externalFacetBucketIdsByMode;
  final bool supportsSeriesIssueJump;
  final bool usesTrackListCard;
  final bool showsSeasonGroupProgress;
  final VideoDisplayLevel? defaultVideoDisplayLevel;
  final VideoGroupingDefault defaultVideoGrouping;
  final Set<String> videoSeriesEntryTypes;
  final Set<String> videoShelfDrilldownEntryTypes;
  final bool usesCompactTableLayout;
  final IconData compactBucketIcon;
  final String emptyStateProviderSummarySuffix;
  final List<LibrarySortFavorite> sortFavorites;
  final List<LibraryTableColumnPreset> columnFavorites;
  final LibraryFilterOptionLabels filterOptionLabels;
  final List<LibraryFilterFieldDefinition> filterFieldDefinitions;
  final LibraryReferenceLabels referenceLabels;
  final LibraryStatusLabels statusLabels;
  final LibraryBucketLabelOverrides bucketLabelOverrides;
  final List<LibraryFieldDefinition<LibraryWorkspaceDto, Object?>>
      fieldDefinitions;

  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>? fieldDefinitionFor(
    String id,
  ) {
    for (final definition in fieldDefinitions) {
      if (definition.id.value == id) {
        return definition;
      }
    }
    return null;
  }
}



String definitionIdFor(Object value) {
  final normalized = switch (value) {
    String text => text.trim(),
    Object _ => value.toString().trim(),
  };
  if (normalized.isEmpty) {
    return '';
  }
  if (value is String) {
    return normalized;
  }
  return normalized.contains('.') ? normalized.split('.').last : normalized;
}

abstract final class LibraryFacetId {
  static const comicStoryArc = 'comic.story_arc';
  static const comicCharacter = 'comic.character';
  static const mediaCharacter = 'media.character';
}

String librarySortColumnFallbackLabel(Object column) {
  final columnName = column is Enum
      ? column.name
      : column.toString().split('.').last;
  final raw = columnName
      .replaceAll('_', ' ')
      .replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (match) => '${match[1]} ${match[2]}',
      );
  if (raw.isEmpty) {
    return columnName;
  }
  return raw.split(' ').map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1);
  }).join(' ');
}
