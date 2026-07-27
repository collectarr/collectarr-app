import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
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

    test('all registered kind modules declare mandatory workspaceDtoFactory', () {
      for (final module in collectarrKindModules) {
        expect(module.workspaceDtoFactory, isNotNull);
      }
    });

    test('field IDs across different kinds are distinctly namespaced (no collision)', () {
      final movieModule = libraryKindModuleForKind(CatalogMediaKind.movie);
      final gameModule = libraryKindModuleForKind(CatalogMediaKind.game);

      final movieReleaseSort = movieModule.fields.sortDefinitionForId('movie.release_date');
      final gameReleaseSort = gameModule.fields.sortDefinitionForId('game.release_date');

      expect(movieReleaseSort, isNotNull);
      expect(gameReleaseSort, isNotNull);
      expect(movieReleaseSort!.id, isNot(equals(gameReleaseSort!.id)));
    });

    test('validateKindModule throws StateError on duplicate column IDs', () {
      final invalidRegistry = AnyLibraryFieldRegistry<Object>(
        columns: [
          LibraryColumnDefinition(id: const LibraryFieldId('test.dup'), label: 'A', getValue: (dto) => null),
          LibraryColumnDefinition(id: const LibraryFieldId('test.dup'), label: 'B', getValue: (dto) => null),
        ],
      );

      final invalidModule = LibraryKindSpec<Object, GenericOwnedDetails>(
        type: moviesLibraryConfig,
        mediaAdapter: movieKindModule.mediaAdapter,
        fields: invalidRegistry,
        workspaceDtoFactory: (entry) => throw UnimplementedError(),
      );

      expect(() => validateKindModule(invalidModule), throwsStateError);
    });

    test('validateKindModule throws StateError on duplicate sort IDs', () {
      final invalidRegistry = AnyLibraryFieldRegistry<Object>(
        sorts: [
          LibrarySortDefinition(id: 'test.sort', label: 'A', compare: (a, b) => 0),
          LibrarySortDefinition(id: 'test.sort', label: 'B', compare: (a, b) => 0),
        ],
      );

      final invalidModule = LibraryKindSpec<Object, GenericOwnedDetails>(
        type: moviesLibraryConfig,
        mediaAdapter: movieKindModule.mediaAdapter,
        fields: invalidRegistry,
        workspaceDtoFactory: (entry) => throw UnimplementedError(),
      );

      expect(() => validateKindModule(invalidModule), throwsStateError);
    });

    test('LibraryKindRegistry throws StateError on duplicate kind registration', () {
      final registry = LibraryKindRegistry.instance;
      // Trigger initialization
      registry.getByKind(CatalogMediaKind.comic);

      expect(
        () => registry.register(comicKindModule),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Duplicate LibraryKindSpec registration for kind: CatalogMediaKind.comic'),
          ),
        ),
      );
    });

    test('LibraryKindRegistry performs O(1) map lookup for all 9 kinds', () {
      for (final kind in CatalogMediaKind.values) {
        if (kind == CatalogMediaKind.unknown) continue;
        final runtime = LibraryKindRegistry.instance.getByKind(kind);
        expect(runtime.kind, equals(kind));
        expect(runtime.createWorkspaceDto, isNotNull);
      }
    });

    test('LibraryKindSpec workspaceDtoFactory returns typed DTO', () {
      final spec = comicKindModule;
      expect(spec, isA<LibraryKindSpec<dynamic, dynamic>>());
      expect(spec.kind, equals(CatalogMediaKind.comic));
    });
  });
}
