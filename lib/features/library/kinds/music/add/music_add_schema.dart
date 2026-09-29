import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/music_country_name.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';

final AddSchema<MusicAddManualDraft> musicAddSchema = musicAddSchemaFor();

AddSchema<MusicAddManualDraft> musicAddSchemaFor({
  Iterable<String>? formatOptions,
  Iterable<String>? genreOptions,
  Iterable<String>? countryOptions,
  Iterable<String>? recordLabelOptions,
  Iterable<String>? packagingOptions,
  Iterable<String>? studioOptions,
  FutureOr<void> Function()? onManageFormat,
  FutureOr<void> Function()? onManageCountry,
  FutureOr<void> Function()? onManageRecordLabel,
  FutureOr<void> Function()? onManagePackaging,
}) =>
    AddSchema<MusicAddManualDraft>(
      title: (_) => 'Manual music album',
      validate: (draft) {
        if (draft.year != null && draft.year! < 1) {
          return 'Release year must be greater than zero';
        }
        return null;
      },
      sections: [
        AddSectionSpec<MusicAddManualDraft>(
          id: 'album',
          label: 'Album details',
          fields: [
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
            LibraryTextFieldSpec<MusicAddManualDraft>(
              id: 'cover_image_url',
              label: 'Cover image URL',
              value: (draft) => draft.coverImageUrl,
              setValue: (draft, value) => draft.coverImageUrl = value,
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
          ],
        ),
        AddSectionSpec<MusicAddManualDraft>(
          id: 'edition',
          label: 'Edition details',
          fields: [
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
              label: 'Catalog number',
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
            LibraryDateFieldSpec<MusicAddManualDraft>(
              id: 'release_date',
              label: 'Release date',
              value: (draft) => draft.releaseDate,
              setValue: (draft, value) => draft.releaseDate = value,
            ),
            LibraryVocabularyFieldSpec<MusicAddManualDraft, String>(
              id: 'record_label',
              label: 'Record label',
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
