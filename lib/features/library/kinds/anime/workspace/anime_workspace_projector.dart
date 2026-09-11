import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/anime/catalog/anime_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_mapper.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class AnimeWorkspaceProjector
    implements LibraryWorkspaceProjector<AnimeWorkspaceDto> {
  const AnimeWorkspaceProjector();

  @override
  AnimeWorkspaceDto projectTitle({
    required LibraryWorkspaceSource source,
    required LibraryTitleNodeRef node,
  }) {
    final video = AnimeCatalogMapper.mapMetadataItemToAnime(
      source.catalogTransport!.toTransportItem(),
    );
    final media = AnimeWorkspaceMapper.fromCatalogItem(
      source.catalogTransport!.toTransportItem(),
    );
    final km = source.catalogTransport?.toTransportItem().kindMetadata;
    final AnimeMetadata? metadata = km is AnimeMetadata
        ? km
        : (km != null
            ? AnimeMetadata.fromJson(
                source.catalogTransport!.toTransportItem().payload,
              )
            : null);
    return AnimeWorkspaceDto(
      common: _animeCommonProjection(source, node),
      personal: PersonalCopyProjection.fromShelf(source),
      video: video,
      media: media,
      metadata: metadata,
    );
  }

  @override
  AnimeWorkspaceDto projectRelease({
    required LibraryWorkspaceSource source,
    required LibraryReleaseNodeRef node,
    required LibraryReleaseState releaseState,
  }) {
    final video = AnimeCatalogMapper.mapMetadataItemToAnime(
      source.catalogTransport!.toTransportItem(),
    );
    final media = AnimeWorkspaceMapper.fromCatalogItem(
      source.catalogTransport!.toTransportItem(),
    );
    final km = source.catalogTransport?.toTransportItem().kindMetadata;
    final AnimeMetadata? metadata = km is AnimeMetadata
        ? km
        : (km != null
            ? AnimeMetadata.fromJson(
                source.catalogTransport!.toTransportItem().payload,
              )
            : null);
    return AnimeWorkspaceDto(
      common: _animeCommonProjection(source, node),
      personal: PersonalCopyProjection.fromShelf(source),
      video: video,
      media: media,
      metadata: metadata,
    );
  }

  @override
  AnimeWorkspaceDto projectCopy({
    required LibraryWorkspaceSource source,
    required LibraryCopyNodeRef node,
  }) {
    final video = AnimeCatalogMapper.mapMetadataItemToAnime(
      source.catalogTransport!.toTransportItem(),
    );
    final media = AnimeWorkspaceMapper.fromCatalogItem(
      source.catalogTransport!.toTransportItem(),
    );
    final km = source.catalogTransport?.toTransportItem().kindMetadata;
    final AnimeMetadata? metadata = km is AnimeMetadata
        ? km
        : (km != null
            ? AnimeMetadata.fromJson(
                source.catalogTransport!.toTransportItem().payload,
              )
            : null);
    return AnimeWorkspaceDto(
      common: _animeCommonProjection(source, node),
      personal: PersonalCopyProjection.fromShelf(source),
      video: video,
      media: media,
      metadata: metadata,
    );
  }
}

WorkspaceCommonProjection _animeCommonProjection(
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
