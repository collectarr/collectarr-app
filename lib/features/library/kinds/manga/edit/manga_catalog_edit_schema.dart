import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/manga/config/manga_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/manga_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/vocabulary/manga_vocabularies.dart';
import 'package:flutter/material.dart';

final EditSchema<MangaEditDraft, MangaEditDraft> mangaCatalogEditionEditSchema =
    EditSchema(
  tabs: [
    EditTabSpec(
      id: 'edition',
      label: 'Edition Details',
      icon: Icons.inventory_2_outlined,
      sections: [
        LibraryFormSectionSpec(
          id: 'edition_details',
          label: 'Edition details',
          fields: [
            LibraryNumberFieldSpec<MangaEditDraft>(
              id: 'volume_number',
              label: 'Volume No.',
              value: (draft) =>
                  int.tryParse(draft.volumeNumberController.text)?.toDouble(),
              setValue: (draft, value) => draft.volumeNumberController.text =
                  value?.toInt().toString() ?? '',
              minimum: 0,
              decimalPlaces: 0,
            ),
            _textField(
              id: 'series_group',
              label: 'Series group',
              read: (draft) => draft.seriesGroupController.text,
              write: (draft, value) => draft.seriesGroupController.text = value,
            ),
            _textField(
              id: 'edition_title',
              label: 'Edition title',
              read: (draft) => draft.editionTitleController.text,
              write: (draft, value) =>
                  draft.editionTitleController.text = value,
            ),
            _textField(
              id: 'variant',
              label: 'Variant',
              read: (draft) => draft.variantController.text,
              write: (draft, value) => draft.variantController.text = value,
            ),
            _vocabularyField(
              id: 'format',
              label: 'Format',
              options: MangaVocabularies.format.builtIns,
              vocabularyKey: MangaVocabularies.format.key,
              read: (draft) => draft.physicalFormatController.text,
              write: (draft, value) =>
                  draft.physicalFormatController.text = value,
            ),
            _textField(
              id: 'binding',
              label: 'Binding',
              read: (draft) => draft.bindingController.text,
              write: (draft, value) => draft.bindingController.text = value,
            ),
            _vocabularyField(
              id: MangaFieldIdentities.publisherId,
              label: MangaFieldIdentities.publisherLabel,
              options: MangaVocabularies.publisher.builtIns,
              vocabularyKey: MangaVocabularies.publisher.key,
              read: (draft) => draft.publisherController.text,
              write: (draft, value) => draft.publisherController.text = value,
            ),
            _vocabularyField(
              id: 'imprint',
              label: 'Imprint',
              options: MangaVocabularies.imprint.builtIns,
              vocabularyKey: MangaVocabularies.imprint.key,
              read: (draft) => draft.imprintController.text,
              write: (draft, value) => draft.imprintController.text = value,
            ),
            _textField(
              id: 'original_publisher',
              label: 'Original Publisher',
              read: (draft) => draft.originalPublisherController.text,
              write: (draft, value) =>
                  draft.originalPublisherController.text = value,
            ),
            _textField(
              id: 'localized_publisher',
              label: 'Localized Publisher',
              read: (draft) => draft.localizedPublisherController.text,
              write: (draft, value) =>
                  draft.localizedPublisherController.text = value,
            ),
            _textField(
              id: 'isbn',
              label: 'ISBN',
              read: (draft) => draft.isbnController.text,
              write: (draft, value) => draft.isbnController.text = value,
            ),
            _textField(
              id: 'barcode',
              label: 'Barcode',
              read: (draft) => draft.barcodeController.text,
              write: (draft, value) => draft.barcodeController.text = value,
            ),
            _textField(
              id: 'language',
              label: 'Language',
              read: (draft) => draft.languageController.text,
              write: (draft, value) => draft.languageController.text = value,
            ),
            LibraryPartialDateFieldSpec<MangaEditDraft>(
              id: 'publication_date',
              label: 'Publication date',
              value: (draft) =>
                  PartialDate.tryParse(draft.releaseDateController.text),
              setValue: (draft, value) =>
                  draft.releaseDateController.text = value?.isoString ?? '',
            ),
            LibraryNumberFieldSpec<MangaEditDraft>(
              id: 'publication_year',
              label: 'Publication year',
              value: (draft) =>
                  int.tryParse(draft.releaseYearController.text)?.toDouble(),
              setValue: (draft, value) => draft.releaseYearController.text =
                  value?.toInt().toString() ?? '',
              minimum: 1,
              decimalPlaces: 0,
            ),
            LibraryNumberFieldSpec<MangaEditDraft>(
              id: 'page_count',
              label: 'Page count',
              value: (draft) =>
                  int.tryParse(draft.pageCountController.text)?.toDouble(),
              setValue: (draft, value) => draft.pageCountController.text =
                  value?.toInt().toString() ?? '',
              minimum: 0,
              decimalPlaces: 0,
            ),
            _textField(
              id: 'release_description',
              label: 'Release description',
              read: (draft) => draft.releaseDescriptionController.text,
              write: (draft, value) =>
                  draft.releaseDescriptionController.text = value,
              maxLines: 4,
            ),
          ],
        ),
      ],
    ),
  ],
);

final EditSchema<MangaEditDraft, MangaEditDraft> mangaCatalogDetailsEditSchema =
    EditSchema(
  tabs: [
    EditTabSpec(
      id: 'details',
      label: 'Details',
      icon: Icons.info_outline,
      sections: [
        LibraryFormSectionSpec(
          id: 'catalog_details',
          label: 'Series and metadata',
          fields: [
            _textField(
              id: 'authors',
              label: 'Authors',
              read: (draft) => draft.authorsController.text,
              write: (draft, value) => draft.authorsController.text = value,
            ),
            _textField(
              id: 'artists',
              label: 'Artists',
              read: (draft) => draft.artistsController.text,
              write: (draft, value) => draft.artistsController.text = value,
            ),
            _textField(
              id: 'characters',
              label: 'Characters',
              read: (draft) => draft.charactersController.text,
              write: (draft, value) => draft.charactersController.text = value,
            ),
            LibraryMultiVocabularyFieldSpec<MangaEditDraft, String>(
              id: 'genres',
              label: 'Genres',
              values: (draft) =>
                  _splitValues(draft.genresController.text).toSet(),
              setValues: (draft, values) =>
                  draft.genresController.text = values.join(', '),
              options: const [],
              allowCustomValues: true,
            ),
            LibraryMultiVocabularyFieldSpec<MangaEditDraft, String>(
              id: 'themes',
              label: 'Themes',
              values: (draft) =>
                  _splitValues(draft.themesController.text).toSet(),
              setValues: (draft, values) =>
                  draft.themesController.text = values.join(', '),
              options: const [],
              allowCustomValues: true,
            ),
            _textField(
              id: 'age_rating',
              label: 'Age rating',
              read: (draft) => draft.ageRatingController.text,
              write: (draft, value) => draft.ageRatingController.text = value,
            ),
            _textField(
              id: 'country',
              label: 'Country',
              read: (draft) => draft.countryController.text,
              write: (draft, value) => draft.countryController.text = value,
            ),
            _textField(
              id: 'demographic',
              label: 'Demographic',
              read: (draft) => draft.demographicController.text,
              write: (draft, value) => draft.demographicController.text = value,
            ),
            _textField(
              id: 'publication_status',
              label: 'Publication status',
              read: (draft) => draft.statusController.text,
              write: (draft, value) => draft.statusController.text = value,
            ),
            _textField(
              id: 'serialization_platform',
              label: 'Serialization platform',
              read: (draft) => draft.serializationController.text,
              write: (draft, value) =>
                  draft.serializationController.text = value,
            ),
          ],
        ),
      ],
    ),
  ],
);

LibraryTextFieldSpec<MangaEditDraft> _textField({
  required String id,
  required String label,
  required String Function(MangaEditDraft draft) read,
  required void Function(MangaEditDraft draft, String value) write,
  int maxLines = 1,
}) =>
    LibraryTextFieldSpec<MangaEditDraft>(
      id: id,
      label: label,
      value: read,
      setValue: write,
      maxLines: maxLines,
    );

LibraryVocabularyFieldSpec<MangaEditDraft, String> _vocabularyField({
  required String id,
  required String label,
  required Iterable<String> options,
  required String vocabularyKey,
  required String Function(MangaEditDraft draft) read,
  required void Function(MangaEditDraft draft, String value) write,
}) =>
    LibraryVocabularyFieldSpec<MangaEditDraft, String>(
      id: id,
      label: label,
      value: (draft) {
        final value = read(draft).trim();
        return value.isEmpty ? null : value;
      },
      setValue: (draft, value) => write(draft, value ?? ''),
      options: [
        for (final option in options)
          LibraryFieldOption(value: option, label: option),
      ],
      pickListKey: vocabularyKey,
    );

List<String> _splitValues(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);
