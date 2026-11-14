import 'package:collectarr_app/features/library/config/edit_capability.dart';
import 'package:collectarr_app/features/library/edit/draft/entry_edit_draft.dart';
import 'package:collectarr_app/features/library/ui/primitives/fixed_select_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/segmented_choice_field.dart';
import 'package:flutter/material.dart';

import 'grading_options.dart';

/// Reference Comics pre-fill: how a new comic is graded, above the shared
/// location, purchase and tag fields; comics have no Condition.
List<LibraryPrefillField> comicPrefillFields(LibraryEntryEditDraft draft) {
  String? text(String key) =>
      draft.text(key).trim().isEmpty ? null : draft.text(key).trim();
  return [
    LibraryPrefillField(
        id: 'raw_or_slabbed',
        label: 'Raw / Slabbed',
        field: LibrarySegmentedChoiceField<String>(
          label: 'Raw / Slabbed',
          value: text('raw_or_slabbed') ?? 'Raw',
          options: const [('Raw', 'Raw'), ('Slabbed', 'Slabbed')],
          onChanged: (value) => draft.set('raw_or_slabbed', value),
        )),
    LibraryPrefillField(
        id: 'grade',
        label: 'Grade',
        field: LibraryFixedSelectField(
          label: 'Grade',
          value: text('grade'),
          options: comicGradeOptions,
          onChanged: (value) => draft.set('grade', value),
        )),
    LibraryPrefillField(
        id: 'grading_company',
        label: 'Grading Company',
        field: LibraryFormField(
          label: 'Grading Company',
          child: LibraryTextFormControl(
            key: const ValueKey('prefill-grading-company'),
            initialValue: text('grading_company') ?? '',
            onChanged: (value) => draft.set(
                'grading_company', value.trim().isEmpty ? null : value.trim()),
          ),
        )),
    LibraryPrefillField(
        id: 'label_type',
        label: 'Label Type',
        field: LibraryFixedSelectField(
          label: 'Label Type',
          value: text('label_type'),
          options: comicLabelTypeOptions,
          onChanged: (value) => draft.set('label_type', value),
        )),
  ];
}
