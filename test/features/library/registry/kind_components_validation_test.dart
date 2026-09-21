import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_fields.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_field_registry.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Kind component registries and namespacing', () {
    test('all registered kinds declare a mandatory workspace projector', () {
      for (final registration in collectarrKindRegistrationsList) {
        expect(
          libraryKindWorkspaceForKind(registration.kind)
              .projectorForScope(LibraryEntityScope.work),
          isNotNull,
        );
      }
    });

    test('feature capability registries cover every active kind', () {
      final activeKinds = collectarrKindRegistrationsList
          .map((registration) => registration.kind);

      expect(collectarrKindPhysicalMediaFormats.keys, containsAll(activeKinds));
      expect(collectarrKindPresentations.keys, containsAll(activeKinds));
      expect(collectarrKindMetadata.keys, containsAll(activeKinds));
      expect(collectarrKindTrackingProfiles.keys, containsAll(activeKinds));
      expect(collectarrKindHierarchies.keys, containsAll(activeKinds));
      expect(collectarrKindInspectors.keys, containsAll(activeKinds));
      expect(collectarrKindEditCapabilities.keys, containsAll(activeKinds));
      expect(collectarrKindTransfers.keys, containsAll(activeKinds));
      expect(collectarrKindStats.keys, containsAll(activeKinds));
      expect(collectarrKindUiPolicies.keys, containsAll(activeKinds));
      expect(collectarrKindLinkedMetadata.keys, containsAll(activeKinds));
      expect(collectarrKindAdds.keys, containsAll(activeKinds));
      expect(collectarrKindWorkCapabilities.keys, containsAll(activeKinds));
      expect(collectarrKindReleaseCapabilities.keys, containsAll(activeKinds));
      expect(collectarrKindSearchTargetOptions.keys, containsAll(activeKinds));
      expect(collectarrKindViewProfiles.keys, containsAll(activeKinds));
    });

    test('feature contributors resolve through their own registry', () {
      for (final registration in collectarrKindRegistrationsList) {
        expect(
          libraryPresentationForKind(registration.kind),
          same(collectarrKindPresentations[registration.kind]),
        );
        expect(
          libraryMetadataForKind(registration.kind),
          same(collectarrKindMetadata[registration.kind]),
        );
        expect(
          libraryHierarchyForKind(registration.kind),
          same(collectarrKindHierarchies[registration.kind]),
        );
        expect(
          libraryEditCapabilitiesForKind(registration.kind),
          same(collectarrKindEditCapabilities[registration.kind]),
        );
        expect(
          libraryAddForKind(registration.kind),
          same(collectarrKindAdds[registration.kind]),
        );
        expect(
          libraryViewProfileForKind(registration.kind),
          same(collectarrKindViewProfiles[registration.kind]),
        );
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
