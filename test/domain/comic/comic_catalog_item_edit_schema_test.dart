import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/catalog_item/comic_catalog_item_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/media_edit_contract.dart';

void main() {
  defineMediaEditContract<
      EditSchema<ComicCatalogItem, ComicCatalogItemFormValues>>(
    name: 'Comic',
    create: () => comicCatalogItemEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );

  test('declares the Comic media tabs and field ordering', () {
    expect(comicCatalogItemEditSchema.tabs.map((tab) => tab.id), [
      'main',
      'details',
      'covers',
    ]);
    expect(
      [
        for (final tab in comicCatalogItemEditSchema.tabs)
          for (final section in tab.sections)
            for (final field in section.fields) field.label,
      ].every((label) => label.isNotEmpty),
      isTrue,
    );
    expect(
      comicCatalogItemEditSchema.tabs.first.sections.first.fields
          .map((field) => field.id),
      [
        'title',
        'comic.series',
        'comic.issue_number',
        'comic.variant',
        'edition_title',
        'barcode',
        'isbn',
        'upc',
        'physical_format',
        'cover_date',
        'release_date',
      ],
    );
  });

  test('binds Comic vocabularies and preserves typed media values', () {
    final original = const ComicCatalogItem(
      title: 'Batman #1',
      seriesTitle: 'Batman',
      publisher: 'DC Comics',
      issueNumber: '1',
      pageCount: 32,
      physicalFormat: 'single_issue',
    );
    final draft = comicCatalogItemFormValuesFrom(original);

    expect(draft.seriesTitle, 'Batman');
    expect(draft.publisher, 'DC Comics');
    expect(draft.pageCount, 32);
    expect(draft.physicalFormatLabel, 'single_issue');
    expect(comicCatalogItemEditSchema.validate!(original, draft), isNull);

    final format = _field('physical_format')
        as LibraryVocabularyFieldSpec<ComicCatalogItemFormValues, String>;
    final publisher = _field('publisher')
        as LibraryVocabularyFieldSpec<ComicCatalogItemFormValues, String>;
    expect(
      format.options.map((option) => option.value),
      ComicVocabularies.physicalFormat.builtIns,
    );
    expect(
      publisher.options.map((option) => option.value),
      ComicVocabularies.publisher.builtIns,
    );

    format.setValue(draft, 'Hardcover');
    publisher.setValue(draft, 'Marvel Comics');
    expect(format.value(draft), 'Hardcover');
    expect(publisher.value(draft), 'Marvel Comics');
    format.setValue(draft, null);
    expect(format.value(draft), isNull);

    final pageCount = _field('comic.page_count')
        as LibraryNumberFieldSpec<ComicCatalogItemFormValues>;
    pageCount.setValue(draft, 48);
    expect(pageCount.value(draft), 48);

    final genres = _field('genres')
        as LibraryMultiVocabularyFieldSpec<ComicCatalogItemFormValues, String>;
    genres.setValues(draft, {'Action', 'Mystery'});
    expect(genres.values(draft), {'Action', 'Mystery'});

    final releaseDate = _field('release_date')
        as LibraryDateFieldSpec<ComicCatalogItemFormValues>;
    releaseDate.setValue(draft, DateTime(2026, 4, 12));
    expect(releaseDate.value(draft), DateTime(2026, 4, 12));
  });

  test('reports invalid media values through schema validation', () {
    final original = const ComicCatalogItem(title: 'X');
    final draft = comicCatalogItemFormValuesFrom(original);

    draft.pageCount = -1;
    expect(
      comicCatalogItemEditSchema.validate!(original, draft),
      'Page count cannot be negative',
    );

    draft.pageCount = null;
    draft.coverDate = DateTime(2026, 3, 4);
    draft.releaseDate = DateTime(2026, 3, 10);
    final updated =
        comicCatalogItemFromFormValues(original: original, values: draft);
    expect(updated.coverDate, DateTime(2026, 3, 4));
    expect(updated.releaseDate, DateTime(2026, 3, 10));
  });
}

LibraryFieldSpec<ComicCatalogItemFormValues> _field(String id) {
  return [
    for (final tab in comicCatalogItemEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}
