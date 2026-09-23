import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';

import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/vocabulary/manga_vocabularies.dart';

final AddSchema<MangaAddManualDraft> mangaAddSchema = mangaAddSchemaFor();

AddSchema<MangaAddManualDraft> mangaAddSchemaFor({
  Iterable<String>? publisherOptions,
  Iterable<String>? imprintOptions,
  Iterable<String>? formatOptions,
  FutureOr<void> Function()? onManagePublisher,
  FutureOr<void> Function()? onManageImprint,
  FutureOr<void> Function()? onManageFormat,
}) {
  return AddSchema<MangaAddManualDraft>(
    title: (_) => 'Manual manga volume',
    validate: (draft) {
      final pageCount = int.tryParse(draft.pageCountController.text);
      if (pageCount != null && pageCount < 0) {
        return 'Page count cannot be negative';
      }
      return null;
    },
    sections: [
      AddSectionSpec<MangaAddManualDraft>(
        id: 'volume',
        label: 'Volume',
        fields: [
          LibraryTextFieldSpec<MangaAddManualDraft>(
            id: 'volume_number',
            label: 'Volume No.',
            value: (draft) => draft.numberController.text,
            setValue: (draft, value) => draft.numberController.text = value,
          ),
          LibraryTextFieldSpec<MangaAddManualDraft>(
            id: 'variant',
            label: 'Variant',
            value: (draft) => draft.variantController.text,
            setValue: (draft, value) => draft.variantController.text = value,
          ),
          LibraryTextFieldSpec<MangaAddManualDraft>(
            id: 'edition_title',
            label: 'Edition title',
            value: (draft) => draft.editionTitleController.text,
            setValue: (draft, value) =>
                draft.editionTitleController.text = value,
          ),
          LibraryTextFieldSpec<MangaAddManualDraft>(
            id: 'barcode',
            label: 'Barcode / ISBN',
            value: (draft) => draft.barcodeController.text,
            setValue: (draft, value) => draft.barcodeController.text = value,
          ),
          LibraryVocabularyFieldSpec<MangaAddManualDraft, String>(
            id: 'format',
            label: 'Format',
            value: (draft) => _nullableText(
              draft.physicalFormatLabelController.text,
            ),
            setValue: (draft, value) =>
                draft.physicalFormatLabelController.text = value ?? '',
            options: _optionsFrom(
              formatOptions ?? MangaVocabularies.format.builtIns,
            ),
            onManage: onManageFormat == null ? null : (_) => onManageFormat(),
          ),
          LibraryNumberFieldSpec<MangaAddManualDraft>(
            id: 'publication_year',
            label: 'Publication year',
            value: (draft) => int.tryParse(draft.yearController.text),
            setValue: (draft, value) =>
                draft.yearController.text = value?.toInt().toString() ?? '',
          ),
          LibraryDateFieldSpec<MangaAddManualDraft>(
            id: 'release_date',
            label: 'Release date',
            value: (draft) => DateTime.tryParse(
              draft.releaseDateController.text,
            ),
            setValue: (draft, value) => draft.releaseDateController.text =
                value == null ? '' : _formatDate(value),
          ),
        ],
      ),
      AddSectionSpec<MangaAddManualDraft>(
        id: 'publication',
        label: 'Publication and metadata',
        fields: [
          LibraryVocabularyFieldSpec<MangaAddManualDraft, String>(
            id: 'publisher',
            label: 'Publisher',
            value: (draft) => _nullableText(draft.publisherController.text),
            setValue: (draft, value) =>
                draft.publisherController.text = value ?? '',
            options: _optionsFrom(
              publisherOptions ?? MangaVocabularies.publisher.builtIns,
            ),
            onManage:
                onManagePublisher == null ? null : (_) => onManagePublisher(),
          ),
          LibraryVocabularyFieldSpec<MangaAddManualDraft, String>(
            id: 'imprint',
            label: 'Imprint',
            value: (draft) => _nullableText(draft.imprintController.text),
            setValue: (draft, value) =>
                draft.imprintController.text = value ?? '',
            options: _optionsFrom(
              imprintOptions ?? MangaVocabularies.imprint.builtIns,
            ),
            onManage: onManageImprint == null ? null : (_) => onManageImprint(),
          ),
          LibraryTextFieldSpec<MangaAddManualDraft>(
            id: 'series_group',
            label: 'Series group',
            value: (draft) => draft.seriesGroupController.text,
            setValue: (draft, value) =>
                draft.seriesGroupController.text = value,
          ),
          LibraryNumberFieldSpec<MangaAddManualDraft>(
            id: 'page_count',
            label: 'Page count',
            value: (draft) => int.tryParse(draft.pageCountController.text),
            setValue: (draft, value) => draft.pageCountController.text =
                value?.toInt().toString() ?? '',
            minimum: 0,
          ),
          LibraryTextFieldSpec<MangaAddManualDraft>(
            id: 'authors',
            label: 'Authors / Artists',
            value: (draft) => draft.creatorsController.text,
            setValue: (draft, value) => draft.creatorsController.text = value,
          ),
          LibraryTextFieldSpec<MangaAddManualDraft>(
            id: 'characters',
            label: 'Characters',
            value: (draft) => draft.charactersController.text,
            setValue: (draft, value) => draft.charactersController.text = value,
          ),
          LibraryTextFieldSpec<MangaAddManualDraft>(
            id: 'genres',
            label: 'Genres',
            value: (draft) => draft.genresEditController.text,
            setValue: (draft, value) => draft.genresEditController.text = value,
          ),
          LibraryTextFieldSpec<MangaAddManualDraft>(
            id: 'age_rating',
            label: 'Age rating',
            value: (draft) => draft.ageRatingController.text,
            setValue: (draft, value) => draft.ageRatingController.text = value,
          ),
          LibraryTextFieldSpec<MangaAddManualDraft>(
            id: 'language',
            label: 'Language',
            value: (draft) => draft.languageController.text,
            setValue: (draft, value) => draft.languageController.text = value,
          ),
          LibraryTextFieldSpec<MangaAddManualDraft>(
            id: 'country',
            label: 'Country',
            value: (draft) => draft.countryController.text,
            setValue: (draft, value) => draft.countryController.text = value,
          ),
          LibraryTextFieldSpec<MangaAddManualDraft>(
            id: 'synopsis',
            label: 'Synopsis',
            value: (draft) => draft.synopsisController.text,
            setValue: (draft, value) => draft.synopsisController.text = value,
            maxLines: 4,
          ),
          LibraryTextFieldSpec<MangaAddManualDraft>(
            id: 'cover_image_url',
            label: 'Cover image URL',
            value: (draft) => draft.coverController.text,
            setValue: (draft, value) => draft.coverController.text = value,
          ),
          LibraryTextFieldSpec<MangaAddManualDraft>(
            id: 'back_cover_image_url',
            label: 'Back cover image URL',
            value: (draft) => draft.backCoverController.text,
            setValue: (draft, value) => draft.backCoverController.text = value,
          ),
        ],
      ),
      AddSectionSpec<MangaAddManualDraft>(
        id: 'collector',
        label: 'Collector',
        fields: [
          LibraryTextFieldSpec<MangaAddManualDraft>(
            id: 'raw_or_slabbed',
            label: 'Raw / Slabbed',
            value: (draft) => draft.rawOrSlabbedController.text,
            setValue: (draft, value) =>
                draft.rawOrSlabbedController.text = value,
          ),
          LibraryTextFieldSpec<MangaAddManualDraft>(
            id: 'grading_company',
            label: 'Grading company',
            value: (draft) => draft.gradingCompanyController.text,
            setValue: (draft, value) =>
                draft.gradingCompanyController.text = value,
          ),
          LibraryTextFieldSpec<MangaAddManualDraft>(
            id: 'grader_notes',
            label: 'Grader notes',
            value: (draft) => draft.graderNotesController.text,
            setValue: (draft, value) =>
                draft.graderNotesController.text = value,
            maxLines: 4,
          ),
          LibraryTextFieldSpec<MangaAddManualDraft>(
            id: 'label_type',
            label: 'Label type',
            value: (draft) => draft.labelTypeController.text,
            setValue: (draft, value) => draft.labelTypeController.text = value,
          ),
          LibraryTextFieldSpec<MangaAddManualDraft>(
            id: 'custom_label',
            label: 'Custom label',
            value: (draft) => draft.customLabelController.text,
            setValue: (draft, value) =>
                draft.customLabelController.text = value,
          ),
          LibraryTextFieldSpec<MangaAddManualDraft>(
            id: 'page_quality',
            label: 'Page quality',
            value: (draft) => draft.pageQualityController.text,
            setValue: (draft, value) =>
                draft.pageQualityController.text = value,
          ),
          LibraryTextFieldSpec<MangaAddManualDraft>(
            id: 'certification_number',
            label: 'Certification number',
            value: (draft) => draft.certificationNumberController.text,
            setValue: (draft, value) =>
                draft.certificationNumberController.text = value,
          ),
        ],
      ),
    ],
  );
}

String? _nullableText(String value) => value.trim().isEmpty ? null : value;

List<LibraryFieldOption<String>> _optionsFrom(Iterable<String> values) => [
      for (final value in values)
        LibraryFieldOption(value: value, label: value),
    ];

String _formatDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
