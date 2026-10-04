import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/entries/movie_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/movie/vocabulary/movie_vocabularies.dart';

final EditSchema<MovieEntryDetails, MovieEntryEditDraft> movieEntryEditSchema =
    EditSchema(
  title: (_) => 'Edit movie entries',
  tabs: [
    EditTabSpec<MovieEntryEditDraft>(
      id: 'entry',
      label: 'Entry',
      sections: [
        LibraryFormSectionSpec<MovieEntryEditDraft>(
          id: 'physical',
          label: 'Media Details',
          fields: [
            _text(
              id: 'features',
              label: 'Features',
              value: (draft) => draft.features ?? '',
              setValue: (draft, value) => draft.features = value,
            ),
            LibraryMultiVocabularyFieldSpec<MovieEntryEditDraft, String>(
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
            LibraryVocabularyFieldSpec<MovieEntryEditDraft, String>(
              id: 'region',
              label: 'Region',
              value: (draft) => draft.region,
              setValue: (draft, value) => draft.region = value,
              options: _options(MovieVocabularies.region.builtIns),
            ),
            LibraryVocabularyFieldSpec<MovieEntryEditDraft, String>(
              id: 'packaging',
              label: 'Packaging',
              value: (draft) => draft.packaging,
              setValue: (draft, value) => draft.packaging = value,
              options: _options(MovieVocabularies.packaging.builtIns),
            ),
            LibraryVocabularyFieldSpec<MovieEntryEditDraft, String>(
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

LibraryTextFieldSpec<MovieEntryEditDraft> _text({
  required String id,
  required String label,
  required String Function(MovieEntryEditDraft draft) value,
  required void Function(MovieEntryEditDraft draft, String value) setValue,
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
