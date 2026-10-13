import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/serial/library_series_selector_field.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/config/comic_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_catalog_form_values.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

List<LibraryFieldSpec<ComicCatalogItemFormValues>>
    _comicIdentityFieldsWithSeriesSelector() {
  final identityFields =
      comicCatalogItemIdentityFields<ComicCatalogItemFormValues>(
    values: (values) => values,
    includeSeries: false,
  );
  return [
    identityFields.first,
    LibraryCustomFieldSpec<ComicCatalogItemFormValues>(
      id: ComicFieldIdentities.seriesId,
      label: ComicFieldIdentities.seriesLabel,
      builder: (context, draft) => Consumer(
        builder: (context, ref, _) => LibrarySeriesSelectorField(
          database: ref.read(localDatabaseProvider),
          mediaKind: CatalogMediaKind.comic.apiValue,
          initialTitle: draft.seriesTitle,
          initialSeriesId: draft.seriesId,
          onChanged: (title, seriesId) {
            draft
              ..seriesTitle = title
              ..seriesId = seriesId;
          },
        ),
      ),
    ),
    ...identityFields.skip(1),
  ];
}

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
          fields: _comicIdentityFieldsWithSeriesSelector(),
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
