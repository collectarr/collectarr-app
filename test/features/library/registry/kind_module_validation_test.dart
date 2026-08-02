import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/config/generic_library_workspace_projector.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Kind Module Validation & Namespacing (Tasks 8 & 9)', () {
    test('all registered kind modules pass validation', () {
      for (final module in collectarrKindModules) {
        expect(() => validateKindModule(module), returnsNormally);
      }
    });

    test('all registered kind modules declare mandatory projector', () {
      for (final module in collectarrKindModules) {
        expect(module.projector, isNotNull);
      }
    });

    test(
        'field IDs across different kinds are distinctly namespaced (no collision)',
        () {
      final movieModule = libraryKindModuleForKind(CatalogMediaKind.movie);
      final gameModule = libraryKindModuleForKind(CatalogMediaKind.game);

      final movieReleaseSort =
          movieModule.fields.sortDefinitionForId('movie.release_date');
      final gameReleaseSort =
          gameModule.fields.sortDefinitionForId('game.release_date');

      expect(movieReleaseSort, isNotNull);
      expect(gameReleaseSort, isNotNull);
      expect(movieReleaseSort!.id, isNot(equals(gameReleaseSort!.id)));
    });

    test('validateKindModule throws StateError on duplicate column IDs', () {
      final invalidRegistry = AnyLibraryFieldRegistry<GenericWorkspaceDto>(
        columns: [
          LibraryColumnDefinition(
              id: const LibraryFieldId('test.dup'),
              label: 'A',
              getValue: (dto) => null),
          LibraryColumnDefinition(
              id: const LibraryFieldId('test.dup'),
              label: 'B',
              getValue: (dto) => null),
        ],
      );

      final invalidModule =
          LibraryKindSpec<GenericWorkspaceDto, GenericOwnedDetails>(
        type: moviesLibraryConfig,
        mediaAdapter: movieKindModule.mediaAdapter,
        fields: invalidRegistry,
        projector: const GenericWorkspaceProjector(),
        ownedDetailsCodec: const GenericOwnedDetailsCodec(),
      );

      expect(() => validateKindModule(invalidModule), throwsStateError);
    });

    test('validateKindModule throws StateError on duplicate sort IDs', () {
      final invalidRegistry = AnyLibraryFieldRegistry<GenericWorkspaceDto>(
        sorts: [
          LibrarySortDefinition(
              id: const LibrarySortId('test.sort'),
              label: 'A',
              compare: (a, b) => 0),
          LibrarySortDefinition(
              id: const LibrarySortId('test.sort'),
              label: 'B',
              compare: (a, b) => 0),
        ],
      );

      final invalidModule =
          LibraryKindSpec<GenericWorkspaceDto, GenericOwnedDetails>(
        type: moviesLibraryConfig,
        mediaAdapter: movieKindModule.mediaAdapter,
        fields: invalidRegistry,
        projector: const GenericWorkspaceProjector(),
        ownedDetailsCodec: const GenericOwnedDetailsCodec(),
      );

      expect(() => validateKindModule(invalidModule), throwsStateError);
    });

    test('LibraryKindRegistry throws StateError on duplicate kind registration',
        () {
      final registry = LibraryKindRegistry.instance;
      // Trigger initialization
      registry.getByKind(CatalogMediaKind.comic);

      expect(
        () => registry.register(comicKindModule),
        throwsStateError,
      );
    });
  });
}
