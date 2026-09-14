import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_release.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/vocabulary/anime_vocabularies.dart';

final EditSchema<AnimeRelease, AnimeReleaseEditDraft> animeReleaseEditSchema =
    EditSchema(
  title: (release) => 'Edit ${release.title}',
  validate: (_, draft) {
    if (draft.title.trim().isEmpty) return 'Release title is required';
    if (draft.mediaCount != null && draft.mediaCount! < 0) {
      return 'Media count cannot be negative';
    }
    if (draft.releaseDateController.text.trim().isNotEmpty &&
        draft.releaseDate == null) {
      return 'Release date is invalid';
    }
    return null;
  },
  tabs: [
    EditTabSpec<AnimeReleaseEditDraft>(
      id: 'release',
      label: 'Release',
      sections: [
        EditSectionSpec<AnimeReleaseEditDraft>(
          id: 'identity',
          label: 'Identity',
          fields: [
            _text(
              id: 'title',
              label: 'Title',
              value: (draft) => draft.title,
              setValue: (draft, value) => draft.title = value,
            ),
            VocabularyEditField<AnimeReleaseEditDraft, String>(
              id: 'format',
              label: 'Physical format',
              value: (draft) => draft.format,
              setValue: (draft, value) => draft.format = value,
              options: _options(AnimeVocabularies.physicalFormat.builtIns),
            ),
            VocabularyEditField<AnimeReleaseEditDraft, String>(
              id: 'region',
              label: 'Region',
              value: (draft) => draft.region,
              setValue: (draft, value) => draft.region = value,
              options: _options(AnimeVocabularies.region.builtIns),
            ),
            _text(
              id: 'language',
              label: 'Language',
              value: (draft) => draft.language ?? '',
              setValue: (draft, value) => draft.language = value,
            ),
            DateEditField<AnimeReleaseEditDraft>(
              id: 'release_date',
              label: 'Release date',
              value: (draft) => draft.releaseDate,
              setValue: (draft, value) => draft.releaseDate = value,
            ),
          ],
        ),
        EditSectionSpec<AnimeReleaseEditDraft>(
          id: 'publishing',
          label: 'Publishing',
          fields: [
            _text(
              id: 'publisher',
              label: 'Publisher / distributor',
              value: (draft) => draft.publisher ?? '',
              setValue: (draft, value) => draft.publisher = value,
            ),
            _text(
              id: 'barcode',
              label: 'Barcode',
              value: (draft) => draft.barcode ?? '',
              setValue: (draft, value) => draft.barcode = value,
            ),
            NumberEditField<AnimeReleaseEditDraft>(
              id: 'media_count',
              label: 'Media count',
              value: (draft) => draft.mediaCount,
              setValue: (draft, value) => draft.mediaCount = value?.toInt(),
              minimum: 0,
            ),
            _text(
              id: 'description',
              label: 'Description',
              value: (draft) => draft.description ?? '',
              setValue: (draft, value) => draft.description = value,
              maxLines: 4,
            ),
            _text(
              id: 'audio_tracks',
              label: 'Audio languages',
              value: (draft) => draft.audioTracks.join(', '),
              setValue: (draft, value) => draft.audioTracks = _split(value),
            ),
            _text(
              id: 'subtitles',
              label: 'Subtitle languages',
              value: (draft) => draft.subtitles.join(', '),
              setValue: (draft, value) => draft.subtitles = _split(value),
            ),
            ImageEditField<AnimeReleaseEditDraft, String>(
              id: 'cover_image_url',
              label: 'Cover image URL',
              value: (draft) => draft.coverImageUrl,
              setValue: (draft, value) => draft.coverImageUrl = value,
            ),
          ],
        ),
      ],
    ),
  ],
);

TextEditField<AnimeReleaseEditDraft> _text({
  required String id,
  required String label,
  required String Function(AnimeReleaseEditDraft draft) value,
  required void Function(AnimeReleaseEditDraft draft, String value) setValue,
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
