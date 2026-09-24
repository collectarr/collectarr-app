import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/game_physical_media_formats.dart';
import 'package:collectarr_app/features/library/release/library_catalog_release_capability.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_release_summary.dart';

final gameKindReleaseCapability =
    LibraryCatalogReleaseProjectionCapability<GameWorkspaceDto>(
  kind: CatalogMediaKind.game,
  summariesFor: _gameReleaseSummaries,
);

final gameKindReleaseDetailSource = LibraryCatalogReleaseDetailSource(
  summariesFor: _gameReleaseSummaries,
  candidateFor: _gameCandidate,
);

Iterable<LibraryWorkspaceReleaseSummary> _gameReleaseSummaries(
  LibraryWorkspaceCatalogData data,
) sync* {
  final catalog = data as GameWorkspaceCatalogData;
  for (final release in catalog.game.releases) {
    yield LibraryWorkspaceReleaseSummary(
      id: release.id,
      title: release.title,
      formatLabel: release.format,
      formatBadge: gameFormatBadge(release.format),
      releaseDate: release.releaseDate,
    );
  }
}

CatalogSearchCandidate _gameCandidate(LibraryWorkspaceCatalogData data) {
  return CatalogSearchCandidate.fromSummary(
    summary: CatalogDisplaySummary(
      ref: data.ref.rootScope,
      kind: data.kind,
      primaryLabel: data.title,
      subtitle: libraryWorkspaceCatalogSynopsis(data),
      imageUrl: data.coverImageUrl,
    ),
  );
}
