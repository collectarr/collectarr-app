import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';

final AddSchema<BookAddManualDraft> bookAddSchema = bookAddSchemaFor();

AddSchema<BookAddManualDraft> bookAddSchemaFor({
  Iterable<String>? publisherOptions,
  Iterable<String>? formatOptions,
  FutureOr<void> Function()? onManagePublisher,
  FutureOr<void> Function()? onManageFormat,
}) {
  BookCatalogFormValues values(BookAddManualDraft draft) => draft.values;

  return AddSchema<BookAddManualDraft>(
    title: (_) => 'Manual book',
    validate: (draft) {
      final pageCount = draft.values.pageCount;
      if (pageCount != null && pageCount < 0) {
        return 'Page count cannot be negative';
      }
      final year = draft.values.publicationYear;
      if (year != null && year < 1) {
        return 'Publication year must be greater than zero';
      }
      return null;
    },
    sections: [
      AddSectionSpec<BookAddManualDraft>(
        id: 'edition',
        label: 'Edition',
        fields: [
          LibraryTextFieldSpec<BookAddManualDraft>(
            id: 'number',
            label: 'Number',
            value: (draft) => values(draft).number,
            setValue: (draft, value) => values(draft).number = value,
          ),
          LibraryTextFieldSpec<BookAddManualDraft>(
            id: 'variant',
            label: 'Variant',
            value: (draft) => values(draft).variant,
            setValue: (draft, value) => values(draft).variant = value,
          ),
          ...bookReleaseFields(
            values: values,
            titleLabel: 'Edition title',
            include: {
              'title',
              'format',
              'release_date',
              'publisher',
              'imprint',
              'language',
              'cover_image_url',
            },
            formatOptions: formatOptions ?? BookVocabularies.format.builtIns,
            publisherOptions:
                publisherOptions ?? BookVocabularies.publisher.builtIns,
            onManageFormat: onManageFormat,
            onManagePublisher: onManagePublisher,
          ),
          LibraryTextFieldSpec<BookAddManualDraft>(
            id: 'barcode',
            label: 'ISBN / Barcode',
            value: (draft) => values(draft).upc,
            setValue: (draft, value) => values(draft).upc = value,
          ),
          LibraryNumberFieldSpec<BookAddManualDraft>(
            id: 'publication_year',
            label: 'Publication year',
            value: (draft) => values(draft).publicationYear?.toDouble(),
            setValue: (draft, value) =>
                values(draft).publicationYear = value?.toInt(),
            minimum: 1,
          ),
        ],
      ),
      AddSectionSpec<BookAddManualDraft>(
        id: 'publication',
        label: 'Publication and metadata',
        fields: [
          LibraryTextFieldSpec<BookAddManualDraft>(
            id: 'series_group',
            label: 'Series group',
            value: (draft) => values(draft).seriesGroup,
            setValue: (draft, value) => values(draft).seriesGroup = value,
          ),
          ...bookReleaseFields(
            values: values,
            include: {'distributor', 'page_count'},
          ),
          LibraryTextFieldSpec<BookAddManualDraft>(
            id: 'authors',
            label: 'Authors',
            value: (draft) => values(draft).authors,
            setValue: (draft, value) => values(draft).authors = value,
          ),
          LibraryTextFieldSpec<BookAddManualDraft>(
            id: 'characters',
            label: 'Characters',
            value: (draft) => values(draft).characters,
            setValue: (draft, value) => values(draft).characters = value,
          ),
          ...bookWorkPublicationFields(
            values: values,
            include: {'genres'},
          ),
          LibraryTextFieldSpec<BookAddManualDraft>(
            id: 'age_rating',
            label: 'Age rating',
            value: (draft) => values(draft).ageRating,
            setValue: (draft, value) => values(draft).ageRating = value,
          ),
          LibraryTextFieldSpec<BookAddManualDraft>(
            id: 'country',
            label: 'Country',
            value: (draft) => values(draft).country,
            setValue: (draft, value) => values(draft).country = value,
          ),
          ...bookWorkFields(
            values: values,
            include: {'description'},
            descriptionLabel: 'Synopsis',
          ),
          LibraryTextFieldSpec<BookAddManualDraft>(
            id: 'back_cover_image_url',
            label: 'Back cover image URL',
            value: (draft) => values(draft).backCoverImageUrl,
            setValue: (draft, value) => values(draft).backCoverImageUrl = value,
          ),
        ],
      ),
    ],
  );
}
