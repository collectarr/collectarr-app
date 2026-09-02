import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_fields.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Kind Module Validation & Namespacing (Tasks 8 & 9)', () {
    test('all registered kind modules pass validation', () {
      for (final module in collectarrKindModules) {
        expect(() => validateKindRuntime(module), returnsNormally);
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
      final movieModule = libraryKindRuntimeForKind(CatalogMediaKind.movie);
      final gameModule = libraryKindRuntimeForKind(CatalogMediaKind.game);

      final movieReleaseSort = movieModule.fields.sortDefinitionForId(
        movieModule.fields.decodeSortId('movie.release_date'),
      );
      final gameReleaseSort = gameModule.fields.sortDefinitionForId(
        gameModule.fields.decodeSortId('game.release_date'),
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
          preferenceCodec: const ComicPreferenceCodec(),
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
          preferenceCodec: const ComicPreferenceCodec(),
        ),
        throwsStateError,
      );
    });

    test('LibraryKindRegistry throws StateError on duplicate kind registration',
        () {
      expect(
        () => LibraryKindRegistry([comicKindModule, comicKindModule]),
        throwsStateError,
      );
    });
  });
}
