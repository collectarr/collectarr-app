import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';

final AddSchema<MusicAddManualDraft> musicAddSchema = musicAddSchemaFor();

AddSchema<MusicAddManualDraft> musicAddSchemaFor({
  Iterable<String>? formatOptions,
  Iterable<String>? genreOptions,
  Iterable<String>? countryOptions,
  Iterable<String>? recordLabelOptions,
  Iterable<String>? packagingOptions,
  FutureOr<void> Function()? onManageFormat,
  FutureOr<void> Function()? onManageCountry,
  FutureOr<void> Function()? onManageRecordLabel,
  FutureOr<void> Function()? onManagePackaging,
}) =>
    AddSchema<MusicAddManualDraft>(
      title: (_) => 'Manual music release',
      validate: (draft) {
        if (draft.year != null && draft.year! < 1) {
          return 'Release year must be greater than zero';
        }
        return null;
      },
      sections: [
        AddSectionSpec<MusicAddManualDraft>(
          id: 'release_group',
          label: 'Album & artist',
          fields: musicReleaseGroupFields(
            values: (draft) => draft.releaseGroup,
            include: {'artist', 'genres', 'cover_image_url'},
            genreOptions: genreOptions ?? MusicVocabularies.genre.builtIns,
          ),
        ),
        AddSectionSpec<MusicAddManualDraft>(
          id: 'release',
          label: 'Release & label',
          fields: [
            ...musicReleaseFields(
              values: (draft) => draft.release,
              include: {
                'title',
                'format',
                'packaging',
                'catalog_number',
                'barcode',
                'country',
                'release_date',
                'record_label',
                'language',
              },
              formatOptions: formatOptions ?? MusicVocabularies.format.builtIns,
              countryOptions:
                  countryOptions ?? MusicVocabularies.country.builtIns,
              recordLabelOptions:
                  recordLabelOptions ?? MusicVocabularies.recordLabel.builtIns,
              packagingOptions:
                  packagingOptions ?? MusicVocabularies.packaging.builtIns,
              onManageFormat: onManageFormat,
              onManageCountry: onManageCountry,
              onManageRecordLabel: onManageRecordLabel,
              onManagePackaging: onManagePackaging,
            ),
            LibraryNumberFieldSpec<MusicAddManualDraft>(
              id: 'year',
              label: 'Year',
              value: (draft) => draft.year,
              setValue: (draft, value) => draft.year = value?.toInt(),
              minimum: 1,
            ),
          ],
        ),
      ],
    );
