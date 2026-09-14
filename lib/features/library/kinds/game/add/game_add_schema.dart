import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart'
    show EditOption;
import 'package:collectarr_app/features/library/kinds/game/add/game_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';

final AddSchema<GameAddManualDraft> gameAddSchema = gameAddSchemaFor();

AddSchema<GameAddManualDraft> gameAddSchemaFor({
  Iterable<String>? platformOptions,
  Iterable<String>? editionOptions,
  Iterable<String>? ageRatingOptions,
  Iterable<String>? regionOptions,
  FutureOr<void> Function()? onManagePlatform,
  FutureOr<void> Function()? onManageEdition,
}) {
  return AddSchema<GameAddManualDraft>(
    title: (_) => 'Manual game',
    validate: (draft) {
      final year = int.tryParse(draft.yearController.text);
      if (year != null && year < 0) {
        return 'Release year cannot be negative';
      }
      if (draft.releaseDateController.text.trim().isNotEmpty &&
          DateTime.tryParse(draft.releaseDateController.text.trim()) == null) {
        return 'Release date is invalid';
      }
      return null;
    },
    sections: [
      AddSectionSpec<GameAddManualDraft>(
        id: 'release',
        label: 'Release',
        fields: [
          VocabularyAddField<GameAddManualDraft, String>(
            id: 'platform',
            label: 'Platform',
            value: (draft) => _nullableText(draft.platformController.text),
            setValue: (draft, value) =>
                draft.platformController.text = value ?? '',
            options: _optionsFrom(
              platformOptions ?? GameVocabularies.platform.builtIns,
            ),
            onManage:
                onManagePlatform == null ? null : (_) => onManagePlatform(),
          ),
          TextAddField<GameAddManualDraft>(
            id: 'catalog_number',
            label: 'Catalog number',
            value: (draft) => draft.numberController.text,
            setValue: (draft, value) => draft.numberController.text = value,
          ),
          TextAddField<GameAddManualDraft>(
            id: 'variant',
            label: 'Variant',
            value: (draft) => draft.variantController.text,
            setValue: (draft, value) => draft.variantController.text = value,
          ),
          TextAddField<GameAddManualDraft>(
            id: 'edition_title',
            label: 'Edition title',
            value: (draft) => draft.editionTitleController.text,
            setValue: (draft, value) =>
                draft.editionTitleController.text = value,
          ),
          VocabularyAddField<GameAddManualDraft, String>(
            id: 'edition',
            label: 'Edition / format',
            value: (draft) =>
                _nullableText(draft.physicalFormatLabelController.text),
            setValue: (draft, value) =>
                draft.physicalFormatLabelController.text = value ?? '',
            options: _optionsFrom(
              editionOptions ?? GameVocabularies.edition.builtIns,
            ),
            onManage: onManageEdition == null ? null : (_) => onManageEdition(),
          ),
          TextAddField<GameAddManualDraft>(
            id: 'barcode',
            label: 'Barcode',
            value: (draft) => draft.barcodeController.text,
            setValue: (draft, value) => draft.barcodeController.text = value,
          ),
          VocabularyAddField<GameAddManualDraft, String>(
            id: 'region',
            label: 'Region',
            value: (draft) => _nullableText(draft.regionController.text),
            setValue: (draft, value) =>
                draft.regionController.text = value ?? '',
            options: _optionsFrom(
              regionOptions ?? GameVocabularies.region.builtIns,
            ),
          ),
          NumberAddField<GameAddManualDraft>(
            id: 'publication_year',
            label: 'Release year',
            value: (draft) => int.tryParse(draft.yearController.text),
            setValue: (draft, value) =>
                draft.yearController.text = value?.toInt().toString() ?? '',
            minimum: 0,
          ),
          DateAddField<GameAddManualDraft>(
            id: 'release_date',
            label: 'Release date',
            value: (draft) => DateTime.tryParse(
              draft.releaseDateController.text.trim(),
            ),
            setValue: (draft, value) => draft.releaseDateController.text =
                value == null ? '' : _formatDate(value),
          ),
        ],
      ),
      AddSectionSpec<GameAddManualDraft>(
        id: 'metadata',
        label: 'Metadata',
        fields: [
          TextAddField<GameAddManualDraft>(
            id: 'publisher',
            label: 'Publisher',
            value: (draft) => draft.publisherController.text,
            setValue: (draft, value) => draft.publisherController.text = value,
          ),
          TextAddField<GameAddManualDraft>(
            id: 'developers',
            label: 'Developers',
            value: (draft) => draft.creatorsController.text,
            setValue: (draft, value) => draft.creatorsController.text = value,
          ),
          TextAddField<GameAddManualDraft>(
            id: 'genres',
            label: 'Genres',
            value: (draft) => draft.genresEditController.text,
            setValue: (draft, value) => draft.genresEditController.text = value,
          ),
          VocabularyAddField<GameAddManualDraft, String>(
            id: 'age_rating',
            label: 'Age rating',
            value: (draft) => _nullableText(draft.ageRatingController.text),
            setValue: (draft, value) =>
                draft.ageRatingController.text = value ?? '',
            options: _optionsFrom(
              ageRatingOptions ?? GameVocabularies.ageRating.builtIns,
            ),
          ),
          TextAddField<GameAddManualDraft>(
            id: 'language',
            label: 'Language',
            value: (draft) => draft.languageController.text,
            setValue: (draft, value) => draft.languageController.text = value,
          ),
          TextAddField<GameAddManualDraft>(
            id: 'country',
            label: 'Country',
            value: (draft) => draft.countryController.text,
            setValue: (draft, value) => draft.countryController.text = value,
          ),
          TextAddField<GameAddManualDraft>(
            id: 'synopsis',
            label: 'Synopsis',
            value: (draft) => draft.synopsisController.text,
            setValue: (draft, value) => draft.synopsisController.text = value,
            maxLines: 4,
          ),
          TextAddField<GameAddManualDraft>(
            id: 'cover_image_url',
            label: 'Cover image URL',
            value: (draft) => draft.coverController.text,
            setValue: (draft, value) => draft.coverController.text = value,
          ),
          TextAddField<GameAddManualDraft>(
            id: 'back_cover_image_url',
            label: 'Back cover image URL',
            value: (draft) => draft.backCoverController.text,
            setValue: (draft, value) => draft.backCoverController.text = value,
          ),
        ],
      ),
    ],
  );
}

String? _nullableText(String value) => value.trim().isEmpty ? null : value;

List<EditOption<String>> _optionsFrom(Iterable<String> values) => [
      for (final value in values) EditOption(value: value, label: value),
    ];

String _formatDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
