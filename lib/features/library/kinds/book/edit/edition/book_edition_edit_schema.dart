import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_domain.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/edition/book_edition_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';
import 'package:flutter/material.dart';

final EditSchema<BookRelease, BookEditionEditDraft> bookEditionEditSchema =
    EditSchema(
  title: (release) => 'Edit ${release.title}',
  validate: (_, draft) {
    final pageCount = int.tryParse(draft.pageCountController.text);
    if (pageCount != null && pageCount < 0) {
      return 'Page count cannot be negative';
    }
    final audioLength = int.tryParse(draft.audioLengthController.text);
    if (audioLength != null && audioLength < 0) {
      return 'Audio length cannot be negative';
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
          id: 'identity',
          label: 'Identity',
          fields: [
            TextEditField<BookEditionEditDraft>(
              id: 'title',
              label: 'Title',
              value: (draft) => draft.titleController.text,
              setValue: (draft, value) => draft.titleController.text = value,
            ),
            VocabularyEditField<BookEditionEditDraft, String>(
              id: 'binding',
              label: 'Binding',
              value: (draft) => _text(draft.bindingController.text),
              setValue: (draft, value) =>
                  draft.bindingController.text = value ?? '',
              options: _options(BookVocabularies.binding.builtIns),
            ),
            VocabularyEditField<BookEditionEditDraft, String>(
              id: 'format',
              label: 'Format',
              value: (draft) => _text(draft.formatController.text),
              setValue: (draft, value) =>
                  draft.formatController.text = value ?? '',
              options: _options(BookVocabularies.format.builtIns),
            ),
            TextEditField<BookEditionEditDraft>(
              id: 'isbn',
              label: 'ISBN',
              value: (draft) => draft.isbnController.text,
              setValue: (draft, value) => draft.isbnController.text = value,
            ),
            TextEditField<BookEditionEditDraft>(
              id: 'upc',
              label: 'UPC',
              value: (draft) => draft.upcController.text,
              setValue: (draft, value) => draft.upcController.text = value,
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
            TextEditField<BookEditionEditDraft>(
              id: 'publisher',
              label: 'Publisher',
              value: (draft) => draft.publisherController.text,
              setValue: (draft, value) =>
                  draft.publisherController.text = value,
            ),
            TextEditField<BookEditionEditDraft>(
              id: 'distributor',
              label: 'Distributor',
              value: (draft) => draft.distributorController.text,
              setValue: (draft, value) =>
                  draft.distributorController.text = value,
            ),
            TextEditField<BookEditionEditDraft>(
              id: 'imprint',
              label: 'Imprint',
              value: (draft) => draft.imprintController.text,
              setValue: (draft, value) => draft.imprintController.text = value,
            ),
            DateEditField<BookEditionEditDraft>(
              id: 'release_date',
              label: 'Release date',
              value: (draft) => DateTime.tryParse(
                draft.releaseDateController.text.trim(),
              ),
              setValue: (draft, value) => draft.releaseDateController.text =
                  value == null ? '' : _formatDate(value),
            ),
            NumberEditField<BookEditionEditDraft>(
              id: 'page_count',
              label: 'Page count',
              value: (draft) => int.tryParse(draft.pageCountController.text),
              setValue: (draft, value) => draft.pageCountController.text =
                  value?.toInt().toString() ?? '',
              minimum: 0,
            ),
            TextEditField<BookEditionEditDraft>(
              id: 'language',
              label: 'Language',
              value: (draft) => draft.languageController.text,
              setValue: (draft, value) => draft.languageController.text = value,
            ),
            TextEditField<BookEditionEditDraft>(
              id: 'region',
              label: 'Region',
              value: (draft) => draft.regionController.text,
              setValue: (draft, value) => draft.regionController.text = value,
            ),
            TextEditField<BookEditionEditDraft>(
              id: 'release_status',
              label: 'Release status',
              value: (draft) => draft.statusController.text,
              setValue: (draft, value) => draft.statusController.text = value,
            ),
          ],
        ),
      ],
    ),
    EditTabSpec(
      id: 'details',
      label: 'Details',
      icon: Icons.info_outline,
      sections: [
        EditSectionSpec(
          id: 'additional_details',
          label: 'Additional details',
          fields: [
            TextEditField<BookEditionEditDraft>(
              id: 'edition_statement',
              label: 'Edition statement',
              value: (draft) => draft.editionStatementController.text,
              setValue: (draft, value) =>
                  draft.editionStatementController.text = value,
            ),
            TextEditField<BookEditionEditDraft>(
              id: 'dimensions',
              label: 'Dimensions',
              value: (draft) => draft.dimensionsController.text,
              setValue: (draft, value) =>
                  draft.dimensionsController.text = value,
            ),
            TextEditField<BookEditionEditDraft>(
              id: 'description',
              label: 'Description',
              value: (draft) => draft.descriptionController.text,
              setValue: (draft, value) =>
                  draft.descriptionController.text = value,
              maxLines: 4,
            ),
            ToggleEditField<BookEditionEditDraft>(
              id: 'first_edition',
              label: 'First edition',
              value: (draft) => draft.firstEdition,
              setValue: (draft, value) => draft.firstEdition = value,
            ),
            NumberEditField<BookEditionEditDraft>(
              id: 'audio_length_minutes',
              label: 'Audio length (minutes)',
              value: (draft) => int.tryParse(draft.audioLengthController.text),
              setValue: (draft, value) => draft.audioLengthController.text =
                  value?.toInt().toString() ?? '',
              minimum: 0,
            ),
          ],
        ),
      ],
    ),
  ],
);

List<EditOption<String>> _options(Iterable<String> values) => [
      for (final value in values) EditOption(value: value, label: value),
    ];

String? _text(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

String _formatDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
