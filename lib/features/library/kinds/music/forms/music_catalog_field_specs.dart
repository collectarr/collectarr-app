import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_ordered_names_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album_relations.dart';
import 'dart:async';

import 'package:collectarr_app/features/library/kinds/music/forms/music_album_form_values.dart';
import 'package:collectarr_app/features/library/kinds/music/music_country_name.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec.dart';

typedef MusicAlbumValuesReader<TDraft> = MusicAlbumFormValues Function(
    TDraft draft);

List<LibraryFieldSpec<TDraft>> musicAlbumFields<TDraft>({
  required MusicAlbumValuesReader<TDraft> values,
  Set<String>? include,
  Iterable<String>? formatOptions,
  Iterable<String>? countryOptions,
  Iterable<String>? recordLabelOptions,
  Iterable<String>? packagingOptions,
  FutureOr<void> Function()? onManageFormat,
  FutureOr<void> Function()? onManageCountry,
  FutureOr<void> Function()? onManageRecordLabel,
  FutureOr<void> Function()? onManagePackaging,
}) =>
    _included<TDraft>([
      _text<TDraft>(
        id: 'title',
        label: 'Title',
        read: (draft) => values(draft).title,
        write: (draft, value) => values(draft).title = value,
      ),
      _text<TDraft>(
        id: 'sort_title',
        label: 'Sort Title',
        read: (draft) => values(draft).sortTitle,
        write: (draft, value) => values(draft).sortTitle = value,
      ),
      _text<TDraft>(
        id: 'subtitle',
        label: 'Subtitle',
        read: (draft) => values(draft).subtitle,
        write: (draft, value) => values(draft).subtitle = value,
      ),
      LibraryCustomFieldSpec<TDraft>(
        id: 'artist',
        label: 'Artist',
        builder: (context, draft) =>
            StatefulBuilder(builder: (context, refresh) {
          final form = values(draft);
          final credits = form.artistCredits.isNotEmpty
              ? form.artistCredits
              : [
                  if (form.artist.trim().isNotEmpty)
                    MusicArtistCredit(
                        id: 'artist-main', creditedName: form.artist),
                ];
          return LibraryOrderedNamesField(
            label: 'Artist',
            values: [
              for (final credit in credits)
                LibraryNamedValue(
                    id: credit.id,
                    name: credit.creditedName,
                    sortName: credit.sortName)
            ],
            onChanged: (names) => refresh(() {
              form.artistCredits = [
                for (var index = 0; index < names.length; index++)
                  MusicArtistCredit(
                    id: names[index].id,
                    creditedName: names[index].name,
                    sortName: names[index].sortName,
                    artistId: credits
                        .where((c) => c.id == names[index].id)
                        .firstOrNull
                        ?.artistId,
                    sequence: index + 1,
                  )
              ];
              form.artist = names
                  .map((value) => value.name.trim())
                  .where((name) => name.isNotEmpty)
                  .join(' / ');
            }),
          );
        }),
      ),
      _text<TDraft>(
        id: 'original_title',
        label: 'Original title',
        read: (draft) => values(draft).originalTitle,
        write: (draft, value) => values(draft).originalTitle = value,
      ),
      LibraryPartialDateFieldSpec<TDraft>(
        id: 'original_release_date',
        label: 'Original Release Date',
        value: (draft) => values(draft).originalReleaseDateParts,
        setValue: (draft, value) {
          values(draft).originalReleaseDateParts = value;
          values(draft).originalReleaseDate = value?.asDateTime;
        },
      ),
      LibraryPartialDateFieldSpec<TDraft>(
        id: 'recording_date',
        label: 'Recording Date',
        value: (draft) => values(draft).recordingDateParts,
        setValue: (draft, value) {
          values(draft).recordingDateParts = value;
          values(draft).recordingDate = value?.asDateTime;
        },
      ),
      LibraryMultiVocabularyFieldSpec<TDraft, String>(
        id: 'studios',
        label: 'Studio',
        pickListKey: MusicVocabularyIds.studio.value,
        pluralLabel: 'Studios',
        values: (draft) => values(draft).studios.toSet(),
        setValues: (draft, next) =>
            values(draft).studios = next.toList(growable: false),
        options: _options(MusicVocabularies.studio.builtIns),
      ),
      LibraryCustomFieldSpec<TDraft>(
        id: 'is_live',
        label: 'Is Live',
        builder: (context, draft) => StatefulBuilder(
            builder: (context, refresh) => LibraryFormField(
                  label: 'Is Live',
                  child: LibrarySegmentedField<bool>(
                      value: values(draft).isLive ?? false,
                      options: const {false: 'No', true: 'Yes'},
                      onChanged: (value) =>
                          refresh(() => values(draft).isLive = value)),
                )),
      ),
      LibraryMultiVocabularyFieldSpec<TDraft, String>(
        id: 'genres',
        label: 'Genre',
        pickListKey: MusicVocabularyIds.genre.value,
        pluralLabel: 'Genres',
        values: (draft) => values(draft).genres.toSet(),
        setValues: (draft, next) =>
            values(draft).genres = next.toList(growable: false),
        options: _options(MusicVocabularies.genre.builtIns),
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'format',
        label: 'Format',
        value: (draft) => _nullable(values(draft).format),
        setValue: (draft, value) {
          values(draft).format = value ?? '';
        },
        options: _options(formatOptions ?? MusicVocabularies.format.builtIns),
        pickListKey: MusicVocabularyIds.format.value,
        onManage: onManageFormat == null ? null : (_) => onManageFormat(),
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'release_type',
        label: 'Release type',
        value: (draft) => _nullable(values(draft).releaseType),
        setValue: (draft, value) => values(draft).releaseType = value ?? '',
        options:
            _options(const ['Album', 'EP', 'Single', 'Compilation', 'Live']),
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'release_status',
        label: 'Release status',
        value: (draft) => _nullable(values(draft).releaseStatus),
        setValue: (draft, value) => values(draft).releaseStatus = value ?? '',
        options: _options(const ['Official', 'Promotional', 'Bootleg']),
      ),
      LibraryPartialDateFieldSpec<TDraft>(
        id: 'release_date',
        label: 'Release Date',
        value: (draft) => values(draft).releaseDateParts,
        setValue: (draft, value) {
          values(draft).releaseDateParts = value;
          values(draft).releaseDate = value?.asDateTime;
        },
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'record_label',
        label: 'Label',
        value: (draft) => _nullable(values(draft).publisher),
        setValue: (draft, value) => values(draft).publisher = value ?? '',
        options: _options(
          recordLabelOptions ?? MusicVocabularies.recordLabel.builtIns,
        ),
        pickListKey: MusicVocabularyIds.recordLabel.value,
        onManage:
            onManageRecordLabel == null ? null : (_) => onManageRecordLabel(),
      ),
      _text<TDraft>(
        id: 'catalog_number',
        label: 'Cat No',
        read: (draft) => values(draft).catalogNumber,
        write: (draft, value) => values(draft).catalogNumber = value,
      ),
      _text<TDraft>(
        id: 'barcode',
        label: 'Barcode',
        read: (draft) => values(draft).barcode,
        write: (draft, value) => values(draft).barcode = value,
      ),
      _text<TDraft>(
        id: 'upc',
        label: 'UPC',
        read: (draft) => values(draft).upc,
        write: (draft, value) => values(draft).upc = value,
      ),
      _text<TDraft>(
        id: 'cover_image_url',
        label: 'Cover image URL',
        read: (draft) => values(draft).coverImageUrl,
        write: (draft, value) => values(draft).coverImageUrl = value,
      ),
      LibraryMultiVocabularyFieldSpec<TDraft, String>(
        id: 'sound_types',
        label: 'Sound',
        pickListKey: MusicVocabularyIds.soundType.value,
        pluralLabel: 'Sound types',
        values: (draft) => values(draft).soundTypes.toSet(),
        setValues: (draft, next) =>
            values(draft).soundTypes = next.toList(growable: false),
        options: _options(MusicVocabularies.soundType.builtIns),
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'vinyl_color',
        label: 'Vinyl Color',
        value: (draft) => _nullable(values(draft).vinylColor),
        setValue: (draft, value) => values(draft).vinylColor = value ?? '',
        options: _options(MusicVocabularies.vinylColor.builtIns),
        pickListKey: MusicVocabularyIds.vinylColor.value,
      ),
      LibraryNumberFieldSpec<TDraft>(
        id: 'vinyl_weight',
        label: 'Vinyl Weight',
        value: (draft) => num.tryParse(values(draft).vinylWeight),
        setValue: (draft, value) =>
            values(draft).vinylWeight = value?.toInt().toString() ?? '',
        minimum: 0,
      ),
      LibraryCustomFieldSpec<TDraft>(
        id: 'rpm',
        label: 'RPM',
        builder: (context, draft) => StatefulBuilder(
            builder: (context, refresh) => LibraryFormField(
                  label: 'RPM',
                  child: LibrarySegmentedField<int>(
                      value: values(draft).rpm ?? 0,
                      options: const {0: 'N/A', 33: '33', 45: '45', 78: '78'},
                      onChanged: (value) => refresh(
                          () => values(draft).rpm = value == 0 ? null : value)),
                )),
      ),
      LibraryMultiVocabularyFieldSpec<TDraft, String>(
        id: 'extra',
        label: 'Extra',
        pluralLabel: 'Extras',
        pickListKey: 'extra',
        options: const [],
        values: (draft) => values(draft)
            .extra
            .split('||')
            .where((value) => value.trim().isNotEmpty)
            .toSet(),
        setValues: (draft, valuesSet) =>
            values(draft).extra = valuesSet.join('||'),
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'spars',
        label: 'SPARS',
        value: (draft) => _nullable(values(draft).spars),
        setValue: (draft, value) => values(draft).spars = value ?? '',
        options: _options(const ['AAD', 'ADD', 'DAD', 'DDD']),
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'country',
        label: 'Country',
        value: (draft) => _nullable(values(draft).countryCode),
        setValue: (draft, value) => values(draft).countryCode = value ?? '',
        options: _countryOptions(
          countryOptions ?? MusicVocabularies.country.builtIns,
        ),
        pickListKey: MusicVocabularyIds.country.value,
        onManage: onManageCountry == null ? null : (_) => onManageCountry(),
      ),
      _text<TDraft>(
        id: 'language',
        label: 'Language',
        read: (draft) => values(draft).language,
        write: (draft, value) => values(draft).language = value,
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'packaging',
        label: 'Packaging',
        value: (draft) => _nullable(values(draft).packaging),
        setValue: (draft, value) => values(draft).packaging = value ?? '',
        options: _options(
          packagingOptions ?? MusicVocabularies.packaging.builtIns,
        ),
        pickListKey: MusicVocabularyIds.packaging.value,
        onManage: onManagePackaging == null ? null : (_) => onManagePackaging(),
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'box_set',
        label: 'Box Set',
        value: (draft) => _nullable(values(draft).boxSet),
        setValue: (draft, value) => values(draft).boxSet = value ?? '',
        options: const [],
        pickListKey: 'box_set',
      ),
    ], include);

List<LibraryFieldSpec<TDraft>> _included<TDraft>(
  List<LibraryFieldSpec<TDraft>> fields,
  Set<String>? include,
) =>
    include == null
        ? fields
        : fields.where((field) => include.contains(field.id)).toList();

LibraryTextFieldSpec<TDraft> _text<TDraft>({
  required String id,
  required String label,
  required String Function(TDraft draft) read,
  required void Function(TDraft draft, String value) write,
}) =>
    LibraryTextFieldSpec<TDraft>(
      id: id,
      label: label,
      value: read,
      setValue: write,
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
