import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/book_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';
import 'package:flutter/material.dart';

final EditSchema<BookCatalogMetadata, BookEditDraft> bookMediaEditSchema =
    EditSchema(
  title: (_) => 'Edit book',
  validate: (_, draft) {
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
  tabs: [
    EditTabSpec(
      id: 'edition',
      label: 'Edition',
      icon: Icons.menu_book,
      sections: [
        EditSectionSpec(
          id: 'edition_details',
          label: 'Edition details',
          fields: [
            _textField(
              id: 'edition_title',
              label: 'Edition title',
              value: (draft) => draft.editionTitleController.text,
              setValue: (draft, value) =>
                  draft.editionTitleController.text = value,
            ),
            _textField(
              id: 'variant',
              label: 'Variant',
              value: (draft) => draft.variantController.text,
              setValue: (draft, value) => draft.variantController.text = value,
            ),
            _textField(
              id: 'barcode',
              label: 'ISBN / Barcode',
              value: (draft) => draft.barcodeController.text,
              setValue: (draft, value) => draft.barcodeController.text = value,
            ),
            VocabularyEditField<BookEditDraft, String>(
              id: 'format',
              label: 'Format',
              value: (draft) => _nullableText(draft.formatController.text),
              setValue: (draft, value) =>
                  draft.formatController.text = value ?? '',
              options: _options(BookVocabularies.format.builtIns),
            ),
            DateEditField<BookEditDraft>(
              id: 'release_date',
              label: 'Release date',
              value: (draft) => DateTime.tryParse(
                draft.releaseDateController.text.trim(),
              ),
              setValue: (draft, value) => draft.releaseDateController.text =
                  value == null ? '' : _formatDate(value),
              validator: (draft) => _validDate(
                draft.releaseDateController.text,
                'Release date',
              ),
            ),
          ],
        ),
      ],
    ),
    EditTabSpec(
      id: 'publication',
      label: 'Publication',
      icon: Icons.public,
      sections: [
        EditSectionSpec(
          id: 'publication_details',
          label: 'Publication details',
          fields: [
            VocabularyEditField<BookEditDraft, String>(
              id: 'publisher',
              label: 'Publisher',
              value: (draft) => _nullableText(draft.publisherController.text),
              setValue: (draft, value) =>
                  draft.publisherController.text = value ?? '',
              options: _options(BookVocabularies.publisher.builtIns),
            ),
            TextEditField<BookEditDraft>(
              id: 'imprint',
              label: 'Imprint',
              value: (draft) => draft.imprintController.text,
              setValue: (draft, value) => draft.imprintController.text = value,
            ),
            NumberEditField<BookEditDraft>(
              id: 'page_count',
              label: 'Page count',
              value: (draft) => int.tryParse(draft.pageCountController.text),
              setValue: (draft, value) => draft.pageCountController.text =
                  value?.toInt().toString() ?? '',
              minimum: 0,
              validator: (draft) {
                final value = int.tryParse(draft.pageCountController.text);
                return value != null && value < 0
                    ? 'Page count cannot be negative'
                    : null;
              },
            ),
            VocabularyEditField<BookEditDraft, String>(
              id: 'language',
              label: 'Language',
              value: (draft) => _nullableText(draft.languageController.text),
              setValue: (draft, value) =>
                  draft.languageController.text = value ?? '',
              options: _options(BookVocabularies.language.builtIns),
            ),
            TextEditField<BookEditDraft>(
              id: 'country',
              label: 'Country',
              value: (draft) => draft.countryController.text,
              setValue: (draft, value) => draft.countryController.text = value,
            ),
          ],
        ),
        EditSectionSpec(
          id: 'classification',
          label: 'Classification and credits',
          fields: [
            _textField(
              id: 'authors',
              label: 'Authors',
              value: (draft) => draft.authorsController.text,
              setValue: (draft, value) => draft.authorsController.text = value,
            ),
            _textField(
              id: 'genres',
              label: 'Genres',
              value: (draft) => draft.genresController.text,
              setValue: (draft, value) => draft.genresController.text = value,
            ),
            _textField(
              id: 'subjects',
              label: 'Subjects',
              value: (draft) => draft.subjectsController.text,
              setValue: (draft, value) => draft.subjectsController.text = value,
            ),
            _textField(
              id: 'translators',
              label: 'Translators',
              value: (draft) => draft.translatorsController.text,
              setValue: (draft, value) =>
                  draft.translatorsController.text = value,
            ),
          ],
        ),
      ],
    ),
  ],
);

TextEditField<BookEditDraft> _textField({
  required String id,
  required String label,
  required String Function(BookEditDraft draft) value,
  required void Function(BookEditDraft draft, String value) setValue,
}) {
  return TextEditField(
    id: id,
    label: label,
    value: value,
    setValue: setValue,
  );
}

List<EditOption<String>> _options(Iterable<String> values) => [
      for (final value in values) EditOption(value: value, label: value),
    ];

String? _nullableText(String value) => value.trim().isEmpty ? null : value;

String? _validDate(String value, String label) {
  return value.trim().isNotEmpty && DateTime.tryParse(value.trim()) == null
      ? '$label is invalid'
      : null;
}

String _formatDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
