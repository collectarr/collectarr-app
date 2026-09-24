import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/movie/vocabulary/movie_vocabularies.dart';

final AddSchema<MovieAddManualDraft> movieAddSchema = movieAddSchemaFor();

AddSchema<MovieAddManualDraft> movieAddSchemaFor({
  Iterable<String>? formatOptions,
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
        id: 'release',
        label: 'Release',
        fields: [
          ...movieReleaseIdentityFields(
            values: getValues,
            formatOptions:
                formatOptions ?? MovieVocabularies.physicalFormat.builtIns,
            regionOptions: regionOptions ?? MovieVocabularies.region.builtIns,
            onManageFormat: onManageFormat,
            onManageRegion: onManageRegion,
          ),
          ...movieReleasePublishingFields(
            values: getValues,
            distributorOptions:
                distributorOptions ?? MovieVocabularies.distributor.builtIns,
            onManageDistributor: onManageDistributor,
          ),
        ],
      ),
      AddSectionSpec<MovieAddManualDraft>(
        id: 'work',
        label: 'Movie metadata',
        fields: [
          ...movieWorkIdentityFields(values: getValues, includeTitle: false),
          ...movieWorkClassificationFields(values: getValues),
        ],
      ),
    ],
  );
}
