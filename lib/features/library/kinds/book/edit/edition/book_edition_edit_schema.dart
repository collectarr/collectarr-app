import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_domain.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_form_values.dart';
import 'package:flutter/material.dart';

final EditSchema<BookRelease, BookCatalogFormValues> bookEditionEditSchema =
    EditSchema(
  title: (release) => 'Edit ${release.title}',
  validate: (_, values) {
    if (values.editionTitle.trim().isEmpty) return 'Edition title is required';
    if (values.pageCount != null && values.pageCount! < 0) {
      return 'Page count cannot be negative';
    }
    if (values.audioLengthMinutes != null && values.audioLengthMinutes! < 0) {
      return 'Audio length cannot be negative';
    }
    return null;
  },
  tabs: [
    EditTabSpec<BookCatalogFormValues>(
      id: 'edition',
      label: 'Edition',
      icon: Icons.menu_book,
      sections: [
        EditSectionSpec<BookCatalogFormValues>(
          id: 'identity',
          label: 'Identity',
          fields: bookReleaseFields(
            values: (values) => values,
            include: {'title', 'binding', 'format', 'isbn', 'upc'},
          ),
        ),
      ],
    ),
    EditTabSpec<BookCatalogFormValues>(
      id: 'publication',
      label: 'Publication',
      icon: Icons.public,
      sections: [
        EditSectionSpec<BookCatalogFormValues>(
          id: 'publication_details',
          label: 'Publication details',
          fields: bookReleaseFields(
            values: (values) => values,
            include: {
              'publisher',
              'distributor',
              'imprint',
              'release_date',
              'page_count',
              'language',
              'region',
              'release_status',
            },
          ),
        ),
      ],
    ),
    EditTabSpec<BookCatalogFormValues>(
      id: 'details',
      label: 'Details',
      icon: Icons.info_outline,
      sections: [
        EditSectionSpec<BookCatalogFormValues>(
          id: 'additional_details',
          label: 'Additional details',
          fields: bookReleaseFields(
            values: (values) => values,
            include: {
              'edition_statement',
              'dimensions',
              'description',
              'first_edition',
              'audio_length_minutes',
              'cover_image_url',
              'thumbnail_image_url',
            },
          ),
        ),
      ],
    ),
  ],
);
