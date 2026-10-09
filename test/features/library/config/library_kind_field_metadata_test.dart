import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';
import 'package:collectarr_app/features/library/config/library_facet_types.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/kinds/anime/config/anime_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/anime/config/anime_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config/boardgame_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config/boardgame_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_facets.dart';
import 'package:collectarr_app/features/library/kinds/book/config/book_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/book/config/book_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_facets.dart';
import 'package:collectarr_app/features/library/kinds/comic/config/comic_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/comic/config/comic_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_facets.dart';
import 'package:collectarr_app/features/library/kinds/game/config/game_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/game/config/game_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_facet_definitions.dart';
import 'package:collectarr_app/features/library/kinds/manga/config/manga_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/manga/config/manga_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_facets.dart';
import 'package:collectarr_app/features/library/kinds/movie/config/movie_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/movie/config/movie_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/config/tv_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/tv/config/tv_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_workspace_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const fields = <LibraryKindFieldMetadata>[
    ...AnimeFieldIdentities.all,
    ...AnimeWorkspaceFieldMetadata.all,
    ...BoardGameFieldIdentities.all,
    ...BoardGameWorkspaceFieldMetadata.all,
    ...BookFieldIdentities.all,
    ...BookWorkspaceFieldMetadata.all,
    ...ComicFieldIdentities.all,
    ...ComicWorkspaceFieldMetadata.all,
    ...GameFieldIdentities.all,
    ...GameWorkspaceFieldMetadata.all,
    ...MangaFieldIdentities.all,
    ...MangaWorkspaceFieldMetadata.all,
    ...MovieFieldIdentities.all,
    ...MovieWorkspaceFieldMetadata.all,
    ...MusicFieldIdentities.all,
    ...MusicWorkspaceFieldMetadata.all,
    ...TvFieldIdentities.all,
    ...TvWorkspaceFieldMetadata.all,
  ];

  test('all registered kind fields have complete, unique semantic identity',
      () {
    final ids = fields.map((field) => field.id).toSet();

    expect(ids, hasLength(fields.length));
    for (final field in fields) {
      expect(field.id, isNotEmpty, reason: 'field ID');
      expect(field.label, isNotEmpty, reason: field.id);
      expect(field.sourcePath, isNotEmpty, reason: field.id);
    }
  });

  test('text cardinality is represented independently from value type', () {
    expect(MusicFieldIdentities.artist.valueType, LibraryFieldValueType.text);
    expect(
      MusicFieldIdentities.artist.cardinality,
      LibraryFieldCardinality.many,
    );
    expect(MusicFieldIdentities.genre.valueType, LibraryFieldValueType.text);
    expect(
      MusicFieldIdentities.genre.cardinality,
      LibraryFieldCardinality.many,
    );
    expect(MovieFieldIdentities.genre.valueType, LibraryFieldValueType.text);
    expect(
      MovieFieldIdentities.genre.cardinality,
      LibraryFieldCardinality.many,
    );
  });

  test('source and semantic path remain explicit for derived fields', () {
    expect(MusicFieldIdentities.format.source, LibraryFieldSource.derived);
    expect(MusicFieldIdentities.format.sourcePath, 'discs[].format');
    expect(BookFieldIdentities.releaseDate.source, LibraryFieldSource.derived);
    expect(BookFieldIdentities.releaseDate.sourcePath, 'release_date');
  });

  test('all nine workspace targets register fields with matching metadata', () {
    expect(collectarrKindWorkspaces, hasLength(9));

    for (final workspace in collectarrKindWorkspaces.values) {
      for (final registry in [workspace.fields, workspace.libraryEntryFields]) {
        final fieldIds = registry.fields.map((field) => field.id.value).toSet();
        expect(fieldIds, hasLength(registry.fields.length));

        for (final field in registry.fields) {
          expect(field.metadata.id, field.id.value);
          expect(field.label, field.metadata.label);
          expect(field.searchable, field.metadata.searchable);
          expect(field.sortable, field.metadata.sortable);
          expect(field.groupable, field.metadata.groupable);
        }

        for (final column in registry.columns) {
          expect(column.metadata.id, column.id.value);
          if (!column.metadata.sortable) expect(column.sortable, isFalse);
          if (!column.metadata.groupable) expect(column.groupable, isFalse);
        }
      }
    }
  });

  test('sort and group factories reject fields without those capabilities', () {
    const metadata = LibraryKindFieldMetadata(
      id: 'test.sample',
      label: 'Sample',
      valueType: LibraryFieldValueType.text,
      cardinality: LibraryFieldCardinality.one,
      source: LibraryFieldSource.derived,
      sourcePath: 'sample',
    );
    final field = LibraryFieldDefinition<String, _TestDto, String?>(
      metadata: metadata,
      id: const LibraryFieldId<String, String?>('test.sample'),
      getValue: (_) => null,
    );

    expect(
      () => sortFromField<String, _TestDto, String>(field),
      throwsArgumentError,
    );
    expect(
      () => groupFromField<String, _TestDto, String?>(field),
      throwsArgumentError,
    );
  });

  test('facet definitions derive IDs and labels from filterable metadata', () {
    final fieldIds = fields.map((field) => field.id).toSet();
    final definitions = [
      ...bookLibraryFacetDefinitions,
      ...boardgameLibraryFacetDefinitions,
      ...comicLibraryFacetDefinitions,
      ...gameLibraryFacetDefinitions,
      ...mangaLibraryFacetDefinitions,
    ];

    for (final definition in definitions) {
      expect(fieldIds, contains(definition.metadata.id));
      expect(definition.id.value, definition.metadata.id);
      expect(definition.label, definition.metadata.label);
      expect(definition.metadata.filterable, isTrue);
    }
  });

  test('facet definitions reject fields without filter capability', () {
    const metadata = LibraryKindFieldMetadata(
      id: 'test.not_filterable',
      label: 'Not Filterable',
      valueType: LibraryFieldValueType.text,
      cardinality: LibraryFieldCardinality.one,
      source: LibraryFieldSource.catalog,
      sourcePath: 'not_filterable',
    );

    expect(
      () => LibraryFacetDefinition<String, Object?, String>(
        metadata: metadata,
        extractValues: (_) => const <String>[],
      ),
      throwsArgumentError,
    );
  });
}

final class _TestDto implements LibraryWorkspaceDto {
  const _TestDto();

  @override
  String get primaryLabel => 'Test';

  @override
  String? get secondaryLabel => null;

  @override
  String? get imageUrl => null;
}
