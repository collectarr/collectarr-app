import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Canonical & Kind-Scoped Group Mode Resolution Tests', () {
    final comicModule = libraryKindRuntimeForKind(CatalogMediaKind.comic);
    final bookModule = libraryKindRuntimeForKind(CatalogMediaKind.book);

    test('findGroupDefinition resolves canonical kind-qualified group ID', () {
      final comicSeriesDef = comicModule.fields.findGroupDefinition(
        comicModule.fields.decodeGroupId('comic.series'),
      );
      expect(comicSeriesDef, isNotNull);
      expect(comicSeriesDef!.label, 'Series');

      final bookAuthorDef = bookModule.fields.findGroupDefinition(
        bookModule.fields.decodeGroupId('book.author'),
      );
      expect(bookAuthorDef, isNotNull);
      expect(bookAuthorDef!.label, 'Author');
    });

    test('findGroupDefinition resolves stored canonical group ID', () {
      final comicPublisherDef = comicModule.fields.findGroupDefinition(
        comicModule.fields.decodeGroupId('group.comic.publisher'),
      );
      expect(comicPublisherDef, isNotNull);
      expect(comicPublisherDef!.id.value, 'comic.publisher');

      final unqualified = comicModule.fields.findGroupDefinition(
        comicModule.fields.decodeGroupId('publisher'),
      );
      expect(unqualified, isNull);
    });

    test('findGroupDefinition rejects wrong-kind group ID', () {
      // Book module should not resolve comic.series or comic.creator
      final bookSeriesFromComic = bookModule.fields.findGroupDefinition(
        bookModule.fields.decodeGroupId('comic.creator'),
      );
      expect(bookSeriesFromComic, isNull);

      // Comic module should not resolve book.author
      final comicAuthor = comicModule.fields.findGroupDefinition(
        comicModule.fields.decodeGroupId('book.author'),
      );
      expect(comicAuthor, isNull);
    });

    test('findGroupDefinition returns null for unknown group ID', () {
      final unknown = comicModule.fields.findGroupDefinition(
        comicModule.fields.decodeGroupId('non_existent_group'),
      );
      expect(unknown, isNull);
    });

    test('libraryGroupModeFromStorageValue decodes with kind scope', () {
      final mode = libraryGroupModeFromStorageValue(
        'group.comic.series',
        comicModule,
      );
      expect(mode, 'comic.series');
    });

    test('libraryGroupModeFromStorageValue preserves standard semantic groups',
        () {
      expect(
        libraryGroupModeFromStorageValue('group.title', comicModule),
        'title',
      );
      expect(
        libraryGroupModeFromStorageValue('comic.location', comicModule),
        'location',
      );
      expect(
        libraryGroupModeFromStorageValue('ownership', comicModule),
        'ownership',
      );
    });

    test('LibraryFolderPreset parses and formats canonical group modes', () {
      final preset = LibraryFolderPreset.parse(
        'group.comic.publisher > group.comic.series',
        comicModule,
      );
      expect(preset.modes, ['comic.publisher', 'comic.series']);
      expect(preset.primaryMode, 'comic.publisher');
      expect(preset.nextModeAfter('comic.publisher'), 'comic.series');
      expect(preset.nextModeAfter('comic.series'), isNull);
      expect(preset.storageValue, 'group.comic.publisher>group.comic.series');
    });

    test('LibraryFolderPreset rejects unknown group ID', () {
      expect(
        () => LibraryFolderPreset.parse('unknown_mode_123', comicModule),
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
        type: comicModule,
      );
      expect(allowed, isTrue);

      // Same mode never allows drilldown
      final sameNotAllowed = libraryAllowsGroupDrilldown(
        currentMode: 'comic.publisher',
        childMode: 'comic.publisher',
        type: comicModule,
      );
      expect(sameNotAllowed, isFalse);
    });
  });
}
