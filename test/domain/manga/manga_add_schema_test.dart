import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/manga/vocabulary/manga_vocabularies.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/add_contract.dart';

void main() {
  defineAddContract<AddSchema<MangaAddManualDraft>>(
    name: 'Manga',
    create: () => mangaAddSchema,
    fieldIds: (schema) => [
      for (final section in schema.sections)
        for (final field in section.fields) field.id,
    ],
    label: (schema, fieldId) => [
      for (final section in schema.sections)
        for (final field in section.fields)
          if (field.id == fieldId) field.label,
    ].single,
  );

  test('declares only catalog volume and publication fields', () {
    final draft = MangaAddManualDraft();

    expect(mangaAddSchema.title!(draft), 'Manual manga volume');
    expect(mangaAddSchema.sections.map((section) => section.id), [
      'volume',
      'publication',
    ]);
    expect(
      [
        for (final section in mangaAddSchema.sections)
          for (final field in section.fields) field.id,
      ],
      [
        'volume_number',
        'variant',
        'release_title',
        'format',
        'binding',
        'publisher',
        'imprint',
        'distributor',
        'isbn',
        'barcode',
        'language',
        'region',
        'release_date',
        'page_count',
        'release_description',
        'cover_image_url',
        'publication_year',
        'series_group',
        'authors',
        'characters',
        'genres',
        'age_rating',
        'country',
        'synopsis',
        'back_cover_image_url',
      ],
    );
  });

  test('binds shared release vocabularies and validates numeric values', () {
    final draft = MangaAddManualDraft();
    final schema = mangaAddSchemaFor();
    final format = _field(schema, 'format')
        as LibraryVocabularyFieldSpec<MangaAddManualDraft, String>;
    final publisher = _field(schema, 'publisher')
        as LibraryVocabularyFieldSpec<MangaAddManualDraft, String>;
    final imprint = _field(schema, 'imprint')
        as LibraryVocabularyFieldSpec<MangaAddManualDraft, String>;
    expect(format.options.map((option) => option.value),
        MangaVocabularies.format.builtIns);
    expect(publisher.options.map((option) => option.value),
        MangaVocabularies.publisher.builtIns);
    expect(imprint.options.map((option) => option.value),
        MangaVocabularies.imprint.builtIns);

    format.updateValue(draft, 'Tankobon (Standard)');
    publisher.updateValue(draft, 'VIZ Media');
    imprint.updateValue(draft, 'Shonen Jump');
    expect(draft.values.format, 'Tankobon (Standard)');
    expect(draft.values.publisher, 'VIZ Media');
    expect(draft.values.imprint, 'Shonen Jump');

    final date = _field(schema, 'release_date')
        as LibraryDateFieldSpec<MangaAddManualDraft>;
    date.setValue(draft, DateTime(2026, 4, 12));
    expect(date.value(draft), DateTime(2026, 4, 12));

    final values = draft.values;
    values
      ..volumeNumber = '3'
      ..variant = 'Deluxe'
      ..releaseTitle = 'Collector edition'
      ..barcode = '9781234567890'
      ..seriesGroup = 'Fullmetal editions'
      ..authors = 'Hiromu Arakawa'
      ..characters = 'Edward Elric'
      ..genres = ['Action', 'Fantasy']
      ..ageRating = 'Teen'
      ..language = 'en'
      ..country = 'US'
      ..description = 'A complete volume.'
      ..coverImageUrl = 'https://example.com/cover.jpg'
      ..backCoverImageUrl = 'https://example.com/back.jpg'
      ..pageCount = 192;
    expect(mangaAddSchema.validate!(draft), isNull);
    values.pageCount = -1;
    expect(mangaAddSchema.validate!(draft), 'Page count cannot be negative');
  });
}

LibraryFieldSpec<MangaAddManualDraft> _field(
  AddSchema<MangaAddManualDraft> schema,
  String id,
) =>
    [
      for (final section in schema.sections)
        for (final field in section.fields)
          if (field.id == id) field,
    ].single;
