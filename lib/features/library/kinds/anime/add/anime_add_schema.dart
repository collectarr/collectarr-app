import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart'
    show EditOption;
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/vocabulary/anime_vocabularies.dart';

final AddSchema<AnimeAddManualDraft> animeAddSchema = animeAddSchemaFor();

AddSchema<AnimeAddManualDraft> animeAddSchemaFor({
  Iterable<String>? formatOptions,
  Iterable<String>? seasonOptions,
  Iterable<String>? airingStatusOptions,
  Iterable<String>? sourceMaterialOptions,
  Iterable<String>? physicalFormatOptions,
  Iterable<String>? regionOptions,
  Iterable<String>? distributorOptions,
  FutureOr<void> Function()? onManageFormat,
  FutureOr<void> Function()? onManageSeason,
  FutureOr<void> Function()? onManagePhysicalFormat,
  FutureOr<void> Function()? onManageRegion,
  FutureOr<void> Function()? onManageDistributor,
}) {
  return AddSchema<AnimeAddManualDraft>(
    title: (_) => 'Manual anime',
    validate: (draft) {
      final seasonYear = int.tryParse(draft.seasonYearController.text);
      if (seasonYear != null && seasonYear < 0) {
        return 'Season year cannot be negative';
      }
      final episodeCount = int.tryParse(draft.episodeCountController.text);
      if (episodeCount != null && episodeCount < 0) {
        return 'Episode count cannot be negative';
      }
      final episodeRuntime = int.tryParse(draft.episodeRuntimeController.text);
      if (episodeRuntime != null && episodeRuntime < 0) {
        return 'Episode runtime cannot be negative';
      }
      final startDate = _date(draft.startDateController.text);
      final endDate = _date(draft.endDateController.text);
      if (_hasText(draft.startDateController.text) && startDate == null) {
        return 'Start date is invalid';
      }
      if (_hasText(draft.endDateController.text) && endDate == null) {
        return 'End date is invalid';
      }
      if (startDate != null && endDate != null && endDate.isBefore(startDate)) {
        return 'End date cannot be before start date';
      }
      final releaseDate = _date(draft.releaseDateController.text);
      if (_hasText(draft.releaseDateController.text) && releaseDate == null) {
        return 'Release date is invalid';
      }
      return null;
    },
    sections: [
      AddSectionSpec<AnimeAddManualDraft>(
        id: 'series',
        label: 'Series',
        fields: [
          VocabularyAddField<AnimeAddManualDraft, String>(
            id: 'format',
            label: 'Anime format',
            value: (draft) => _nullable(draft.formatController.text),
            setValue: (draft, value) =>
                draft.formatController.text = value ?? '',
            options: _options(
              formatOptions ?? AnimeVocabularies.format.builtIns,
            ),
            onManage: onManageFormat == null ? null : (_) => onManageFormat(),
          ),
          VocabularyAddField<AnimeAddManualDraft, String>(
            id: 'season',
            label: 'Release season',
            value: (draft) => _nullable(draft.seasonController.text),
            setValue: (draft, value) =>
                draft.seasonController.text = value ?? '',
            options: _options(
              seasonOptions ?? AnimeVocabularies.season.builtIns,
            ),
            onManage: onManageSeason == null ? null : (_) => onManageSeason(),
          ),
          NumberAddField<AnimeAddManualDraft>(
            id: 'season_year',
            label: 'Season year',
            value: (draft) => int.tryParse(draft.seasonYearController.text),
            setValue: (draft, value) => draft.seasonYearController.text =
                value?.toInt().toString() ?? '',
            minimum: 0,
          ),
          NumberAddField<AnimeAddManualDraft>(
            id: 'episode_count',
            label: 'Episode count',
            value: (draft) => int.tryParse(draft.episodeCountController.text),
            setValue: (draft, value) => draft.episodeCountController.text =
                value?.toInt().toString() ?? '',
            minimum: 0,
          ),
          NumberAddField<AnimeAddManualDraft>(
            id: 'episode_runtime_minutes',
            label: 'Episode runtime (minutes)',
            value: (draft) => int.tryParse(draft.episodeRuntimeController.text),
            setValue: (draft, value) => draft.episodeRuntimeController.text =
                value?.toInt().toString() ?? '',
            minimum: 0,
          ),
          VocabularyAddField<AnimeAddManualDraft, String>(
            id: 'airing_status',
            label: 'Airing status',
            value: (draft) => _nullable(draft.airingStatusController.text),
            setValue: (draft, value) =>
                draft.airingStatusController.text = value ?? '',
            options: _options(
              airingStatusOptions ??
                  const [
                    'Currently Airing',
                    'Finished Airing',
                    'Not Yet Aired',
                    'Cancelled',
                  ],
            ),
          ),
          VocabularyAddField<AnimeAddManualDraft, String>(
            id: 'source_material',
            label: 'Source material',
            value: (draft) => _nullable(draft.sourceMaterialController.text),
            setValue: (draft, value) =>
                draft.sourceMaterialController.text = value ?? '',
            options: _options(
              sourceMaterialOptions ??
                  const [
                    'Manga',
                    'Light Novel',
                    'Original',
                    'Visual Novel',
                    'Game',
                    'Novel',
                    'Other',
                  ],
            ),
          ),
          TextAddField<AnimeAddManualDraft>(
            id: 'studio',
            label: 'Studio',
            value: (draft) => draft.studioController.text,
            setValue: (draft, value) => draft.studioController.text = value,
          ),
          DateAddField<AnimeAddManualDraft>(
            id: 'start_date',
            label: 'Start date',
            value: (draft) => _date(draft.startDateController.text),
            setValue: (draft, value) => draft.startDateController.text =
                value == null ? '' : _formatDate(value),
          ),
          DateAddField<AnimeAddManualDraft>(
            id: 'end_date',
            label: 'End date',
            value: (draft) => _date(draft.endDateController.text),
            setValue: (draft, value) => draft.endDateController.text =
                value == null ? '' : _formatDate(value),
          ),
        ],
      ),
      AddSectionSpec<AnimeAddManualDraft>(
        id: 'release',
        label: 'Release',
        fields: [
          TextAddField<AnimeAddManualDraft>(
            id: 'edition_title',
            label: 'Edition title',
            value: (draft) => draft.editionTitleController.text,
            setValue: (draft, value) =>
                draft.editionTitleController.text = value,
          ),
          VocabularyAddField<AnimeAddManualDraft, String>(
            id: 'physical_format',
            label: 'Physical format',
            value: (draft) => _nullable(
              draft.physicalFormatLabelController.text,
            ),
            setValue: (draft, value) =>
                draft.physicalFormatLabelController.text = value ?? '',
            options: _options(
              physicalFormatOptions ??
                  AnimeVocabularies.physicalFormat.builtIns,
            ),
            onManage: onManagePhysicalFormat == null
                ? null
                : (_) => onManagePhysicalFormat(),
          ),
          VocabularyAddField<AnimeAddManualDraft, String>(
            id: 'region',
            label: 'Region',
            value: (draft) => _nullable(draft.countryController.text),
            setValue: (draft, value) =>
                draft.countryController.text = value ?? '',
            options: _options(
              regionOptions ?? AnimeVocabularies.region.builtIns,
            ),
            onManage: onManageRegion == null ? null : (_) => onManageRegion(),
          ),
          TextAddField<AnimeAddManualDraft>(
            id: 'barcode',
            label: 'Barcode',
            value: (draft) => draft.barcodeController.text,
            setValue: (draft, value) => draft.barcodeController.text = value,
          ),
          TextAddField<AnimeAddManualDraft>(
            id: 'publisher',
            label: 'Publisher / distributor',
            value: (draft) => draft.publisherController.text,
            setValue: (draft, value) => draft.publisherController.text = value,
          ),
          TextAddField<AnimeAddManualDraft>(
            id: 'variant',
            label: 'Variant',
            value: (draft) => draft.variantController.text,
            setValue: (draft, value) => draft.variantController.text = value,
          ),
          DateAddField<AnimeAddManualDraft>(
            id: 'release_date',
            label: 'Release date',
            value: (draft) => _date(draft.releaseDateController.text),
            setValue: (draft, value) => draft.releaseDateController.text =
                value == null ? '' : _formatDate(value),
          ),
        ],
      ),
      AddSectionSpec<AnimeAddManualDraft>(
        id: 'metadata',
        label: 'Metadata',
        fields: [
          TextAddField<AnimeAddManualDraft>(
            id: 'native_title',
            label: 'Native title',
            value: (draft) => draft.nativeTitleController.text,
            setValue: (draft, value) =>
                draft.nativeTitleController.text = value,
          ),
          TextAddField<AnimeAddManualDraft>(
            id: 'romaji_title',
            label: 'Romaji title',
            value: (draft) => draft.romajiTitleController.text,
            setValue: (draft, value) =>
                draft.romajiTitleController.text = value,
          ),
          TextAddField<AnimeAddManualDraft>(
            id: 'english_title',
            label: 'English title',
            value: (draft) => draft.englishTitleController.text,
            setValue: (draft, value) =>
                draft.englishTitleController.text = value,
          ),
          TextAddField<AnimeAddManualDraft>(
            id: 'alternate_titles',
            label: 'Alternate titles',
            value: (draft) => draft.alternateTitlesController.text,
            setValue: (draft, value) =>
                draft.alternateTitlesController.text = value,
          ),
          TextAddField<AnimeAddManualDraft>(
            id: 'genres',
            label: 'Genres',
            value: (draft) => draft.genresEditController.text,
            setValue: (draft, value) => draft.genresEditController.text = value,
          ),
          TextAddField<AnimeAddManualDraft>(
            id: 'themes',
            label: 'Themes',
            value: (draft) => draft.themesController.text,
            setValue: (draft, value) => draft.themesController.text = value,
          ),
          TextAddField<AnimeAddManualDraft>(
            id: 'producers',
            label: 'Producers',
            value: (draft) => draft.producersController.text,
            setValue: (draft, value) => draft.producersController.text = value,
          ),
          TextAddField<AnimeAddManualDraft>(
            id: 'licensors',
            label: 'Licensors',
            value: (draft) => draft.licensorsController.text,
            setValue: (draft, value) => draft.licensorsController.text = value,
          ),
          TextAddField<AnimeAddManualDraft>(
            id: 'synopsis',
            label: 'Synopsis',
            value: (draft) => draft.synopsisController.text,
            setValue: (draft, value) => draft.synopsisController.text = value,
            maxLines: 4,
          ),
          TextAddField<AnimeAddManualDraft>(
            id: 'original_language',
            label: 'Original language',
            value: (draft) => draft.languageController.text,
            setValue: (draft, value) => draft.languageController.text = value,
          ),
          TextAddField<AnimeAddManualDraft>(
            id: 'cover_image_url',
            label: 'Cover image URL',
            value: (draft) => draft.coverController.text,
            setValue: (draft, value) => draft.coverController.text = value,
          ),
        ],
      ),
    ],
  );
}

String? _nullable(String value) => value.trim().isEmpty ? null : value;

bool _hasText(String value) => value.trim().isNotEmpty;

DateTime? _date(String value) => DateTime.tryParse(value.trim());

List<EditOption<String>> _options(Iterable<String> values) => [
      for (final value in values) EditOption(value: value, label: value),
    ];

String _formatDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
