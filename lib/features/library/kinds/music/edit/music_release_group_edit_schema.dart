import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_group_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:flutter/material.dart';

final EditSchema<MusicReleaseGroup, MusicReleaseGroupEditDraft>
    musicReleaseGroupEditSchema = EditSchema(
  title: (group) => 'Edit ${group.title}',
  validate: (_, draft) {
    if (draft.title.trim().isEmpty) return 'Release group title is required';
    return null;
  },
  tabs: [
    EditTabSpec<MusicReleaseGroupEditDraft>(
      id: 'release_group',
      label: 'Release group',
      icon: Icons.music_note_outlined,
      sections: [
        EditSectionSpec<MusicReleaseGroupEditDraft>(
          id: 'identity',
          label: 'Identity',
          fields: [
            _text(
                id: 'title',
                label: 'Title',
                value: (draft) => draft.title,
                setValue: (draft, value) => draft.title = value),
            _text(
                id: 'sort_title',
                label: 'Sort title',
                value: (draft) => draft.sortTitle ?? '',
                setValue: (draft, value) => draft.sortTitle = value),
            _text(
                id: 'artist',
                label: 'Artist',
                value: (draft) => draft.artist ?? '',
                setValue: (draft, value) => draft.artist = value),
            _text(
                id: 'original_title',
                label: 'Original title',
                value: (draft) => draft.originalTitle ?? '',
                setValue: (draft, value) => draft.originalTitle = value),
            _text(
                id: 'synopsis',
                label: 'Synopsis',
                value: (draft) => draft.synopsis ?? '',
                setValue: (draft, value) => draft.synopsis = value),
            LibrarySelectFieldSpec<MusicReleaseGroupEditDraft, bool>(
              id: 'is_live',
              label: 'Recording type',
              value: (draft) => draft.isLive,
              setValue: (draft, value) => draft.isLive = value,
              options: const [
                LibraryFieldOption(value: true, label: 'Live recording'),
                LibraryFieldOption(value: false, label: 'Studio recording'),
              ],
            ),
          ],
        ),
        EditSectionSpec<MusicReleaseGroupEditDraft>(
          id: 'recording',
          label: 'Recording',
          fields: [
            LibraryDateFieldSpec<MusicReleaseGroupEditDraft>(
              id: 'original_release_date',
              label: 'Original release date',
              value: (draft) => draft.originalReleaseDate,
              setValue: (draft, value) => draft.originalReleaseDate = value,
            ),
            LibraryDateFieldSpec<MusicReleaseGroupEditDraft>(
              id: 'recording_date',
              label: 'Recording date',
              value: (draft) => draft.recordingDate,
              setValue: (draft, value) => draft.recordingDate = value,
            ),
            _text(
                id: 'studio',
                label: 'Studio',
                value: (draft) => draft.studio ?? '',
                setValue: (draft, value) => draft.studio = value),
            LibraryVocabularyFieldSpec<MusicReleaseGroupEditDraft, String>(
              id: 'genres',
              label: 'Genres',
              value: (draft) => draft.genres.join(', '),
              setValue: (draft, value) => draft.genres = _split(value ?? ''),
              options: _options(MusicVocabularies.genre.builtIns),
            ),
            _text(
                id: 'cover_image_url',
                label: 'Cover image URL',
                value: (draft) => draft.coverImageUrl ?? '',
                setValue: (draft, value) => draft.coverImageUrl = value),
          ],
        ),
      ],
    ),
  ],
);

LibraryTextFieldSpec<MusicReleaseGroupEditDraft> _text({
  required String id,
  required String label,
  required String Function(MusicReleaseGroupEditDraft draft) value,
  required void Function(MusicReleaseGroupEditDraft draft, String value)
      setValue,
}) =>
    LibraryTextFieldSpec(
        id: id, label: label, value: value, setValue: setValue);

List<LibraryFieldOption<String>> _options(Iterable<String> values) => [
      for (final value in values)
        LibraryFieldOption(value: value, label: value),
    ];

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);
