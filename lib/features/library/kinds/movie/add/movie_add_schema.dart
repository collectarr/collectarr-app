import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart'
    show EditOption;
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/vocabulary/movie_vocabularies.dart';

final AddSchema<MovieAddManualDraft> movieAddSchema = movieAddSchemaFor();

AddSchema<MovieAddManualDraft> movieAddSchemaFor({
  Iterable<String>? formatOptions,
  Iterable<String>? regionOptions,
  Iterable<String>? distributorOptions,
  FutureOr<void> Function()? onManageFormat,
  FutureOr<void> Function()? onManageRegion,
  FutureOr<void> Function()? onManageDistributor,
}) {
  return AddSchema<MovieAddManualDraft>(
    title: (_) => 'Manual movie',
    validate: (draft) {
      final year = int.tryParse(draft.yearController.text);
      if (year != null && year < 0) {
        return 'Release year cannot be negative';
      }
      final rawDate = draft.releaseDateController.text.trim();
      if (rawDate.isNotEmpty && DateTime.tryParse(rawDate) == null) {
        return 'Release date is invalid';
      }
      return null;
    },
    sections: [
      AddSectionSpec<MovieAddManualDraft>(
        id: 'release',
        label: 'Release',
        fields: [
          TextAddField<MovieAddManualDraft>(
            id: 'edition_title',
            label: 'Edition title',
            value: (draft) => draft.editionTitleController.text,
            setValue: (draft, value) =>
                draft.editionTitleController.text = value,
          ),
          TextAddField<MovieAddManualDraft>(
            id: 'variant',
            label: 'Variant',
            value: (draft) => draft.variantController.text,
            setValue: (draft, value) => draft.variantController.text = value,
          ),
          VocabularyAddField<MovieAddManualDraft, String>(
            id: 'format',
            label: 'Format',
            value: (draft) => _nullableText(
              draft.physicalFormatLabelController.text,
            ),
            setValue: (draft, value) =>
                draft.physicalFormatLabelController.text = value ?? '',
            options: _options(
              formatOptions ?? MovieVocabularies.physicalFormat.builtIns,
            ),
            onManage: onManageFormat == null ? null : (_) => onManageFormat(),
          ),
          VocabularyAddField<MovieAddManualDraft, String>(
            id: 'region',
            label: 'Region',
            value: (draft) => _nullableText(draft.countryController.text),
            setValue: (draft, value) =>
                draft.countryController.text = value ?? '',
            options:
                _options(regionOptions ?? MovieVocabularies.region.builtIns),
            onManage: onManageRegion == null ? null : (_) => onManageRegion(),
          ),
          TextAddField<MovieAddManualDraft>(
            id: 'barcode',
            label: 'Barcode',
            value: (draft) => draft.barcodeController.text,
            setValue: (draft, value) => draft.barcodeController.text = value,
          ),
          NumberAddField<MovieAddManualDraft>(
            id: 'release_year',
            label: 'Release year',
            value: (draft) => int.tryParse(draft.yearController.text),
            setValue: (draft, value) =>
                draft.yearController.text = value?.toInt().toString() ?? '',
            minimum: 0,
          ),
          DateAddField<MovieAddManualDraft>(
            id: 'release_date',
            label: 'Release date',
            value: (draft) =>
                DateTime.tryParse(draft.releaseDateController.text.trim()),
            setValue: (draft, value) => draft.releaseDateController.text =
                value == null ? '' : _formatDate(value),
          ),
        ],
      ),
      AddSectionSpec<MovieAddManualDraft>(
        id: 'metadata',
        label: 'Metadata',
        fields: [
          VocabularyAddField<MovieAddManualDraft, String>(
            id: 'distributor',
            label: 'Studio / distributor',
            value: (draft) => _nullableText(draft.publisherController.text),
            setValue: (draft, value) =>
                draft.publisherController.text = value ?? '',
            options: _options(
              distributorOptions ?? MovieVocabularies.distributor.builtIns,
            ),
            onManage: onManageDistributor == null
                ? null
                : (_) => onManageDistributor(),
          ),
          TextAddField<MovieAddManualDraft>(
            id: 'directors',
            label: 'Director(s)',
            value: (draft) => draft.creatorsController.text,
            setValue: (draft, value) => draft.creatorsController.text = value,
          ),
          TextAddField<MovieAddManualDraft>(
            id: 'characters',
            label: 'Characters',
            value: (draft) => draft.charactersController.text,
            setValue: (draft, value) => draft.charactersController.text = value,
          ),
          TextAddField<MovieAddManualDraft>(
            id: 'genres',
            label: 'Genres',
            value: (draft) => draft.genresEditController.text,
            setValue: (draft, value) => draft.genresEditController.text = value,
          ),
          TextAddField<MovieAddManualDraft>(
            id: 'age_rating',
            label: 'Age rating',
            value: (draft) => draft.ageRatingController.text,
            setValue: (draft, value) => draft.ageRatingController.text = value,
          ),
          TextAddField<MovieAddManualDraft>(
            id: 'language',
            label: 'Language',
            value: (draft) => draft.languageController.text,
            setValue: (draft, value) => draft.languageController.text = value,
          ),
          TextAddField<MovieAddManualDraft>(
            id: 'synopsis',
            label: 'Synopsis',
            value: (draft) => draft.synopsisController.text,
            setValue: (draft, value) => draft.synopsisController.text = value,
            maxLines: 4,
          ),
          TextAddField<MovieAddManualDraft>(
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

String? _nullableText(String value) => value.trim().isEmpty ? null : value;

List<EditOption<String>> _options(Iterable<String> values) => [
      for (final value in values) EditOption(value: value, label: value),
    ];

String _formatDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
