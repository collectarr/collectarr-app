import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Canonical & Kind-Scoped Group Mode Resolution Tests', () {
    final comicModule = libraryKindRegistrationForKind(CatalogMediaKind.comic);
    final bookModule = libraryKindRegistrationForKind(CatalogMediaKind.book);
    final comicWorkspace = libraryKindWorkspaceForKind(CatalogMediaKind.comic);
    final bookWorkspace = libraryKindWorkspaceForKind(CatalogMediaKind.book);

    test('findGroupDefinition resolves canonical kind-qualified group ID', () {
      final comicSeriesDef = comicWorkspace.fields.findGroupDefinition(
        comicWorkspace.fields.decodeGroupId('comic.series'),
      );
      expect(comicSeriesDef, isNotNull);
      expect(comicSeriesDef!.label, 'Series');

      final bookAuthorDef = bookWorkspace.fields.findGroupDefinition(
        bookWorkspace.fields.decodeGroupId('book.author'),
      );
      expect(bookAuthorDef, isNotNull);
      expect(bookAuthorDef!.label, 'Author');
    });

    test('findGroupDefinition resolves stored canonical group ID', () {
      final comicPublisherDef = comicWorkspace.fields.findGroupDefinition(
        comicWorkspace.fields.decodeGroupId('group.comic.publisher'),
      );
      expect(comicPublisherDef, isNotNull);
      expect(comicPublisherDef!.id.value, 'comic.publisher');

      final unqualified = comicWorkspace.fields.findGroupDefinition(
        comicWorkspace.fields.decodeGroupId('publisher'),
      );
      expect(unqualified, isNotNull);
      expect(unqualified!.id.value, 'comic.publisher');
    });

    test('findGroupDefinition rejects wrong-kind group ID', () {
      // Book module should not resolve comic.series or comic.creator
      final bookSeriesFromComic = bookWorkspace.fields.findGroupDefinition(
        bookWorkspace.fields.decodeGroupId('comic.creator'),
      );
      expect(bookSeriesFromComic, isNull);

      // Comic module should not resolve book.author
      final comicAuthor = comicWorkspace.fields.findGroupDefinition(
        comicWorkspace.fields.decodeGroupId('book.author'),
      );
      expect(comicAuthor, isNull);
    });

    test('findGroupDefinition returns null for unknown group ID', () {
      final unknown = comicWorkspace.fields.findGroupDefinition(
        comicWorkspace.fields.decodeGroupId('non_existent_group'),
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
        'comic.location',
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
