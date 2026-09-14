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

  test('declares Manga volume, metadata, and collector sections', () {
    final draft = MangaAddManualDraft();
    addTearDown(draft.dispose);

    expect(mangaAddSchema.title!(draft), 'Manual manga volume');
    expect(mangaAddSchema.sections.map((section) => section.id), [
      'volume',
      'publication',
      'collector',
    ]);
    expect(
      [
        for (final section in mangaAddSchema.sections)
          for (final field in section.fields) field.id,
      ],
      [
        'volume_number',
        'variant',
        'edition_title',
        'barcode',
        'format',
        'publication_year',
        'release_date',
        'publisher',
        'imprint',
        'series_group',
        'page_count',
        'authors',
        'characters',
        'genres',
        'age_rating',
        'language',
        'country',
        'synopsis',
        'cover_image_url',
        'back_cover_image_url',
        'raw_or_slabbed',
        'grading_company',
        'grader_notes',
        'label_type',
        'custom_label',
        'page_quality',
        'certification_number',
      ],
    );
  });

  test('binds Manga vocabularies and preserves manual values', () {
    final draft = MangaAddManualDraft();
    addTearDown(draft.dispose);

    expect(mangaAddSchema.validate!(draft), isNull);
    final format =
        _field('format') as VocabularyAddField<MangaAddManualDraft, String>;
    final publisher =
        _field('publisher') as VocabularyAddField<MangaAddManualDraft, String>;
    final imprint =
        _field('imprint') as VocabularyAddField<MangaAddManualDraft, String>;
    expect(
      format.options.map((option) => option.value),
      MangaVocabularies.format.builtIns,
    );
    expect(
      publisher.options.map((option) => option.value),
      MangaVocabularies.publisher.builtIns,
    );
    expect(
      imprint.options.map((option) => option.value),
      MangaVocabularies.imprint.builtIns,
    );

    format.updateValue(draft, 'Tankobon (Standard)');
    publisher.updateValue(draft, 'VIZ Media');
    imprint.updateValue(draft, 'Shonen Jump');
    expect(format.currentValue(draft), 'Tankobon (Standard)');
    expect(publisher.currentValue(draft), 'VIZ Media');
    expect(imprint.currentValue(draft), 'Shonen Jump');

    final releaseDate =
        _field('release_date') as DateAddField<MangaAddManualDraft>;
    releaseDate.setValue(draft, DateTime(2026, 4, 12));
    expect(releaseDate.value(draft), DateTime(2026, 4, 12));

    for (final entry in const {
      'volume_number': '3',
      'variant': 'Deluxe',
      'edition_title': 'Collector edition',
      'barcode': '9781234567890',
      'series_group': 'Fullmetal editions',
      'authors': 'Hiromu Arakawa',
      'characters': 'Edward Elric',
      'genres': 'Action, Fantasy',
      'age_rating': 'Teen',
      'language': 'en',
      'country': 'US',
      'synopsis': 'A complete volume.',
      'cover_image_url': 'https://example.com/cover.jpg',
      'back_cover_image_url': 'https://example.com/back.jpg',
      'raw_or_slabbed': 'Slabbed',
      'grading_company': 'CGC',
      'grader_notes': 'Clean and centered',
      'label_type': 'Signature Series',
      'custom_label': 'First print',
      'page_quality': 'White',
      'certification_number': '123456',
    }.entries) {
      final field = _field(entry.key) as TextAddField<MangaAddManualDraft>;
      field.setValue(draft, entry.value);
      expect(field.value(draft), entry.value);
    }

    final pageCount =
        _field('page_count') as NumberAddField<MangaAddManualDraft>;
    pageCount.setValue(draft, 192);
    expect(pageCount.value(draft), 192);
    expect(mangaAddSchema.validate!(draft), isNull);
    pageCount.setValue(draft, -1);
    expect(mangaAddSchema.validate!(draft), 'Page count cannot be negative');
  });
}

AddFieldSpec<MangaAddManualDraft> _field(String id) {
  return [
    for (final section in mangaAddSchema.sections)
      for (final field in section.fields)
        if (field.id == id) field,
  ].single;
}
