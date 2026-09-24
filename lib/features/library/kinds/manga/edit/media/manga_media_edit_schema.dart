import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_media.dart';
import 'package:collectarr_app/features/library/kinds/manga/forms/manga_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/manga/forms/manga_catalog_form_values.dart';
import 'package:flutter/material.dart';

final EditSchema<MangaMedia, MangaCatalogFormValues> mangaMediaEditSchema =
    EditSchema(
  title: (_) => 'Edit manga',
  validate: (_, values) =>
      values.title.trim().isEmpty ? 'Manga title is required' : null,
  tabs: [
    EditTabSpec<MangaCatalogFormValues>(
      id: 'identity',
      label: 'Identity',
      icon: Icons.title,
      sections: [
        EditSectionSpec<MangaCatalogFormValues>(
          id: 'titles',
          label: 'Titles',
          fields: mangaWorkFields(
            values: (values) => values,
          ),
        ),
      ],
    ),
    EditTabSpec<MangaCatalogFormValues>(
      id: 'publication',
      label: 'Publication',
      icon: Icons.menu_book,
      sections: [
        EditSectionSpec<MangaCatalogFormValues>(
          id: 'details',
          label: 'Publication details',
          fields: mangaPublicationFields(
            values: (values) => values,
          ),
        ),
      ],
    ),
  ],
);
