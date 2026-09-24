import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_values.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/add_contract.dart';

void main() {
  defineAddContract<AddSchema<BoardgameAddManualDraft>>(
    name: 'BoardGame',
    create: () => boardGameAddSchema,
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

  test('manual Add exposes typed work and edition data', () {
    final draft = BoardgameAddManualDraft();
    addTearDown(draft.dispose);

    expect(boardGameAddSchema.sections.map((section) => section.id), [
      'work',
      'edition',
    ]);
    final ids = [
      for (final section in boardGameAddSchema.sections)
        for (final field in section.fields) field.id,
    ];
    expect(ids, containsAll([
      'designers',
      'categories',
      'year_published',
      'edition_title',
      'publisher',
      'barcode',
      'release_date',
    ]));
    expect(draft.values, isA<BoardGameCatalogFormValues>());
  });

  test('validates the player range without parsing controller text', () {
    final draft = BoardgameAddManualDraft(
      values: BoardGameCatalogFormValues(minPlayers: 5, maxPlayers: 2),
    );
    addTearDown(draft.dispose);
    expect(
      boardGameAddSchema.validate!(draft),
      'Minimum players cannot exceed maximum players',
    );
    draft.values.maxPlayers = 6;
    expect(boardGameAddSchema.validate!(draft), isNull);
  });
}
