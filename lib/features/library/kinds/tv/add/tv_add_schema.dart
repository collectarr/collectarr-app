import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';

import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/vocabulary/tv_vocabularies.dart';

final AddSchema<TvAddManualDraft> tvAddSchema = tvAddSchemaFor();

AddSchema<TvAddManualDraft> tvAddSchemaFor({
  Iterable<String>? formatOptions,
  Iterable<String>? regionOptions,
  Iterable<String>? networkOptions,
  FutureOr<void> Function()? onManageFormat,
  FutureOr<void> Function()? onManageRegion,
  FutureOr<void> Function()? onManageNetwork,
}) {
  return AddSchema<TvAddManualDraft>(
    title: (_) => 'Manual TV show',
    validate: (draft) {
      final season = int.tryParse(draft.numberController.text);
      if (season != null && season < 0) {
        return 'Season number cannot be negative';
      }
      final year = int.tryParse(draft.yearController.text);
      if (year != null && year < 0) {
        return 'First air year cannot be negative';
      }
      final rawDate = draft.releaseDateController.text.trim();
      if (rawDate.isNotEmpty && DateTime.tryParse(rawDate) == null) {
        return 'Release date is invalid';
      }
      return null;
    },
    sections: [
      AddSectionSpec<TvAddManualDraft>(
        id: 'series',
        label: 'Series',
        fields: [
          LibraryTextFieldSpec<TvAddManualDraft>(
            id: 'network',
            label: 'Network / studio',
            value: (draft) => draft.publisherController.text,
            setValue: (draft, value) => draft.publisherController.text = value,
          ),
          LibraryVocabularyFieldSpec<TvAddManualDraft, String>(
            id: 'network_vocabulary',
            label: 'Original network',
            value: (draft) => _nullableText(draft.publisherController.text),
            setValue: (draft, value) =>
                draft.publisherController.text = value ?? '',
            options: _options(
              networkOptions ?? TvVocabularies.network.builtIns,
            ),
            onManage: onManageNetwork == null ? null : (_) => onManageNetwork(),
          ),
          LibraryNumberFieldSpec<TvAddManualDraft>(
            id: 'season_number',
            label: 'Season number',
            value: (draft) => int.tryParse(draft.numberController.text),
            setValue: (draft, value) =>
                draft.numberController.text = value?.toInt().toString() ?? '',
            minimum: 0,
          ),
          LibraryNumberFieldSpec<TvAddManualDraft>(
            id: 'first_air_year',
            label: 'First air year',
            value: (draft) => int.tryParse(draft.yearController.text),
            setValue: (draft, value) =>
                draft.yearController.text = value?.toInt().toString() ?? '',
            minimum: 0,
          ),
        ],
      ),
      AddSectionSpec<TvAddManualDraft>(
        id: 'release',
        label: 'Release',
        fields: [
          LibraryTextFieldSpec<TvAddManualDraft>(
            id: 'edition_title',
            label: 'Edition title',
            value: (draft) => draft.editionTitleController.text,
            setValue: (draft, value) =>
                draft.editionTitleController.text = value,
          ),
          LibraryVocabularyFieldSpec<TvAddManualDraft, String>(
            id: 'format',
            label: 'Format',
            value: (draft) =>
                _nullableText(draft.physicalFormatLabelController.text),
            setValue: (draft, value) =>
                draft.physicalFormatLabelController.text = value ?? '',
            options: _options(
              formatOptions ?? TvVocabularies.physicalFormat.builtIns,
            ),
            onManage: onManageFormat == null ? null : (_) => onManageFormat(),
          ),
          LibraryVocabularyFieldSpec<TvAddManualDraft, String>(
            id: 'region',
            label: 'Region',
            value: (draft) => _nullableText(draft.countryController.text),
            setValue: (draft, value) =>
                draft.countryController.text = value ?? '',
            options: _options(
              regionOptions ?? TvVocabularies.region.builtIns,
            ),
            onManage: onManageRegion == null ? null : (_) => onManageRegion(),
          ),
          LibraryTextFieldSpec<TvAddManualDraft>(
            id: 'barcode',
            label: 'Barcode',
            value: (draft) => draft.barcodeController.text,
            setValue: (draft, value) => draft.barcodeController.text = value,
          ),
          LibraryDateFieldSpec<TvAddManualDraft>(
            id: 'release_date',
            label: 'Release date',
            value: (draft) =>
                DateTime.tryParse(draft.releaseDateController.text.trim()),
            setValue: (draft, value) => draft.releaseDateController.text =
                value == null ? '' : _formatDate(value),
          ),
        ],
      ),
      AddSectionSpec<TvAddManualDraft>(
        id: 'metadata',
        label: 'Metadata',
        fields: [
          LibraryTextFieldSpec<TvAddManualDraft>(
            id: 'creators',
            label: 'Cast / crew',
            value: (draft) => draft.creatorsController.text,
            setValue: (draft, value) => draft.creatorsController.text = value,
          ),
          LibraryTextFieldSpec<TvAddManualDraft>(
            id: 'characters',
            label: 'Characters',
            value: (draft) => draft.charactersController.text,
            setValue: (draft, value) => draft.charactersController.text = value,
          ),
          LibraryTextFieldSpec<TvAddManualDraft>(
            id: 'genres',
            label: 'Genres',
            value: (draft) => draft.genresEditController.text,
            setValue: (draft, value) => draft.genresEditController.text = value,
          ),
          LibraryTextFieldSpec<TvAddManualDraft>(
            id: 'content_rating',
            label: 'Content rating',
            value: (draft) => draft.ageRatingController.text,
            setValue: (draft, value) => draft.ageRatingController.text = value,
          ),
          LibraryTextFieldSpec<TvAddManualDraft>(
            id: 'original_language',
            label: 'Original language',
            value: (draft) => draft.languageController.text,
            setValue: (draft, value) => draft.languageController.text = value,
          ),
          LibraryTextFieldSpec<TvAddManualDraft>(
            id: 'synopsis',
            label: 'Synopsis',
            value: (draft) => draft.synopsisController.text,
            setValue: (draft, value) => draft.synopsisController.text = value,
            maxLines: 4,
          ),
          LibraryImageFieldSpec<TvAddManualDraft, String>(
            id: 'cover_image_url',
            label: 'Cover image URL',
            value: (draft) => _nullableText(draft.coverController.text),
            setValue: (draft, value) =>
                draft.coverController.text = value ?? '',
          ),
        ],
      ),
    ],
  );
}

String? _nullableText(String value) => value.trim().isEmpty ? null : value;

List<LibraryFieldOption<String>> _options(Iterable<String> values) => [
      for (final value in values)
        LibraryFieldOption(value: value, label: value),
    ];

String _formatDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
