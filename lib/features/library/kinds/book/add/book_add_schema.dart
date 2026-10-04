import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_person_credits_field.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';

final AddSchema<BookAddManualDraft> bookAddSchema = bookAddSchemaFor();

AddSchema<BookAddManualDraft> bookAddSchemaFor({
  Set<String>? fieldIds,
  Map<String, String> sectionLabels = const {},
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
    sections: _filterSections(fieldIds, sectionLabels, [
      AddSectionSpec<BookAddManualDraft>(
        id: 'edition',
        label: 'Edition',
        fields: [
          libraryAddCatalogTitleField<BookAddManualDraft>(),
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
          ...bookCatalogEditionFields(
            values: values,
            titleLabel: 'Edition title',
            include: {
              'title',
              'format',
              'isbn',
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
            label: 'Barcode',
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
        fullWidthFieldIds: const {'catalog_title'},
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
          ...bookCatalogEditionFields(
            values: values,
            include: {'distributor', 'page_count'},
          ),
          LibraryCustomFieldSpec<BookAddManualDraft>(
            id: 'authors',
            label: 'Authors',
            builder: (context, draft) => BookPersonCreditsField(
              label: 'Authors',
              role: 'Author',
              credits: values(draft).authors,
              onChanged: (credits) => values(draft).authors = credits,
            ),
          ),
          LibraryCustomFieldSpec<BookAddManualDraft>(
            id: 'translators',
            label: 'Translators',
            builder: (context, draft) => BookPersonCreditsField(
              label: 'Translators',
              role: 'Translator',
              credits: values(draft).translators,
              onChanged: (credits) => values(draft).translators = credits,
            ),
          ),
          LibraryTextFieldSpec<BookAddManualDraft>(
            id: 'characters',
            label: 'Characters',
            value: (draft) => values(draft).characters,
            setValue: (draft, value) => values(draft).characters = value,
          ),
          ...bookPublicationHistoryFields(
            values: values,
            include: {'genres', 'subjects'},
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
          ...bookCatalogIdentityFields(
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
    ]),
  );
}

List<AddSectionSpec<BookAddManualDraft>> _filterSections(
  Set<String>? fieldIds,
  Map<String, String> sectionLabels,
  List<AddSectionSpec<BookAddManualDraft>> sections,
) {
  if (fieldIds == null && sectionLabels.isEmpty) return sections;
  return [
    for (final section in sections)
      if (section.fields
          .where((field) => fieldIds == null || fieldIds.contains(field.id))
          .isNotEmpty)
        AddSectionSpec<BookAddManualDraft>(
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
          visibleWhen: section.visibleWhen,
        ),
  ];
}
