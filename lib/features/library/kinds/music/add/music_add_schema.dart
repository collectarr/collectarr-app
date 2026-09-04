import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart'
    show EditOption;
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';

final AddSchema<MusicAddManualDraft> musicAddSchema = musicAddSchemaFor();

AddSchema<MusicAddManualDraft> musicAddSchemaFor({
  Iterable<String>? formatOptions,
  Iterable<String>? genreOptions,
  Iterable<String>? countryOptions,
  Iterable<String>? recordLabelOptions,
  FutureOr<void> Function()? onManageFormat,
  FutureOr<void> Function()? onManageGenre,
  FutureOr<void> Function()? onManageCountry,
  FutureOr<void> Function()? onManageRecordLabel,
}) {
  return AddSchema<MusicAddManualDraft>(
    title: (_) => 'Manual music release',
    validate: (draft) {
      final year = int.tryParse(draft.yearController.text.trim());
      if (year != null && year < 0) return 'Release year cannot be negative';
      final dateText = draft.releaseDateController.text.trim();
      if (dateText.isNotEmpty && DateTime.tryParse(dateText) == null) {
        return 'Release date is invalid';
      }
      return null;
    },
    sections: [
      AddSectionSpec<MusicAddManualDraft>(
        id: 'release',
        label: 'Release',
        fields: [
          TextAddField<MusicAddManualDraft>(
            id: 'edition_title',
            label: 'Release title',
            value: (draft) => draft.editionTitleController.text,
            setValue: (draft, value) =>
                draft.editionTitleController.text = value,
          ),
          VocabularyAddField<MusicAddManualDraft, String>(
            id: 'format',
            label: 'Format',
            value: (draft) =>
                _nullable(draft.physicalFormatLabelController.text),
            setValue: (draft, value) =>
                draft.physicalFormatLabelController.text = value ?? '',
            options: _options(
              formatOptions ?? MusicVocabularies.format.builtIns,
            ),
            onManage: onManageFormat == null ? null : (_) => onManageFormat(),
          ),
          TextAddField<MusicAddManualDraft>(
            id: 'catalog_number',
            label: 'Catalog number',
            value: (draft) => draft.numberController.text,
            setValue: (draft, value) => draft.numberController.text = value,
          ),
          TextAddField<MusicAddManualDraft>(
            id: 'barcode',
            label: 'Barcode',
            value: (draft) => draft.barcodeController.text,
            setValue: (draft, value) => draft.barcodeController.text = value,
          ),
          VocabularyAddField<MusicAddManualDraft, String>(
            id: 'country',
            label: 'Country',
            value: (draft) => _nullable(draft.countryController.text),
            setValue: (draft, value) =>
                draft.countryController.text = value ?? '',
            options: _options(
              countryOptions ?? MusicVocabularies.country.builtIns,
            ),
            onManage: onManageCountry == null ? null : (_) => onManageCountry(),
          ),
          DateAddField<MusicAddManualDraft>(
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
      AddSectionSpec<MusicAddManualDraft>(
        id: 'music',
        label: 'Music metadata',
        fields: [
          TextAddField<MusicAddManualDraft>(
            id: 'artist',
            label: 'Artist',
            value: (draft) => draft.creatorsController.text,
            setValue: (draft, value) => draft.creatorsController.text = value,
          ),
          VocabularyAddField<MusicAddManualDraft, String>(
            id: 'record_label',
            label: 'Record label',
            value: (draft) => _nullable(draft.publisherController.text),
            setValue: (draft, value) =>
                draft.publisherController.text = value ?? '',
            options: _options(
              recordLabelOptions ?? MusicVocabularies.recordLabel.builtIns,
            ),
            onManage: onManageRecordLabel == null
                ? null
                : (_) => onManageRecordLabel(),
          ),
          TextAddField<MusicAddManualDraft>(
            id: 'genres',
            label: 'Genres',
            value: (draft) => draft.genresEditController.text,
            setValue: (draft, value) => draft.genresEditController.text = value,
          ),
          TextAddField<MusicAddManualDraft>(
            id: 'language',
            label: 'Language',
            value: (draft) => draft.languageController.text,
            setValue: (draft, value) => draft.languageController.text = value,
          ),
          TextAddField<MusicAddManualDraft>(
            id: 'synopsis',
            label: 'Notes',
            value: (draft) => draft.synopsisController.text,
            setValue: (draft, value) => draft.synopsisController.text = value,
            maxLines: 4,
          ),
          TextAddField<MusicAddManualDraft>(
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

String? _nullable(String value) => value.trim().isEmpty ? null : value.trim();

List<EditOption<String>> _options(Iterable<String> values) => [
      for (final value in values) EditOption(value: value, label: value),
    ];

String _formatDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
