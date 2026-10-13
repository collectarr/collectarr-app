import 'dart:async';

import 'package:collectarr_app/features/library/forms/library_form_schema.dart';
import 'package:collectarr_app/features/library/add/schema/library_add_catalog_title_field.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_field_identities.dart';

final LibraryFormSchema<MusicAddManualDraft> musicAddSchema =
    musicAddSchemaFor();

LibraryFormSchema<MusicAddManualDraft> musicAddSchemaFor({
  Iterable<String>? formatOptions,
  Iterable<String>? genreOptions,
  Iterable<String>? countryOptions,
  Iterable<String>? recordLabelOptions,
  Iterable<String>? packagingOptions,
  Iterable<String>? soundTypeOptions,
  FutureOr<void> Function()? onManageFormat,
  FutureOr<void> Function()? onManageCountry,
  FutureOr<void> Function()? onManageRecordLabel,
  FutureOr<void> Function()? onManagePackaging,
}) {
  final sharedFields = musicAlbumFields<MusicAddManualDraft>(
    values: (draft) => draft.values,
    formatSummary: (draft) =>
        formatDiscsSummary(draft.discs.map((d) => d.format)),
    formatOptions: formatOptions,
    genreOptions: genreOptions,
    countryOptions: countryOptions,
    recordLabelOptions: recordLabelOptions,
    packagingOptions: packagingOptions,
    soundTypeOptions: soundTypeOptions,
    onManageFormat: onManageFormat,
    onManageCountry: onManageCountry,
    onManageRecordLabel: onManageRecordLabel,
    onManagePackaging: onManagePackaging,
  );
  return LibraryFormSchema<MusicAddManualDraft>(
    title: (_) => 'Manual music album',
    validate: (draft) {
      if (draft.discs.any(
        (disc) => disc.format.trim().isNotEmpty && disc.formatFamily == null,
      )) {
        return 'Choose a family for each custom disc format';
      }
      if (draft.releaseDateParts?.year case final year? when year < 1) {
        return 'Release year must be greater than zero';
      }
      if (draft.discs.any(
        (disc) => disc.tracks.any(
          (track) =>
              track.duration.trim().isNotEmpty && track.durationMs == null,
        ),
      )) {
        return 'Track lengths must use seconds, MM:SS, or HH:MM:SS';
      }
      return null;
    },
    sections: [
      LibraryFormSectionSpec<MusicAddManualDraft>(
        id: 'album',
        label: 'Album details',
        fullWidthFieldIds: const {'catalog_title'},
        fields: [
          libraryAddCatalogTitleField<MusicAddManualDraft>(
              actions: musicTitleActions),
          for (final field in sharedFields)
            if (field.id != MusicFieldIdentities.titleId &&
                field.id != 'cover_image_url' &&
                field.id != 'back_cover_image_url')
              field,
        ],
      ),
    ],
  );
}
