import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/entries/tv_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/tv/vocabulary/tv_vocabularies.dart';

const _tvHdrFormats = [
  'HDR10',
  'HDR10+',
  'Dolby Vision',
  'HLG',
];

final EditSchema<TvEntryDetails, TvEntryEditDraft> tvEntryEditSchema =
    EditSchema(
  title: (_) => 'Edit TV entries',
  tabs: [
    EditTabSpec<TvEntryEditDraft>(
      id: 'entry',
      label: 'Entry',
      sections: [
        LibraryFormSectionSpec<TvEntryEditDraft>(
          id: 'physical',
          label: 'Media Details',
          fields: [
            _text(
              id: 'features',
              label: 'Features',
              value: (draft) => draft.features ?? '',
              setValue: (draft, value) => draft.features = value,
            ),
            LibraryMultiVocabularyFieldSpec<TvEntryEditDraft, String>(
              id: 'hdr_formats',
              values: (draft) => draft.hdrFormats.toSet(),
              setValues: (draft, values) =>
                  draft.hdrFormats = values.toList(growable: false),
              label: 'HDR formats',
              options: _options(_tvHdrFormats),
            ),
            _text(
              id: 'box_set_id',
              label: 'Box set ID',
              value: (draft) => draft.boxSetId ?? '',
              setValue: (draft, value) => draft.boxSetId = value,
            ),
            _text(
              id: 'box_set_name',
              label: 'Box set name',
              value: (draft) => draft.boxSetName ?? '',
              setValue: (draft, value) => draft.boxSetName = value,
            ),
            LibraryVocabularyFieldSpec<TvEntryEditDraft, String>(
              id: 'region',
              label: 'Region',
              value: (draft) => draft.region,
              setValue: (draft, value) => draft.region = value,
              options: _options(TvVocabularies.region.builtIns),
              pickListKey: TvVocabularyIds.region.value,
            ),
            LibraryVocabularyFieldSpec<TvEntryEditDraft, String>(
              id: 'packaging',
              label: 'Packaging',
              value: (draft) => draft.packaging,
              setValue: (draft, value) => draft.packaging = value,
              options: _options(TvVocabularies.packaging.builtIns),
              pickListKey: TvVocabularyIds.packaging.value,
            ),
            LibraryVocabularyFieldSpec<TvEntryEditDraft, String>(
              id: 'distributor',
              label: 'Distributor',
              value: (draft) => draft.distributor,
              setValue: (draft, value) => draft.distributor = value,
              options: _options(TvVocabularies.distributor.builtIns),
              pickListKey: TvVocabularyIds.distributor.value,
            ),
          ],
        ),
      ],
    ),
  ],
);

LibraryTextFieldSpec<TvEntryEditDraft> _text({
  required String id,
  required String label,
  required String Function(TvEntryEditDraft draft) value,
  required void Function(TvEntryEditDraft draft, String value) setValue,
}) =>
    LibraryTextFieldSpec(
      id: id,
      label: label,
      value: value,
      setValue: setValue,
    );

List<LibraryFieldOption<String>> _options(Iterable<String> values) => [
      for (final value in values)
        LibraryFieldOption(value: value, label: value),
    ];
