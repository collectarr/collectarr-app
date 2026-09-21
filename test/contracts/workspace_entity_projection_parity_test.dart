import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_release_summary.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_source.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'every kind projects the exact selected release for ReleaseRef and CopyRef',
      () {
    for (final kind in CatalogMediaKind.values.where(
      (kind) => kind != CatalogMediaKind.unknown,
    )) {
      final workId = 'workspace-${kind.apiValue}';
      final owned = testOwnedItem(
        id: 'owned-${kind.apiValue}',
        itemId: workId,
        kind: kind.apiValue,
      );
      final source = LibraryWorkspaceSource(
        itemId: workId,
        catalogData: testWorkspaceCatalogData(
          testCatalogItem(
            id: workId,
            kind: kind.apiValue,
            title: 'Work ${kind.apiValue}',
            editions: const [
              CatalogEditionDto(
                id: 'release-1',
                title: 'First release',
                publisher: 'First publisher',
              ),
              CatalogEditionDto(
                id: 'release-2',
                title: 'Second release',
                publisher: 'Second publisher',
              ),
            ],
          ),
        ),
        ownedSummary: testOwnedSummary(owned),
      );
      final workspace = libraryKindWorkspaceForKind(kind);
      final releaseRef = LibraryReleaseRef(
        workId: workId,
        releaseId: 'release-2',
        release: const LibraryWorkspaceReleaseSummary(
          id: 'release-2',
          title: 'Second release',
        ),
      );
      final copyRef = LibraryCopyRef(
        workId: workId,
        releaseId: 'release-2',
        ownedRef: source.ownedSummary!.ref,
      );

      final releaseDto = workspace
          .projectorForScope(LibraryEntityScope.release)
          .project(source: source, entity: releaseRef);
      final copyDto = workspace
          .projectorForScope(LibraryEntityScope.copy)
          .project(source: source, entity: copyRef);
      final releaseProjection = _selectedRelease(releaseDto);
      final copyProjection = _selectedRelease(copyDto);

      expect(
        releaseProjection.id,
        'release-2',
        reason: '${kind.apiValue} ReleaseRef must select release-2',
      );
      expect(
        releaseProjection.title,
        'Second release',
        reason: '${kind.apiValue} ReleaseRef must not select release-1',
      );

      expect(
        copyProjection.id,
        'release-2',
        reason: '${kind.apiValue} CopyRef must retain its parent release',
      );
      expect(copyProjection.title, 'Second release');

      final staleReleaseRef = LibraryReleaseRef(
        workId: workId,
        releaseId: 'release-stale',
        release: const LibraryWorkspaceReleaseSummary(
          id: 'release-stale',
          title: 'Stale release',
        ),
      );
      expect(
        () => workspace
            .projectorForScope(LibraryEntityScope.release)
            .project(source: source, entity: staleReleaseRef),
        throwsStateError,
        reason:
            '${kind.apiValue} must reject a stale ReleaseRef instead of using primary release',
      );
      expect(
        () => workspace.projectorForScope(LibraryEntityScope.copy).project(
            source: source,
            entity: LibraryCopyRef(
              workId: workId,
              releaseId: 'release-stale',
              ownedRef: source.ownedSummary!.ref,
            )),
        throwsStateError,
        reason:
            '${kind.apiValue} must reject a stale CopyRef instead of substituting another release',
      );
    }
  });
}

({String id, String title}) _selectedRelease(LibraryWorkspaceDto dto) {
  return switch (dto) {
    AnimeWorkspaceDto(:final release) => (
        id: release!.id.toString(),
        title: release.title,
      ),
    BoardGameWorkspaceDto(:final release) => (
        id: release!.id,
        title: release.title,
      ),
    BookWorkspaceDto(:final release) => (
        id: release!.id,
        title: release.title,
      ),
    ComicWorkspaceDto(:final release) => (
        id: release!.id,
        title: release.title,
      ),
    GameWorkspaceDto(:final release) => (
        id: release!.id,
        title: release.title,
      ),
    MangaWorkspaceDto(:final release) => (
        id: release!.id,
        title: release.title,
      ),
    MovieWorkspaceDto(:final release) => (
        id: release!.id,
        title: release.title,
      ),
    MusicReleaseWorkspaceDto(:final release) => (
        id: release!.id.value,
        title: release.title,
      ),
    MusicOwnedCopyWorkspaceDto(:final release) => (
        id: release!.id.value,
        title: release.title,
      ),
    TvWorkspaceDto(:final release) => (
        id: release!.id,
        title: release.title,
      ),
    _ => throw StateError('Unexpected workspace DTO type: ${dto.runtimeType}'),
  };
}
