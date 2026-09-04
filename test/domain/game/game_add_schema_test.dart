import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_schema.dart';
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

  test('declares Game release and metadata sections', () {
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
        'edition',
        'barcode',
        'publication_year',
        'release_date',
        'publisher',
        'developers',
        'age_rating',
        'genres',
      ]),
    );
  });

  test('binds Game vocabularies and validates release values', () {
    final draft = GameAddManualDraft();
    addTearDown(draft.dispose);

    final platform =
        _field('platform') as VocabularyAddField<GameAddManualDraft, String>;
    final edition =
        _field('edition') as VocabularyAddField<GameAddManualDraft, String>;
    final ageRating =
        _field('age_rating') as VocabularyAddField<GameAddManualDraft, String>;
    final region =
        _field('region') as VocabularyAddField<GameAddManualDraft, String>;
    expect(
      platform.options.map((option) => option.value),
      GameVocabularies.platform.builtIns,
    );
    expect(
      edition.options.map((option) => option.value),
      GameVocabularies.edition.builtIns,
    );
    expect(
      ageRating.options.map((option) => option.value),
      GameVocabularies.ageRating.builtIns,
    );
    expect(
      region.options.map((option) => option.value),
      GameVocabularies.region.builtIns,
    );

    platform.updateValue(draft, 'PC');
    edition.updateValue(draft, 'Collector\'s Edition');
    ageRating.updateValue(draft, 'ESRB: Teen (T)');
    region.updateValue(draft, 'Region Free');
    expect(platform.currentValue(draft), 'PC');
    expect(edition.currentValue(draft), 'Collector\'s Edition');
    expect(ageRating.currentValue(draft), 'ESRB: Teen (T)');
    expect(region.currentValue(draft), 'Region Free');

    final releaseDate =
        _field('release_date') as DateAddField<GameAddManualDraft>;
    releaseDate.setValue(draft, DateTime(2026, 4, 12));
    expect(releaseDate.value(draft), DateTime(2026, 4, 12));
    expect(gameAddSchema.validate!(draft), isNull);

    final year =
        _field('publication_year') as NumberAddField<GameAddManualDraft>;
    year.setValue(draft, -1);
    expect(gameAddSchema.validate!(draft), 'Release year cannot be negative');
    year.setValue(draft, 2026);
    draft.releaseDateController.text = 'not-a-date';
    expect(gameAddSchema.validate!(draft), 'Release date is invalid');
  });
}

AddFieldSpec<GameAddManualDraft> _field(String id) {
  return [
    for (final section in gameAddSchema.sections)
      for (final field in section.fields)
        if (field.id == id) field,
  ].single;
}
