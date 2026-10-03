import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_fields.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/config/library_duplicate_presentation.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/game/game_physical_media_formats.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';

class GameLibraryMediaPresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const GameLibraryMediaPresentationBuilder({
    this.metadataLabels = const LibraryMetadataLabels(),
  });

  final LibraryMetadataLabels metadataLabels;

  @override
  String? buildAddPreviewItemNumber({
    required CatalogSearchCandidate item,
  }) =>
      item.gameCatalogFields.itemNumber;

  @override
  List<LibraryFormatBadgeDescriptor> buildAddPreviewFormatBadges({
    required CatalogSearchCandidate item,
  }) {
    final itemDto = item.gameCatalogFields.metadata;
    if (itemDto == null) return const [];
    final badge = gameFormatBadge(
      itemDto.physicalFormat,
      label: itemDto.physicalFormatLabel,
    );
    return badge == null ? const [] : [badge];
  }

  @override
  List<LibraryDuplicateCandidate> buildDuplicateCandidates(
    LibraryWorkspaceSource entry,
  ) {
    final catalog = entry.catalogData;
    if (catalog is! GameWorkspaceCatalogData) return const [];
    final metadata = catalog.metadata;
    final identifier = normalizeLibraryDuplicateIdentifier(metadata.barcode);
    if (identifier == null) return const [];
    return [
      LibraryDuplicateCandidate(
        key: 'identifier:$identifier',
        label: 'Identifier ${metadata.barcode!.trim()}',
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
    final hydratedMetadata = hydrated.gameCatalogFields;
    final fallbackMetadata = fallback.gameCatalogFields;
    final coverImageUrl =
        hydratedMetadata.coverImageUrl ?? fallbackMetadata.coverImageUrl;
    final thumbnailImageUrl = hydratedMetadata.coverImageUrl != null
        ? hydratedMetadata.thumbnailImageUrl
        : fallbackMetadata.thumbnailImageUrl ?? fallbackMetadata.coverImageUrl;
    return CatalogSearchCandidate.fromItem(
      hydrated.kindCapability.mapTransport((transport) {
        final metadata = GameCatalogMetadata.fromJson(transport.kindData);
        final updated = GameCatalogMetadata.fromJson(applyJsonFieldPatch(
          metadata,
          {
            'cover_image_url': coverImageUrl,
            'thumbnail_image_url': thumbnailImageUrl,
          },
        ));
        return transport.replacingKindData(updated);
      }),
    );
  }

  @override
  String? buildAddPreviewSynopsis({required CatalogSearchCandidate item}) =>
      item.gameCatalogFields.synopsis;

  @override
  List<String> buildCatalogSearchAliases({
    required CatalogSearchCandidate item,
  }) =>
      item.gameCatalogFields.searchAliases;

  @override
  LibraryAddSearchResultDisplay? buildSearchResultDisplay({
    required CatalogSearchCandidate item,
  }) =>
      _buildGameSearchResultDisplay(item);

  @override
  List<(String, String?)> buildAddPreviewMetadataRows({
    required CatalogSearchCandidate item,
    required LibraryMediaPreviewLabels previewLabels,
  }) {
    final fields = item.gameCatalogFields;
    final metadata = fields.metadata;
    final releaseDate = fields.releaseDate;
    return [
      (
        previewLabels.labelFor('publisher', fallback: 'Publisher'),
        metadata?.publisher ?? metadata?.developers.firstOrNull
      ),
      (
        'Released',
        releaseDate == null
            ? item.gameCatalogFields.releaseYear?.toString()
            : '${releaseDate.year}-${releaseDate.month.toString().padLeft(2, '0')}-${releaseDate.day.toString().padLeft(2, '0')}',
      ),
      if (item.gameCatalogFields.itemNumber != null)
        (
          previewLabels.labelFor('item_number', fallback: 'Number'),
          item.gameCatalogFields.itemNumber
        ),
      if ((metadata?.variantName ?? metadata?.editionTitle) != null)
        (
          previewLabels.labelFor('variant', fallback: 'Variant'),
          metadata?.variantName ?? metadata?.editionTitle
        ),
      (
        previewLabels.labelFor('barcode', fallback: 'Barcode'),
        metadata?.barcode
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
    final adapter = dto is GameWorkspaceDto ? dto : null;
    final gameDto = dto is GameWorkspaceDto ? dto : null;
    final variant = adapter?.variant;
    final barcode = gameDto?.barcode;
    final publisher = gameDto?.publisher;
    final releaseDate = adapter?.releaseDate;

    final metadata = item.source.catalogData is GameWorkspaceCatalogData
        ? (item.source.catalogData! as GameWorkspaceCatalogData).metadata
        : null;
    return LibraryMetadataPresentation(
      labels: metadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: item.node.catalogItemId),
          LibraryDetailField(label: 'Title', value: dto.primaryLabel),
        ],
        if (variant != null)
          LibraryDetailField(
              label: 'Platform / Edition',
              value: variant,
              onTap: tapFor(variant)),
        if (barcode != null)
          LibraryDetailField(label: 'UPC / Barcode', value: barcode),
        if (metadata?.ageRating != null)
          LibraryDetailField(label: 'Age Rating', value: metadata!.ageRating!),
      ],
      contextFacts: [
        if (publisher != null)
          LibraryDetailField(
              label: 'Publisher / Studio',
              value: publisher,
              onTap: tapFor(publisher)),
        if (releaseDate != null)
          LibraryDetailField(
            label: 'Released',
            value: formatPresentationNullableDate(releaseDate) ??
                releaseDate.year.toString(),
          ),
      ],
      sections: {
        'creators': LibraryMetadataSection(
          values:
              metadata?.creators.map((credit) => credit.toJson()).toList() ??
                  const <Map<String, dynamic>>[],
          placement: LibraryMetadataSectionPlacement.credits,
          renderer: LibraryMetadataSectionRenderer.credits,
          completenessWeight: 12,
        ),
        'genres': LibraryMetadataSection(
          values: metadata?.genres ?? const <String>[],
        ),
      },
    );
  }
}

LibraryAddSearchResultDisplay _buildGameSearchResultDisplay(
  CatalogSearchCandidate item,
) {
  final fields = item.gameCatalogFields;
  final metadata = fields.metadata;
  final itemNumber = fields.itemNumber?.trim();
  final subtitle = [
    if ((metadata?.publisher ?? metadata?.developers.firstOrNull)?.trim()
        case final value? when value.isNotEmpty)
      value,
    if ((fields.releaseYear ?? fields.releaseDate?.year) case final year?)
      year.toString(),
    if ((metadata?.physicalFormatLabel ?? metadata?.physicalFormat)?.trim()
        case final value? when value.isNotEmpty)
      value,
    if (metadata?.barcode?.trim() case final value? when value.isNotEmpty)
      value,
  ].join(' | ');
  return LibraryAddSearchResultDisplay(
    title: itemNumber == null || itemNumber.isEmpty
        ? item.summary.primaryLabel
        : '${item.summary.primaryLabel} #$itemNumber',
    secondaryLine: subtitle.isEmpty ? null : subtitle,
    year: fields.releaseYear ?? fields.releaseDate?.year,
    detailLine: null,
  );
}
