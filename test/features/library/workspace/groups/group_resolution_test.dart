import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Canonical & Kind-Scoped Group Mode Resolution Tests', () {
    final comicModule = libraryKindRuntimeForKind(CatalogMediaKind.comic);
    final bookModule = libraryKindRuntimeForKind(CatalogMediaKind.book);

    test('findGroupDefinition resolves canonical kind-qualified group ID', () {
      final comicSeriesDef =
          comicModule.fields.findGroupDefinition('comic.series');
      expect(comicSeriesDef, isNotNull);
      expect(comicSeriesDef!.label, 'Series');

      final bookAuthorDef =
          bookModule.fields.findGroupDefinition('book.author');
      expect(bookAuthorDef, isNotNull);
      expect(bookAuthorDef!.label, 'Author');
    });

    test(
        'findGroupDefinition resolves legacy preference string and group. prefix',
        () {
      // Legacy unprefixed
      final comicSeriesDef = comicModule.fields.findGroupDefinition('series');
      expect(comicSeriesDef, isNotNull);
      expect(comicSeriesDef!.id.value, 'comic.series');

      // Persisted 'group.' prefix
      final comicPublisherDef =
          comicModule.fields.findGroupDefinition('group.comic.publisher');
      expect(comicPublisherDef, isNotNull);
      expect(comicPublisherDef!.id.value, 'comic.publisher');

      final legacyGroupPublisherDef =
          comicModule.fields.findGroupDefinition('group.publisher');
      expect(legacyGroupPublisherDef, isNotNull);
      expect(legacyGroupPublisherDef!.id.value, 'comic.publisher');
    });

    test('findGroupDefinition rejects wrong-kind group ID', () {
      // Book module should not resolve comic.series or comic.creator
      final bookSeriesFromComic =
          bookModule.fields.findGroupDefinition('comic.creator');
      expect(bookSeriesFromComic, isNull);

      // Comic module should not resolve book.author
      final comicAuthor = comicModule.fields.findGroupDefinition('book.author');
      expect(comicAuthor, isNull);
    });

    test('findGroupDefinition returns null for unknown group ID', () {
      final unknown =
          comicModule.fields.findGroupDefinition('non_existent_group');
      expect(unknown, isNull);
    });

    test('libraryGroupModeFromStorageValue decodes with kind scope', () {
      final mode = libraryGroupModeFromStorageValue(
        'group.series',
        comicModule.type,
      );
      expect(mode, 'comic.series');
    });

    test('LibraryFolderPreset parses and formats canonical group modes', () {
      final preset = LibraryFolderPreset.parse(
        'group.publisher > group.series',
        comicModule.type,
      );
      expect(preset.modes, ['comic.publisher', 'comic.series']);
      expect(preset.primaryMode, 'comic.publisher');
      expect(preset.nextModeAfter('comic.publisher'), 'comic.series');
      expect(preset.nextModeAfter('comic.series'), isNull);
      expect(preset.storageValue, 'group.comic.publisher>group.comic.series');
    });

    test('LibraryFolderPreset rejects unknown group ID', () {
      expect(
        () => LibraryFolderPreset.parse('unknown_mode_123', comicModule.type),
        throwsArgumentError,
      );
    });

    test(
        'libraryAllowsGroupDrilldown delegates to group definition drilldownChildId',
        () {
      // Different modes with same type allow drilldown unless definition overrides
      final allowed = libraryAllowsGroupDrilldown(
        currentMode: 'comic.publisher',
        childMode: 'comic.series',
        type: comicModule.type,
      );
      expect(allowed, isTrue);

      // Same mode never allows drilldown
      final sameNotAllowed = libraryAllowsGroupDrilldown(
        currentMode: 'comic.publisher',
        childMode: 'comic.publisher',
        type: comicModule.type,
      );
      expect(sameNotAllowed, isFalse);
    });
  });
}
