import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_owned_item_projection.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MangaWorkspaceProjector
    implements LibraryWorkspaceProjector<MangaWorkspaceDto> {
  const MangaWorkspaceProjector();

  @override
  MangaWorkspaceDto projectTitle({
    required LibraryWorkspaceSource source,
    required LibraryTitleNodeRef node,
  }) {
    MangaMetadata? metadata;
    final km = source.catalogTransport
        ?.mapTransport((transport) => transport)
        .kindMetadata;
    if (km is MangaMetadata) {
      metadata = km;
    }
    final owned =
        MangaOwnedItemProjection.fromDispatch(source.ownedItemDispatch);
    final ownedDetails = owned is MangaOwnedItem ? owned.details : null;

    return MangaWorkspaceDto(
      common: _mangaCommonProjection(source, node),
      personal: PersonalCopyProjection.fromShelf(source),
      metadata: metadata,
      ownedDetails: ownedDetails,
    );
  }

  @override
  MangaWorkspaceDto projectRelease({
    required LibraryWorkspaceSource source,
    required LibraryReleaseNodeRef node,
    required LibraryReleaseState releaseState,
  }) {
    throw UnsupportedError(
        'Release projection is not supported for MangaWorkspaceProjector');
  }

  @override
  MangaWorkspaceDto projectCopy({
    required LibraryWorkspaceSource source,
    required LibraryCopyNodeRef node,
  }) {
    throw UnsupportedError(
        'Copy projection is not supported for MangaWorkspaceProjector');
  }
}

WorkspaceCommonProjection _mangaCommonProjection(
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
