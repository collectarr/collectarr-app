import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/add_contract.dart';

void main() {
  defineAddContract<AddSchema<GameAddManualDraft>>(
    name: 'Game',
    create: () => gameAddSchema,
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

  test('declares typed Game release and metadata fields', () {
    final draft = GameAddManualDraft();
    addTearDown(draft.dispose);

    expect(gameAddSchema.title!(draft), 'Manual game');
    expect(gameAddSchema.sections.map((section) => section.id), [
      'release',
      'metadata',
    ]);
    expect(
      [
        for (final section in gameAddSchema.sections)
          for (final field in section.fields) field.id,
      ],
      containsAll(<String>[
        'platform',
        'format',
        'barcode',
        'release_year',
        'release_date',
        'publisher',
        'developers',
        'age_ratings',
        'genres',
      ]),
    );
  });

  test('binds Game vocabularies and validates release values', () {
    final draft = GameAddManualDraft();
    addTearDown(draft.dispose);

    final platform = _field('platform')
        as LibraryVocabularyFieldSpec<GameAddManualDraft, String>;
    final format = _field('format')
        as LibraryVocabularyFieldSpec<GameAddManualDraft, String>;
    final ageRatings = _field('age_ratings')
        as LibraryMultiVocabularyFieldSpec<GameAddManualDraft, String>;
    final region = _field('region')
        as LibraryVocabularyFieldSpec<GameAddManualDraft, String>;
    expect(
      platform.options.map((option) => option.value),
      GameVocabularies.platform.builtIns,
    );
    expect(
      format.options.map((option) => option.value),
      GameVocabularies.edition.builtIns,
    );
    expect(
      ageRatings.options.map((option) => option.value),
      GameVocabularies.ageRating.builtIns,
    );
    expect(
      region.options.map((option) => option.value),
      GameVocabularies.region.builtIns,
    );

    platform.updateValue(draft, 'PC');
    format.updateValue(draft, 'Collector\'s Edition');
    ageRatings.updateValues(draft, {'ESRB: Teen (T)'});
    region.updateValue(draft, 'Region Free');
    expect(platform.currentValue(draft), 'PC');
    expect(format.currentValue(draft), 'Collector\'s Edition');
    expect(ageRatings.currentValues(draft), {'ESRB: Teen (T)'});
    expect(region.currentValue(draft), 'Region Free');

    (_field('release_date') as LibraryDateFieldSpec<GameAddManualDraft>)
        .setValue(draft, DateTime(2026, 4, 12));
    expect(gameAddSchema.validate!(draft), isNull);

    draft.values.releaseYear = 0;
    expect(gameAddSchema.validate!(draft), 'Release year must be positive');
    draft.values.releaseYear = 2026;
    expect(gameAddSchema.validate!(draft), isNull);
  });

  test('typed values do not depend on text controllers', () {
    final values = GameCatalogFormValues(
      title: 'Game',
      platforms: const ['PC'],
    );
    expect(values.title, 'Game');
    expect(values.platforms, ['PC']);
  });
}

LibraryFieldSpec<GameAddManualDraft> _field(String id) {
  return [
    for (final section in gameAddSchema.sections)
      for (final field in section.fields)
        if (field.id == id) field,
  ].single;
}
