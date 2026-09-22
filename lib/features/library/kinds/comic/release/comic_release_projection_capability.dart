import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/release/library_catalog_release_capability.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_release_summary.dart';

final comicKindReleaseCapability =
    LibraryCatalogReleaseProjectionCapability<ComicWorkspaceDto>(
  kind: CatalogMediaKind.comic,
  summariesFor: _comicReleaseSummaries,
);

final comicKindReleaseDetailSource = LibraryCatalogReleaseDetailSource(
  summariesFor: _comicReleaseSummaries,
  candidateFor: _comicCandidate,
);

Iterable<LibraryWorkspaceReleaseSummary> _comicReleaseSummaries(
  LibraryWorkspaceCatalogData data,
) sync* {
  final catalog = data as ComicWorkspaceCatalogData;
  for (final release in catalog.comic.releases) {
    yield LibraryWorkspaceReleaseSummary(
      id: release.id,
      title: release.title,
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

CatalogSearchCandidate _comicCandidate(LibraryWorkspaceCatalogData data) {
  return CatalogSearchCandidate.fromSummary(
    summary: CatalogDisplaySummary(
      ref: data.ref.rootScope,
      kind: data.kind,
      title: data.title,
      subtitle: data.synopsis,
      imageUrl: data.coverImageUrl,
    ),
  );
}
