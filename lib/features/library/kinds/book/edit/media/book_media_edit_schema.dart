import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_media.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_form_values.dart';
import 'package:flutter/material.dart';

final EditSchema<BookMedia, BookCatalogFormValues> bookMediaEditSchema =
    EditSchema(
  title: (_) => 'Edit book media',
  validate: (_, values) =>
      values.title.trim().isEmpty ? 'Book title is required' : null,
  tabs: [
    EditTabSpec<BookCatalogFormValues>(
      id: 'identity',
      label: 'Identity',
      icon: Icons.title,
      sections: [
        EditSectionSpec<BookCatalogFormValues>(
          id: 'titles',
          label: 'Titles',
          fields: bookWorkFields(values: (values) => values),
        ),
      ],
    ),
    EditTabSpec<BookCatalogFormValues>(
      id: 'publication',
      label: 'Publication',
      icon: Icons.menu_book,
      sections: [
        EditSectionSpec<BookCatalogFormValues>(
          id: 'details',
          label: 'Publication details',
          fields: bookWorkPublicationFields(values: (values) => values),
        ),
      ],
    ),
  ],
);
