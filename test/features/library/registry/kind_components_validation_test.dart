import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_action_registry.dart';
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

    test('every active kind has work, release, and copy edit builders', () {
      const requiredScopes = <LibraryEntityScope>[
        LibraryEntityScope.work,
        LibraryEntityScope.release,
        LibraryEntityScope.copy,
      ];

      for (final registration in collectarrKindRegistrationsList) {
        final editRegistry = collectarrKindEditCapabilities[registration.kind]!
            .presentationCapability
            .editRegistry;

        for (final scope in requiredScopes) {
          expect(
            editRegistry.builderForScope(scope),
            isNotNull,
            reason: '${registration.kind} is missing the $scope edit builder',
          );
        }
      }
    });

    test('every active kind owns actions for work, release, and copy', () {
      for (final registration in collectarrKindRegistrationsList) {
        final capability = collectarrKindEntityActions[registration.kind];
        expect(capability, isNotNull,
            reason: '${registration.kind} is missing entity actions');
        expect(capability!.work, isNotNull);
        expect(capability.release, isNotNull);
        expect(capability.copy, isNotNull);
        for (final entry in capability.semanticActions.entries) {
          expect(
            entry.key,
            isIn(LibraryEntityScope.values),
            reason: '${registration.kind} has an invalid action scope',
          );
          expect(
              entry.value.map((action) => action.id), everyElement(isNotEmpty));
        }
      }

      expect(
        collectarrKindEntityActions[CatalogMediaKind.music]!
            .semanticActions[LibraryEntityScope.release]!
            .map((action) => action.id),
        contains('music.log_listen'),
      );
      expect(
        collectarrKindEntityActions[CatalogMediaKind.comic]!
            .semanticActions[LibraryEntityScope.work]!
            .map((action) => action.id),
        contains('comic.missing_issues'),
      );
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

      final movieReleaseFields =
          movieWorkspace.fieldsForScope(LibraryEntityScope.release);
      final gameReleaseFields =
          gameWorkspace.fieldsForScope(LibraryEntityScope.release);
      final movieReleaseSort = movieReleaseFields.sortDefinitionForId(
        movieReleaseFields.decodeSortId('movie.release_date'),
      );
      final gameReleaseSort = gameReleaseFields.sortDefinitionForId(
        gameReleaseFields.decodeSortId('game.release_date'),
      );

      expect(movieReleaseSort, isNotNull);
      expect(gameReleaseSort, isNotNull);
      expect(movieReleaseSort!.id, isNot(equals(gameReleaseSort!.id)));
    });

    test('LibraryFieldRegistry throws StateError on duplicate column IDs', () {
      expect(
        () => LibraryFieldRegistry<ComicWorkspaceDto>(
          kindNamespace: 'comic',
          entityScope: LibraryEntityScope.work,
          columns: [
            comicLibraryColumnDefinitions.first,
            comicLibraryColumnDefinitions.first,
          ],
          sorts: const [],
          groups: const [],
          primaryColumn: comicLibraryEntityWorkspaceSchema.primaryColumn,
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
          entityScope: LibraryEntityScope.release,
          columns: const [],
          sorts: [
            comicLibrarySortDefinitions.first,
            comicLibrarySortDefinitions.first,
          ],
          groups: const [],
          primaryColumn: comicLibraryEntityWorkspaceSchema.primaryColumn,
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
