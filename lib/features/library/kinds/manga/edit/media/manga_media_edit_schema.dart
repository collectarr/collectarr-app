import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/manga_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/vocabulary/manga_vocabularies.dart';
import 'package:flutter/material.dart';

final EditSchema<MangaMetadata, MangaEditDraft> mangaMediaEditSchema =
    EditSchema(
  title: (_) => 'Edit manga',
  validate: (_, draft) {
    final pageCount = int.tryParse(draft.pageCountController.text);
    if (pageCount != null && pageCount < 0) {
      return 'Page count cannot be negative';
    }
    if (draft.releaseDateController.text.trim().isNotEmpty &&
        _parseDate(draft.releaseDateController.text) == null) {
      return 'Release date is invalid';
    }
    return null;
  },
  tabs: [
    EditTabSpec(
      id: 'main',
      label: 'Main',
      icon: Icons.article,
      sections: [
        EditSectionSpec(
          id: 'volume',
          label: 'Volume',
          fields: [
            _textField(
              id: 'volume_number',
              label: 'Volume No.',
              value: (draft) => draft.volumeNumberController.text,
              setValue: (draft, value) =>
                  draft.volumeNumberController.text = value,
            ),
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
              label: 'Barcode / ISBN',
              value: (draft) => draft.barcodeController.text,
              setValue: (draft, value) => draft.barcodeController.text = value,
            ),
            VocabularyEditField<MangaEditDraft, String>(
              id: 'format',
              label: 'Format',
              value: (draft) => _nullableText(
                draft.physicalFormatController.text,
              ),
              setValue: (draft, value) =>
                  draft.physicalFormatController.text = value ?? '',
              options: _options(MangaVocabularies.format.builtIns),
            ),
            DateEditField<MangaEditDraft>(
              id: 'release_date',
              label: 'Release date',
              value: (draft) => _parseDate(draft.releaseDateController.text),
              setValue: (draft, value) => draft.releaseDateController.text =
                  value == null ? '' : _formatDate(value),
              validator: (draft) => _dateValidator(
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
      icon: Icons.menu_book,
      sections: [
        EditSectionSpec(
          id: 'publication_details',
          label: 'Publication details',
          fields: [
            VocabularyEditField<MangaEditDraft, String>(
              id: 'publisher',
              label: 'Publisher',
              value: (draft) => _nullableText(draft.publisherController.text),
              setValue: (draft, value) =>
                  draft.publisherController.text = value ?? '',
              options: _options(MangaVocabularies.publisher.builtIns),
            ),
            _textField(
              id: 'original_publisher',
              label: 'Original publisher',
              value: (draft) => draft.originalPublisherController.text,
              setValue: (draft, value) =>
                  draft.originalPublisherController.text = value,
            ),
            _textField(
              id: 'localized_publisher',
              label: 'Localized publisher',
              value: (draft) => draft.localizedPublisherController.text,
              setValue: (draft, value) =>
                  draft.localizedPublisherController.text = value,
            ),
            VocabularyEditField<MangaEditDraft, String>(
              id: 'imprint',
              label: 'Imprint',
              value: (draft) => _nullableText(draft.imprintController.text),
              setValue: (draft, value) =>
                  draft.imprintController.text = value ?? '',
              options: _options(MangaVocabularies.imprint.builtIns),
            ),
            NumberEditField<MangaEditDraft>(
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
            _textField(
              id: 'language',
              label: 'Language',
              value: (draft) => draft.languageController.text,
              setValue: (draft, value) => draft.languageController.text = value,
            ),
            _textField(
              id: 'country',
              label: 'Country',
              value: (draft) => draft.countryController.text,
              setValue: (draft, value) => draft.countryController.text = value,
            ),
            SelectEditField<MangaEditDraft, String>(
              id: 'demographic',
              label: 'Demographic',
              value: (draft) => _nullableText(draft.demographicController.text),
              setValue: (draft, value) =>
                  draft.demographicController.text = value ?? '',
              options: _options(
                MangaDemographic.values.map((value) => value.label),
              ),
            ),
            SelectEditField<MangaEditDraft, String>(
              id: 'publication_status',
              label: 'Publication status',
              value: (draft) => _nullableText(draft.statusController.text),
              setValue: (draft, value) =>
                  draft.statusController.text = value ?? '',
              options: _options(
                MangaPublicationStatus.values.map((value) => value.label),
              ),
            ),
            VocabularyEditField<MangaEditDraft, String>(
              id: 'serialization',
              label: 'Serialization',
              value: (draft) =>
                  _nullableText(draft.serializationController.text),
              setValue: (draft, value) =>
                  draft.serializationController.text = value ?? '',
              options: _options(MangaVocabularies.serialization.builtIns),
            ),
          ],
        ),
        EditSectionSpec(
          id: 'classification',
          label: 'Classification and credits',
          fields: [
            _textField(
              id: 'genres',
              label: 'Genres',
              value: (draft) => draft.genresController.text,
              setValue: (draft, value) => draft.genresController.text = value,
            ),
            _textField(
              id: 'themes',
              label: 'Themes',
              value: (draft) => draft.themesController.text,
              setValue: (draft, value) => draft.themesController.text = value,
            ),
            _textField(
              id: 'authors',
              label: 'Authors',
              value: (draft) => draft.authorsController.text,
              setValue: (draft, value) => draft.authorsController.text = value,
            ),
            _textField(
              id: 'artists',
              label: 'Artists',
              value: (draft) => draft.artistsController.text,
              setValue: (draft, value) => draft.artistsController.text = value,
            ),
          ],
        ),
      ],
    ),
  ],
);

TextEditField<MangaEditDraft> _textField({
  required String id,
  required String label,
  required String Function(MangaEditDraft draft) value,
  required void Function(MangaEditDraft draft, String value) setValue,
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

DateTime? _parseDate(String value) => DateTime.tryParse(value.trim());

String? _dateValidator(String value, String label) {
  return value.trim().isNotEmpty && _parseDate(value) == null
      ? '$label is invalid'
      : null;
}

String _formatDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
