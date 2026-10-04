import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/movie/vocabulary/movie_vocabularies.dart';

final AddSchema<MovieAddManualDraft> movieAddSchema = movieAddSchemaFor();

AddSchema<MovieAddManualDraft> movieAddSchemaFor({
  Iterable<String>? formatOptions,
  Iterable<String>? genreOptions,
  Iterable<String>? regionOptions,
  Iterable<String>? distributorOptions,
  FutureOr<void> Function()? onManageFormat,
  FutureOr<void> Function()? onManageRegion,
  FutureOr<void> Function()? onManageDistributor,
}) {
  MovieCatalogFormValues getValues(MovieAddManualDraft draft) => draft.values;
  return AddSchema<MovieAddManualDraft>(
    title: (_) => 'Manual movie',
    validate: (draft) {
      final year = draft.values.releaseYear;
      if (year != null && year < 1) {
        return 'Release year must be greater than zero';
      }
      return null;
    },
    sections: [
      AddSectionSpec<MovieAddManualDraft>(
        id: 'catalog_item',
        label: 'Catalog Item',
        fields: movieCatalogItemFields(
          values: getValues,
          genreOptions:
              genreOptions ?? MovieVocabularies.genre.builtIns,
          formatOptions:
              formatOptions ?? MovieVocabularies.physicalFormat.builtIns,
          regionOptions: regionOptions ?? MovieVocabularies.region.builtIns,
          distributorOptions:
              distributorOptions ?? MovieVocabularies.distributor.builtIns,
          onManageFormat: onManageFormat,
          onManageRegion: onManageRegion,
          onManageDistributor: onManageDistributor,
        ),
      ),
    ],
  );
}
