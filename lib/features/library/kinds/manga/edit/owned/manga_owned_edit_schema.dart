import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/manga_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:flutter/material.dart';

final EditSchema<MangaOwnedDetails, MangaEditDraft> mangaOwnedEditSchema =
    EditSchema(
  title: (_) => 'Edit manga ownership',
  tabs: [
    EditTabSpec(
      id: 'owned',
      label: 'Owned',
      icon: Icons.inventory_2,
      sections: [
        EditSectionSpec(
          id: 'grading',
          label: 'Grading',
          fields: [
            SelectEditField<MangaEditDraft, String>(
              id: 'raw_or_slabbed',
              label: 'Raw / Slabbed',
              value: (draft) => draft.rawOrSlabbed,
              setValue: (draft, value) => draft.rawOrSlabbed = value,
              options: const [
                EditOption(value: 'Raw', label: 'Raw'),
                EditOption(value: 'Slabbed', label: 'Slabbed'),
              ],
            ),
            TextEditField<MangaEditDraft>(
              id: 'grading_company',
              label: 'Grading company',
              value: (draft) => draft.gradingCompany ?? '',
              setValue: (draft, value) =>
                  draft.gradingCompany = _emptyToNull(value),
            ),
            TextEditField<MangaEditDraft>(
              id: 'grader_notes',
              label: 'Grader notes',
              value: (draft) => draft.graderNotes ?? '',
              setValue: (draft, value) =>
                  draft.graderNotes = _emptyToNull(value),
              maxLines: 4,
            ),
            TextEditField<MangaEditDraft>(
              id: 'label_type',
              label: 'Label type',
              value: (draft) => draft.labelType ?? '',
              setValue: (draft, value) => draft.labelType = _emptyToNull(value),
            ),
            TextEditField<MangaEditDraft>(
              id: 'custom_label',
              label: 'Custom label',
              value: (draft) => draft.customLabel ?? '',
              setValue: (draft, value) =>
                  draft.customLabel = _emptyToNull(value),
            ),
            TextEditField<MangaEditDraft>(
              id: 'page_quality',
              label: 'Page quality',
              value: (draft) => draft.pageQuality ?? '',
              setValue: (draft, value) =>
                  draft.pageQuality = _emptyToNull(value),
            ),
            TextEditField<MangaEditDraft>(
              id: 'certification_number',
              label: 'Certification number',
              value: (draft) => draft.certificationNumber ?? '',
              setValue: (draft, value) =>
                  draft.certificationNumber = _emptyToNull(value),
            ),
          ],
        ),
        EditSectionSpec(
          id: 'signature',
          label: 'Signature',
          fields: [
            TextEditField<MangaEditDraft>(
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
            ToggleEditField<MangaEditDraft>(
              id: 'obi_strip_present',
              label: 'Obi strip present',
              value: (draft) => draft.obiStripPresent,
              setValue: (draft, value) => draft.obiStripPresent = value,
            ),
            ToggleEditField<MangaEditDraft>(
              id: 'slipcover_present',
              label: 'Slipcover present',
              value: (draft) => draft.slipcoverPresent,
              setValue: (draft, value) => draft.slipcoverPresent = value,
            ),
            ToggleEditField<MangaEditDraft>(
              id: 'dust_jacket_present',
              label: 'Dust jacket present',
              value: (draft) => draft.dustJacketPresent,
              setValue: (draft, value) => draft.dustJacketPresent = value,
            ),
            TextEditField<MangaEditDraft>(
              id: 'dust_jacket_condition',
              label: 'Dust jacket condition',
              value: (draft) => draft.dustJacketCondition ?? '',
              setValue: (draft, value) =>
                  draft.dustJacketCondition = _emptyToNull(value),
            ),
            TextEditField<MangaEditDraft>(
              id: 'box_set_outer_condition',
              label: 'Box set outer condition',
              value: (draft) => draft.boxSetOuterCondition ?? '',
              setValue: (draft, value) =>
                  draft.boxSetOuterCondition = _emptyToNull(value),
            ),
            ToggleEditField<MangaEditDraft>(
              id: 'inserts_present',
              label: 'Inserts present',
              value: (draft) => draft.insertsPresent,
              setValue: (draft, value) => draft.insertsPresent = value,
            ),
            TextEditField<MangaEditDraft>(
              id: 'printing',
              label: 'Printing',
              value: (draft) => draft.printing ?? '',
              setValue: (draft, value) => draft.printing = _emptyToNull(value),
            ),
            TextEditField<MangaEditDraft>(
              id: 'localized_edition',
              label: 'Localized edition',
              value: (draft) => draft.localizedEdition ?? '',
              setValue: (draft, value) =>
                  draft.localizedEdition = _emptyToNull(value),
            ),
          ],
        ),
      ],
    ),
  ],
);

String? _emptyToNull(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
