import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';

final EditSchema<MusicRelease, MusicReleaseEditDraft> musicReleaseEditSchema =
    EditSchema(
  title: (release) => 'Edit ${release.title}',
  validate: (_, draft) {
    if (draft.title.trim().isEmpty) return 'Release title is required';
    return null;
  },
  tabs: [
    EditTabSpec<MusicReleaseEditDraft>(
      id: 'release',
      label: 'Release',
      sections: [
        EditSectionSpec<MusicReleaseEditDraft>(
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
              id: 'artist',
              label: 'Artist',
              value: (draft) => draft.artist ?? '',
              setValue: (draft, value) => draft.artist = value,
            ),
            _text(
              id: 'sort_title',
              label: 'Sort title',
              value: (draft) => draft.sortTitle ?? '',
              setValue: (draft, value) => draft.sortTitle = value,
            ),
            VocabularyEditField<MusicReleaseEditDraft, String>(
              id: 'release_type',
              label: 'Release type',
              value: (draft) => draft.releaseType,
              setValue: (draft, value) => draft.releaseType = value,
              options: _options(
                  const ['Album', 'EP', 'Single', 'Compilation', 'Live']),
            ),
            VocabularyEditField<MusicReleaseEditDraft, String>(
              id: 'release_status',
              label: 'Release status',
              value: (draft) => draft.releaseStatus,
              setValue: (draft, value) => draft.releaseStatus = value,
              options: _options(const ['Official', 'Promotional', 'Bootleg']),
            ),
          ],
        ),
        EditSectionSpec<MusicReleaseEditDraft>(
          id: 'publishing',
          label: 'Publishing',
          fields: [
            _text(
              id: 'publisher',
              label: 'Record label',
              value: (draft) => draft.publisher ?? '',
              setValue: (draft, value) => draft.publisher = value,
            ),
            _text(
              id: 'catalog_number',
              label: 'Catalog number',
              value: (draft) => draft.catalogNumber ?? '',
              setValue: (draft, value) => draft.catalogNumber = value,
            ),
            _text(
              id: 'barcode',
              label: 'Barcode',
              value: (draft) => draft.barcode ?? '',
              setValue: (draft, value) => draft.barcode = value,
            ),
            VocabularyEditField<MusicReleaseEditDraft, String>(
              id: 'country_code',
              label: 'Country',
              value: (draft) => draft.countryCode,
              setValue: (draft, value) => draft.countryCode = value,
              options: _options(MusicVocabularies.country.builtIns),
            ),
            _text(
              id: 'language',
              label: 'Language',
              value: (draft) => draft.language ?? '',
              setValue: (draft, value) => draft.language = value,
            ),
            DateEditField<MusicReleaseEditDraft>(
              id: 'release_date',
              label: 'Release date',
              value: (draft) => draft.releaseDate,
              setValue: (draft, value) => draft.releaseDate = value,
            ),
            DateEditField<MusicReleaseEditDraft>(
              id: 'recording_date',
              label: 'Recording date',
              value: (draft) => draft.recordingDate,
              setValue: (draft, value) => draft.recordingDate = value,
            ),
            _text(
              id: 'genres',
              label: 'Genres',
              value: (draft) => draft.genres.join(', '),
              setValue: (draft, value) => draft.genres = _split(value),
            ),
            _text(
              id: 'studio',
              label: 'Studio',
              value: (draft) => draft.studio ?? '',
              setValue: (draft, value) => draft.studio = value,
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

TextEditField<MusicReleaseEditDraft> _text({
  required String id,
  required String label,
  required String Function(MusicReleaseEditDraft draft) value,
  required void Function(MusicReleaseEditDraft draft, String value) setValue,
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

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);
