import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/entry/comic_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:flutter/material.dart';

final EditSchema<ComicEntryDetails, ComicEntryEditDraft> comicEntryEditSchema =
    EditSchema(
  title: (_) => 'Edit comic entries',
  validate: (_, draft) {
    if (draft.coverPriceCents case final price? when price < 0) {
      return 'Cover price cannot be negative';
    }
    return null;
  },
  tabs: [
    EditTabSpec(
      id: 'entry',
      label: 'Entry',
      icon: Icons.inventory_2,
      sections: [
        EditSectionSpec(
          id: 'collector',
          label: 'Collector',
          fields: [
            LibrarySelectFieldSpec<ComicEntryEditDraft, String>(
              id: 'raw_or_slabbed',
              label: 'Raw / Slabbed',
              value: (draft) => draft.rawOrSlabbed,
              setValue: (draft, value) => draft.rawOrSlabbed = value,
              options: const [
                LibraryFieldOption(value: 'Raw', label: 'Raw'),
                LibraryFieldOption(value: 'Slabbed', label: 'Slabbed'),
              ],
            ),
            LibraryTextFieldSpec<ComicEntryEditDraft>(
              id: 'grading_company',
              label: 'Grading company',
              value: (draft) => draft.gradingCompany ?? '',
              setValue: (draft, value) => draft.gradingCompany = value,
            ),
            LibraryTextFieldSpec<ComicEntryEditDraft>(
              id: 'certification_number',
              label: 'Certification number',
              value: (draft) => draft.certificationNumber ?? '',
              setValue: (draft, value) => draft.certificationNumber = value,
            ),
            LibraryTextFieldSpec<ComicEntryEditDraft>(
              id: 'label_type',
              label: 'Label type',
              value: (draft) => draft.labelType ?? '',
              setValue: (draft, value) => draft.labelType = value,
            ),
            LibraryTextFieldSpec<ComicEntryEditDraft>(
              id: 'custom_label',
              label: 'Custom label',
              value: (draft) => draft.customLabel ?? '',
              setValue: (draft, value) => draft.customLabel = value,
            ),
            LibraryVocabularyFieldSpec<ComicEntryEditDraft, String>(
              id: 'page_quality',
              label: 'Page quality',
              value: (draft) => draft.pageQuality,
              setValue: (draft, value) => draft.pageQuality = value,
              options: _options(ComicVocabularies.pageQuality.builtIns),
            ),
            LibraryTextFieldSpec<ComicEntryEditDraft>(
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
            LibraryTextFieldSpec<ComicEntryEditDraft>(
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
            LibraryToggleFieldSpec<ComicEntryEditDraft>(
              id: 'key_comic',
              label: 'Key comic',
              value: (draft) => draft.keyComic,
              setValue: (draft, value) => draft.keyComic = value,
            ),
            LibraryTextFieldSpec<ComicEntryEditDraft>(
              id: 'key_reason',
              label: 'Key reason',
              value: (draft) => draft.keyReason ?? '',
              setValue: (draft, value) => draft.keyReason = value,
              visibleWhen: (draft) => draft.keyComic,
            ),
            LibraryVocabularyFieldSpec<ComicEntryEditDraft, String>(
              id: 'key_category',
              label: 'Key category',
              value: (draft) => draft.keyCategory,
              setValue: (draft, value) => draft.keyCategory = value,
              options: _options(ComicVocabularies.keyCategory.builtIns),
              visibleWhen: (draft) => draft.keyComic,
            ),
            LibraryTextFieldSpec<ComicEntryEditDraft>(
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
            LibraryMoneyFieldSpec<ComicEntryEditDraft>(
              id: 'cover_price',
              label: 'Cover price',
              cents: (draft) => draft.coverPriceCents,
              setCents: (draft, value) => draft.coverPriceCents = value,
              currency: (_) => 'USD',
              validator: _validCoverPrice,
            ),
            LibraryDateFieldSpec<ComicEntryEditDraft>(
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

List<LibraryFieldOption<String>> _options(Iterable<String> values) => [
      for (final value in values)
        LibraryFieldOption(value: value, label: value),
    ];

String? _validCoverPrice(ComicEntryEditDraft draft) {
  final value = draft.coverPriceCents;
  return value != null && value < 0 ? 'Cover price cannot be negative' : null;
}
