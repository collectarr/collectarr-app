import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/book_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';
import 'package:flutter/material.dart';

final EditSchema<BookOwnedDetails, BookEditDraft> bookOwnedEditSchema =
    EditSchema(
  title: (_) => 'Edit book ownership',
  tabs: [
    EditTabSpec(
      id: 'owned',
      label: 'Owned',
      icon: Icons.inventory_2,
      sections: [
        EditSectionSpec(
          id: 'signature',
          label: 'Signature',
          fields: [
            TextEditField<BookEditDraft>(
              id: 'signed_by',
              label: 'Signed by',
              value: (draft) => draft.signedBy ?? '',
              setValue: (draft, value) => draft.signedBy = _emptyToNull(value),
            ),
          ],
        ),
        EditSectionSpec(
          id: 'edition_details',
          label: 'Edition details',
          fields: [
            ToggleEditField<BookEditDraft>(
              id: 'dust_jacket_present',
              label: 'Dust jacket present',
              value: (draft) => draft.dustJacketPresent,
              setValue: (draft, value) => draft.dustJacketPresent = value,
            ),
            VocabularyEditField<BookEditDraft, String>(
              id: 'dust_jacket_condition',
              label: 'Dust jacket condition',
              value: (draft) => _emptyToNull(draft.dustJacketCondition ?? ''),
              setValue: (draft, value) => draft.dustJacketCondition = value,
              options: _options(BookVocabularies.condition.builtIns),
              visibleWhen: (draft) => draft.dustJacketPresent,
            ),
          ],
        ),
      ],
    ),
  ],
);

List<EditOption<String>> _options(Iterable<String> values) => [
      for (final value in values) EditOption(value: value, label: value),
    ];

String? _emptyToNull(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
