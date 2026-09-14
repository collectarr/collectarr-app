import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_release.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/vocabulary/movie_vocabularies.dart';

final EditSchema<MovieRelease, MovieReleaseEditDraft> movieReleaseEditSchema =
    EditSchema(
  title: (release) => 'Edit ${release.title}',
  validate: (_, draft) {
    if (draft.title.trim().isEmpty) return 'Release title is required';
    if (draft.releaseDateController.text.trim().isNotEmpty &&
        draft.releaseDate == null) {
      return 'Release date is invalid';
    }
    return null;
  },
  tabs: [
    EditTabSpec<MovieReleaseEditDraft>(
      id: 'release',
      label: 'Release',
      sections: [
        EditSectionSpec<MovieReleaseEditDraft>(
          id: 'identity',
          label: 'Identity',
          fields: [
            _text(
              id: 'title',
              label: 'Title',
              value: (draft) => draft.title,
              setValue: (draft, value) => draft.title = value,
            ),
            VocabularyEditField<MovieReleaseEditDraft, String>(
              id: 'format',
              label: 'Format',
              value: (draft) => draft.format,
              setValue: (draft, value) => draft.format = value,
              options: _options(MovieVocabularies.physicalFormat.builtIns),
            ),
            VocabularyEditField<MovieReleaseEditDraft, String>(
              id: 'region',
              label: 'Region',
              value: (draft) => draft.region,
              setValue: (draft, value) => draft.region = value,
              options: _options(MovieVocabularies.region.builtIns),
            ),
            DateEditField<MovieReleaseEditDraft>(
              id: 'release_date',
              label: 'Release date',
              value: (draft) => draft.releaseDate,
              setValue: (draft, value) => draft.releaseDate = value,
            ),
          ],
        ),
        EditSectionSpec<MovieReleaseEditDraft>(
          id: 'publishing',
          label: 'Publishing',
          fields: [
            _text(
              id: 'distributor',
              label: 'Distributor',
              value: (draft) => draft.distributor ?? '',
              setValue: (draft, value) => draft.distributor = value,
            ),
            _text(
              id: 'language',
              label: 'Language',
              value: (draft) => draft.language ?? '',
              setValue: (draft, value) => draft.language = value,
            ),
            _text(
              id: 'description',
              label: 'Description',
              value: (draft) => draft.description ?? '',
              setValue: (draft, value) => draft.description = value,
              maxLines: 4,
            ),
            _text(
              id: 'cover_image_url',
              label: 'Cover image URL',
              value: (draft) => draft.coverImageUrl ?? '',
              setValue: (draft, value) => draft.coverImageUrl = value,
            ),
          ],
        ),
      ],
    ),
  ],
);

TextEditField<MovieReleaseEditDraft> _text({
  required String id,
  required String label,
  required String Function(MovieReleaseEditDraft draft) value,
  required void Function(MovieReleaseEditDraft draft, String value) setValue,
  int maxLines = 1,
}) =>
    TextEditField(
      id: id,
      label: label,
      value: value,
      setValue: setValue,
      maxLines: maxLines,
    );

List<EditOption<String>> _options(Iterable<String> values) => [
      for (final value in values) EditOption(value: value, label: value),
    ];
