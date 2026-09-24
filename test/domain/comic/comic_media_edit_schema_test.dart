import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/media/comic_media_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/media_edit_contract.dart';

void main() {
  defineMediaEditContract<EditSchema<ComicMedia, ComicMediaFormValues>>(
    name: 'Comic',
    create: () => comicMediaEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );

  test('declares the Comic media tabs and field ordering', () {
    expect(comicMediaEditSchema.tabs.map((tab) => tab.id), [
      'main',
      'details',
      'creators',
      'characters',
      'links',
      'cover',
      'photos',
    ]);
    expect(
      [
        for (final tab in comicMediaEditSchema.tabs)
          for (final section in tab.sections)
            for (final field in section.fields) field.label,
      ].every((label) => label.isNotEmpty),
      isTrue,
    );
    expect(
      comicMediaEditSchema.tabs.first.sections.first.fields
          .map((field) => field.id),
      [
        'series',
        'issue_number',
        'variant',
        'edition_title',
        'barcode',
        'physical_format',
        'cover_date',
        'release_date',
      ],
    );
  });

  test('binds Comic vocabularies and preserves typed media values', () {
    final original = const ComicMedia(
      title: 'Batman',
      publisher: 'DC Comics',
      issueNumber: '1',
      pageCount: 32,
      physicalFormatLabel: 'Single Issue',
    );
    final draft = comicMediaFormValuesFrom(original);

    expect(draft.seriesTitle, 'Batman');
    expect(draft.publisher, 'DC Comics');
    expect(draft.pageCount, 32);
    expect(draft.physicalFormatLabel, 'Single Issue');
    expect(comicMediaEditSchema.validate!(original, draft), isNull);

    final format = _field('physical_format')
        as LibraryVocabularyFieldSpec<ComicMediaFormValues, String>;
    final publisher = _field('publisher')
        as LibraryVocabularyFieldSpec<ComicMediaFormValues, String>;
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

    final pageCount =
        _field('page_count') as LibraryNumberFieldSpec<ComicMediaFormValues>;
    pageCount.setValue(draft, 48);
    expect(pageCount.value(draft), 48);

    final genres = _field('genres')
        as LibraryMultiVocabularyFieldSpec<ComicMediaFormValues, String>;
    genres.setValues(draft, {'Action', 'Mystery'});
    expect(genres.values(draft), {'Action', 'Mystery'});

    final releaseDate =
        _field('release_date') as LibraryDateFieldSpec<ComicMediaFormValues>;
    releaseDate.setValue(draft, DateTime(2026, 4, 12));
    expect(releaseDate.value(draft), DateTime(2026, 4, 12));
  });

  test('reports invalid media values through schema validation', () {
    final original = const ComicMedia(title: 'X');
    final draft = comicMediaFormValuesFrom(original);

    draft.pageCount = -1;
    expect(
      comicMediaEditSchema.validate!(original, draft),
      'Page count cannot be negative',
    );

    draft.pageCount = null;
    draft.coverDate = DateTime(2026, 3, 4);
    draft.releaseDate = DateTime(2026, 3, 10);
    final updated = comicMediaFromFormValues(original: original, values: draft);
    expect(updated.coverDate, DateTime(2026, 3, 4));
    expect(updated.releaseDate, DateTime(2026, 3, 10));
  });
}

LibraryFieldSpec<ComicMediaFormValues> _field(String id) {
  return [
    for (final tab in comicMediaEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}
