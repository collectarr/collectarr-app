import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_owned_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/anime/vocabulary/anime_vocabularies.dart';

final EditSchema<AnimeOwnedDetails, AnimeOwnedEditDraft> animeOwnedEditSchema =
    EditSchema(
  title: (_) => 'Edit anime ownership',
  tabs: [
    EditTabSpec<AnimeOwnedEditDraft>(
      id: 'owned',
      label: 'Owned',
      sections: [
        EditSectionSpec<AnimeOwnedEditDraft>(
          id: 'physical',
          label: 'Physical copy',
          fields: [
            _text(
              id: 'features',
              label: 'Features',
              value: (draft) => draft.features ?? '',
              setValue: (draft, value) => draft.features = value,
            ),
            MultiVocabularyEditField<AnimeOwnedEditDraft, String>(
              id: 'hdr_formats',
              values: (draft) => draft.hdrFormats.toSet(),
              setValues: (draft, values) =>
                  draft.hdrFormats = values.toList(growable: false),
              label: 'HDR formats',
              options: _options(AnimeVocabularies.hdr.builtIns),
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
            VocabularyEditField<AnimeOwnedEditDraft, String>(
              id: 'region',
              label: 'Region',
              value: (draft) => draft.region,
              setValue: (draft, value) => draft.region = value,
              options: _options(AnimeVocabularies.region.builtIns),
            ),
            VocabularyEditField<AnimeOwnedEditDraft, String>(
              id: 'packaging',
              label: 'Packaging',
              value: (draft) => draft.packaging,
              setValue: (draft, value) => draft.packaging = value,
              options: _options(AnimeVocabularies.packaging.builtIns),
            ),
            VocabularyEditField<AnimeOwnedEditDraft, String>(
              id: 'distributor',
              label: 'Distributor',
              value: (draft) => draft.distributor,
              setValue: (draft, value) => draft.distributor = value,
              options: _options(AnimeVocabularies.distributor.builtIns),
            ),
          ],
        ),
      ],
    ),
  ],
);

TextEditField<AnimeOwnedEditDraft> _text({
  required String id,
  required String label,
  required String Function(AnimeOwnedEditDraft draft) value,
  required void Function(AnimeOwnedEditDraft draft, String value) setValue,
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
