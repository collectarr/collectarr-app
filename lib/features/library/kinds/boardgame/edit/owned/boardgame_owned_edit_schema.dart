import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/boardgame_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';
import 'package:flutter/material.dart';

final EditSchema<BoardGameOwnedDetails, BoardGameEditDraft>
    boardGameOwnedEditSchema = EditSchema(
  title: (_) => 'Edit board game ownership',
  tabs: [
    EditTabSpec(
      id: 'owned',
      label: 'Owned',
      icon: Icons.inventory_2,
      sections: [
        EditSectionSpec(
          id: 'edition',
          label: 'Edition details',
          fields: [
            _textField(
              id: 'edition_language',
              label: 'Edition language',
              value: (draft) => draft.editionLanguage ?? '',
              setValue: (draft, value) => draft.editionLanguage = _text(value),
            ),
            _textField(
              id: 'edition_region',
              label: 'Edition region',
              value: (draft) => draft.editionRegion ?? '',
              setValue: (draft, value) => draft.editionRegion = _text(value),
            ),
          ],
        ),
        EditSectionSpec(
          id: 'condition',
          label: 'Condition and completeness',
          fields: [
            _textField(
              id: 'component_condition',
              label: 'Component condition',
              value: (draft) => draft.componentCondition ?? '',
              setValue: (draft, value) =>
                  draft.componentCondition = _text(value),
            ),
            _textField(
              id: 'component_completeness',
              label: 'Component completeness',
              value: (draft) => draft.componentCompleteness ?? '',
              setValue: (draft, value) =>
                  draft.componentCompleteness = _text(value),
            ),
            _textField(
              id: 'missing_pieces_notes',
              label: 'Missing pieces notes',
              value: (draft) => draft.missingPiecesNotes ?? '',
              setValue: (draft, value) =>
                  draft.missingPiecesNotes = _text(value),
            ),
          ],
        ),
        EditSectionSpec(
          id: 'customization',
          label: 'Customization and storage',
          fields: [
            ToggleEditField<BoardGameEditDraft>(
              id: 'is_sleeved',
              label: 'Sleeved',
              value: (draft) => draft.isSleeved,
              setValue: (draft, value) => draft.isSleeved = value,
            ),
            ToggleEditField<BoardGameEditDraft>(
              id: 'has_custom_insert',
              label: 'Custom insert',
              value: (draft) => draft.hasCustomInsert,
              setValue: (draft, value) => draft.hasCustomInsert = value,
            ),
            ToggleEditField<BoardGameEditDraft>(
              id: 'has_painted_miniatures',
              label: 'Painted miniatures',
              value: (draft) => draft.hasPaintedMiniatures,
              setValue: (draft, value) => draft.hasPaintedMiniatures = value,
            ),
            _textField(
              id: 'storage_notes',
              label: 'Storage notes',
              value: (draft) => draft.storageNotes ?? '',
              setValue: (draft, value) => draft.storageNotes = _text(value),
            ),
          ],
        ),
      ],
    ),
  ],
);

TextEditField<BoardGameEditDraft> _textField({
  required String id,
  required String label,
  required String Function(BoardGameEditDraft draft) value,
  required void Function(BoardGameEditDraft draft, String value) setValue,
}) {
  return TextEditField(
    id: id,
    label: label,
    value: value,
    setValue: setValue,
  );
}

String? _text(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
