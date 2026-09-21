import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/release/library_catalog_release_capability.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_release_summary.dart';

final mangaKindReleaseCapability =
    LibraryCatalogReleaseProjectionCapability<MangaWorkspaceDto>(
  kind: CatalogMediaKind.manga,
  summariesFor: _mangaReleaseSummaries,
);

final mangaKindReleaseDetailSource = LibraryCatalogReleaseDetailSource(
  summariesFor: _mangaReleaseSummaries,
  candidateFor: _mangaCandidate,
);

Iterable<LibraryWorkspaceReleaseSummary> _mangaReleaseSummaries(
  LibraryWorkspaceCatalogData data,
) sync* {
  final catalog = data as MangaWorkspaceCatalogData;
  for (final release in catalog.metadata.editions) {
    yield LibraryWorkspaceReleaseSummary(
      id: release.id,
      title: release.title,
      formatLabel: release.displayFormat,
      releaseDate: release.releaseDate,
      variantCount: release.variants.length,
      variants: [
        for (final variant in release.variants)
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
}

CatalogSearchCandidate _mangaCandidate(LibraryWorkspaceCatalogData data) {
  return CatalogSearchCandidate.fromKindProjection(
    id: data.ref.rootScope.id,
    kind: data.kind,
    title: data.title,
    synopsis: data.synopsis,
    coverImageUrl: data.coverImageUrl,
    releaseDate: data.releaseDate,
  );
}
