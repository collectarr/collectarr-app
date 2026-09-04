import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_owned_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/tv/vocabulary/tv_vocabularies.dart';

const _tvHdrFormats = [
  'HDR10',
  'HDR10+',
  'Dolby Vision',
  'HLG',
];

final EditSchema<TvOwnedDetails, TvOwnedEditDraft> tvOwnedEditSchema =
    EditSchema(
  title: (_) => 'Edit TV ownership',
  tabs: [
    EditTabSpec<TvOwnedEditDraft>(
      id: 'owned',
      label: 'Owned',
      sections: [
        EditSectionSpec<TvOwnedEditDraft>(
          id: 'physical',
          label: 'Physical copy',
          fields: [
            _text(
              id: 'features',
              label: 'Features',
              value: (draft) => draft.features ?? '',
              setValue: (draft, value) => draft.features = value,
            ),
            MultiVocabularyEditField<TvOwnedEditDraft, String>(
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
            VocabularyEditField<TvOwnedEditDraft, String>(
              id: 'region',
              label: 'Region',
              value: (draft) => draft.region,
              setValue: (draft, value) => draft.region = value,
              options: _options(TvVocabularies.region.builtIns),
            ),
            VocabularyEditField<TvOwnedEditDraft, String>(
              id: 'packaging',
              label: 'Packaging',
              value: (draft) => draft.packaging,
              setValue: (draft, value) => draft.packaging = value,
              options: _options(TvVocabularies.packaging.builtIns),
            ),
            VocabularyEditField<TvOwnedEditDraft, String>(
              id: 'distributor',
              label: 'Distributor',
              value: (draft) => draft.distributor,
              setValue: (draft, value) => draft.distributor = value,
              options: _options(TvVocabularies.distributor.builtIns),
            ),
          ],
        ),
      ],
    ),
  ],
);

TextEditField<TvOwnedEditDraft> _text({
  required String id,
  required String label,
  required String Function(TvOwnedEditDraft draft) value,
  required void Function(TvOwnedEditDraft draft, String value) setValue,
}) =>
    TextEditField(
      id: id,
      label: label,
      value: value,
      setValue: setValue,
    );

List<EditOption<String>> _options(Iterable<String> values) => [
      for (final value in values) EditOption(value: value, label: value),
    ];
