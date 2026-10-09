import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';
import 'package:collectarr_app/features/library/config/library_entry_field_metadata.dart';
import 'package:collectarr_app/features/library/config/library_facet_types.dart';
import 'package:collectarr_app/features/library/config/generic_library_media_presentation.dart';
import 'package:collectarr_app/features/library/config/presentation/library_filter_presentation.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/kinds/anime/config/anime_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/anime/config/anime_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/anime/presentation.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config/boardgame_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config/boardgame_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/presentation.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_facets.dart';
import 'package:collectarr_app/features/library/kinds/book/config/book_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/book/config/book_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/presentation.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_facets.dart';
import 'package:collectarr_app/features/library/kinds/comic/config/comic_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/comic/config/comic_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/presentation.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_facets.dart';
import 'package:collectarr_app/features/library/kinds/game/config/game_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/game/config/game_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/presentation.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_facet_definitions.dart';
import 'package:collectarr_app/features/library/kinds/manga/config/manga_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/manga/config/manga_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/presentation.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_facets.dart';
import 'package:collectarr_app/features/library/kinds/movie/config/movie_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/movie/config/movie_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/movie/presentation.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_catalog_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_catalog_item_workspace_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_library_entry_workspace_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_personal_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_facets.dart';
import 'package:collectarr_app/features/library/kinds/music/presentation.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_field_labels.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_groups.dart';
import 'package:collectarr_app/features/library/kinds/tv/config/tv_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/tv/config/tv_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/presentation.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_workspace_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const fields = <LibraryKindFieldMetadata>[
    ...LibraryEntryFieldMetadata.all,
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

  test('Music live status stays boolean while labels are presentation values',
      () {
    expect(MusicWorkspaceFieldMetadata.isLive.valueType,
        LibraryFieldValueType.boolean);
    expect(MusicWorkspaceFieldMetadata.isLive.cardinality,
        LibraryFieldCardinality.many);
    expect(
        MusicWorkspaceFieldMetadata.isLive.source, LibraryFieldSource.catalog);
    expect(MusicWorkspaceFieldMetadata.isLive.sourcePath, 'discs[].is_live');
    expect(musicLiveStudioLabels([true, false]), ['Live', 'Studio']);
  });

  test('every Music grouping field is backed by canonical metadata', () {
    final groups = musicWorkspaceGroupDefinitions(includePersonal: true);
    final groupIds = groups.map((group) => group.id.value).toSet();

    for (final groupingField in MusicGroupingField.values) {
      final metadata = groupingField.fieldMetadata;
      expect(metadata.id, groupingField.id);
      expect(metadata.label, groupingField.label);
      expect(metadata.groupable, isTrue, reason: metadata.id);
      expect(fields.map((field) => field.id), contains(metadata.id));
      expect(groupIds, contains(metadata.id));
      final group = groups
          .singleWhere((definition) => definition.id.value == groupingField.id);
      expect(group.bucketVocabulary, metadata.vocabulary, reason: metadata.id);
    }
  });

  test('Music contained disc and credit groups follow field capabilities', () {
    final groups = musicWorkspaceGroupDefinitions(includePersonal: true);
    final groupIds = groups.map((group) => group.id.value).toSet();
    final expectedFields = <LibraryKindFieldMetadata>[
      MusicFieldIdentities.discFormat,
      MusicWorkspaceFieldMetadata.discFormatFamily,
      MusicWorkspaceFieldMetadata.recordingDate,
      MusicWorkspaceFieldMetadata.recordingMonth,
      MusicWorkspaceFieldMetadata.recordingYear,
      MusicWorkspaceFieldMetadata.isLive,
      MusicWorkspaceFieldMetadata.rpm,
      MusicWorkspaceFieldMetadata.spars,
      MusicWorkspaceFieldMetadata.sound,
      MusicWorkspaceFieldMetadata.recordingLocations,
      MusicWorkspaceFieldMetadata.vinylColor,
      MusicWorkspaceFieldMetadata.creditContributor,
      MusicWorkspaceFieldMetadata.creditRole,
      MusicWorkspaceFieldMetadata.creditInstrument,
    ];

    for (final field in expectedFields) {
      expect(field.groupable, isTrue, reason: field.id);
      expect(groupIds, contains(field.id), reason: field.id);
    }
    expect(groups.map((group) => group.category), contains('Credits'));
    expect(groups.map((group) => group.category), isNot(contains('Classical')));
    expect(groups.map((group) => group.category), isNot(contains('People')));
    expect(
      groups
          .where((group) => group.category == 'Credits')
          .map((group) => group.label),
      containsAll(['Contributor', 'Credit Role', 'Credit Instrument']),
    );
  });

  test('Music disc date reducers are scalar sortable fields', () {
    final earliest = MusicWorkspaceFieldMetadata.earliestDiscRecordingDate;
    final latest = MusicWorkspaceFieldMetadata.latestDiscRecordingDate;

    for (final metadata in [earliest, latest]) {
      expect(metadata.valueType, LibraryFieldValueType.partialDate);
      expect(metadata.cardinality, LibraryFieldCardinality.one);
      expect(metadata.source, LibraryFieldSource.derived);
      expect(metadata.sortable, isTrue);
    }

    final catalogSortIds = musicCatalogItemWorkspaceSchema.sorts
        .map((definition) => definition.id.value)
        .toSet();
    final entrySortIds = musicLibraryEntryWorkspaceSchema.sorts
        .map((definition) => definition.id.value)
        .toSet();
    for (final metadata in [earliest, latest]) {
      expect(catalogSortIds, contains(metadata.id));
      expect(entrySortIds, contains(metadata.id));
    }
  });

  test('Music multi-value search indexes selected facts only', () {
    expect(MusicFieldIdentities.discFormat.searchable, isTrue);
    expect(MusicWorkspaceFieldMetadata.recordingLocations.searchable, isTrue);
    expect(MusicWorkspaceFieldMetadata.creditContributor.searchable, isTrue);
    expect(MusicWorkspaceFieldMetadata.creditRole.searchable, isFalse);
    expect(MusicWorkspaceFieldMetadata.creditInstrument.searchable, isFalse);
    expect(MusicWorkspaceFieldMetadata.sound.searchable, isFalse);
    expect(MusicWorkspaceFieldMetadata.spars.searchable, isFalse);
    expect(MusicWorkspaceFieldMetadata.rpm.searchable, isFalse);
    expect(MusicWorkspaceFieldMetadata.vinylColor.searchable, isFalse);
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
    expect(
      MusicFieldIdentities.formatSummary.source,
      LibraryFieldSource.derived,
    );
    expect(MusicFieldIdentities.formatSummary.sourcePath, 'format_summary');
    expect(
      MusicFieldIdentities.formatSummary.cardinality,
      LibraryFieldCardinality.one,
    );
    expect(
      MusicFieldIdentities.discFormat.source,
      LibraryFieldSource.catalog,
    );
    expect(MusicFieldIdentities.discFormat.sourcePath, 'discs[].format');
    expect(
      MusicFieldIdentities.discFormat.cardinality,
      LibraryFieldCardinality.many,
    );
    expect(
      MusicFieldIdentities.discFormat.valueType,
      LibraryFieldValueType.text,
    );
    expect(BookFieldIdentities.releaseDate.source, LibraryFieldSource.derived);
    expect(BookFieldIdentities.releaseDate.sourcePath, 'release_date');
  });

  test('Music catalog fields are shared and summaries stay distinct', () {
    final catalogFields = musicCatalogItemWorkspaceSchema.fields;
    final entryFields = musicLibraryEntryWorkspaceSchema.fields;

    for (final field in MusicCatalogWorkspaceFields.all) {
      expect(catalogFields.any((candidate) => identical(candidate, field)),
          isTrue);
      expect(
          entryFields.any((candidate) => identical(candidate, field)), isTrue);
    }
    for (final field in MusicPersonalWorkspaceFields.all) {
      expect(catalogFields.any((candidate) => identical(candidate, field)),
          isFalse);
      expect(
          entryFields.any((candidate) => identical(candidate, field)), isTrue);
    }

    expect(
      MusicCatalogWorkspaceFields.formatSummary.metadata,
      same(MusicFieldIdentities.formatSummary),
    );
    expect(
      MusicCatalogWorkspaceFields.discFormat.metadata,
      same(MusicFieldIdentities.discFormat),
    );
    expect(
      MusicCatalogWorkspaceFields.formatSummary.metadata.cardinality,
      LibraryFieldCardinality.one,
    );
    expect(
      MusicCatalogWorkspaceFields.discFormat.metadata.cardinality,
      LibraryFieldCardinality.many,
    );

    expect(
      MusicWorkspaceFieldMetadata.storageSummary.cardinality,
      LibraryFieldCardinality.one,
    );
    expect(
      MusicWorkspaceFieldMetadata.storageDevice.cardinality,
      LibraryFieldCardinality.many,
    );
    expect(
      MusicWorkspaceFieldMetadata.storageSlot.cardinality,
      LibraryFieldCardinality.many,
    );
    expect(MusicWorkspaceFieldMetadata.storageDevice.sortable, isFalse);
    expect(MusicWorkspaceFieldMetadata.storageSlot.sortable, isFalse);
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

  test('filterable metadata fields are exposed to Smart List rules', () {
    final registeredFieldIds = {
      for (final workspace in collectarrKindWorkspaces.values)
        for (final registry in [workspace.fields, workspace.libraryEntryFields])
          for (final field in registry.fields) field.id.value,
    };
    final presentationFilterIds = {
      for (final filter in [
        ...animeLibraryFilterDefinitions,
        ...boardGamesLibraryFilterDefinitions,
        ...bookLibraryFilterDefinitions,
        ...comicLibraryFilterDefinitions,
        ...gamesLibraryFilterDefinitions,
        ...mangaLibraryFilterDefinitions,
        ...moviesLibraryFilterDefinitions,
        ...musicLibraryFilterDefinitions,
        ...tvLibraryFilterDefinitions,
      ])
        filter.metadata.id,
    };
    final missing = fields
        .where((field) => field.filterable)
        .where((field) =>
            !registeredFieldIds.contains(field.id) &&
            !presentationFilterIds.contains(field.id))
        .map((field) => field.id)
        .toList()
      ..sort();

    expect(
      missing,
      isEmpty,
      reason:
          'Filterable fields unavailable to Smart Lists: ${missing.join(', ')}',
    );
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
      ...musicLibraryFacetDefinitions,
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

  test('all toolbar filters declare filterable field metadata', () {
    final fieldIds = fields.map((field) => field.id).toSet();
    final definitions = <LibraryFilterDefinition<Object?>>[
      ...genericLibraryFilterDefinitions,
      ...animeLibraryFilterDefinitions,
      ...boardGamesLibraryFilterDefinitions,
      ...bookLibraryFilterDefinitions,
      ...comicLibraryFilterDefinitions,
      ...gamesLibraryFilterDefinitions,
      ...mangaLibraryFilterDefinitions,
      ...moviesLibraryFilterDefinitions,
      ...musicLibraryFilterDefinitions,
      ...tvLibraryFilterDefinitions,
    ];

    for (final definition in definitions) {
      expect(definition.metadata.filterable, isTrue, reason: definition.id);
      expect(fieldIds, contains(definition.metadata.id), reason: definition.id);
    }
  });

  test('toolbar filters reject fields without filter capability', () {
    const metadata = LibraryKindFieldMetadata(
      id: 'test.not_filterable',
      label: 'Not Filterable',
      valueType: LibraryFieldValueType.text,
      cardinality: LibraryFieldCardinality.one,
      source: LibraryFieldSource.catalog,
      sourcePath: 'not_filterable',
    );

    expect(
      () => LibraryFilterDefinition<Object?>(
        id: 'not_filterable',
        label: 'Not Filterable',
        metadata: metadata,
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
