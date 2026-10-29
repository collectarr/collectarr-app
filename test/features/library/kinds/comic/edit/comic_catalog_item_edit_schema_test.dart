import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../contracts/support/media_edit_contract.dart';

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
        'comic.series',
        'barcode',
        'physical_format',
        'series_group',
        'comic.issue_number',
        'comic.variant',
        'variant_description',
        'cover_date',
        'release_date',
        'publisher',
        'comic.imprint',
      ],
    );
  });

  test('edits subtitle and variant description independently of edition', () {
    const original = ComicCatalogItem(
      title: 'The issue title',
      seriesTitle: 'The series',
      subtitle: 'Original subtitle',
      variantDescription: 'Regular Edition',
      editionTitle: 'Collected edition',
    );
    final draft = comicCatalogItemFormValuesFrom(original);
    expect(draft.subtitle, 'Original subtitle');
    expect(draft.variantDescription, 'Regular Edition');
    (_field('subtitle') as LibraryTextFieldSpec<ComicCatalogItemFormValues>)
        .setValue(draft, 'New subtitle');
    (_field('variant_description')
            as LibraryTextFieldSpec<ComicCatalogItemFormValues>)
        .setValue(draft, 'Foil cover');
    final updated =
        comicCatalogItemFromFormValues(original: original, values: draft);
    expect(updated.subtitle, 'New subtitle');
    expect(updated.variantDescription, 'Foil cover');
    expect(updated.editionTitle, 'Collected edition');
    expect(updated.title, 'The issue title');
    draft.subtitle = '';
    draft.variantDescription = '';
    final cleared =
        comicCatalogItemFromFormValues(original: original, values: draft);
    expect(cleared.subtitle, isNull);
    expect(cleared.variantDescription, isNull);
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
        as LibraryPartialDateFieldSpec<ComicCatalogItemFormValues>;
    releaseDate.setValue(
        draft, const PartialDate(year: 2026, month: 4, day: 12));
    expect(releaseDate.value(draft),
        const PartialDate(year: 2026, month: 4, day: 12));
  });

  test('publication dates retain missing calendar parts and can be cleared',
      () {
    const original = ComicCatalogItem(title: 'A comic');
    final draft = comicCatalogItemFormValuesFrom(original);
    final cover = _field('cover_date')
        as LibraryPartialDateFieldSpec<ComicCatalogItemFormValues>;
    final release = _field('release_date')
        as LibraryPartialDateFieldSpec<ComicCatalogItemFormValues>;
    cover.setValue(draft, const PartialDate(year: 2024));
    release.setValue(draft, const PartialDate(month: 5, day: 3));
    final updated =
        comicCatalogItemFromFormValues(original: original, values: draft);
    expect(updated.coverDateParts, const PartialDate(year: 2024));
    expect(updated.coverDate, isNull);
    expect(updated.releaseDateParts, const PartialDate(month: 5, day: 3));
    expect(updated.releaseDate, isNull);
    cover.setValue(draft, null);
    release.setValue(draft, null);
    final cleared =
        comicCatalogItemFromFormValues(original: updated, values: draft);
    expect(cleared.coverDateParts, isNull);
    expect(cleared.releaseDateParts, isNull);
  });

  test('publication Age is independent from audience age rating', () {
    const original = ComicCatalogItem(
      title: 'Example',
      publicationAge: 'Modern',
      ageRating: 'Teen',
    );
    final values = comicCatalogItemFormValuesFrom(original);
    final age = _field('publication_age')
        as LibraryVocabularyFieldSpec<ComicCatalogItemFormValues, String>;
    expect(age.value(values), 'Modern');
    age.setValue(values, 'Golden');
    final updated =
        comicCatalogItemFromFormValues(original: original, values: values);
    final restored = ComicCatalogItem.fromJson(updated.toJson());
    expect(restored.publicationAge, 'Golden');
    expect(restored.ageRating, 'Teen');
    age.setValue(values, null);
    expect(
        comicCatalogItemFromFormValues(original: updated, values: values)
            .publicationAge,
        isNull);
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
