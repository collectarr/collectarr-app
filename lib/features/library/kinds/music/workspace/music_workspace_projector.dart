import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MusicWorkspaceProjector
    implements LibraryWorkspaceProjector<MusicWorkspaceDto> {
  const MusicWorkspaceProjector();

  @override
  MusicWorkspaceDto projectTitle({
    required LibraryWorkspaceSource source,
    required LibraryTitleNodeRef node,
  }) {
    final music = MusicCatalogMapper.mapMetadataItemToMusic(
      source.catalogTransport!.toTransportItem(),
    );
    final release = MusicWorkspaceMapper.fromCatalogItem(
      source.catalogTransport!.toTransportItem(),
    );
    MusicCatalogMetadata? metadata;
    final km = source.catalogTransport?.kindMetadata;
    if (km is MusicCatalogMetadata) {
      metadata = km;
    }
    return MusicWorkspaceDto(
      common: _musicCommonProjection(source, node),
      personal: PersonalCopyProjection.fromShelf(source),
      music: music,
      release: release,
      metadata: metadata,
    );
  }

  @override
  MusicWorkspaceDto projectRelease({
    required LibraryWorkspaceSource source,
    required LibraryReleaseNodeRef node,
    required LibraryReleaseState releaseState,
  }) {
    final music = MusicCatalogMapper.mapMetadataItemToMusic(
      source.catalogTransport!.toTransportItem(),
    );
    final release = MusicWorkspaceMapper.fromCatalogItem(
      source.catalogTransport!.toTransportItem(),
      releaseId: node.releaseId,
      edition: node.edition,
    );
    MusicCatalogMetadata? metadata;
    final km = source.catalogTransport?.kindMetadata;
    if (km is MusicCatalogMetadata) {
      metadata = km;
    }
    return MusicWorkspaceDto(
      common: _musicCommonProjection(source, node),
      personal:
          PersonalCopyProjection.fromShelf(source, releaseState: releaseState),
      music: music,
      release: release,
      metadata: metadata,
    );
  }

  @override
  MusicWorkspaceDto projectCopy({
    required LibraryWorkspaceSource source,
    required LibraryCopyNodeRef node,
  }) {
    return projectTitle(
      source: source,
      node: LibraryTitleNodeRef(titleItemId: node.titleItemId),
    );
  }
}

WorkspaceCommonProjection _musicCommonProjection(
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
  final payload =
      catalog?.toTransportItem().payload ?? const <String, dynamic>{};
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
