import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/movie/vocabulary/movie_vocabularies.dart';

final AddSchema<MovieAddManualDraft> movieAddSchema = movieAddSchemaFor();

final AddSchema<MovieAddManualDraft> movieCoverAddSchema =
    movieCoverAddSchemaFor();

AddSchema<MovieAddManualDraft> movieAddSchemaFor({
  Set<String>? fieldIds,
  String sectionLabel = 'Catalog Item',
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
  MovieCatalogFormValues getValues(MovieAddManualDraft draft) => draft.values;
  final fields = movieCatalogItemFields<MovieAddManualDraft>(
    values: getValues,
    genreOptions: genreOptions ?? MovieVocabularies.genre.builtIns,
    formatOptions: formatOptions ?? MovieVocabularies.physicalFormat.builtIns,
    regionOptions: regionOptions ?? MovieVocabularies.region.builtIns,
    distributorOptions:
        distributorOptions ?? MovieVocabularies.distributor.builtIns,
    audioTrackOptions: audioTrackOptions ?? MovieVocabularies.audio.builtIns,
    subtitleOptions: subtitleOptions ?? MovieVocabularies.subtitles.builtIns,
    onManageFormat: onManageFormat,
    onManageRegion: onManageRegion,
    onManageDistributor: onManageDistributor,
  );
  return AddSchema<MovieAddManualDraft>(
    title: (_) => 'Manual movie',
    validate: (draft) {
      final year = draft.values.releaseYear;
      if (year != null && year < 1) {
        return 'Release year must be greater than zero';
      }
      final discs = draft.values.nrDiscs;
      if (discs != null && discs < 1) {
        return 'Disc count must be greater than zero';
      }
      return null;
    },
    sections: [
      AddSectionSpec<MovieAddManualDraft>(
        id: 'catalog_item',
        label: sectionLabel,
        fields: [
          if (fieldIds == null || fieldIds.contains('catalog_title'))
            libraryAddCatalogTitleField<MovieAddManualDraft>(),
          ...fields.where((field) =>
              field.id != movieCoverImageUrlFieldId &&
              (fieldIds == null || fieldIds.contains(field.id))),
        ],
        fullWidthFieldIds: const {'catalog_title'},
      ),
    ],
  );
}

AddSchema<MovieAddManualDraft> movieCoverAddSchemaFor() {
  MovieCatalogFormValues getValues(MovieAddManualDraft draft) => draft.values;
  final coverField = movieCatalogItemFields<MovieAddManualDraft>(
    values: getValues,
  ).singleWhere((field) => field.id == movieCoverImageUrlFieldId);
  return AddSchema<MovieAddManualDraft>(
    sections: [
      AddSectionSpec<MovieAddManualDraft>(
        id: 'cover',
        label: 'Cover',
        fields: [coverField],
      ),
    ],
  );
}
