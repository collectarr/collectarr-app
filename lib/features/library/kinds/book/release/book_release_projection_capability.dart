import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/book/book_physical_media_formats.dart';
import 'package:collectarr_app/features/library/release/library_catalog_release_capability.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_release_summary.dart';

final bookKindReleaseCapability =
    LibraryCatalogReleaseProjectionCapability<BookWorkspaceDto>(
  kind: CatalogMediaKind.book,
  summariesFor: _bookReleaseSummaries,
);

final bookKindReleaseDetailSource = LibraryCatalogReleaseDetailSource(
  summariesFor: _bookReleaseSummaries,
  candidateFor: _bookCandidate,
);

Iterable<LibraryWorkspaceReleaseSummary> _bookReleaseSummaries(
  LibraryWorkspaceCatalogData data,
) sync* {
  final catalog = data as BookWorkspaceCatalogData;
  for (final release in catalog.book.releases) {
    yield LibraryWorkspaceReleaseSummary(
      id: release.id,
      title: release.title,
      formatLabel: release.physicalFormatLabel ?? release.physicalFormat,
      formatBadge: bookFormatBadge(
        release.physicalFormat,
        label: release.physicalFormatLabel,
      ),
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
            formatBadge: bookFormatBadge(
              variant.physicalFormat,
              label: variant.physicalFormatLabel,
            ),
            sku: variant.sku,
            isPrimary: variant.isPrimary,
          ),
      ],
    );
  }
}

CatalogSearchCandidate _bookCandidate(LibraryWorkspaceCatalogData data) {
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
