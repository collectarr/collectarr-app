import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/vocabulary/tv_vocabularies.dart';

final EditSchema<TvRelease, TvReleaseEditDraft> tvReleaseEditSchema =
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
    EditTabSpec<TvReleaseEditDraft>(
      id: 'release',
      label: 'Release',
      sections: [
        EditSectionSpec<TvReleaseEditDraft>(
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
            VocabularyEditField<TvReleaseEditDraft, String>(
              id: 'format',
              label: 'Format',
              value: (draft) => draft.format,
              setValue: (draft, value) => draft.format = value,
              options: _options(TvVocabularies.physicalFormat.builtIns),
            ),
            VocabularyEditField<TvReleaseEditDraft, String>(
              id: 'region',
              label: 'Region',
              value: (draft) => draft.region,
              setValue: (draft, value) => draft.region = value,
              options: _options(TvVocabularies.region.builtIns),
            ),
            DateEditField<TvReleaseEditDraft>(
              id: 'release_date',
              label: 'Release date',
              value: (draft) => draft.releaseDate,
              setValue: (draft, value) => draft.releaseDate = value,
            ),
          ],
        ),
        EditSectionSpec<TvReleaseEditDraft>(
          id: 'publishing',
          label: 'Publishing',
          fields: [
            _text(
              id: 'publisher',
              label: 'Publisher',
              value: (draft) => draft.publisher ?? '',
              setValue: (draft, value) => draft.publisher = value,
            ),
            _text(
              id: 'sku',
              label: 'SKU / barcode',
              value: (draft) => draft.sku ?? '',
              setValue: (draft, value) => draft.sku = value,
            ),
            _text(
              id: 'case_type',
              label: 'Case type',
              value: (draft) => draft.caseType ?? '',
              setValue: (draft, value) => draft.caseType = value,
            ),
            _text(
              id: 'description',
              label: 'Description',
              value: (draft) => draft.description ?? '',
              setValue: (draft, value) => draft.description = value,
              maxLines: 4,
            ),
            _text(
              id: 'content_rating',
              label: 'Content rating',
              value: (draft) => draft.contentRating ?? '',
              setValue: (draft, value) => draft.contentRating = value,
            ),
            _text(
              id: 'audio',
              label: 'Audio languages',
              value: (draft) => draft.languageAudio.join(', '),
              setValue: (draft, value) => draft.languageAudio = _split(value),
            ),
            _text(
              id: 'subtitles',
              label: 'Subtitle languages',
              value: (draft) => draft.languageSubtitles.join(', '),
              setValue: (draft, value) =>
                  draft.languageSubtitles = _split(value),
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

TextEditField<TvReleaseEditDraft> _text({
  required String id,
  required String label,
  required String Function(TvReleaseEditDraft draft) value,
  required void Function(TvReleaseEditDraft draft, String value) setValue,
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
    .toSet()
    .toList(growable: false);

List<EditOption<String>> _options(Iterable<String> values) => [
      for (final value in values) EditOption(value: value, label: value),
    ];
