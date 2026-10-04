import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
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
      final catalogItemId = 'workspace-${kind.apiValue}';
      final entry = testLibraryEntry(
        id: 'entry-${kind.apiValue}',
        itemId: catalogItemId,
        kind: kind.apiValue,
      );
      final source = LibraryWorkspaceSource(
        itemId: catalogItemId,
        catalogData: testWorkspaceCatalogData(
          testCatalogItem(
            id: catalogItemId,
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
        libraryEntrySummary: testLibraryEntrySummary(entry),
      );
      final workspace = libraryKindWorkspaceForKind(kind);
      if (kind == CatalogMediaKind.anime || kind == CatalogMediaKind.manga) {
        expect(
          () => workspace.projectorForScope(LibraryEntityScope.release),
          throwsStateError,
          reason:
              '${kind.apiValue} editions are Catalog Items, not Release nodes',
        );
        continue;
      }
      final releaseRef = LibraryReleaseRef(
        catalogItemId: catalogItemId,
        releaseId: 'release-2',
        release: const LibraryWorkspaceReleaseSummary(
          id: 'release-2',
          title: 'Second release',
        ),
      );
      final copyRef = LibraryEntryNodeRef(
        catalogItemId: catalogItemId,
        libraryEntryRef: source.libraryEntrySummary!.ref,
      );

      final releaseDto = workspace
          .projectorForScope(LibraryEntityScope.release)
          .project(source: source, entity: releaseRef);
      final copyDto = workspace
          .projectorForScope(LibraryEntityScope.libraryEntry)
          .project(source: source, entity: copyRef);
      final releaseProjection = _selectedRelease(releaseDto, releaseRef);
      final copyProjection = _selectedRelease(copyDto, copyRef);

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
        catalogItemId: catalogItemId,
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
        () => workspace
            .projectorForScope(LibraryEntityScope.libraryEntry)
            .project(
                source: source,
                entity: LibraryEntryNodeRef(
                  catalogItemId: catalogItemId,
                  libraryEntryRef: source.libraryEntrySummary!.ref,
                )),
        throwsStateError,
        reason:
            '${kind.apiValue} must reject a stale CopyRef instead of substituting another release',
      );
    }
  });
}

({String id, String title}) _selectedRelease(
  LibraryWorkspaceDto dto,
  LibraryEntityRef node,
) {
  if (dto case MusicCatalogItemWorkspaceDto(:final music)) {
    return (id: music.id.value, title: music.title);
  }
  if (dto case MusicLibraryEntryWorkspaceDto(:final music)) {
    return (id: music.id.value, title: music.title);
  }
  final id = switch (node) {
    LibraryReleaseRef(:final releaseId) => releaseId,
    LibraryEntryNodeRef(:final libraryEntryRef) =>
      libraryEntryRef.id.value,
    _ => throw StateError('Unexpected workspace node: ${node.runtimeType}'),
  };
  return (id: id, title: dto.primaryLabel);
}
