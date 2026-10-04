import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_catalog_field_specs.dart';

final AddSchema<MusicAddManualDraft> musicAddSchema = musicAddSchemaFor();

AddSchema<MusicAddManualDraft> musicAddSchemaFor({
  Iterable<String>? formatOptions,
  Iterable<String>? genreOptions,
  Iterable<String>? countryOptions,
  Iterable<String>? recordLabelOptions,
  Iterable<String>? packagingOptions,
  Iterable<String>? studioOptions,
  Iterable<String>? soundTypeOptions,
  FutureOr<void> Function()? onManageFormat,
  FutureOr<void> Function()? onManageCountry,
  FutureOr<void> Function()? onManageRecordLabel,
  FutureOr<void> Function()? onManagePackaging,
}) {
  final sharedFields = musicAlbumFields<MusicAddManualDraft>(
    values: (draft) => draft.values,
    formatOptions: formatOptions,
    genreOptions: genreOptions,
    countryOptions: countryOptions,
    recordLabelOptions: recordLabelOptions,
    packagingOptions: packagingOptions,
    studioOptions: studioOptions,
    soundTypeOptions: soundTypeOptions,
    onManageFormat: onManageFormat,
    onManageCountry: onManageCountry,
    onManageRecordLabel: onManageRecordLabel,
    onManagePackaging: onManagePackaging,
  );
  return AddSchema<MusicAddManualDraft>(
    title: (_) => 'Manual music album',
    validate: (draft) {
      if (draft.releaseDateParts?.year case final year? when year < 1) {
        return 'Release year must be greater than zero';
      }
      if (draft.discs.any(
        (disc) => disc.tracks.any(
          (track) =>
              track.duration.trim().isNotEmpty && track.durationMs == null,
        ),
      )) {
        return 'Track lengths must use MM:SS or HH:MM:SS';
      }
      return null;
    },
    sections: [
      AddSectionSpec<MusicAddManualDraft>(
        id: 'album',
        label: 'Album details',
        fullWidthFieldIds: const {'catalog_title'},
        fields: [
          libraryAddCatalogTitleField<MusicAddManualDraft>(),
          for (final field in sharedFields)
            if (field.id != 'title' &&
                field.id != 'cover_image_url' &&
                field.id != 'back_cover_image_url')
              field,
        ],
      ),
    ],
  );
}
