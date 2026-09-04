import 'package:collectarr_app/features/library/kinds/book/book_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_fields.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Book workspace exposes a complete typed schema registry', () {
    final registry = bookKindModule.fields;
    final fieldIds = registry.fields.map((field) => field.id.value).toList();
    final columnIds =
        registry.columns.map((column) => column.id.value).toList();
    final sortIds = registry.sorts.map((sort) => sort.id.value).toList();
    final groupIds = registry.groups.map((group) => group.id.value).toList();

    expect(registry.kindNamespace, 'book');
    expect(fieldIds, isNotEmpty);
    expect(columnIds, isNotEmpty);
    expect(sortIds, isNotEmpty);
    expect(groupIds, isNotEmpty);
    expect(fieldIds.toSet(), hasLength(fieldIds.length));
    expect(columnIds.toSet(), hasLength(columnIds.length));
    expect(sortIds.toSet(), hasLength(sortIds.length));
    expect(groupIds.toSet(), hasLength(groupIds.length));
    expect(fieldIds.every((id) => id.startsWith('book.')), isTrue);
    expect(columnIds.every((id) => id.startsWith('book.')), isTrue);
    expect(sortIds.every((id) => id.startsWith('book.')), isTrue);
    expect(groupIds.every((id) => id.startsWith('book.')), isTrue);

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

    expect(
      bookKindModule.facets!.definitions
          .map((definition) => definition.id.value),
      containsAll([
        'book.author',
        'book.publisher',
        'book.genre',
        'book.format',
        'book.subject',
        'book.translator',
      ]),
    );
  });

  test('Book facet values and vocabularies remain kind-owned', () {
    final dto = BookWorkspaceDto(
      common: WorkspaceCommonProjection(
        title: 'Dune',
        publisher: 'Ace',
      ),
      personal: PersonalCopyProjection(),
      book: BookCatalogItem(
        id: 'book-1',
        work: BookWorkMetadata(title: 'Dune'),
        publishing: BookPublishingMetadata(),
        releases: [],
      ),
      metadata: BookCatalogMetadata(
        title: 'Dune',
        authors: ['Frank Herbert'],
        genres: ['Science Fiction'],
        subjects: ['Politics'],
        translators: ['Ion Hobana'],
        editions: [
          BookEditionMetadata(
            id: 'edition-1',
            title: 'Dune',
            format: 'Hardcover',
          ),
        ],
      ),
    );

    final facetValues = <String, Iterable<String>>{
      for (final definition in bookLibraryFacetDefinitions)
        definition.id.value: definition.extractValues(dto),
    };
    expect(facetValues['book.author'], contains('Frank Herbert'));
    expect(facetValues['book.publisher'], contains('Ace'));
    expect(facetValues['book.genre'], contains('Science Fiction'));
    expect(facetValues['book.format'], contains('Hardcover'));
    expect(facetValues['book.subject'], contains('Politics'));
    expect(facetValues['book.translator'], contains('Ion Hobana'));

    final facets = bookKindModule.facets!;
    expect(
      facets.externalFacetBucketIdsByMode.keys,
      containsAll(['book.genre', 'book.subject']),
    );

    final vocabularyCapability = bookKindModule.edit.vocabularies;
    expect(vocabularyCapability, isNotNull);
    expect(
      vocabularyCapability!.definitions.map((definition) => definition.key),
      BookVocabularies.all.map((definition) => definition.key),
    );
    expect(
      vocabularyCapability.definitions
          .map((definition) => definition.key)
          .every((key) => key.startsWith('book.')),
      isTrue,
    );
    expect(BookVocabularies.condition.id, BookVocabularyIds.condition);
  });
}
