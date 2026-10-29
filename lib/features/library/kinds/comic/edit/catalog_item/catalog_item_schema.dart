import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/serial/library_series_selector_field.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/config/comic_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/catalog_form_values.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import '../../forms/catalog_form_layout.dart';
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

List<LibraryFieldSpec<ComicCatalogItemFormValues>> _fields(List<String> ids) {
  final fields = {
    for (final field in [
      ..._comicIdentityFieldsWithSeriesSelector(),
      ...comicCatalogItemPublicationFields<ComicCatalogItemFormValues>(
          values: (values) => values),
    ])
      field.id: field,
  };
  return [for (final id in ids) fields[id]!];
}

final EditSchema<ComicCatalogItem, ComicCatalogItemFormValues>
    comicCatalogItemEditSchema = EditSchema(
  title: (_) => 'Edit comic',
  validate: (_, values) => validateComicCatalogItem(values),
  tabs: [
    EditTabSpec<ComicCatalogItemFormValues>(
      id: 'main',
      label: 'Main',
      icon: AppIcons.book,
      sections: [
        LibraryFormSectionSpec(
          id: 'issue',
          label: '',
          columns: comicMainColumns,
          fields: _fields(const [
            'comic.series',
            'barcode',
            'physical_format',
            'series_group',
            'comic.issue_number',
            'comic.variant',
            'variant_description',
            'cover_date',
            'release_date',
            'publisher',
            'comic.imprint'
          ]),
        )
      ],
    ),
    EditTabSpec<ComicCatalogItemFormValues>(
      id: 'details',
      label: 'Details',
      icon: AppIcons.tabDetails,
      sections: [
        LibraryFormSectionSpec(
          id: 'publication',
          label: '',
          columns: comicDetailsColumns('title'),
          fields: _fields(const [
            'crossover',
            'story_arcs',
            'title',
            'subtitle',
            'country',
            'language',
            'publication_age',
            'comic.page_count',
            'genres',
            'age_rating',
            'edition_title',
            'isbn',
            'upc'
          ]),
        )
      ],
    ),
  ],
);
