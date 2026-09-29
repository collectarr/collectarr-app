import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/music_country_name.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/core/models/partial_date.dart';

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
}) =>
    AddSchema<MusicAddManualDraft>(
      title: (_) => 'Manual music album',
      validate: (draft) {
        if ((draft.releaseDate?.year ?? draft.releaseDateParts?.year)
            case final year? when year < 1) {
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
          fields: [
            LibraryTextFieldSpec<MusicAddManualDraft>(
              id: 'sort_title',
              label: 'Sort Title',
              value: (draft) => draft.sortTitle,
              setValue: (draft, value) => draft.sortTitle = value,
            ),
            LibraryTextFieldSpec<MusicAddManualDraft>(
              id: 'subtitle',
              label: 'Subtitle',
              value: (draft) => draft.subtitle,
              setValue: (draft, value) => draft.subtitle = value,
            ),
            LibraryTextFieldSpec<MusicAddManualDraft>(
              id: 'artist',
              label: 'Artist',
              value: (draft) => draft.artist,
              setValue: (draft, value) => draft.artist = value,
            ),
            LibraryMultiVocabularyFieldSpec<MusicAddManualDraft, String>(
              id: 'genres',
              label: 'Genre',
              pickListKey: MusicVocabularyIds.genre.value,
              pluralLabel: 'Genres',
              values: (draft) => draft.genres.toSet(),
              setValues: (draft, next) =>
                  draft.genres = next.toList(growable: false),
              options:
                  _options(genreOptions ?? MusicVocabularies.genre.builtIns),
            ),
            LibraryMultiVocabularyFieldSpec<MusicAddManualDraft, String>(
              id: 'studios',
              label: 'Studio',
              pickListKey: MusicVocabularyIds.studio.value,
              pluralLabel: 'Studios',
              values: (draft) => draft.studios.toSet(),
              setValues: (draft, values) =>
                  draft.studios = values.toList(growable: false),
              options: _options(
                studioOptions ?? MusicVocabularies.studio.builtIns,
              ),
            ),
            LibraryPartialDateFieldSpec<MusicAddManualDraft>(
              id: 'release_date',
              label: 'Release Date',
              value: (draft) =>
                  draft.releaseDateParts ?? _partsFromDate(draft.releaseDate),
              setValue: (draft, value) {
                draft.releaseDateParts = value;
                draft.releaseDate = value?.asDateTime;
              },
            ),
            LibraryPartialDateFieldSpec<MusicAddManualDraft>(
              id: 'original_release_date',
              label: 'Original Release Date',
              value: (draft) =>
                  draft.originalReleaseDateParts ??
                  _partsFromDate(draft.originalReleaseDate),
              setValue: (draft, value) {
                draft.originalReleaseDateParts = value;
                draft.originalReleaseDate = value?.asDateTime;
              },
            ),
            LibraryPartialDateFieldSpec<MusicAddManualDraft>(
              id: 'recording_date',
              label: 'Recording Date',
              value: (draft) =>
                  draft.recordingDateParts ??
                  _partsFromDate(draft.recordingDate),
              setValue: (draft, value) {
                draft.recordingDateParts = value;
                draft.recordingDate = value?.asDateTime;
              },
            ),
          ],
        ),
        AddSectionSpec<MusicAddManualDraft>(
          id: 'edition',
          label: 'Edition details',
          fields: [
            LibraryVocabularyFieldSpec<MusicAddManualDraft, String>(
              id: 'record_label',
              label: 'Label',
              value: (draft) => _nullable(draft.recordLabel),
              setValue: (draft, value) => draft.recordLabel = value ?? '',
              options: _options(
                recordLabelOptions ?? MusicVocabularies.recordLabel.builtIns,
              ),
              pickListKey: MusicVocabularyIds.recordLabel.value,
              onManage: onManageRecordLabel == null
                  ? null
                  : (_) => onManageRecordLabel(),
            ),
            LibraryVocabularyFieldSpec<MusicAddManualDraft, String>(
              id: 'format',
              label: 'Format',
              value: (draft) => _nullable(draft.format),
              setValue: (draft, value) => draft.format = value ?? '',
              options:
                  _options(formatOptions ?? MusicVocabularies.format.builtIns),
              pickListKey: MusicVocabularyIds.format.value,
              onManage: onManageFormat == null ? null : (_) => onManageFormat(),
            ),
            LibraryVocabularyFieldSpec<MusicAddManualDraft, String>(
              id: 'packaging',
              label: 'Packaging',
              value: (draft) => _nullable(draft.packaging),
              setValue: (draft, value) => draft.packaging = value ?? '',
              options: _options(
                packagingOptions ?? MusicVocabularies.packaging.builtIns,
              ),
              pickListKey: MusicVocabularyIds.packaging.value,
              onManage:
                  onManagePackaging == null ? null : (_) => onManagePackaging(),
            ),
            LibraryTextFieldSpec<MusicAddManualDraft>(
              id: 'catalog_number',
              label: 'Cat No',
              value: (draft) => draft.catalogNumber,
              setValue: (draft, value) => draft.catalogNumber = value,
            ),
            LibraryTextFieldSpec<MusicAddManualDraft>(
              id: 'barcode',
              label: 'Barcode',
              value: (draft) => draft.barcode,
              setValue: (draft, value) => draft.barcode = value,
            ),
            LibraryVocabularyFieldSpec<MusicAddManualDraft, String>(
              id: 'country',
              label: 'Country',
              value: (draft) => _nullable(draft.countryCode),
              setValue: (draft, value) => draft.countryCode = value ?? '',
              options: _countryOptions(
                countryOptions ?? MusicVocabularies.country.builtIns,
              ),
              pickListKey: MusicVocabularyIds.country.value,
              onManage:
                  onManageCountry == null ? null : (_) => onManageCountry(),
            ),
          ],
        ),
        AddSectionSpec<MusicAddManualDraft>(
          id: 'technical',
          label: 'Pressing details',
          fields: [
            LibrarySelectFieldSpec<MusicAddManualDraft, bool>(
              id: 'is_live',
              label: 'Recording Type',
              value: (draft) => draft.isLive,
              setValue: (draft, value) => draft.isLive = value,
              options: const [
                LibraryFieldOption(value: false, label: 'Studio recording'),
                LibraryFieldOption(value: true, label: 'Live recording'),
              ],
            ),
            LibraryMultiVocabularyFieldSpec<MusicAddManualDraft, String>(
              id: 'sound_types',
              label: 'Sound',
              pickListKey: MusicVocabularyIds.soundType.value,
              pluralLabel: 'Sound types',
              values: (draft) => draft.soundTypes.toSet(),
              setValues: (draft, values) =>
                  draft.soundTypes = values.toList(growable: false),
              options: _options(
                soundTypeOptions ?? MusicVocabularies.soundType.builtIns,
              ),
            ),
            LibraryVocabularyFieldSpec<MusicAddManualDraft, String>(
              id: 'vinyl_color',
              label: 'Vinyl Color',
              value: (draft) => _nullable(draft.vinylColor),
              setValue: (draft, value) => draft.vinylColor = value ?? '',
              options: _options(MusicVocabularies.vinylColor.builtIns),
              pickListKey: MusicVocabularyIds.vinylColor.value,
            ),
            LibraryTextFieldSpec<MusicAddManualDraft>(
              id: 'vinyl_weight',
              label: 'Vinyl Weight',
              value: (draft) => draft.vinylWeight,
              setValue: (draft, value) => draft.vinylWeight = value,
            ),
            LibraryNumberFieldSpec<MusicAddManualDraft>(
              id: 'rpm',
              label: 'RPM',
              value: (draft) => draft.rpm,
              setValue: (draft, value) => draft.rpm = value?.toInt(),
              minimum: 1,
            ),
            LibraryTextFieldSpec<MusicAddManualDraft>(
              id: 'extra',
              label: 'Extra',
              value: (draft) => draft.extra,
              setValue: (draft, value) => draft.extra = value,
              maxLines: 3,
            ),
            LibraryTextFieldSpec<MusicAddManualDraft>(
              id: 'spars',
              label: 'SPARS',
              value: (draft) => draft.spars,
              setValue: (draft, value) => draft.spars = value,
            ),
            LibraryTextFieldSpec<MusicAddManualDraft>(
              id: 'box_set',
              label: 'Box Set',
              value: (draft) => draft.boxSet,
              setValue: (draft, value) => draft.boxSet = value,
            ),
          ],
        ),
      ],
    );

PartialDate? _partsFromDate(DateTime? value) =>
    value == null ? null : PartialDate.fromDateTime(value);

String? _nullable(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

List<LibraryFieldOption<String>> _options(Iterable<String> values) => [
      for (final value in values)
        LibraryFieldOption(value: value, label: value),
    ];

List<LibraryFieldOption<String>> _countryOptions(Iterable<String> values) {
  final options = [
    for (final value in values)
      LibraryFieldOption(value: value, label: musicCountryName(value) ?? value),
  ];
  options.sort((left, right) => left.label.compareTo(right.label));
  return options;
}
