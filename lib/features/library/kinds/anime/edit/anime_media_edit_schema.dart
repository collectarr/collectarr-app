import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_media_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/vocabulary/anime_vocabularies.dart';

final EditSchema<AnimeMedia, AnimeMediaEditDraft> animeMediaEditSchema =
    EditSchema(
  title: (media) => 'Edit ${media.title}',
  validate: (_, draft) {
    if (draft.title.trim().isEmpty) return 'Anime title is required';
    if (draft.seasonYear != null && draft.seasonYear! < 0) {
      return 'Season year cannot be negative';
    }
    if (draft.episodeCount != null && draft.episodeCount! < 0) {
      return 'Episode count cannot be negative';
    }
    if (draft.episodeRuntimeMinutes != null &&
        draft.episodeRuntimeMinutes! < 0) {
      return 'Episode runtime cannot be negative';
    }
    if (_hasText(draft.originalAirDateController.text) &&
        draft.originalAirDate == null) {
      return 'Start date is invalid';
    }
    if (_hasText(draft.endDateController.text) && draft.endDate == null) {
      return 'End date is invalid';
    }
    if (draft.originalAirDate != null &&
        draft.endDate != null &&
        draft.endDate!.isBefore(draft.originalAirDate!)) {
      return 'End date cannot be before start date';
    }
    return null;
  },
  tabs: [
    EditTabSpec<AnimeMediaEditDraft>(
      id: 'anime',
      label: 'Anime',
      sections: [
        EditSectionSpec<AnimeMediaEditDraft>(
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
            ImageEditField<AnimeMediaEditDraft, String>(
              id: 'cover_image_url',
              label: 'Cover image URL',
              value: (draft) => draft.coverImageUrl,
              setValue: (draft, value) => draft.coverImageUrl = value,
            ),
          ],
        ),
        EditSectionSpec<AnimeMediaEditDraft>(
          id: 'classification',
          label: 'Classification',
          fields: [
            VocabularyEditField<AnimeMediaEditDraft, String>(
              id: 'anime_type',
              label: 'Anime format',
              value: (draft) => draft.animeType,
              setValue: (draft, value) => draft.animeType = value,
              options: _options(AnimeVocabularies.format.builtIns),
            ),
            VocabularyEditField<AnimeMediaEditDraft, String>(
              id: 'season',
              label: 'Release season',
              value: (draft) => draft.season,
              setValue: (draft, value) => draft.season = value,
              options: _options(AnimeVocabularies.season.builtIns),
            ),
            VocabularyEditField<AnimeMediaEditDraft, String>(
              id: 'source_material',
              label: 'Source material',
              value: (draft) => draft.sourceMaterial,
              setValue: (draft, value) => draft.sourceMaterial = value,
              options: _options(const [
                'Manga',
                'Light Novel',
                'Original',
                'Visual Novel',
                'Game',
                'Novel',
                'Other',
              ]),
            ),
            _text(
              id: 'original_language',
              label: 'Original language',
              value: (draft) => draft.originalLanguage ?? '',
              setValue: (draft, value) => draft.originalLanguage = value,
            ),
            _text(
              id: 'genres',
              label: 'Genres',
              value: (draft) => draft.genres.join(', '),
              setValue: (draft, value) => draft.genres = _split(value),
            ),
            _text(
              id: 'themes',
              label: 'Themes',
              value: (draft) => draft.themes.join(', '),
              setValue: (draft, value) => draft.themes = _split(value),
            ),
          ],
        ),
        EditSectionSpec<AnimeMediaEditDraft>(
          id: 'production',
          label: 'Production',
          fields: [
            _text(
              id: 'studios',
              label: 'Studios',
              value: (draft) => draft.studios.join(', '),
              setValue: (draft, value) => draft.studios = _split(value),
            ),
            _text(
              id: 'producers',
              label: 'Producers',
              value: (draft) => draft.producers.join(', '),
              setValue: (draft, value) => draft.producers = _split(value),
            ),
            _text(
              id: 'licensors',
              label: 'Licensors',
              value: (draft) => draft.licensors.join(', '),
              setValue: (draft, value) => draft.licensors = _split(value),
            ),
            _text(
              id: 'status',
              label: 'Airing status',
              value: (draft) => draft.status ?? '',
              setValue: (draft, value) => draft.status = value,
            ),
          ],
        ),
        EditSectionSpec<AnimeMediaEditDraft>(
          id: 'schedule',
          label: 'Schedule',
          fields: [
            NumberEditField<AnimeMediaEditDraft>(
              id: 'season_year',
              label: 'Season year',
              value: (draft) => draft.seasonYear,
              setValue: (draft, value) => draft.seasonYear = value?.toInt(),
              minimum: 0,
            ),
            NumberEditField<AnimeMediaEditDraft>(
              id: 'episode_count',
              label: 'Episode count',
              value: (draft) => draft.episodeCount,
              setValue: (draft, value) => draft.episodeCount = value?.toInt(),
              minimum: 0,
            ),
            NumberEditField<AnimeMediaEditDraft>(
              id: 'episode_runtime_minutes',
              label: 'Episode runtime (minutes)',
              value: (draft) => draft.episodeRuntimeMinutes,
              setValue: (draft, value) =>
                  draft.episodeRuntimeMinutes = value?.toInt(),
              minimum: 0,
            ),
            DateEditField<AnimeMediaEditDraft>(
              id: 'start_date',
              label: 'Start date',
              value: (draft) => draft.originalAirDate,
              setValue: (draft, value) => draft.originalAirDate = value,
            ),
            DateEditField<AnimeMediaEditDraft>(
              id: 'end_date',
              label: 'End date',
              value: (draft) => draft.endDate,
              setValue: (draft, value) => draft.endDate = value,
            ),
          ],
        ),
      ],
    ),
  ],
);

TextEditField<AnimeMediaEditDraft> _text({
  required String id,
  required String label,
  required String Function(AnimeMediaEditDraft draft) value,
  required void Function(AnimeMediaEditDraft draft, String value) setValue,
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

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);

bool _hasText(String value) => value.trim().isNotEmpty;
