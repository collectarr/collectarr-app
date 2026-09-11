import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_fields.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_field_registry.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Kind Module Validation & Namespacing (Tasks 8 & 9)', () {
    test('all registered kind modules declare mandatory projector', () {
      for (final module in collectarrKindRegistrationsList) {
        expect(libraryKindWorkspaceForKind(module.kind).projector, isNotNull);
      }
    });

    test('feature capability registries cover every active kind', () {
      final activeKinds =
          collectarrKindRegistrationsList.map((module) => module.kind);

      expect(collectarrKindPhysicalMediaFormats.keys, containsAll(activeKinds));
      expect(collectarrKindPresentations.keys, containsAll(activeKinds));
      expect(collectarrKindMetadata.keys, containsAll(activeKinds));
      expect(collectarrKindTrackingProfiles.keys, containsAll(activeKinds));
      expect(collectarrKindHierarchies.keys, containsAll(activeKinds));
      expect(collectarrKindInspectors.keys, containsAll(activeKinds));
      expect(collectarrKindEdits.keys, containsAll(activeKinds));
      expect(collectarrKindTransfers.keys, containsAll(activeKinds));
      expect(collectarrKindStats.keys, containsAll(activeKinds));
      expect(collectarrKindUiPolicies.keys, containsAll(activeKinds));
      expect(collectarrKindLinkedMetadata.keys, containsAll(activeKinds));
      expect(collectarrKindAdds.keys, containsAll(activeKinds));
      expect(collectarrKindTitleCapabilities.keys, containsAll(activeKinds));
      expect(collectarrKindReleaseCapabilities.keys, containsAll(activeKinds));
      expect(collectarrKindSearchTargetOptions.keys, containsAll(activeKinds));
      expect(collectarrKindViewProfiles.keys, containsAll(activeKinds));
    });

    test('module capability access resolves through the matching feature map',
        () {
      for (final module in collectarrKindRegistrationsList) {
        expect(module.presentation,
            same(collectarrKindPresentations[module.kind]));
        expect(module.metadata, same(collectarrKindMetadata[module.kind]));
        expect(module.hierarchy, same(collectarrKindHierarchies[module.kind]));
        expect(module.edit, same(collectarrKindEdits[module.kind]));
        expect(module.add, same(collectarrKindAdds[module.kind]));
        expect(
            module.viewProfile, same(collectarrKindViewProfiles[module.kind]));
      }
    });

    test(
        'field IDs across different kinds are distinctly namespaced (no collision)',
        () {
      final movieWorkspace =
          libraryKindWorkspaceForKind(CatalogMediaKind.movie);
      final gameWorkspace = libraryKindWorkspaceForKind(CatalogMediaKind.game);

      final movieReleaseSort = movieWorkspace.fields.sortDefinitionForId(
        movieWorkspace.fields.decodeSortId('movie.release_date'),
      );
      final gameReleaseSort = gameWorkspace.fields.sortDefinitionForId(
        gameWorkspace.fields.decodeSortId('game.release_date'),
      );

      expect(movieReleaseSort, isNotNull);
      expect(gameReleaseSort, isNotNull);
      expect(movieReleaseSort!.id, isNot(equals(gameReleaseSort!.id)));
    });

    test('LibraryFieldRegistry throws StateError on duplicate column IDs', () {
      expect(
        () => LibraryFieldRegistry<ComicWorkspaceDto>(
          kindNamespace: 'comic',
          columns: [
            comicLibraryColumnDefinitions.first,
            comicLibraryColumnDefinitions.first,
          ],
          sorts: const [],
          groups: const [],
          defaultVisibleColumns: const {},
          defaultSort: ComicSortIds.series,
          preferenceCodec:
              const IdentityLibraryWorkspacePreferenceCodec<ComicKind>(),
        ),
        throwsStateError,
      );
    });

    test('LibraryFieldRegistry throws StateError on duplicate sort IDs', () {
      expect(
        () => LibraryFieldRegistry<ComicWorkspaceDto>(
          kindNamespace: 'comic',
          columns: const [],
          sorts: [
            comicLibrarySortDefinitions.first,
            comicLibrarySortDefinitions.first,
          ],
          groups: const [],
          defaultVisibleColumns: const {},
          defaultSort: ComicSortIds.series,
          preferenceCodec:
              const IdentityLibraryWorkspacePreferenceCodec<ComicKind>(),
        ),
        throwsStateError,
      );
    });

    test('LibraryKindRegistry throws StateError on duplicate kind registration',
        () {
      expect(
        () => LibraryKindRegistry([
          const ComicRegistration(),
          const ComicRegistration(),
        ]),
        throwsStateError,
      );
    });
  });
}
