import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/vocabulary/movie_vocabularies.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/add_contract.dart';

void main() {
  defineAddContract<AddSchema<MovieAddManualDraft>>(
    name: 'Movie',
    create: () => movieAddSchema,
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

  test('declares Movie release and metadata sections', () {
    final draft = MovieAddManualDraft();
    addTearDown(draft.dispose);

    expect(movieAddSchema.title!(draft), 'Manual movie');
    expect(movieAddSchema.sections.map((section) => section.id), [
      'release',
      'metadata',
    ]);
    expect(
      [
        for (final section in movieAddSchema.sections)
          for (final field in section.fields) field.id,
      ],
      containsAll(<String>[
        'edition_title',
        'format',
        'region',
        'barcode',
        'release_year',
        'release_date',
        'distributor',
        'directors',
        'genres',
        'age_rating',
      ]),
    );
  });

  test('binds Movie vocabularies and validates manual values', () {
    final draft = MovieAddManualDraft();
    addTearDown(draft.dispose);

    final format =
        _field('format') as VocabularyAddField<MovieAddManualDraft, String>;
    final region =
        _field('region') as VocabularyAddField<MovieAddManualDraft, String>;
    final distributor = _field('distributor')
        as VocabularyAddField<MovieAddManualDraft, String>;
    expect(
      format.options.map((option) => option.value),
      MovieVocabularies.physicalFormat.builtIns,
    );
    expect(
      region.options.map((option) => option.value),
      MovieVocabularies.region.builtIns,
    );
    expect(
      distributor.options.map((option) => option.value),
      MovieVocabularies.distributor.builtIns,
    );

    format.updateValue(draft, 'Blu-ray');
    region.updateValue(draft, 'Region A / Region 1');
    distributor.updateValue(draft, 'Criterion Collection');
    expect(format.currentValue(draft), 'Blu-ray');
    expect(region.currentValue(draft), 'Region A / Region 1');
    expect(distributor.currentValue(draft), 'Criterion Collection');

    final date = _field('release_date') as DateAddField<MovieAddManualDraft>;
    date.setValue(draft, DateTime(2026, 4, 12));
    expect(date.value(draft), DateTime(2026, 4, 12));
    expect(movieAddSchema.validate!(draft), isNull);

    final year = _field('release_year') as NumberAddField<MovieAddManualDraft>;
    year.setValue(draft, -1);
    expect(movieAddSchema.validate!(draft), 'Release year cannot be negative');
    year.setValue(draft, 2026);
    draft.releaseDateController.text = 'not-a-date';
    expect(movieAddSchema.validate!(draft), 'Release date is invalid');
  });
}

AddFieldSpec<MovieAddManualDraft> _field(String id) {
  return [
    for (final section in movieAddSchema.sections)
      for (final field in section.fields)
        if (field.id == id) field,
  ].single;
}
