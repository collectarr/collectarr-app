import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_media.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_media_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';

final EditSchema<MusicMedia, MusicMediaEditDraft> musicMediaEditSchema =
    EditSchema(
  title: (media) => 'Edit ${media.title ?? 'media'}',
  validate: (_, draft) {
    if (draft.mediaNumber < 0) return 'Media number cannot be negative';
    if (draft.rpm != null && draft.rpm! < 0) return 'RPM cannot be negative';
    if (draft.trackCount != null && draft.trackCount! < 0) {
      return 'Track count cannot be negative';
    }
    return null;
  },
  tabs: [
    EditTabSpec<MusicMediaEditDraft>(
      id: 'media',
      label: 'Media',
      sections: [
        EditSectionSpec<MusicMediaEditDraft>(
          id: 'identity',
          label: 'Identity',
          fields: [
            NumberEditField<MusicMediaEditDraft>(
              id: 'media_number',
              label: 'Media number',
              value: (draft) => draft.mediaNumber,
              setValue: (draft, value) =>
                  draft.mediaNumber = value?.toInt() ?? 0,
              minimum: 0,
            ),
            _text(
              id: 'title',
              label: 'Title',
              value: (draft) => draft.title ?? '',
              setValue: (draft, value) => draft.title = value,
            ),
            VocabularyEditField<MusicMediaEditDraft, String>(
              id: 'media_type',
              label: 'Media type',
              value: (draft) => draft.mediaType,
              setValue: (draft, value) => draft.mediaType = value,
              options: _options(MusicVocabularies.mediaType.builtIns),
            ),
            VocabularyEditField<MusicMediaEditDraft, String>(
              id: 'packaging',
              label: 'Packaging',
              value: (draft) => draft.packaging,
              setValue: (draft, value) => draft.packaging = value,
              options: _options(MusicVocabularies.packaging.builtIns),
            ),
            _text(
              id: 'media_condition',
              label: 'Media condition',
              value: (draft) => draft.mediaCondition ?? '',
              setValue: (draft, value) => draft.mediaCondition = value,
            ),
          ],
        ),
        EditSectionSpec<MusicMediaEditDraft>(
          id: 'technical',
          label: 'Technical',
          fields: [
            NumberEditField<MusicMediaEditDraft>(
              id: 'track_count',
              label: 'Track count',
              value: (draft) => draft.trackCount,
              setValue: (draft, value) => draft.trackCount = value?.toInt(),
              minimum: 0,
            ),
            NumberEditField<MusicMediaEditDraft>(
              id: 'rpm',
              label: 'RPM',
              value: (draft) => draft.rpm,
              setValue: (draft, value) => draft.rpm = value?.toInt(),
              minimum: 0,
            ),
            _text(
              id: 'sound_type',
              label: 'Sound type',
              value: (draft) => draft.soundType ?? '',
              setValue: (draft, value) => draft.soundType = value,
            ),
            _text(
              id: 'spars',
              label: 'S.P.A.R.S.',
              value: (draft) => draft.spars ?? '',
              setValue: (draft, value) => draft.spars = value,
            ),
            _text(
              id: 'vinyl_color',
              label: 'Vinyl color',
              value: (draft) => draft.vinylColor ?? '',
              setValue: (draft, value) => draft.vinylColor = value,
            ),
            _text(
              id: 'vinyl_weight',
              label: 'Vinyl weight',
              value: (draft) => draft.vinylWeight ?? '',
              setValue: (draft, value) => draft.vinylWeight = value,
            ),
          ],
        ),
      ],
    ),
  ],
);

TextEditField<MusicMediaEditDraft> _text({
  required String id,
  required String label,
  required String Function(MusicMediaEditDraft draft) value,
  required void Function(MusicMediaEditDraft draft, String value) setValue,
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
