import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_values.dart';

final AddSchema<GameAddManualDraft> gameAddSchema = gameAddSchemaFor();

AddSchema<GameAddManualDraft> gameAddSchemaFor({
  Set<String>? fieldIds,
  Map<String, String> sectionLabels = const {},
  Iterable<String>? platformOptions,
  Iterable<String>? editionOptions,
  Iterable<String>? ageRatingOptions,
  Iterable<String>? regionOptions,
  FutureOr<void> Function()? onManagePlatform,
  FutureOr<void> Function()? onManageEdition,
}) {
  GameCatalogFormValues values(GameAddManualDraft draft) => draft.values;

  return AddSchema<GameAddManualDraft>(
    title: (_) => 'Manual game',
    validate: (draft) {
      final year = draft.values.releaseYear;
      if (year != null && year < 1) return 'Release year must be positive';
      return null;
    },
    sections: _filterSections(fieldIds, sectionLabels, [
      AddSectionSpec<GameAddManualDraft>(
        id: 'catalog_item',
        label: 'Catalog Item',
        fields: [
          libraryAddCatalogTitleField<GameAddManualDraft>(),
          ...gameCatalogItemFields(
            values: values,
            include: {
              'edition_title',
              'platform',
              'region',
              'format',
              'release_date',
              'catalog_number',
              'barcode',
              'cover_image_url',
              'release_year',
              'variant',
              'back_cover_image_url',
            },
            platformOptions: platformOptions,
            regionOptions: regionOptions,
            formatOptions: editionOptions,
            onManagePlatform: onManagePlatform,
            onManageFormat: onManageEdition,
          ),
        ],
        fullWidthFieldIds: const {'catalog_title'},
      ),
      AddSectionSpec<GameAddManualDraft>(
        id: 'game_details',
        label: 'Game Details',
        fields: gameMetadataFields(
          values: values,
          ageRatingOptions: ageRatingOptions,
          include: {
            'publisher',
            'sort_title',
            'subtitle',
            'identifiers',
            'company_roles',
            'search_aliases',
            'original_language',
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

List<AddSectionSpec<GameAddManualDraft>> _filterSections(
  Set<String>? fieldIds,
  Map<String, String> sectionLabels,
  List<AddSectionSpec<GameAddManualDraft>> sections,
) {
  if (fieldIds == null && sectionLabels.isEmpty) return sections;
  return [
    for (final section in sections)
      if (section.fields
          .where((field) => fieldIds == null || fieldIds.contains(field.id))
          .isNotEmpty)
        AddSectionSpec<GameAddManualDraft>(
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
