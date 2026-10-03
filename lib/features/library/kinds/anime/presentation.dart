import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_link_dto.dart';
import 'package:collectarr_app/features/library/kinds/anime/catalog/anime_catalog_fields.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_library_entry_projection.dart';
import 'package:collectarr_app/features/library/config/library_duplicate_presentation.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_card_presentation.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_physical_media_formats.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';
import 'package:flutter/material.dart';

const animeMetadataLabels = LibraryMetadataLabels(
  identitySectionTitle: 'Anime identity',
  contextSectionTitle: 'Anime context',
  creditsSectionTitle: 'Cast & Discovery',
  values: {'creators': 'Cast & Crew', 'characters': 'Characters'},
);

class AnimeLibraryMediaPresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const AnimeLibraryMediaPresentationBuilder();

  @override
  String? buildAddPreviewItemNumber({
    required CatalogSearchCandidate item,
  }) =>
      item.animeCatalogFields.itemNumber;

  @override
  List<LibraryFormatBadgeDescriptor> buildAddPreviewFormatBadges({
    required CatalogSearchCandidate item,
  }) {
    final seen = <String>{};
    final result = <LibraryFormatBadgeDescriptor>[];
    final fields = item.animeCatalogFields;
    final badge = animeFormatBadge(
      fields.physicalFormat,
      label: fields.physicalFormatLabel,
    );
    if (badge != null && seen.add(badge.key)) result.add(badge);
    return result;
  }

  @override
  List<LibraryDuplicateCandidate> buildDuplicateCandidates(
    LibraryWorkspaceSource entry,
  ) {
    final catalog = entry.catalogData;
    if (catalog is! AnimeWorkspaceCatalogData) return const [];
    final identifier =
        normalizeLibraryDuplicateIdentifier(catalog.metadata?.barcode);
    if (identifier == null) return const [];
    return [
      LibraryDuplicateCandidate(
        key: 'identifier:$identifier',
        label: 'Identifier ${catalog.metadata!.barcode!.trim()}',
        reason: 'Same identifier',
        confidenceScore: 78,
      ),
    ];
  }

  @override
  List<LibraryWorkspaceLinkSummary> buildWorkspaceLinks(
    LibraryWorkspaceSource entry,
  ) {
    final catalog = entry.catalogData;
    if (catalog is! AnimeWorkspaceCatalogData) return const [];
    return [
      for (final value in catalog.metadata?.links ?? const <TrailerLinkDto>[])
        if (value.url.trim().isNotEmpty)
          LibraryWorkspaceLinkSummary(
            url: value.url,
            label: value.title,
            source: value.source,
            isTrailer: value.isTrailerLink,
            isAutomatic: value.isAutomatic,
          ),
    ];
  }

  @override
  CatalogSearchCandidate mergeHydratedAddItem({
    required CatalogSearchCandidate hydrated,
    required CatalogSearchCandidate fallback,
  }) {
    final hydratedMetadata = hydrated.animeCatalogFields;
    final fallbackMetadata = fallback.animeCatalogFields;
    final coverImageUrl =
        hydratedMetadata.coverImageUrl ?? fallbackMetadata.coverImageUrl;
    final thumbnailImageUrl = hydratedMetadata.coverImageUrl != null
        ? hydratedMetadata.thumbnailImageUrl
        : fallbackMetadata.thumbnailImageUrl ?? fallbackMetadata.coverImageUrl;
    return CatalogSearchCandidate.fromItem(
      hydrated.kindCapability.mapTransport((transport) {
        final metadata = AnimeMetadata.fromJson(transport.kindData);
        final updated = AnimeMetadata.fromJson(applyJsonFieldPatch(metadata, {
          'cover_image_url': coverImageUrl,
          'thumbnail_image_url': thumbnailImageUrl,
        }));
        return transport.replacingKindData(updated);
      }),
    );
  }

  @override
  String? buildAddPreviewSynopsis({required CatalogSearchCandidate item}) =>
      item.animeCatalogFields.synopsis;

  @override
  List<String> buildCatalogSearchAliases({
    required CatalogSearchCandidate item,
  }) =>
      item.animeCatalogFields.searchAliases;

  @override
  LibraryAddSearchResultDisplay? buildSearchResultDisplay({
    required CatalogSearchCandidate item,
  }) =>
      _buildAnimeSearchResultDisplay(item);

  @override
  List<(String, String?)> buildAddPreviewMetadataRows({
    required CatalogSearchCandidate item,
    required LibraryMediaPreviewLabels previewLabels,
  }) {
    final releaseDate = item.animeCatalogFields.releaseDate;
    return [
      (
        previewLabels.labelFor('publisher', fallback: 'Publisher'),
        item.animeCatalogFields.publisher
      ),
      (
        'Released',
        releaseDate == null
            ? item.animeCatalogFields.releaseYear?.toString()
            : '${releaseDate.year}-${releaseDate.month.toString().padLeft(2, '0')}-${releaseDate.day.toString().padLeft(2, '0')}',
      ),
      if (item.animeCatalogFields.itemNumber != null)
        (
          previewLabels.labelFor('item_number', fallback: 'Number'),
          item.animeCatalogFields.itemNumber
        ),
      if (item.animeCatalogFields.variant != null)
        (
          previewLabels.labelFor('variant', fallback: 'Variant'),
          item.animeCatalogFields.variant
        ),
      (
        previewLabels.labelFor('barcode', fallback: 'Barcode'),
        item.animeCatalogFields.barcode
      ),
    ];
  }

  @override
  bool canOpenKindDrilldown(LibraryProjectionView item) {
    return item.node.scope == LibraryEntityScope.catalogItem &&
        item.source.mediaKind == CatalogMediaKind.anime;
  }

  @override
  LibraryMetadataPresentation buildMetadataPresentation({
    required String singularLabel,
    required LibraryProjectionView item,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  }) {
    final dto = item.dto;
    if (dto is! AnimeWorkspaceDto) {
      throw StateError('Expected AnimeWorkspaceDto for anime presentation');
    }
    final seriesTitle = dto.seriesTitle;
    final variant = dto.variant;
    final barcode = dto.barcode;
    final publisher = dto.publisher;
    final releaseDate = dto.releaseDate;
    final country = dto.country;
    final language = dto.language;
    return LibraryMetadataPresentation(
      labels: animeMetadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: item.node.catalogItemId),
          LibraryDetailField(label: 'Title', value: dto.primaryLabel),
        ],
        if (seriesTitle != null)
          LibraryDetailField(
            label: 'Series',
            value: seriesTitle,
            onTap: tapFor(seriesTitle),
          ),
        if (item.node.scope != LibraryEntityScope.catalogItem &&
            variant != null)
          LibraryDetailField(
            label: 'Format / Edition',
            value: variant,
            onTap: tapFor(variant),
          ),
        if (item.node.scope != LibraryEntityScope.catalogItem &&
            barcode != null)
          LibraryDetailField(label: 'UPC / Barcode', value: barcode),
      ],
      contextFacts: [
        if (publisher != null)
          LibraryDetailField(
            label: 'Studio',
            value: publisher,
            onTap: tapFor(publisher),
          ),
        LibraryDetailField(
          label: 'Released',
          value: genericLibraryDash(
            formatPresentationNullableDate(releaseDate),
          ),
        ),
        if (country != null)
          LibraryDetailField(label: 'Country', value: country),
        if (language != null)
          LibraryDetailField(label: 'Language', value: language),
      ],
      sections: {
        'creators': LibraryMetadataSection(
          values: publisher == null
              ? const []
              : <Map<String, dynamic>>[
                  {'name': publisher},
                ],
          placement: LibraryMetadataSectionPlacement.credits,
          renderer: LibraryMetadataSectionRenderer.credits,
          completenessWeight: 12,
        ),
      },
    );
  }

  @override
  List<Widget> buildInspectorSections({
    required BuildContext context,
    required LibraryProjectionView item,
    required Color accent,
    ValueChanged<String>? onFilterByValue,
  }) {
    final dto = item.dto;
    if (dto is! AnimeWorkspaceDto ||
        dto.common.synopsis?.trim().isNotEmpty != true) {
      return const [];
    }
    return [
      LibraryDetailSection(
        title: 'Summary',
        accentColor: accent,
        children: [
          SelectableText(
            dto.common.synopsis!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                ),
          ),
        ],
      ),
    ];
  }
}

LibraryAddSearchResultDisplay _buildAnimeSearchResultDisplay(
  CatalogSearchCandidate item,
) {
  final itemNumber = item.animeCatalogFields.itemNumber?.trim();
  final subtitle = [
    if (item.animeCatalogFields.publisher?.trim() case final value?
        when value.isNotEmpty)
      value,
    if ((item.animeCatalogFields.releaseYear ??
            item.animeCatalogFields.releaseDate?.year)
        case final year?)
      year.toString(),
    if (item.animeCatalogFields.physicalFormatLabel?.trim() case final value?
        when value.isNotEmpty)
      value,
    if (item.animeCatalogFields.barcode?.trim() case final value?
        when value.isNotEmpty)
      value,
  ].join(' | ');
  return LibraryAddSearchResultDisplay(
    title: itemNumber == null || itemNumber.isEmpty
        ? item.summary.primaryLabel
        : '${item.summary.primaryLabel} #$itemNumber',
    secondaryLine: subtitle.isEmpty ? null : subtitle,
    year: item.animeCatalogFields.releaseYear ??
        item.animeCatalogFields.releaseDate?.year,
    detailLine: null,
  );
}

const animeLibraryMediaBuilder = AnimeLibraryMediaPresentationBuilder();

const animePreviewLabels = LibraryMediaPreviewLabels(
  values: {
    'series': 'Series',
    'item_count': 'Episodes',
    'item_number': 'Edition no.',
    'publisher': 'Studio',
    'variant': 'Format / Edition',
    'barcode': 'UPC / Barcode',
  },
);

const animeStatsLabels = LibraryMediaStatsLabels(
  values: {'top_series': 'Top Series', 'top_publisher': 'Top Studios'},
);

final animeLibraryFilterDefinitions = <LibraryFilterDefinition<Object?>>[
  LibraryFilterDefinition<Object?>(
    id: 'series',
    label: 'Series',
    anyLabel: 'Any series',
    value: (item) => (item.dto is AnimeWorkspaceDto)
        ? (item.dto as AnimeWorkspaceDto).seriesTitle
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'location',
    label: 'Location',
    anyLabel: 'Any location',
  ),
  LibraryFilterDefinition<Object?>(
    id: 'tag',
    label: 'Tag',
    anyLabel: 'Any tag',
    inputKind: LibraryFilterInputKind.autocomplete,
    value: (item) => AnimeLibraryEntryProjection.fromDispatch(
      item.source.libraryEntryDispatch,
    )?.personal.tags?.split(','),
  ),
  LibraryFilterDefinition<Object?>(
    id: 'publisher',
    label: 'Studio',
    anyLabel: 'Any studio',
    value: (item) => (item.dto is AnimeWorkspaceDto)
        ? (item.dto as AnimeWorkspaceDto).publisher
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'year',
    label: 'Year',
    anyLabel: 'Any year',
    value: (item) => (item.dto is AnimeWorkspaceDto)
        ? (item.dto as AnimeWorkspaceDto).releaseDate?.year.toString()
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'condition',
    label: 'Condition',
    anyLabel: 'Any condition',
    value: (item) => AnimeLibraryEntryProjection.fromDispatch(
      item.source.libraryEntryDispatch,
    )?.personal.condition,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'country',
    label: 'Country',
    anyLabel: 'Any country',
    value: (item) => (item.dto is AnimeWorkspaceDto)
        ? (item.dto as AnimeWorkspaceDto).country
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'language',
    label: 'Language',
    anyLabel: 'Any language',
    value: (item) => (item.dto is AnimeWorkspaceDto)
        ? (item.dto as AnimeWorkspaceDto).language
        : null,
  ),
];

const animeLibraryGroupLabels = LibraryPresentationLabels(
  values: {
    'series': 'Series',
    'series_plural': 'Series',
    'unknown_series': 'Unknown series',
    'publisher': 'Studio',
    'publisher_plural': 'Studios',
    'unknown_publisher': 'Unknown studio',
    'publisher_mode': 'Studios',
    'genre': 'Genres',
    'genre_plural': 'Genres',
  },
);

const animeLibraryBucketLabelOverrides = LibraryPresentationLabels();

String animeLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return defaultLibraryBucketLabel(
    context,
    animeLibraryGroupLabels,
    animeLibraryBucketLabelOverrides,
  );
}

final animeLibraryMediaPresentation = LibraryMediaPresentation(
  searchFieldLabels: const LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
  ),
  filterLabels: const LibraryPresentationLabels(
    values: {
      'series': 'Series',
      'series_any': 'Any series',
      'publisher': 'Studio',
      'publisher_any': 'Any studio',
      'year': 'Year',
      'year_any': 'Any year',
    },
  ),
  groupLabels: animeLibraryGroupLabels,
  builder: animeLibraryMediaBuilder,
  bucketLabelBuilder: animeLibraryBucketLabelBuilder,
  cardPresentationBuilder: buildAnimeCardPresentation,
  compactBucketIcon: Icons.tv_outlined,
  previewLabels: animePreviewLabels,
  statsLabels: animeStatsLabels,
  filterDefinitions: animeLibraryFilterDefinitions,
);
