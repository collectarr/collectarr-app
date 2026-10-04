import 'dart:async';

import 'package:collectarr_app/features/library/schema/library_form_schema.dart';
import 'package:collectarr_app/features/library/add/schema/library_add_catalog_title_field.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_values.dart';

final LibraryFormSchema<GameCatalogFormDraft> gameAddSchema = gameAddSchemaFor();

LibraryFormSchema<TDraft> gameAddSchemaFor<TDraft extends GameCatalogFormDraft>({
  Set<String>? fieldIds,
  Map<String, String> sectionLabels = const {},
  Iterable<String>? platformOptions,
  Iterable<String>? editionOptions,
  String? Function(String value)? physicalFormatIdForValue,
  Iterable<String>? ageRatingOptions,
  Iterable<String>? regionOptions,
  FutureOr<void> Function()? onManageEdition,
}) {
  GameCatalogFormValues values(TDraft draft) => draft.values;

  return LibraryFormSchema<TDraft>(
    title: (_) => 'Manual game',
    validate: (draft) {
      final year = draft.values.releaseYear;
      if (year != null && year < 1) return 'Release year must be positive';
      return null;
    },
    sections: _filterSections(fieldIds, sectionLabels, [
      LibraryFormSectionSpec<TDraft>(
        id: 'catalog_item',
        label: 'Catalog Item',
        fields: [
          libraryAddCatalogTitleField<TDraft>(),
          ...gameCatalogItemFields(
            values: values,
            include: {
              'edition_title',
              'region',
              'format',
              'release_date',
              'catalog_number',
              'barcode',
              'cover_image_url',
              'thumbnail_image_url',
              'release_year',
              'variant',
            },
            regionOptions: regionOptions,
            formatOptions: editionOptions,
            physicalFormatIdForValue: physicalFormatIdForValue,
            onManageFormat: onManageEdition,
          ),
        ],
        fullWidthFieldIds: const {'catalog_title'},
      ),
      LibraryFormSectionSpec<TDraft>(
        id: 'game_details',
        label: 'Game Details',
        fields: gameMetadataFields(
          values: values,
          ageRatingOptions: ageRatingOptions,
          platformOptions: platformOptions,
          include: {
            'display_title',
            'publisher',
            'original_title',
            'localized_title',
            'sort_title',
            'subtitle',
            'identifiers',
            'company_roles',
            'search_aliases',
            'original_language',
            'platforms',
            'developers',
            'genres',
            'age_ratings',
            'languages',
            'country',
            'franchise',
            'series',
            'description',
          },
        ),
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
          visibleWhen: section.visibleWhen,
        ),
  ];
}
