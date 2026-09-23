import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/game_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';
import 'package:flutter/material.dart';

final EditSchema<GameOwnedDetails, GameEditDraft> gameOwnedEditSchema =
    EditSchema(
  title: (_) => 'Edit game ownership',
  tabs: [
    EditTabSpec(
      id: 'owned',
      label: 'Owned',
      icon: Icons.inventory_2,
      sections: [
        EditSectionSpec(
          id: 'completeness',
          label: 'Completeness',
          fields: [
            LibraryVocabularyFieldSpec<GameEditDraft, String>(
              id: 'completeness',
              label: 'Completeness',
              value: (draft) => draft.gameCompleteness,
              setValue: (draft, value) => draft.gameCompleteness = value,
              options: _options(GameVocabularies.condition.builtIns),
            ),
            LibraryToggleFieldSpec<GameEditDraft>(
              id: 'has_box',
              label: 'Has box',
              value: (draft) => draft.gameHasBox ?? false,
              setValue: (draft, value) => draft.gameHasBox = value,
            ),
            LibraryToggleFieldSpec<GameEditDraft>(
              id: 'has_manual',
              label: 'Has manual',
              value: (draft) => draft.gameHasManual ?? false,
              setValue: (draft, value) => draft.gameHasManual = value,
            ),
          ],
        ),
        EditSectionSpec(
          id: 'valuation',
          label: 'Valuation',
          fields: [
            LibraryTextFieldSpec<GameEditDraft>(
              id: 'pricecharting_id',
              label: 'PriceCharting ID',
              value: (draft) => draft.gamePriceChartingId ?? '',
              setValue: (draft, value) =>
                  draft.gamePriceChartingId = _emptyToNull(value),
            ),
            LibraryVocabularyFieldSpec<GameEditDraft, String>(
              id: 'core_region',
              label: 'Core region',
              value: (draft) => draft.gameCoreRegion,
              setValue: (draft, value) => draft.gameCoreRegion = value,
              options: _options(GameVocabularies.region.builtIns),
            ),
            LibraryToggleFieldSpec<GameEditDraft>(
              id: 'value_locked',
              label: 'Value locked',
              value: (draft) => draft.gameValueIsLocked,
              setValue: (draft, value) => draft.gameValueIsLocked = value,
            ),
          ],
        ),
      ],
    ),
  ],
);

List<LibraryFieldOption<String>> _options(Iterable<String> values) => [
      for (final value in values)
        LibraryFieldOption(value: value, label: value),
    ];

String? _emptyToNull(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
