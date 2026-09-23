import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_owned_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/movie/vocabulary/movie_vocabularies.dart';

final EditSchema<MovieOwnedDetails, MovieOwnedEditDraft> movieOwnedEditSchema =
    EditSchema(
  title: (_) => 'Edit movie ownership',
  tabs: [
    EditTabSpec<MovieOwnedEditDraft>(
      id: 'owned',
      label: 'Owned',
      sections: [
        EditSectionSpec<MovieOwnedEditDraft>(
          id: 'physical',
          label: 'Physical copy',
          fields: [
            _text(
              id: 'features',
              label: 'Features',
              value: (draft) => draft.features ?? '',
              setValue: (draft, value) => draft.features = value,
            ),
            LibraryMultiVocabularyFieldSpec<MovieOwnedEditDraft, String>(
              id: 'hdr_formats',
              values: (draft) => draft.hdrFormats.toSet(),
              setValues: (draft, values) =>
                  draft.hdrFormats = values.toList(growable: false),
              label: 'HDR formats',
              options: _options(MovieVocabularies.hdr.builtIns),
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
            LibraryVocabularyFieldSpec<MovieOwnedEditDraft, String>(
              id: 'region',
              label: 'Region',
              value: (draft) => draft.region,
              setValue: (draft, value) => draft.region = value,
              options: _options(MovieVocabularies.region.builtIns),
            ),
            LibraryVocabularyFieldSpec<MovieOwnedEditDraft, String>(
              id: 'packaging',
              label: 'Packaging',
              value: (draft) => draft.packaging,
              setValue: (draft, value) => draft.packaging = value,
              options: _options(MovieVocabularies.packaging.builtIns),
            ),
            LibraryVocabularyFieldSpec<MovieOwnedEditDraft, String>(
              id: 'distributor',
              label: 'Distributor',
              value: (draft) => draft.distributor,
              setValue: (draft, value) => draft.distributor = value,
              options: _options(MovieVocabularies.distributor.builtIns),
            ),
          ],
        ),
      ],
    ),
  ],
);

LibraryTextFieldSpec<MovieOwnedEditDraft> _text({
  required String id,
  required String label,
  required String Function(MovieOwnedEditDraft draft) value,
  required void Function(MovieOwnedEditDraft draft, String value) setValue,
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
