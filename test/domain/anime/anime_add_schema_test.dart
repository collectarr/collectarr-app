import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/anime/vocabulary/anime_vocabularies.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/add_contract.dart';

void main() {
  defineAddContract<AddSchema<AnimeAddManualDraft>>(
    name: 'Anime',
    create: () => animeAddSchema,
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

  test('declares Anime series, release, and metadata sections', () {
    final draft = AnimeAddManualDraft();
    addTearDown(draft.dispose);

    expect(animeAddSchema.title!(draft), 'Manual anime');
    expect(animeAddSchema.sections.map((section) => section.id), [
      'series',
      'release',
      'metadata',
    ]);
    expect(
      [
        for (final section in animeAddSchema.sections)
          for (final field in section.fields) field.id,
      ],
      containsAll(<String>[
        'format',
        'season',
        'season_year',
        'episode_count',
        'episode_runtime_minutes',
        'airing_status',
        'source_material',
        'studio',
        'edition_title',
        'physical_format',
        'region',
        'barcode',
        'publisher',
        'release_date',
        'native_title',
        'romaji_title',
        'genres',
        'themes',
        'synopsis',
      ]),
    );
  });

  test('binds Anime vocabularies and validates dates/counts', () {
    final draft = AnimeAddManualDraft();
    addTearDown(draft.dispose);

    final format =
        _field('format') as VocabularyAddField<AnimeAddManualDraft, String>;
    final season =
        _field('season') as VocabularyAddField<AnimeAddManualDraft, String>;
    final region =
        _field('region') as VocabularyAddField<AnimeAddManualDraft, String>;
    expect(
      format.options.map((option) => option.value),
      AnimeVocabularies.format.builtIns,
    );
    expect(
      season.options.map((option) => option.value),
      AnimeVocabularies.season.builtIns,
    );
    expect(
      region.options.map((option) => option.value),
      AnimeVocabularies.region.builtIns,
    );

    format.updateValue(draft, 'OVA');
    season.updateValue(draft, 'Winter');
    region.updateValue(draft, 'Region B / Region 2');
    expect(format.currentValue(draft), 'OVA');
    expect(season.currentValue(draft), 'Winter');
    expect(region.currentValue(draft), 'Region B / Region 2');

    final count =
        _field('episode_count') as NumberAddField<AnimeAddManualDraft>;
    count.setValue(draft, -1);
    expect(animeAddSchema.validate!(draft), 'Episode count cannot be negative');
    count.setValue(draft, 12);

    draft.startDateController.text = '2026-05-02';
    draft.endDateController.text = '2026-04-02';
    expect(
      animeAddSchema.validate!(draft),
      'End date cannot be before start date',
    );
    draft.endDateController.text = 'not-a-date';
    expect(animeAddSchema.validate!(draft), 'End date is invalid');
  });
}

AddFieldSpec<AnimeAddManualDraft> _field(String id) {
  return [
    for (final section in animeAddSchema.sections)
      for (final field in section.fields)
        if (field.id == id) field,
  ].single;
}
