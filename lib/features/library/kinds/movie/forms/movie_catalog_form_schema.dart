import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_field_specs.dart';

/// Builds one tab's fields from the same Movie field definitions used by Add
/// and Edit.
AddSchema<TDraft> movieCatalogFormSchemaFor<TDraft>({
  required MovieFormValuesReader<TDraft> values,
  required Set<String> fieldIds,
  required String sectionLabel,
  Iterable<String>? formatOptions,
  Iterable<String>? genreOptions,
  Iterable<String>? regionOptions,
  Iterable<String>? distributorOptions,
  Iterable<String>? audioTrackOptions,
  Iterable<String>? subtitleOptions,
  FutureOr<void> Function()? onManageFormat,
  FutureOr<void> Function()? onManageRegion,
  FutureOr<void> Function()? onManageDistributor,
}) {
  final fields = movieCatalogItemFields<TDraft>(
    values: values,
    formatOptions: formatOptions,
    genreOptions: genreOptions,
    regionOptions: regionOptions,
    distributorOptions: distributorOptions,
    audioTrackOptions: audioTrackOptions,
    subtitleOptions: subtitleOptions,
    onManageFormat: onManageFormat,
    onManageRegion: onManageRegion,
    onManageDistributor: onManageDistributor,
  ).where((field) => fieldIds.contains(field.id));

  return AddSchema<TDraft>(
    sections: [
      AddSectionSpec<TDraft>(
        id: 'catalog_item',
        label: sectionLabel,
        fields: fields.toList(growable: false),
        fullWidthFieldIds: const {
          'catalog_title',
          'synopsis',
          movieCoverImageUrlFieldId,
        },
      ),
    ],
  );
}
