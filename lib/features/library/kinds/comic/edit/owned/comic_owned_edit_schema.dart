import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/owned/comic_owned_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:flutter/material.dart';

final EditSchema<ComicOwnedDetails, ComicOwnedEditDraft> comicOwnedEditSchema =
    EditSchema(
  title: (_) => 'Edit comic ownership',
  validate: (_, draft) {
    if (draft.coverPriceCents case final price? when price < 0) {
      return 'Cover price cannot be negative';
    }
    return null;
  },
  tabs: [
    EditTabSpec(
      id: 'owned',
      label: 'Owned',
      icon: Icons.inventory_2,
      sections: [
        EditSectionSpec(
          id: 'collector',
          label: 'Collector',
          fields: [
            SelectEditField<ComicOwnedEditDraft, String>(
              id: 'raw_or_slabbed',
              label: 'Raw / Slabbed',
              value: (draft) => draft.rawOrSlabbed,
              setValue: (draft, value) => draft.rawOrSlabbed = value,
              options: const [
                EditOption(value: 'Raw', label: 'Raw'),
                EditOption(value: 'Slabbed', label: 'Slabbed'),
              ],
            ),
            TextEditField<ComicOwnedEditDraft>(
              id: 'grading_company',
              label: 'Grading company',
              value: (draft) => draft.gradingCompany ?? '',
              setValue: (draft, value) => draft.gradingCompany = value,
            ),
            TextEditField<ComicOwnedEditDraft>(
              id: 'certification_number',
              label: 'Certification number',
              value: (draft) => draft.certificationNumber ?? '',
              setValue: (draft, value) => draft.certificationNumber = value,
            ),
            TextEditField<ComicOwnedEditDraft>(
              id: 'label_type',
              label: 'Label type',
              value: (draft) => draft.labelType ?? '',
              setValue: (draft, value) => draft.labelType = value,
            ),
            TextEditField<ComicOwnedEditDraft>(
              id: 'custom_label',
              label: 'Custom label',
              value: (draft) => draft.customLabel ?? '',
              setValue: (draft, value) => draft.customLabel = value,
            ),
            VocabularyEditField<ComicOwnedEditDraft, String>(
              id: 'page_quality',
              label: 'Page quality',
              value: (draft) => draft.pageQuality,
              setValue: (draft, value) => draft.pageQuality = value,
              options: _options(ComicVocabularies.pageQuality.builtIns),
            ),
            TextEditField<ComicOwnedEditDraft>(
              id: 'grader_notes',
              label: 'Grader notes',
              value: (draft) => draft.graderNotes ?? '',
              setValue: (draft, value) => draft.graderNotes = value,
              maxLines: 4,
            ),
          ],
        ),
        EditSectionSpec(
          id: 'signature',
          label: 'Signature',
          fields: [
            TextEditField<ComicOwnedEditDraft>(
              id: 'signed_by',
              label: 'Signed by',
              value: (draft) => draft.signedBy ?? '',
              setValue: (draft, value) => draft.signedBy = value,
            ),
          ],
        ),
        EditSectionSpec(
          id: 'key_comic',
          label: 'Key comic',
          fields: [
            ToggleEditField<ComicOwnedEditDraft>(
              id: 'key_comic',
              label: 'Key comic',
              value: (draft) => draft.keyComic,
              setValue: (draft, value) => draft.keyComic = value,
            ),
            TextEditField<ComicOwnedEditDraft>(
              id: 'key_reason',
              label: 'Key reason',
              value: (draft) => draft.keyReason ?? '',
              setValue: (draft, value) => draft.keyReason = value,
              visibleWhen: (draft) => draft.keyComic,
            ),
            VocabularyEditField<ComicOwnedEditDraft, String>(
              id: 'key_category',
              label: 'Key category',
              value: (draft) => draft.keyCategory,
              setValue: (draft, value) => draft.keyCategory = value,
              options: _options(ComicVocabularies.keyCategory.builtIns),
              visibleWhen: (draft) => draft.keyComic,
            ),
            TextEditField<ComicOwnedEditDraft>(
              id: 'key_severity',
              label: 'Key severity',
              value: (draft) => draft.keySeverity ?? '',
              setValue: (draft, value) => draft.keySeverity = value,
              visibleWhen: (draft) => draft.keyComic,
            ),
          ],
        ),
        EditSectionSpec(
          id: 'preservation',
          label: 'Preservation and value',
          fields: [
            MoneyEditField<ComicOwnedEditDraft>(
              id: 'cover_price',
              label: 'Cover price',
              cents: (draft) => draft.coverPriceCents,
              setCents: (draft, value) => draft.coverPriceCents = value,
              currency: (_) => 'USD',
              validator: _validCoverPrice,
            ),
            DateEditField<ComicOwnedEditDraft>(
              id: 'last_bag_board_date',
              label: 'Last bag and board date',
              value: (draft) => draft.lastBagBoardDate,
              setValue: (draft, value) => draft.lastBagBoardDate = value,
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

String? _validCoverPrice(ComicOwnedEditDraft draft) {
  final value = draft.coverPriceCents;
  return value != null && value < 0 ? 'Cover price cannot be negative' : null;
}
