import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_duplicate_presentation.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_transport.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_card_presentation.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_preview_seasons_section.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
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
  List<LibraryDuplicateCandidate> buildDuplicateCandidates(
    LibraryWorkspaceSource entry,
  ) {
    final item = entry.catalogTransport;
    final identifier =
        normalizeLibraryDuplicateIdentifier(item?.identifierCode);
    if (item == null || identifier == null) return const [];
    return [
      LibraryDuplicateCandidate(
        key: 'identifier:$identifier',
        label: 'Identifier ${item.identifierCode!.trim()}',
        reason: 'Same identifier',
        confidenceScore: 78,
      ),
    ];
  }

  @override
  List<CatalogEditionDto> buildReleaseEditions({
    required LibraryAddCatalogTransport item,
  }) {
    return item.editions;
  }

  @override
  LibraryAddSearchResultDisplay? buildSearchResultDisplay({
    required LibraryAddCatalogTransport item,
  }) =>
      _buildAnimeSearchResultDisplay(item);

  @override
  bool canOpenKindDrilldown(LibraryProjectionView item) {
    return item.node.scope == LibraryBrowserScope.title &&
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
    final seriesTitle = dto.common.seriesTitle;
    final variant = dto.common.variant;
    final barcode = dto.barcode;
    final publisher = dto.publisher;
    final releaseDate = dto.common.releaseDate;
    final country = dto.common.country;
    final language = dto.common.language;
    return LibraryMetadataPresentation(
      labels: animeMetadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: item.node.titleItemId),
          LibraryDetailField(label: 'Title', value: dto.title),
        ],
        if (seriesTitle != null)
          LibraryDetailField(
            label: 'Series',
            value: seriesTitle,
            onTap: tapFor(seriesTitle),
          ),
        if (item.node.scope != LibraryBrowserScope.title && variant != null)
          LibraryDetailField(
            label: 'Format / Edition',
            value: variant,
            onTap: tapFor(variant),
          ),
        if (item.node.scope != LibraryBrowserScope.title && barcode != null)
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

  @override
  List<Widget> buildAddPreviewSections({
    required Color accent,
    required CatalogMediaKind kind,
    required String provider,
    required String providerItemId,
  }) {
    return [
      AnimeAddPreviewSeasonsSection(
        kind: kind,
        provider: provider,
        providerItemId: providerItemId,
        accent: accent,
      ),
    ];
  }
}

LibraryAddSearchResultDisplay _buildAnimeSearchResultDisplay(
  LibraryAddCatalogTransport item,
) {
  final itemNumber = item.itemNumber?.trim();
  final subtitle = [
    if (item.publisher?.trim() case final value? when value.isNotEmpty) value,
    if ((item.releaseYear ?? item.releaseDate?.year) case final year?)
      year.toString(),
    if (item.physicalFormatLabel?.trim() case final value?
        when value.isNotEmpty)
      value,
    if (item.identifierCode?.trim() case final value? when value.isNotEmpty)
      value,
  ].join(' | ');
  return LibraryAddSearchResultDisplay(
    title: itemNumber == null || itemNumber.isEmpty
        ? item.title
        : '${item.title} #$itemNumber',
    secondaryLine: subtitle.isEmpty ? null : subtitle,
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

final animeLibraryFilterDefinitions = <LibraryFilterDefinition<dynamic>>[
  LibraryFilterDefinition<dynamic>(
    id: 'series',
    label: 'Series',
    anyLabel: 'Any series',
    value: (item) => (item.dto is WorkspaceDtoAdapter)
        ? (item.dto as WorkspaceDtoAdapter).seriesTitle
        : null,
  ),
  LibraryFilterDefinition<dynamic>(
    id: 'location',
    label: 'Location',
    anyLabel: 'Any location',
  ),
  LibraryFilterDefinition<dynamic>(
    id: 'tag',
    label: 'Tag',
    anyLabel: 'Any tag',
    inputKind: LibraryFilterInputKind.autocomplete,
    value: (item) => AnimeOwnedItemProjection.tryFromTyped(
      item.source.typedOwnedItem,
    )?.tags?.split(','),
  ),
  LibraryFilterDefinition<dynamic>(
    id: 'publisher',
    label: 'Studio',
    anyLabel: 'Any studio',
    value: (item) => (item.dto is AnimeWorkspaceDto)
        ? (item.dto as AnimeWorkspaceDto).publisher
        : null,
  ),
  LibraryFilterDefinition<dynamic>(
    id: 'year',
    label: 'Year',
    anyLabel: 'Any year',
    value: (item) => (item.dto is WorkspaceDtoAdapter)
        ? (item.dto as WorkspaceDtoAdapter).releaseDate?.year.toString()
        : null,
  ),
  LibraryFilterDefinition<dynamic>(
    id: 'condition',
    label: 'Condition',
    anyLabel: 'Any condition',
    value: (item) => AnimeOwnedItemProjection.tryFromTyped(
      item.source.typedOwnedItem,
    )?.condition,
  ),
  LibraryFilterDefinition<dynamic>(
    id: 'country',
    label: 'Country',
    anyLabel: 'Any country',
    value: (item) => (item.dto is WorkspaceDtoAdapter)
        ? (item.dto as WorkspaceDtoAdapter).country
        : null,
  ),
  LibraryFilterDefinition<dynamic>(
    id: 'language',
    label: 'Language',
    anyLabel: 'Any language',
    value: (item) => (item.dto is WorkspaceDtoAdapter)
        ? (item.dto as WorkspaceDtoAdapter).language
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
  usesCompactTableLayout: true,
  compactBucketIcon: Icons.tv_outlined,
  previewLabels: animePreviewLabels,
  statsLabels: animeStatsLabels,
  filterDefinitions: animeLibraryFilterDefinitions,
);
