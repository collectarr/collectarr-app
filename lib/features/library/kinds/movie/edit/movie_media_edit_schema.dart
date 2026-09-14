import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_media_edit_draft.dart';

final EditSchema<MovieMedia, MovieMediaEditDraft> movieMediaEditSchema =
    EditSchema(
  title: (_) => 'Edit movie media',
  validate: (_, draft) {
    if (draft.title.trim().isEmpty) return 'Movie title is required';
    final runtime = draft.runtimeMinutes;
    if (runtime != null && runtime < 0) {
      return 'Runtime cannot be negative';
    }
    if (draft.releaseDateController.text.trim().isNotEmpty &&
        draft.releaseDate == null) {
      return 'Release date is invalid';
    }
    return null;
  },
  tabs: [
    EditTabSpec<MovieMediaEditDraft>(
      id: 'media',
      label: 'Media',
      sections: [
        EditSectionSpec<MovieMediaEditDraft>(
          id: 'identity',
          label: 'Identity',
          fields: [
            _text(
              id: 'title',
              label: 'Title',
              value: (draft) => draft.title,
              setValue: (draft, value) => draft.title = value,
            ),
            _text(
              id: 'sort_title',
              label: 'Sort title',
              value: (draft) => draft.sortTitle,
              setValue: (draft, value) => draft.sortTitle = value,
            ),
            _text(
              id: 'description',
              label: 'Synopsis',
              value: (draft) => draft.description,
              setValue: (draft, value) => draft.description = value,
              maxLines: 4,
            ),
          ],
        ),
        EditSectionSpec<MovieMediaEditDraft>(
          id: 'classification',
          label: 'Classification',
          fields: [
            _text(
              id: 'genres',
              label: 'Genres',
              value: (draft) => draft.genres.join(', '),
              setValue: (draft, value) => draft.genres = _split(value),
            ),
            _text(
              id: 'original_language',
              label: 'Original language',
              value: (draft) => draft.originalLanguage,
              setValue: (draft, value) => draft.originalLanguage = value,
            ),
            _text(
              id: 'age_rating',
              label: 'Age rating',
              value: (draft) => draft.ageRating,
              setValue: (draft, value) => draft.ageRating = value,
            ),
            _text(
              id: 'audience_rating',
              label: 'Audience rating',
              value: (draft) => draft.audienceRating,
              setValue: (draft, value) => draft.audienceRating = value,
            ),
            NumberEditField<MovieMediaEditDraft>(
              id: 'runtime_minutes',
              label: 'Runtime (minutes)',
              value: (draft) => draft.runtimeMinutes,
              setValue: (draft, value) => draft.runtimeMinutes = value?.toInt(),
              minimum: 0,
            ),
            DateEditField<MovieMediaEditDraft>(
              id: 'release_date',
              label: 'Release date',
              value: (draft) => draft.releaseDate,
              setValue: (draft, value) => draft.releaseDate = value,
              validator: (draft) =>
                  draft.releaseDateController.text.trim().isNotEmpty &&
                          draft.releaseDate == null
                      ? 'Release date is invalid'
                      : null,
            ),
            _text(
              id: 'subtitle',
              label: 'Subtitle',
              value: (draft) => draft.subtitle,
              setValue: (draft, value) => draft.subtitle = value,
            ),
          ],
        ),
      ],
    ),
  ],
);

TextEditField<MovieMediaEditDraft> _text({
  required String id,
  required String label,
  required String Function(MovieMediaEditDraft draft) value,
  required void Function(MovieMediaEditDraft draft, String value) setValue,
  int maxLines = 1,
}) =>
    TextEditField(
      id: id,
      label: label,
      value: value,
      setValue: setValue,
      maxLines: maxLines,
    );

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toList(growable: false);
