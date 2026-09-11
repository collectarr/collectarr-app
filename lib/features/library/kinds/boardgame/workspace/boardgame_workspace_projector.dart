import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class BoardGameWorkspaceProjector
    implements LibraryWorkspaceProjector<BoardGameWorkspaceDto> {
  const BoardGameWorkspaceProjector();

  @override
  BoardGameWorkspaceDto projectTitle({
    required LibraryWorkspaceSource source,
    required LibraryTitleNodeRef node,
  }) {
    final boardgame = BoardGameCatalogMapper.mapMetadataItemToBoardGame(
      source.catalogTransport!.mapTransport((transport) => transport),
    );
    BoardGameMetadata? metadata;
    final km = source.catalogTransport
        ?.mapTransport((transport) => transport)
        .kindMetadata;
    if (km is BoardGameMetadata) {
      metadata = km;
    }
    return BoardGameWorkspaceDto(
      common: _boardGameCommonProjection(source, node),
      personal: PersonalCopyProjection.fromShelf(source),
      boardgame: boardgame,
      metadata: metadata,
    );
  }

  @override
  BoardGameWorkspaceDto projectRelease({
    required LibraryWorkspaceSource source,
    required LibraryReleaseNodeRef node,
    required LibraryReleaseState releaseState,
  }) {
    final boardgame = BoardGameCatalogMapper.mapMetadataItemToBoardGame(
      source.catalogTransport!.mapTransport((transport) => transport),
    );
    final metadata = _metadataFor(source);
    return BoardGameWorkspaceDto(
      common: _boardGameCommonProjection(source, node),
      personal:
          PersonalCopyProjection.fromShelf(source, releaseState: releaseState),
      boardgame: boardgame,
      metadata: metadata,
    );
  }

  @override
  BoardGameWorkspaceDto projectCopy({
    required LibraryWorkspaceSource source,
    required LibraryCopyNodeRef node,
  }) {
    return projectTitle(
      source: source,
      node: LibraryTitleNodeRef(titleItemId: node.titleItemId),
    );
  }

  static BoardGameMetadata? _metadataFor(LibraryWorkspaceSource source) {
    final metadata = source.catalogTransport
        ?.mapTransport((transport) => transport)
        .kindMetadata;
    if (metadata is BoardGameMetadata) {
      return metadata;
    }
    return metadata == null
        ? null
        : BoardGameMetadata.fromJson(
            source.catalogTransport!
                .mapTransport((transport) => transport)
                .payload,
          );
  }
}

WorkspaceCommonProjection _boardGameCommonProjection(
  LibraryWorkspaceSource source,
  LibraryNodeRef node,
) {
  final catalog = source.catalogTransport;
  final edition = node is LibraryReleaseNodeRef ? node.edition : null;
  CatalogVariantDto? primaryVariant;
  if (edition != null) {
    for (final candidate in edition.variants) {
      if (candidate.isPrimary) {
        primaryVariant = candidate;
        break;
      }
    }
    primaryVariant ??= edition.variants.isEmpty ? null : edition.variants.first;
  }
  final payload = catalog?.mapTransport((transport) => transport).payload ??
      const <String, dynamic>{};
  final rawSeries = payload['series'];
  final seriesMap = rawSeries is Map ? rawSeries : null;
  final publishing = payload['publishing'] as Map?;
  return WorkspaceCommonProjection(
    title: catalog?.displayTitle ?? catalog?.title ?? '',
    synopsis: catalog?.synopsis,
    seriesTitle: (seriesMap?['series_title'] ??
            seriesMap?['seriesTitle'] ??
            (rawSeries is String ? rawSeries : null) ??
            payload['series_title'] ??
            payload['seriesTitle'])
        ?.toString(),
    itemNumber: (payload['item_number'] ?? payload['itemNumber'])?.toString(),
    releaseDate: edition?.releaseDate ?? catalog?.releaseDate,
    variant: primaryVariant?.name ??
        edition?.title ??
        payload['variant']?.toString(),
    country:
        (payload['country'] ?? publishing?['original_country'])?.toString(),
    language: edition?.language ??
        (payload['language'] ?? publishing?['original_language'])?.toString(),
    currency: source.ownedSummary?.currency,
    referenceFormatLabel: primaryVariant?.physicalFormat ??
        edition?.format ??
        (payload['physical_format_label'] ?? payload['physical_format'])
            ?.toString(),
    coverImageUrl: primaryVariant?.coverImageUrl ??
        primaryVariant?.thumbnailImageUrl ??
        catalog?.coverImageUrl,
  );
}
