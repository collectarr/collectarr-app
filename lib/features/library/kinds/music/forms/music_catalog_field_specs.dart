import 'dart:async';

import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_box_set_membership.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_release_form_values.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_release_group_form_values.dart';
import 'package:collectarr_app/features/library/kinds/music/music_country_name.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec.dart';

typedef MusicReleaseGroupValuesReader<TDraft> = MusicReleaseGroupFormValues
    Function(TDraft draft);
typedef MusicReleaseValuesReader<TDraft> = MusicReleaseFormValues Function(
    TDraft draft);

List<LibraryFieldSpec<TDraft>> musicReleaseGroupFields<TDraft>({
  required MusicReleaseGroupValuesReader<TDraft> values,
  Set<String>? include,
  Iterable<String>? genreOptions,
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
        label: 'Sort title',
        read: (draft) => values(draft).sortTitle,
        write: (draft, value) => values(draft).sortTitle = value,
      ),
      _text<TDraft>(
        id: 'artist',
        label: 'Artist',
        read: (draft) => values(draft).artist,
        write: (draft, value) => values(draft).artist = value,
      ),
      _text<TDraft>(
        id: 'original_title',
        label: 'Original title',
        read: (draft) => values(draft).originalTitle,
        write: (draft, value) => values(draft).originalTitle = value,
      ),
      LibrarySelectFieldSpec<TDraft, bool>(
        id: 'is_live',
        label: 'Recording type',
        value: (draft) => values(draft).isLive,
        setValue: (draft, value) => values(draft).isLive = value,
        options: const [
          LibraryFieldOption(value: true, label: 'Live recording'),
          LibraryFieldOption(value: false, label: 'Studio recording'),
        ],
      ),
      LibraryDateFieldSpec<TDraft>(
        id: 'original_release_date',
        label: 'Original release date',
        value: (draft) => values(draft).originalReleaseDate,
        setValue: (draft, value) => values(draft).originalReleaseDate = value,
      ),
      LibraryDateFieldSpec<TDraft>(
        id: 'recording_date',
        label: 'Recording date',
        value: (draft) => values(draft).recordingDate,
        setValue: (draft, value) => values(draft).recordingDate = value,
      ),
      _text<TDraft>(
        id: 'studio',
        label: 'Studio',
        read: (draft) => values(draft).studio,
        write: (draft, value) => values(draft).studio = value,
      ),
      LibraryMultiVocabularyFieldSpec<TDraft, String>(
        id: 'genres',
        label: 'Genre',
        pickListKey: MusicVocabularyIds.genre.value,
        pluralLabel: 'Genres',
        values: (draft) => values(draft).genres.toSet(),
        setValues: (draft, next) =>
            values(draft).genres = next.toList(growable: false),
        options: _options(genreOptions ?? MusicVocabularies.genre.builtIns),
      ),
      _text<TDraft>(
        id: 'cover_image_url',
        label: 'Cover image URL',
        read: (draft) => values(draft).coverImageUrl,
        write: (draft, value) => values(draft).coverImageUrl = value,
      ),
    ], include);

List<LibraryFieldSpec<TDraft>> musicReleaseFields<TDraft>({
  required MusicReleaseValuesReader<TDraft> values,
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
        label: 'Release title',
        read: (draft) => values(draft).title,
        write: (draft, value) => values(draft).title = value,
      ),
      _text<TDraft>(
        id: 'sort_title',
        label: 'Sort title',
        read: (draft) => values(draft).sortTitle,
        write: (draft, value) => values(draft).sortTitle = value,
      ),
      _text<TDraft>(
        id: 'subtitle',
        label: 'Subtitle',
        read: (draft) => values(draft).subtitle,
        write: (draft, value) => values(draft).subtitle = value,
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'format',
        label: 'Format',
        value: (draft) => _nullable(
          values(draft).physicalFormatLabel.isNotEmpty
              ? values(draft).physicalFormatLabel
              : values(draft).physicalFormat,
        ),
        setValue: (draft, value) {
          values(draft).physicalFormat = value ?? '';
          values(draft).physicalFormatLabel = value ?? '';
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
      LibraryDateFieldSpec<TDraft>(
        id: 'release_date',
        label: 'Release date',
        value: (draft) => values(draft).releaseDate,
        setValue: (draft, value) => values(draft).releaseDate = value,
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'record_label',
        label: 'Record label',
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
        label: 'Catalog number',
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
      _text<TDraft>(
        id: 'box_set_ref',
        label: 'Box set reference',
        read: (draft) => values(draft).boxSetMembership?.boxSetRef.id ?? '',
        write: (draft, value) {
          final id = value.trim();
          final current = values(draft).boxSetMembership;
          values(draft).boxSetMembership = id.isEmpty
              ? null
              : MusicBoxSetMembership(
                  boxSetRef: CatalogEntityRef(
                    kind: CatalogMediaKind.music,
                    entityType: const CatalogEntityTypeId('box_set'),
                    id: id,
                    rootId: current?.boxSetRef.rootId,
                    parentId: current?.boxSetRef.parentId,
                  ),
                  sequenceNumber: current?.sequenceNumber,
                );
        },
      ),
      _text<TDraft>(
        id: 'box_set_name',
        label: 'Box set name',
        read: (draft) => values(draft).boxSetName,
        write: (draft, value) => values(draft).boxSetName = value,
      ),
      LibraryNumberFieldSpec<TDraft>(
        id: 'box_set_position',
        label: 'Box set position',
        value: (draft) =>
            values(draft).boxSetMembership?.sequenceNumber?.toDouble(),
        setValue: (draft, value) {
          final current = values(draft).boxSetMembership;
          if (current == null) return;
          values(draft).boxSetMembership = MusicBoxSetMembership(
            boxSetRef: current.boxSetRef,
            sequenceNumber: value?.toInt(),
          );
        },
        minimum: 1,
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
