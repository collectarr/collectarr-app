import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_duplicate_presentation.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_transport.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

class GameLibraryMediaPresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const GameLibraryMediaPresentationBuilder({
    this.metadataLabels = const LibraryMetadataLabels(),
  });

  final LibraryMetadataLabels metadataLabels;

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
      _buildGameSearchResultDisplay(item);

  @override
  LibraryMetadataPresentation buildMetadataPresentation({
    required String singularLabel,
    required LibraryProjectionView item,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  }) {
    final dto = item.dto;
    final adapter = dto is WorkspaceDtoAdapter ? dto : null;
    final gameDto = dto is GameWorkspaceDto ? dto : null;
    final variant = adapter?.variant;
    final barcode = gameDto?.barcode;
    final publisher = gameDto?.publisher;
    final releaseDate = adapter?.releaseDate;

    final kindMetadata = item.source.catalogTransport?.kindMetadata;
    final metadata = kindMetadata is GameCatalogMetadata ? kindMetadata : null;
    return LibraryMetadataPresentation(
      labels: metadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: item.node.titleItemId),
          LibraryDetailField(label: 'Title', value: dto.title),
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
          values: metadata?.creators ?? const <Map<String, dynamic>>[],
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
