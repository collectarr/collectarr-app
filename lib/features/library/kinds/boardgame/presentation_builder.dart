import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_fields.dart';
import 'package:collectarr_app/features/library/config/library_duplicate_presentation.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_physical_media_formats.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';

class BoardGameLibraryMediaPresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const BoardGameLibraryMediaPresentationBuilder({
    this.metadataLabels = const LibraryMetadataLabels(),
  });

  final LibraryMetadataLabels metadataLabels;

  @override
  LibraryCardPresentation buildCardPresentation(
    LibraryProjectionView item, {
    bool coverFocused = false,
  }) {
    final dto = item.dto is BoardGameWorkspaceDto
        ? item.dto as BoardGameWorkspaceDto
        : null;
    return LibraryCardPresentation(
      itemNumber: dto?.itemNumber,
      variant: dto?.variant,
      releaseDate: dto?.releaseDate,
      format: dto?.format,
      synopsis: dto?.synopsis,
      seriesTitle: dto?.seriesTitle,
      identifierCode: dto?.identifierCode,
      currency: dto?.currency,
      contextFacts: [
        dto?.publisher,
      ].whereType<String>().where((value) => value.trim().isNotEmpty).toList(),
    );
  }

  @override
  String? buildAddPreviewItemNumber({
    required CatalogSearchCandidate item,
  }) =>
      item.kindCapability.mapTransport((transport) => transport).itemNumber;

  @override
  List<LibraryFormatBadgeDescriptor> buildAddPreviewFormatBadges({
    required CatalogSearchCandidate item,
  }) {
    final transport =
        item.kindCapability.mapTransport((transport) => transport);
    final badge = boardGameFormatBadge(
      transport.physicalFormat,
      label: transport.physicalFormatLabel,
    );
    return badge == null ? const [] : [badge];
  }

  @override
  List<LibraryDuplicateCandidate> buildDuplicateCandidates(
    LibraryWorkspaceSource entry,
  ) {
    final catalog = entry.catalogData;
    if (catalog is! BoardGameWorkspaceCatalogData) return const [];
    final item = catalog.boardgame;
    final identifier = normalizeLibraryDuplicateIdentifier(item.barcode);
    if (identifier == null) return const [];
    return [
      LibraryDuplicateCandidate(
        key: 'identifier:$identifier',
        label: 'Identifier ${item.barcode!.trim()}',
        reason: 'Same identifier',
        confidenceScore: 78,
      ),
    ];
  }

  @override
  CatalogSearchCandidate mergeHydratedAddItem({
    required CatalogSearchCandidate hydrated,
    required CatalogSearchCandidate fallback,
  }) {
    final hydratedMetadata = hydrated.boardGameCatalogFields;
    final fallbackMetadata = fallback.boardGameCatalogFields;
    final coverImageUrl =
        hydratedMetadata.coverImageUrl ?? fallbackMetadata.coverImageUrl;
    final thumbnailImageUrl = hydratedMetadata.coverImageUrl != null
        ? hydratedMetadata.thumbnailImageUrl
        : fallbackMetadata.thumbnailImageUrl ?? fallbackMetadata.coverImageUrl;
    return CatalogSearchCandidate.fromItem(
      hydrated.kindCapability.mapTransport(
        (transport) => transport.copyWith(
          coverImageUrl: coverImageUrl,
          thumbnailImageUrl: thumbnailImageUrl,
        ),
      ),
    );
  }

  @override
  String? buildAddPreviewSynopsis({required CatalogSearchCandidate item}) =>
      item.boardGameCatalogFields.synopsis;

  @override
  List<String> buildCatalogSearchAliases({
    required CatalogSearchCandidate item,
  }) =>
      item.boardGameCatalogFields.searchAliases;

  @override
  LibraryAddSearchResultDisplay? buildSearchResultDisplay({
    required CatalogSearchCandidate item,
  }) =>
      _buildBoardGameSearchResultDisplay(item);

  @override
  List<(String, String?)> buildAddPreviewMetadataRows({
    required CatalogSearchCandidate item,
    required LibraryMediaPreviewLabels previewLabels,
  }) {
    final releaseDate = item.boardGameCatalogFields.releaseDate;
    return [
      (
        previewLabels.labelFor('publisher', fallback: 'Publisher'),
        item.kindCapability.mapTransport((transport) => transport).publisher
      ),
      (
        'Released',
        releaseDate == null
            ? item.boardGameCatalogFields.releaseYear?.toString()
            : '${releaseDate.year}-${releaseDate.month.toString().padLeft(2, '0')}-${releaseDate.day.toString().padLeft(2, '0')}',
      ),
      if (item.kindCapability
              .mapTransport((transport) => transport)
              .itemNumber !=
          null)
        (
          previewLabels.labelFor('item_number', fallback: 'Number'),
          item.kindCapability.mapTransport((transport) => transport).itemNumber
        ),
      if (item.kindCapability.mapTransport((transport) => transport).variant !=
          null)
        (
          previewLabels.labelFor('variant', fallback: 'Variant'),
          item.kindCapability.mapTransport((transport) => transport).variant
        ),
      (
        previewLabels.labelFor('barcode', fallback: 'Barcode'),
        item.kindCapability
            .mapTransport((transport) => transport)
            .identifierCode
      ),
    ];
  }

  @override
  LibraryMetadataPresentation buildMetadataPresentation({
    required String singularLabel,
    required LibraryProjectionView item,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  }) {
    final dto = item.dto;
    final adapter = dto is BoardGameWorkspaceDto ? dto : null;
    final bgDto = dto is BoardGameWorkspaceDto ? dto : null;
    final itemNumber = adapter?.itemNumber;
    final variant = adapter?.variant;
    final barcode = bgDto?.barcode;
    final publisher = bgDto?.publisher;
    final releaseDate = adapter?.releaseDate;
    final country = adapter?.country;
    final language = adapter?.language;

    final metadata = item.source.catalogData is BoardGameWorkspaceCatalogData
        ? (item.source.catalogData! as BoardGameWorkspaceCatalogData).metadata
        : null;
    final series = metadata?.series;

    return LibraryMetadataPresentation(
      labels: metadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: item.node.workId),
          LibraryDetailField(label: 'Title', value: dto.primaryLabel),
        ],
        if (series?.seriesTitle != null)
          LibraryDetailField(
              label: 'Series',
              value: series!.seriesTitle!,
              onTap: tapFor(series.seriesTitle)),
        LibraryDetailField(
            label: 'Edition',
            value: genericLibraryDash(itemNumber),
            onTap: tapFor(itemNumber)),
        LibraryDetailField(
            label: 'Expansion / Edition',
            value: genericLibraryDash(variant),
            onTap: tapFor(variant)),
        LibraryDetailField(
            label: 'Barcode', value: genericLibraryDash(barcode)),
      ],
      contextFacts: [
        LibraryDetailField(
            label: 'Publisher / Designer',
            value: genericLibraryDash(publisher),
            onTap: tapFor(publisher)),
        LibraryDetailField(
            label: 'Released',
            value: genericLibraryDash(
              formatPresentationNullableDate(releaseDate) ??
                  releaseDate?.year.toString(),
            )),
        if (metadata?.minPlayers != null || metadata?.maxPlayers != null)
          LibraryDetailField(
            label: 'Players',
            value: (metadata?.minPlayers != null &&
                    metadata?.maxPlayers != null &&
                    metadata!.minPlayers != metadata.maxPlayers)
                ? '${metadata.minPlayers}â€“${metadata.maxPlayers}'
                : '${metadata?.maxPlayers ?? metadata?.minPlayers}',
          ),
        if (metadata?.minPlaytimeMinutes != null ||
            metadata?.maxPlaytimeMinutes != null)
          LibraryDetailField(
            label: 'Playtime',
            value: (metadata?.minPlaytimeMinutes != null &&
                    metadata?.maxPlaytimeMinutes != null &&
                    metadata!.minPlaytimeMinutes != metadata.maxPlaytimeMinutes)
                ? '${metadata.minPlaytimeMinutes}-${metadata.maxPlaytimeMinutes} min'
                : '${metadata?.maxPlaytimeMinutes ?? metadata?.minPlaytimeMinutes} min',
          ),
        if (metadata?.minimumAge != null)
          LibraryDetailField(
            label: 'Min Age',
            value: '${metadata!.minimumAge}+',
          ),
        if (metadata?.complexityWeight != null)
          LibraryDetailField(
            label: 'Complexity',
            value: '${metadata!.complexityWeight!.toStringAsFixed(2)} / 5.0',
          ),
        if (metadata?.bggRank != null)
          LibraryDetailField(label: 'BGG Rank', value: '#${metadata!.bggRank}'),
        if (metadata?.bggRating != null)
          LibraryDetailField(
              label: 'BGG Rating',
              value: metadata!.bggRating!.toStringAsFixed(1)),
        if (country != null)
          LibraryDetailField(
              label: 'Country', value: country, onTap: tapFor(country)),
        if (language != null)
          LibraryDetailField(
              label: 'Language', value: language, onTap: tapFor(language)),
      ],
      sections: {
        'creators': LibraryMetadataSection(
          values: metadata?.creators ?? const <Map<String, dynamic>>[],
          placement: LibraryMetadataSectionPlacement.credits,
          renderer: LibraryMetadataSectionRenderer.credits,
          completenessWeight: 12,
        ),
        'genres': LibraryMetadataSection(
          values: metadata?.categories ?? const <String>[],
        ),
      },
    );
  }
}

LibraryAddSearchResultDisplay _buildBoardGameSearchResultDisplay(
  CatalogSearchCandidate item,
) {
  final itemNumber = item.kindCapability
      .mapTransport((transport) => transport)
      .itemNumber
      ?.trim();
  final subtitle = [
    if (item.kindCapability
            .mapTransport((transport) => transport)
            .publisher
            ?.trim()
        case final value? when value.isNotEmpty)
      value,
    if ((item.boardGameCatalogFields.releaseYear ??
            item.boardGameCatalogFields.releaseDate?.year)
        case final year?)
      year.toString(),
    if (item.kindCapability
            .mapTransport((transport) => transport)
            .physicalFormatLabel
            ?.trim()
        case final value? when value.isNotEmpty)
      value,
    if (item.kindCapability
            .mapTransport((transport) => transport)
            .identifierCode
            ?.trim()
        case final value? when value.isNotEmpty)
      value,
  ].join(' | ');
  return LibraryAddSearchResultDisplay(
    title: itemNumber == null || itemNumber.isEmpty
        ? item.summary.primaryLabel
        : '${item.summary.primaryLabel} #$itemNumber',
    secondaryLine: subtitle.isEmpty ? null : subtitle,
    year: item.boardGameCatalogFields.releaseYear ??
        item.boardGameCatalogFields.releaseDate?.year,
    detailLine: null,
  );
}
