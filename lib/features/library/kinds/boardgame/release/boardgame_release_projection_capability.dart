import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_physical_media_formats.dart';
import 'package:collectarr_app/features/library/release/library_catalog_release_capability.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_release_summary.dart';

final boardGameKindReleaseCapability =
    LibraryCatalogReleaseProjectionCapability<BoardGameWorkspaceDto>(
  kind: CatalogMediaKind.boardgame,
  summariesFor: _boardGameReleaseSummaries,
);

final boardGameKindReleaseDetailSource = LibraryCatalogReleaseDetailSource(
  summariesFor: _boardGameReleaseSummaries,
  candidateFor: _boardGameCandidate,
);

Iterable<LibraryWorkspaceReleaseSummary> _boardGameReleaseSummaries(
  LibraryWorkspaceCatalogData data,
) sync* {
  final catalog = data as BoardGameWorkspaceCatalogData;
  for (final release in catalog.boardgame.releases) {
    yield LibraryWorkspaceReleaseSummary(
      id: release.id,
      title: release.title,
      formatLabel: release.format,
      formatBadge: boardGameFormatBadge(release.format),
      releaseDate: release.releaseDate,
    );
  }
}

CatalogSearchCandidate _boardGameCandidate(
  LibraryWorkspaceCatalogData data,
) {
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
