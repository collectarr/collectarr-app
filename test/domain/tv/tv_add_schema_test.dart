import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/tv/vocabulary/tv_vocabularies.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/add_contract.dart';

void main() {
  defineAddContract<AddSchema<TvAddManualDraft>>(
    name: 'TV',
    create: () => tvAddSchema,
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

  test('declares TV series, release, and metadata fields', () {
    final draft = TvAddManualDraft();
    addTearDown(draft.dispose);

    expect(tvAddSchema.title!(draft), 'Manual TV show');
    expect(tvAddSchema.sections.map((section) => section.id), [
      'series',
      'release',
      'metadata',
    ]);
    expect(
      [
        for (final section in tvAddSchema.sections)
          for (final field in section.fields) field.id,
      ],
      containsAll(<String>[
        'network',
        'season_number',
        'first_air_year',
        'title',
        'format',
        'region',
        'barcode',
        'release_date',
        'creators',
        'genres',
        'content_rating',
      ]),
    );
  });

  test('binds TV vocabularies and validates manual values', () {
    final draft = TvAddManualDraft();
    addTearDown(draft.dispose);

    final network = _field('network')
        as LibraryVocabularyFieldSpec<TvAddManualDraft, String>;
    expect(
      network.options.map((option) => option.value),
      TvVocabularies.network.builtIns,
    );
    network.updateValue(draft, 'HBO');
    expect(network.currentValue(draft), 'HBO');

    final season =
        _field('season_number') as LibraryNumberFieldSpec<TvAddManualDraft>;
    season.setValue(draft, -1);
    expect(tvAddSchema.validate!(draft), 'Season number cannot be negative');
    season.setValue(draft, 1);

    final releaseDate =
        _field('release_date') as LibraryDateFieldSpec<TvAddManualDraft>;
    releaseDate.setValue(draft, DateTime.utc(2020, 1, 2));
    expect(draft.release.releaseDate, DateTime.utc(2020, 1, 2));
    expect(tvAddSchema.validate!(draft), isNull);
  });
}

LibraryFieldSpec<TvAddManualDraft> _field(String id) {
  return [
    for (final section in tvAddSchema.sections)
      for (final field in section.fields)
        if (field.id == id) field,
  ].single;
}
