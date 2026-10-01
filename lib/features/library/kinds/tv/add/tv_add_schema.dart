import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/forms/tv_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/tv/vocabulary/tv_vocabularies.dart';

final AddSchema<TvAddManualDraft> tvAddSchema = tvAddSchemaFor();

AddSchema<TvAddManualDraft> tvAddSchemaFor({
  Iterable<String>? formatOptions,
  FutureOr<void> Function()? onManageFormat,
}) {
  TvCatalogItemFormValues values(TvAddManualDraft draft) => draft.values;

  return AddSchema<TvAddManualDraft>(
    title: (_) => 'Manual TV Catalog Item',
    validate: (draft) {
      final seasonNumber = draft.values.seasonNumber;
      if (seasonNumber != null && seasonNumber < 0) {
        return 'Season number cannot be negative';
      }
      final runtime = draft.values.runtimeMinutes;
      if (runtime != null && runtime < 1) {
        return 'Runtime must be greater than zero';
      }
      final discCount = draft.values.discCount;
      if (discCount != null && discCount < 1) {
        return 'Disc count must be greater than zero';
      }
      return null;
    },
    sections: [
      AddSectionSpec<TvAddManualDraft>(
        id: 'catalog_item',
        label: 'Catalog Item',
        fields: [
          LibraryTextFieldSpec<TvAddManualDraft>(
            id: 'sort_key',
            label: 'Sort Title',
            value: (draft) => values(draft).sortKey,
            setValue: (draft, value) => values(draft).sortKey = value,
          ),
          LibraryTextFieldSpec<TvAddManualDraft>(
            id: 'original_title',
            label: 'Original Title',
            value: (draft) => values(draft).originalTitle,
            setValue: (draft, value) => values(draft).originalTitle = value,
          ),
          LibraryTextFieldSpec<TvAddManualDraft>(
            id: 'edition_title',
            label: 'Edition Title',
            value: (draft) => values(draft).editionTitle,
            setValue: (draft, value) => values(draft).editionTitle = value,
          ),
          LibraryTextFieldSpec<TvAddManualDraft>(
            id: 'synopsis',
            label: 'Synopsis',
            value: (draft) => values(draft).synopsis,
            setValue: (draft, value) => values(draft).synopsis = value,
            maxLines: 4,
          ),
          LibraryImageFieldSpec<TvAddManualDraft, String>(
            id: 'cover_image_url',
            label: 'Front Cover URL',
            value: (draft) => _nullable(values(draft).coverImageUrl),
            setValue: (draft, value) =>
                values(draft).coverImageUrl = value ?? '',
          ),
          LibraryDateFieldSpec<TvAddManualDraft>(
            id: 'release_date',
            label: 'Release Date',
            value: (draft) => values(draft).releaseDate,
            setValue: (draft, value) => values(draft).releaseDate = value,
          ),
          LibraryVocabularyFieldSpec<TvAddManualDraft, String>(
            id: 'physical_format',
            label: 'Format',
            value: (draft) => _nullable(values(draft).physicalFormat),
            setValue: (draft, value) =>
                values(draft).physicalFormat = value ?? '',
            options: _options(
              formatOptions ?? TvVocabularies.physicalFormat.builtIns,
            ),
            onManage: onManageFormat == null ? null : (_) => onManageFormat(),
          ),
          LibraryTextFieldSpec<TvAddManualDraft>(
            id: 'country',
            label: 'Country',
            value: (draft) => values(draft).country,
            setValue: (draft, value) => values(draft).country = value,
          ),
          LibraryTextFieldSpec<TvAddManualDraft>(
            id: 'publisher',
            label: 'Publisher / Network',
            value: (draft) => values(draft).publisher,
            setValue: (draft, value) => values(draft).publisher = value,
          ),
          LibraryTextFieldSpec<TvAddManualDraft>(
            id: 'language',
            label: 'Language',
            value: (draft) => values(draft).language,
            setValue: (draft, value) => values(draft).language = value,
          ),
          LibraryTextFieldSpec<TvAddManualDraft>(
            id: 'age_rating',
            label: 'Age Rating',
            value: (draft) => values(draft).ageRating,
            setValue: (draft, value) => values(draft).ageRating = value,
          ),
          LibraryTextFieldSpec<TvAddManualDraft>(
            id: 'genres',
            label: 'Genres',
            value: (draft) => values(draft).genres.join(', '),
            setValue: (draft, value) => values(draft).genres = _split(value),
          ),
          LibraryTextFieldSpec<TvAddManualDraft>(
            id: 'barcode',
            label: 'Barcode',
            value: (draft) => values(draft).barcode,
            setValue: (draft, value) => values(draft).barcode = value,
          ),
          LibraryTextFieldSpec<TvAddManualDraft>(
            id: 'creators',
            label: 'Creators',
            value: (draft) => values(draft).creators.join(', '),
            setValue: (draft, value) => values(draft).creators = _split(value),
          ),
          LibraryTextFieldSpec<TvAddManualDraft>(
            id: 'characters',
            label: 'Characters',
            value: (draft) => values(draft).characters.join(', '),
            setValue: (draft, value) =>
                values(draft).characters = _split(value),
          ),
          LibraryTextFieldSpec<TvAddManualDraft>(
            id: 'audio_tracks',
            label: 'Audio Tracks',
            value: (draft) => values(draft).audioTracks,
            setValue: (draft, value) => values(draft).audioTracks = value,
          ),
          LibraryTextFieldSpec<TvAddManualDraft>(
            id: 'subtitles',
            label: 'Subtitles',
            value: (draft) => values(draft).subtitles,
            setValue: (draft, value) => values(draft).subtitles = value,
          ),
          LibraryNumberFieldSpec<TvAddManualDraft>(
            id: 'season_number',
            label: 'Season Number',
            value: (draft) => values(draft).seasonNumber,
            setValue: (draft, value) =>
                values(draft).seasonNumber = value?.toInt(),
            minimum: 0,
          ),
          LibraryNumberFieldSpec<TvAddManualDraft>(
            id: 'runtime_minutes',
            label: 'Runtime (minutes)',
            value: (draft) => values(draft).runtimeMinutes,
            setValue: (draft, value) =>
                values(draft).runtimeMinutes = value?.toInt(),
            minimum: 1,
          ),
          LibraryNumberFieldSpec<TvAddManualDraft>(
            id: 'nr_discs',
            label: 'Disc Count',
            value: (draft) => values(draft).discCount,
            setValue: (draft, value) =>
                values(draft).discCount = value?.toInt(),
            minimum: 1,
          ),
          LibraryTextFieldSpec<TvAddManualDraft>(
            id: 'screen_ratio',
            label: 'Screen Ratio',
            value: (draft) => values(draft).screenRatio,
            setValue: (draft, value) => values(draft).screenRatio = value,
          ),
        ],
      ),
    ],
  );
}

String? _nullable(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);

List<LibraryFieldOption<String>> _options(Iterable<String> values) => [
      for (final value in values)
        LibraryFieldOption(value: value, label: value),
    ];
