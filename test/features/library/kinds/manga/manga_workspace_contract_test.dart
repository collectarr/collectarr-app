import 'package:collectarr_app/features/library/kinds/manga/manga_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/vocabulary/manga_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_fields.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Manga workspace exposes a complete typed schema registry', () {
    final registry = mangaKindModule.fields;
    final fieldIds = registry.fields.map((field) => field.id.value).toList();
    final columnIds =
        registry.columns.map((column) => column.id.value).toList();
    final sortIds = registry.sorts.map((sort) => sort.id.value).toList();
    final groupIds = registry.groups.map((group) => group.id.value).toList();

    expect(registry.kindNamespace, 'manga');
    expect(fieldIds, isNotEmpty);
    expect(columnIds, isNotEmpty);
    expect(sortIds, isNotEmpty);
    expect(groupIds, isNotEmpty);
    expect(fieldIds.toSet(), hasLength(fieldIds.length));
    expect(columnIds.toSet(), hasLength(columnIds.length));
    expect(sortIds.toSet(), hasLength(sortIds.length));
    expect(groupIds.toSet(), hasLength(groupIds.length));
    expect(fieldIds.every((id) => id.startsWith('manga.')), isTrue);
    expect(columnIds.every((id) => id.startsWith('manga.')), isTrue);
    expect(sortIds.every((id) => id.startsWith('manga.')), isTrue);
    expect(groupIds.every((id) => id.startsWith('manga.')), isTrue);
    expect(
      mangaKindModule.facets!.definitions
          .map((definition) => definition.id.value),
      containsAll([
        'manga.publisher',
        'manga.genre',
        'manga.character',
        'manga.theme',
        'manga.demographic',
      ]),
    );

    for (final column in registry.columns) {
      expect(fieldIds, contains(column.id.value));
    }
    for (final visibleColumn in registry.defaultVisibleColumns) {
      expect(registry.columnDefinitionForId(visibleColumn), isNotNull);
    }
    expect(registry.findSortDefinition(registry.defaultSort), isNotNull);
    expect(
      registry.defaultGroup == null
          ? null
          : registry.findGroupDefinition(registry.defaultGroup!),
      registry.defaultGroup == null ? isNull : isNotNull,
    );

    final dto = MangaWorkspaceDto(
      common: const WorkspaceCommonProjection(
        title: 'Vagabond',
        publisher: 'VIZ Media',
      ),
      personal: PersonalCopyProjection(),
      metadata: const MangaMetadata(
        genres: ['Adventure'],
        themes: ['Samurai'],
        demographic: MangaDemographic.seinen,
      ),
    );
    final facetValues = <String, Iterable<String>>{
      for (final definition in mangaLibraryFacetDefinitions)
        definition.id.value: definition.extractValues(dto).whereType<String>(),
    };
    expect(facetValues['manga.publisher'], contains('VIZ Media'));
    expect(facetValues['manga.genre'], contains('Adventure'));
    expect(facetValues['manga.character'], isEmpty);
    expect(facetValues['manga.theme'], contains('Samurai'));
    expect(facetValues['manga.demographic'], contains('Seinen'));
  });

  test('Manga workspace facets and vocabularies are kind-owned', () {
    final facets = mangaKindModule.facets;
    expect(facets, isNotNull);
    expect(
      facets!.externalFacetBucketIdsByMode.keys,
      containsAll(['manga.genre', 'manga.demographic']),
    );

    final vocabularyCapability = mangaKindModule.edit.vocabularies;
    expect(vocabularyCapability, isNotNull);
    expect(
      vocabularyCapability!.definitions.map((definition) => definition.key),
      MangaVocabularies.all.map((definition) => definition.key),
    );
    expect(
      vocabularyCapability.definitions
          .map((definition) => definition.key)
          .every((key) => key.startsWith('manga.')),
      isTrue,
    );
  });
}
