import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_catalog_form_values.dart';
import 'package:flutter/material.dart';

final EditSchema<ComicCatalogItem, ComicCatalogItemFormValues>
    comicCatalogItemEditSchema = EditSchema(
  title: (_) => 'Edit comic',
  validate: (_, values) => validateComicCatalogItem(values),
  tabs: [
    EditTabSpec<ComicCatalogItemFormValues>(
      id: 'main',
      label: 'Main',
      icon: Icons.article,
      sections: [
        LibraryFormSectionSpec<ComicCatalogItemFormValues>(
          id: 'catalog_snapshot',
          label: 'Issue',
          fields: comicCatalogItemIdentityFields(
            values: (values) => values,
          ),
        ),
      ],
    ),
    EditTabSpec<ComicCatalogItemFormValues>(
      id: 'details',
      label: 'Details',
      icon: Icons.search,
      sections: [
        LibraryFormSectionSpec<ComicCatalogItemFormValues>(
          id: 'catalog_details',
          label: 'Publication details',
          fields: [
            for (final field in comicCatalogItemPublicationFields<
                ComicCatalogItemFormValues>(
              values: (values) => values,
            ))
              if (field.id != 'cover_image_url') field,
          ],
        ),
      ],
    ),
    EditTabSpec<ComicCatalogItemFormValues>(
      id: 'covers',
      label: 'Covers',
      icon: Icons.camera_alt_outlined,
      sections: [
        LibraryFormSectionSpec<ComicCatalogItemFormValues>(
          id: 'cover',
          label: 'Cover',
          fields: comicCatalogItemCoverFields<ComicCatalogItemFormValues>(
            values: (values) => values,
          ),
        ),
      ],
    ),
  ],
);
