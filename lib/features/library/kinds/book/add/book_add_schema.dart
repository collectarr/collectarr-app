import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart'
    show EditOption;
import 'package:collectarr_app/features/library/kinds/book/add/book_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';

final AddSchema<BookAddManualDraft> bookAddSchema = bookAddSchemaFor();

AddSchema<BookAddManualDraft> bookAddSchemaFor({
  Iterable<String>? publisherOptions,
  Iterable<String>? formatOptions,
  FutureOr<void> Function()? onManagePublisher,
  FutureOr<void> Function()? onManageFormat,
}) {
  return AddSchema<BookAddManualDraft>(
    title: (_) => 'Manual book',
    validate: (draft) {
      final pageCount = int.tryParse(draft.pageCountController.text);
      if (pageCount != null && pageCount < 0) {
        return 'Page count cannot be negative';
      }
      if (draft.releaseDateController.text.trim().isNotEmpty &&
          DateTime.tryParse(draft.releaseDateController.text.trim()) == null) {
        return 'Release date is invalid';
      }
      return null;
    },
    sections: [
      AddSectionSpec<BookAddManualDraft>(
        id: 'edition',
        label: 'Edition',
        fields: [
          TextAddField<BookAddManualDraft>(
            id: 'number',
            label: 'Number',
            value: (draft) => draft.numberController.text,
            setValue: (draft, value) => draft.numberController.text = value,
          ),
          TextAddField<BookAddManualDraft>(
            id: 'variant',
            label: 'Variant',
            value: (draft) => draft.variantController.text,
            setValue: (draft, value) => draft.variantController.text = value,
          ),
          TextAddField<BookAddManualDraft>(
            id: 'edition_title',
            label: 'Edition title',
            value: (draft) => draft.editionTitleController.text,
            setValue: (draft, value) =>
                draft.editionTitleController.text = value,
          ),
          TextAddField<BookAddManualDraft>(
            id: 'barcode',
            label: 'ISBN / Barcode',
            value: (draft) => draft.barcodeController.text,
            setValue: (draft, value) => draft.barcodeController.text = value,
          ),
          VocabularyAddField<BookAddManualDraft, String>(
            id: 'format',
            label: 'Format',
            value: (draft) => _nullableText(
              draft.physicalFormatLabelController.text,
            ),
            setValue: (draft, value) =>
                draft.physicalFormatLabelController.text = value ?? '',
            options: _optionsFrom(
              formatOptions ?? BookVocabularies.format.builtIns,
            ),
            onManage: onManageFormat == null ? null : (_) => onManageFormat(),
          ),
          NumberAddField<BookAddManualDraft>(
            id: 'publication_year',
            label: 'Publication year',
            value: (draft) => int.tryParse(draft.yearController.text),
            setValue: (draft, value) =>
                draft.yearController.text = value?.toInt().toString() ?? '',
          ),
          DateAddField<BookAddManualDraft>(
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
      AddSectionSpec<BookAddManualDraft>(
        id: 'publication',
        label: 'Publication and metadata',
        fields: [
          VocabularyAddField<BookAddManualDraft, String>(
            id: 'publisher',
            label: 'Publisher',
            value: (draft) => _nullableText(draft.publisherController.text),
            setValue: (draft, value) =>
                draft.publisherController.text = value ?? '',
            options: _optionsFrom(
              publisherOptions ?? BookVocabularies.publisher.builtIns,
            ),
            onManage:
                onManagePublisher == null ? null : (_) => onManagePublisher(),
          ),
          TextAddField<BookAddManualDraft>(
            id: 'imprint',
            label: 'Imprint',
            value: (draft) => draft.imprintController.text,
            setValue: (draft, value) => draft.imprintController.text = value,
          ),
          TextAddField<BookAddManualDraft>(
            id: 'series_group',
            label: 'Series group',
            value: (draft) => draft.seriesGroupController.text,
            setValue: (draft, value) =>
                draft.seriesGroupController.text = value,
          ),
          NumberAddField<BookAddManualDraft>(
            id: 'page_count',
            label: 'Page count',
            value: (draft) => int.tryParse(draft.pageCountController.text),
            setValue: (draft, value) => draft.pageCountController.text =
                value?.toInt().toString() ?? '',
            minimum: 0,
          ),
          TextAddField<BookAddManualDraft>(
            id: 'authors',
            label: 'Authors',
            value: (draft) => draft.creatorsController.text,
            setValue: (draft, value) => draft.creatorsController.text = value,
          ),
          TextAddField<BookAddManualDraft>(
            id: 'characters',
            label: 'Characters',
            value: (draft) => draft.charactersController.text,
            setValue: (draft, value) => draft.charactersController.text = value,
          ),
          TextAddField<BookAddManualDraft>(
            id: 'genres',
            label: 'Genres',
            value: (draft) => draft.genresEditController.text,
            setValue: (draft, value) => draft.genresEditController.text = value,
          ),
          TextAddField<BookAddManualDraft>(
            id: 'age_rating',
            label: 'Age rating',
            value: (draft) => draft.ageRatingController.text,
            setValue: (draft, value) => draft.ageRatingController.text = value,
          ),
          VocabularyAddField<BookAddManualDraft, String>(
            id: 'language',
            label: 'Language',
            value: (draft) => _nullableText(draft.languageController.text),
            setValue: (draft, value) =>
                draft.languageController.text = value ?? '',
            options: _optionsFrom(BookVocabularies.language.builtIns),
          ),
          TextAddField<BookAddManualDraft>(
            id: 'country',
            label: 'Country',
            value: (draft) => draft.countryController.text,
            setValue: (draft, value) => draft.countryController.text = value,
          ),
          TextAddField<BookAddManualDraft>(
            id: 'synopsis',
            label: 'Synopsis',
            value: (draft) => draft.synopsisController.text,
            setValue: (draft, value) => draft.synopsisController.text = value,
            maxLines: 4,
          ),
          TextAddField<BookAddManualDraft>(
            id: 'cover_image_url',
            label: 'Cover image URL',
            value: (draft) => draft.coverController.text,
            setValue: (draft, value) => draft.coverController.text = value,
          ),
          TextAddField<BookAddManualDraft>(
            id: 'back_cover_image_url',
            label: 'Back cover image URL',
            value: (draft) => draft.backCoverController.text,
            setValue: (draft, value) => draft.backCoverController.text = value,
          ),
        ],
      ),
      AddSectionSpec<BookAddManualDraft>(
        id: 'ownership',
        label: 'Ownership',
        fields: [
          TextAddField<BookAddManualDraft>(
            id: 'signed_by',
            label: 'Signed by',
            value: (draft) => draft.signedByController.text,
            setValue: (draft, value) => draft.signedByController.text = value,
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
