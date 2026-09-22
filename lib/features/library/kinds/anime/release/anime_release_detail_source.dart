import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_release.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/release/library_release_detail_option.dart';
import 'package:collectarr_app/features/library/release/library_release_detail_source.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_release_summary.dart';

const _animeReleaseSourceKey = 'release_source';
const _animeReleaseSourceCatalog = 'core_release';

class AnimeReleaseAnchor {
  const AnimeReleaseAnchor({required this.editionId});

  final String editionId;
}

/// Adapts the canonical Core Anime release graph to the shared release
/// summary contract without inventing an identity or a fallback release.
List<CatalogEditionDto> canonicalAnimeReleaseEditions(AnimeMedia media) => [
      for (final release in media.releases) _canonicalEditionFor(release),
    ];

CatalogEditionDto _canonicalEditionFor(AnimeRelease release) {
  final raw = Map<String, dynamic>.from(release.rawPayload);
  final metadata = <String, dynamic>{
    ...raw,
    _animeReleaseSourceKey: _animeReleaseSourceCatalog,
    if (release.media.isNotEmpty)
      'media': release.media.map((entry) => entry.toJson()).toList(),
    if (release.episodeMappings.isNotEmpty)
      'episode_mappings':
          release.episodeMappings.map((entry) => entry.toJson()).toList(),
  };
  return CatalogEditionDto(
    id: release.id.value,
    title: release.title,
    format: release.format,
    publisher: release.publisher,
    distributor: release.distributor,
    upc: release.barcode,
    language: release.audioTracks.firstOrNull,
    region: release.regionCode,
    releaseDate: release.releaseDate,
    physicalFormat: release.format,
    physicalFormatLabel: release.format,
    metadata: metadata,
    discs: [
      for (final media in release.media)
        CatalogDiscDto(
          discNumber: media.mediaNumber,
          name: media.title ?? media.mediaType,
        ),
    ],
  );
}

AnimeReleaseAnchor animeReleaseAnchorForEdition(CatalogEditionDto edition) =>
    AnimeReleaseAnchor(editionId: edition.id);

bool matchesAnimeReleaseAnchor(
  CatalogEditionDto edition, {
  String? editionId,
  String? variantId,
  String? bundleReleaseId,
}) {
  final requestedId = editionId?.trim();
  if (requestedId == null || requestedId.isEmpty) return false;
  return edition.id == requestedId;
}

String animeReleaseSourceLabel(CatalogEditionDto edition) => 'Core release';

bool isCatalogAnimeRelease(CatalogEditionDto edition) => true;

bool isLocalAnchorAnimeRelease(CatalogEditionDto edition) => false;

bool isTitleSnapshotAnimeRelease(CatalogEditionDto edition) => false;

String? preferredAnimeEditionVariantId(CatalogEditionDto edition) => null;

final class AnimeReleaseDetailSource implements LibraryReleaseDetailSource {
  const AnimeReleaseDetailSource();

  List<CatalogEditionDto> resolveCatalogData(
    LibraryWorkspaceCatalogData catalogData, {
    Iterable<OwnedItemSummary> ownedItems = const <OwnedItemSummary>[],
    Iterable<WishlistItem> wishlistItems = const <WishlistItem>[],
  }) {
    if (catalogData is! AnimeWorkspaceCatalogData) {
      throw ArgumentError.value(
        catalogData,
        'catalogData',
        'Expected AnimeWorkspaceCatalogData',
      );
    }
    return canonicalAnimeReleaseEditions(catalogData.media);
  }

  @override
  CatalogSearchCandidate candidateForCatalogData(
    LibraryWorkspaceCatalogData catalogData,
  ) {
    if (catalogData is! AnimeWorkspaceCatalogData) {
      throw ArgumentError.value(
        catalogData,
        'catalogData',
        'Expected AnimeWorkspaceCatalogData',
      );
    }
    return CatalogSearchCandidate.fromItem(catalogData.releaseTransport);
  }

  CatalogEntityRef targetRefForEdition(
    CatalogEntityRef rootRef,
    CatalogEditionDto edition,
  ) {
    return CatalogEntityRef(
      kind: rootRef.kind,
      entityType: const CatalogEntityTypeId('edition'),
      id: edition.id,
      rootId: rootRef.id,
    );
  }

  bool matchesTarget(CatalogEntityRef targetRef, CatalogEditionDto edition) {
    return targetRef.entityType.apiValue == 'edition' &&
        targetRef.id == edition.id;
  }

  String sourceLabel(CatalogEditionDto edition) =>
      animeReleaseSourceLabel(edition);

  bool isCatalogRelease(CatalogEditionDto edition) =>
      isCatalogAnimeRelease(edition);

  bool isTitleSnapshotRelease(CatalogEditionDto edition) =>
      isTitleSnapshotAnimeRelease(edition);

  String? preferredVariantId(CatalogEditionDto edition) =>
      preferredAnimeEditionVariantId(edition);

  LibraryWorkspaceReleaseSummary workspaceSummaryForEdition(
    CatalogEditionDto edition,
  ) {
    return LibraryWorkspaceReleaseSummary(
      id: edition.id,
      title: edition.title,
      formatLabel: edition.format ?? edition.physicalFormatLabel,
      formatBadge: animeFormatBadge(
        edition.physicalFormat,
        label: edition.format ?? edition.physicalFormatLabel,
      ),
      releaseDate: edition.releaseDate,
      variantCount: edition.variants.length,
      variants: [
        for (final variant in edition.variants)
          LibraryWorkspaceVariantSummary(
            id: variant.id,
            name: variant.name,
            coverImageUrl: variant.coverImageUrl,
            thumbnailImageUrl: variant.thumbnailImageUrl,
            formatLabel: variant.physicalFormatLabel ?? variant.physicalFormat,
            sku: variant.sku,
            isPrimary: variant.isPrimary,
          ),
      ],
    );
  }

  @override
  List<LibraryReleaseDetailOption> detailOptionsForCatalogData(
    LibraryWorkspaceCatalogData catalogData,
    CatalogEntityRef rootRef, {
    Iterable<OwnedItemSummary> ownedItems = const <OwnedItemSummary>[],
    Iterable<WishlistItem> wishlistItems = const <WishlistItem>[],
  }) {
    final editions = resolveCatalogData(catalogData);
    return [
      for (final edition in editions)
        LibraryReleaseDetailOption(
          targetRef: targetRefForEdition(rootRef, edition),
          summary: workspaceSummaryForEdition(edition),
          sourceLabel: sourceLabel(edition),
          isCatalogRelease: isCatalogRelease(edition),
          isTitleSnapshotRelease: isTitleSnapshotRelease(edition),
        ),
    ];
  }
}
