import 'dart:async';

import 'package:collectarr_app/features/library/forms/library_form_schema.dart';
import 'package:collectarr_app/features/library/add/schema/library_add_catalog_title_field.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_form_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_person_credits_field.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';

final LibraryFormSchema<BookCatalogFormDraft> bookAddSchema =
    bookAddSchemaFor();

LibraryFormSchema<TDraft>
    bookAddSchemaFor<TDraft extends BookCatalogFormDraft>({
  Set<String>? fieldIds,
  Map<String, String> sectionLabels = const {},
  Iterable<String>? publisherOptions,
  Iterable<String>? formatOptions,
  FutureOr<void> Function()? onManagePublisher,
  FutureOr<void> Function()? onManageFormat,
}) {
  BookCatalogFormValues values(TDraft draft) => draft.values;

  return LibraryFormSchema<TDraft>(
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
    sections: _filterSections(fieldIds, sectionLabels, [
      LibraryFormSectionSpec<TDraft>(
        id: 'edition',
        label: 'Edition',
        fields: [
          libraryAddCatalogTitleField<TDraft>(),
          ...bookCatalogIdentityFields(
            values: values,
            include: {
              'sort_title',
              'subtitle',
              'original_title',
              'localized_title',
            },
          ),
          LibraryTextFieldSpec<TDraft>(
            id: 'number',
            label: 'Number',
            value: (draft) => values(draft).number,
            setValue: (draft, value) => values(draft).number = value,
          ),
          LibraryTextFieldSpec<TDraft>(
            id: 'variant',
            label: 'Variant',
            value: (draft) => values(draft).variant,
            setValue: (draft, value) => values(draft).variant = value,
          ),
          ...bookCatalogEditionFields(
            values: values,
            titleLabel: 'Edition title',
            include: {
              'title',
              'binding',
              'format',
              'isbn',
              'release_date',
              'publisher',
              'imprint',
              'language',
              'cover_image_url',
              'thumbnail_image_url',
              'region',
              'release_status',
              'edition_statement',
              'dimensions',
              'first_edition',
              'audio_length_minutes',
            },
            formatOptions: formatOptions ?? BookVocabularies.format.builtIns,
            publisherOptions:
                publisherOptions ?? BookVocabularies.publisher.builtIns,
            onManageFormat: onManageFormat,
            onManagePublisher: onManagePublisher,
          ),
          LibraryTextFieldSpec<TDraft>(
            id: 'barcode',
            label: 'Barcode',
            value: (draft) => values(draft).upc,
            setValue: (draft, value) => values(draft).upc = value,
          ),
          LibraryNumberFieldSpec<TDraft>(
            id: 'publication_year',
            label: 'Publication year',
            value: (draft) => values(draft).publicationYear?.toDouble(),
            setValue: (draft, value) =>
                values(draft).publicationYear = value?.toInt(),
            minimum: 1,
          ),
        ],
        fullWidthFieldIds: const {'catalog_title'},
      ),
      LibraryFormSectionSpec<TDraft>(
        id: 'publication',
        label: 'Publication and metadata',
        fields: [
          LibraryTextFieldSpec<TDraft>(
            id: 'series_group',
            label: 'Series group',
            value: (draft) => values(draft).seriesGroup,
            setValue: (draft, value) => values(draft).seriesGroup = value,
          ),
          ...bookCatalogEditionFields(
            values: values,
            include: {'distributor', 'page_count', 'series_title'},
          ),
          LibraryCustomFieldSpec<TDraft>(
            id: 'authors',
            label: 'Authors',
            builder: (context, draft) => BookPersonCreditsField(
              label: 'Authors',
              role: 'Author',
              credits: values(draft).authors,
              onChanged: (credits) => values(draft).authors = credits,
            ),
          ),
          LibraryCustomFieldSpec<TDraft>(
            id: 'translators',
            label: 'Translators',
            builder: (context, draft) => BookPersonCreditsField(
              label: 'Translators',
              role: 'Translator',
              credits: values(draft).translators,
              onChanged: (credits) => values(draft).translators = credits,
            ),
          ),
          LibraryTextFieldSpec<TDraft>(
            id: 'characters',
            label: 'Characters',
            value: (draft) => values(draft).characters,
            setValue: (draft, value) => values(draft).characters = value,
          ),
          ...bookPublicationHistoryFields(
            values: values,
            include: {
              'original_language',
              'first_publication_date',
              'original_publication_date',
              'genres',
              'subjects',
              'search_aliases',
            },
          ),
          LibraryTextFieldSpec<TDraft>(
            id: 'age_rating',
            label: 'Age rating',
            value: (draft) => values(draft).ageRating,
            setValue: (draft, value) => values(draft).ageRating = value,
          ),
          LibraryTextFieldSpec<TDraft>(
            id: 'country',
            label: 'Country',
            value: (draft) => values(draft).country,
            setValue: (draft, value) => values(draft).country = value,
          ),
          ...bookCatalogIdentityFields(
            values: values,
            include: {'description'},
            descriptionLabel: 'Synopsis',
          ),
          LibraryTextFieldSpec<TDraft>(
            id: 'back_cover_image_url',
            label: 'Back cover image URL',
            value: (draft) => values(draft).backCoverImageUrl,
            setValue: (draft, value) => values(draft).backCoverImageUrl = value,
          ),
        ],
      ),
    ]),
  );
}

List<LibraryFormSectionSpec<TDraft>> _filterSections<TDraft>(
  Set<String>? fieldIds,
  Map<String, String> sectionLabels,
  List<LibraryFormSectionSpec<TDraft>> sections,
) {
  if (fieldIds == null && sectionLabels.isEmpty) return sections;
  return [
    for (final section in sections)
      if (section.fields
          .where((field) => fieldIds == null || fieldIds.contains(field.id))
          .isNotEmpty)
        LibraryFormSectionSpec<TDraft>(
          id: section.id,
          label: sectionLabels[section.id] ?? section.label,
          fields: [
            for (final field in section.fields)
              if (fieldIds == null || fieldIds.contains(field.id)) field,
          ],
          maxColumns: section.maxColumns,
          fullWidthFieldIds: section.fullWidthFieldIds,
          fieldColumnSpans: section.fieldColumnSpans,
          rightAlignedFieldIds: section.rightAlignedFieldIds,
          columns: section.columns,
          visibleWhen: section.visibleWhen,
        ),
  ];
}
