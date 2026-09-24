import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/manga/forms/manga_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/manga/forms/manga_catalog_form_values.dart';

final EditSchema<CatalogEditionDto, MangaCatalogFormValues>
    mangaReleaseEditSchema = EditSchema(
  title: (release) => 'Edit ${release.title}',
  validate: (_, values) {
    if (values.releaseTitle.trim().isEmpty) return 'Edition title is required';
    if (values.pageCount != null && values.pageCount! < 0) {
      return 'Page count must be a non-negative number';
    }
    return null;
  },
  tabs: [
    EditTabSpec<MangaCatalogFormValues>(
      id: 'release',
      label: 'Edition',
      sections: [
        EditSectionSpec<MangaCatalogFormValues>(
          id: 'identity',
          label: 'Identity',
          fields: mangaReleaseFields(
            values: (values) => values,
            include: {
              'release_title',
              'format',
              'binding',
              'language',
              'region',
              'release_date',
            },
          ),
        ),
        EditSectionSpec<MangaCatalogFormValues>(
          id: 'publishing',
          label: 'Publishing and identifiers',
          fields: mangaReleaseFields(
            values: (values) => values,
            include: {
              'publisher',
              'imprint',
              'distributor',
              'isbn',
              'barcode',
              'page_count',
            },
          ),
        ),
        EditSectionSpec<MangaCatalogFormValues>(
          id: 'artwork',
          label: 'Artwork and notes',
          fields: mangaReleaseFields(
            values: (values) => values,
            include: {'release_description', 'cover_image_url'},
          ),
        ),
      ],
    ),
  ],
);
