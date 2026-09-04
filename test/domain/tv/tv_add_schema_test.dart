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
        'edition_title',
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

    final network = _field('network_vocabulary')
        as VocabularyAddField<TvAddManualDraft, String>;
    expect(
      network.options.map((option) => option.value),
      TvVocabularies.network.builtIns,
    );
    network.updateValue(draft, 'HBO');
    expect(network.currentValue(draft), 'HBO');

    final season = _field('season_number') as NumberAddField<TvAddManualDraft>;
    season.setValue(draft, -1);
    expect(tvAddSchema.validate!(draft), 'Season number cannot be negative');
    season.setValue(draft, 1);

    draft.releaseDateController.text = 'not-a-date';
    expect(tvAddSchema.validate!(draft), 'Release date is invalid');
  });
}

AddFieldSpec<TvAddManualDraft> _field(String id) {
  return [
    for (final section in tvAddSchema.sections)
      for (final field in section.fields)
        if (field.id == id) field,
  ].single;
}
