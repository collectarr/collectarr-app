import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/forms/tv_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/tv/vocabulary/tv_vocabularies.dart';

final AddSchema<TvAddManualDraft> tvAddSchema = tvAddSchemaFor();

AddSchema<TvAddManualDraft> tvAddSchemaFor({
  Iterable<String>? formatOptions,
  Iterable<String>? regionOptions,
  Iterable<String>? networkOptions,
  FutureOr<void> Function()? onManageFormat,
  FutureOr<void> Function()? onManageRegion,
  FutureOr<void> Function()? onManageNetwork,
}) {
  return AddSchema<TvAddManualDraft>(
    title: (_) => 'Manual TV show',
    validate: (draft) {
      if (draft.seasonNumber != null && draft.seasonNumber! < 0) {
        return 'Season number cannot be negative';
      }
      if (draft.firstAirYear != null && draft.firstAirYear! < 0) {
        return 'First air year cannot be negative';
      }
      return null;
    },
    sections: [
      AddSectionSpec<TvAddManualDraft>(
        id: 'series',
        label: 'Series',
        fields: [
          ...tvSeriesIdentityFields(
            values: (draft) => draft.series,
            includeTitle: false,
          ),
          ...tvSeriesBroadcastFields(
            values: (draft) => draft.series,
            networkOptions: networkOptions ?? TvVocabularies.network.builtIns,
            onManageNetwork: onManageNetwork,
          ),
          ...tvSeriesClassificationFields(values: (draft) => draft.series),
          ..._seasonFields(),
        ],
      ),
      AddSectionSpec<TvAddManualDraft>(
        id: 'release',
        label: 'Release',
        fields: [
          ...tvReleaseIdentityFields(
            values: (draft) => draft.release,
            formatOptions:
                formatOptions ?? TvVocabularies.physicalFormat.builtIns,
            regionOptions: regionOptions ?? TvVocabularies.region.builtIns,
            onManageFormat: onManageFormat,
            onManageRegion: onManageRegion,
          ),
          ...tvReleasePublishingFields(values: (draft) => draft.release),
        ],
      ),
      AddSectionSpec<TvAddManualDraft>(
        id: 'metadata',
        label: 'Metadata',
        fields: [
          ..._creatorsAndCharacters((draft) => draft.series),
        ],
      ),
    ],
  );
}

List<LibraryFieldSpec<TvAddManualDraft>> _seasonFields() => [
      LibraryNumberFieldSpec<TvAddManualDraft>(
        id: 'season_number',
        label: 'Season number',
        value: (draft) => draft.seasonNumber,
        setValue: (draft, value) => draft.seasonNumber = value?.toInt(),
        minimum: 0,
      ),
      LibraryNumberFieldSpec<TvAddManualDraft>(
        id: 'first_air_year',
        label: 'First air year',
        value: (draft) => draft.firstAirYear,
        setValue: (draft, value) => draft.firstAirYear = value?.toInt(),
        minimum: 0,
      ),
    ];

List<LibraryFieldSpec<TvAddManualDraft>> _creatorsAndCharacters(
  TvSeriesValuesReader<TvAddManualDraft> values,
) =>
    [
      LibraryTextFieldSpec<TvAddManualDraft>(
        id: 'creators',
        label: 'Cast / crew',
        value: (draft) => values(draft).creators.join(', '),
        setValue: (draft, value) => values(draft).creators = _split(value),
      ),
      LibraryTextFieldSpec<TvAddManualDraft>(
        id: 'characters',
        label: 'Characters',
        value: (draft) => values(draft).characters.join(', '),
        setValue: (draft, value) => values(draft).characters = _split(value),
      ),
    ];

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);
