import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_form_schema.dart';
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
  final selectedFieldIds = fieldIds ??
      movieAllFieldIds.difference(const {movieCoverImageUrlFieldId});
  final formSchema = movieCatalogFormSchemaFor<MovieAddManualDraft>(
    values: (draft) => draft.values,
    fieldIds: selectedFieldIds,
    sectionLabel: sectionLabel,
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
    sections: formSchema.sections,
  );
}

AddSchema<MovieAddManualDraft> movieCoverAddSchemaFor() {
  return movieCatalogFormSchemaFor<MovieAddManualDraft>(
    values: (draft) => draft.values,
    fieldIds: const {movieCoverImageUrlFieldId},
    sectionLabel: 'Cover',
  );
}
