import 'dart:async';

import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';

List<LibraryFieldSpec<T>> comicMediaIdentityFields<T>({
  required ComicMediaValuesReader<T> values,
  Iterable<String>? physicalFormatOptions,
  FutureOr<void> Function()? onManagePhysicalFormat,
  bool includeSeries = true,
}) =>
    [
      if (includeSeries)
        _text<T>(
          id: 'series',
          label: 'Series',
          value: (draft) => values(draft).seriesTitle,
          setValue: (draft, value) => values(draft).seriesTitle = value,
        ),
      _text<T>(
        id: 'issue_number',
        label: 'Issue number',
        value: (draft) => values(draft).issueNumber,
        setValue: (draft, value) => values(draft).issueNumber = value,
      ),
      _text<T>(
        id: 'variant',
        label: 'Variant',
        value: (draft) => values(draft).variant,
        setValue: (draft, value) => values(draft).variant = value,
      ),
      _text<T>(
        id: 'edition_title',
        label: 'Edition title',
        value: (draft) => values(draft).editionTitle,
        setValue: (draft, value) => values(draft).editionTitle = value,
      ),
      _text<T>(
        id: 'barcode',
        label: 'Barcode',
        value: (draft) => values(draft).barcode,
        setValue: (draft, value) => values(draft).barcode = value,
      ),
      LibraryVocabularyFieldSpec<T, String>(
        id: 'physical_format',
        label: 'Format',
        value: (draft) => _nullable(values(draft).physicalFormatLabel),
        setValue: (draft, value) =>
            values(draft).physicalFormatLabel = value ?? '',
        options: _options(
          physicalFormatOptions ?? ComicVocabularies.physicalFormat.builtIns,
        ),
        onManage: onManagePhysicalFormat == null
            ? null
            : (_) => onManagePhysicalFormat(),
      ),
      LibraryDateFieldSpec<T>(
        id: 'cover_date',
        label: 'Cover date',
        value: (draft) => values(draft).coverDate,
        setValue: (draft, value) => values(draft).coverDate = value,
      ),
      LibraryDateFieldSpec<T>(
        id: 'release_date',
        label: 'Release date',
        value: (draft) => values(draft).releaseDate,
        setValue: (draft, value) => values(draft).releaseDate = value,
      ),
    ];

List<LibraryFieldSpec<T>> comicMediaPublicationFields<T>({
  required ComicMediaValuesReader<T> values,
  Iterable<String>? publisherOptions,
  Iterable<String>? imprintOptions,
  Iterable<String>? seriesGroupOptions,
  FutureOr<void> Function()? onManagePublisher,
  FutureOr<void> Function()? onManageImprint,
  FutureOr<void> Function()? onManageSeriesGroup,
}) =>
    [
      _vocabulary<T>(
        id: 'publisher',
        label: 'Publisher',
        value: (draft) => values(draft).publisher,
        setValue: (draft, value) => values(draft).publisher = value ?? '',
        options: publisherOptions ?? ComicVocabularies.publisher.builtIns,
        onManage: onManagePublisher,
      ),
      _vocabulary<T>(
        id: 'imprint',
        label: 'Imprint',
        value: (draft) => values(draft).imprint,
        setValue: (draft, value) => values(draft).imprint = value ?? '',
        options: imprintOptions ?? ComicVocabularies.imprint.builtIns,
        onManage: onManageImprint,
      ),
      _vocabulary<T>(
        id: 'series_group',
        label: 'Series group',
        value: (draft) => values(draft).seriesGroup,
        setValue: (draft, value) => values(draft).seriesGroup = value ?? '',
        options: seriesGroupOptions ?? ComicVocabularies.seriesGroup.builtIns,
        onManage: onManageSeriesGroup,
      ),
      LibraryNumberFieldSpec<T>(
        id: 'page_count',
        label: 'Page count',
        value: (draft) => values(draft).pageCount,
        setValue: (draft, value) => values(draft).pageCount = value?.round(),
        minimum: 0,
      ),
      _text<T>(
        id: 'age_rating',
        label: 'Age rating',
        value: (draft) => values(draft).ageRating,
        setValue: (draft, value) => values(draft).ageRating = value,
      ),
      LibraryMultiVocabularyFieldSpec<T, String>(
        id: 'genres',
        label: 'Genres',
        values: (draft) => values(draft).genres.toSet(),
        setValues: (draft, next) => values(draft).genres = next.toList(),
        options: const [],
      ),
      _text<T>(
        id: 'language',
        label: 'Language',
        value: (draft) => values(draft).language,
        setValue: (draft, value) => values(draft).language = value,
      ),
      _text<T>(
        id: 'country',
        label: 'Country',
        value: (draft) => values(draft).country,
        setValue: (draft, value) => values(draft).country = value,
      ),
      LibraryMultiVocabularyFieldSpec<T, String>(
        id: 'crossover',
        label: 'Crossover',
        values: (draft) => _split(values(draft).crossover).toSet(),
        setValues: (draft, next) => values(draft).crossover = next.join(', '),
        options: const [],
      ),
      LibraryMultiVocabularyFieldSpec<T, String>(
        id: 'story_arcs',
        label: 'Story arcs',
        values: (draft) => values(draft).storyArcs.toSet(),
        setValues: (draft, next) => values(draft).storyArcs = next.toList(),
        options: const [],
      ),
      _text<T>(
        id: 'cover_image_url',
        label: 'Cover image URL',
        value: (draft) => values(draft).coverImageUrl,
        setValue: (draft, value) => values(draft).coverImageUrl = value,
      ),
    ];

List<LibraryFieldSpec<T>> comicReleaseFields<T>({
  required ComicReleaseValuesReader<T> values,
  Iterable<String>? publisherOptions,
  Iterable<String>? imprintOptions,
}) =>
    [
      _text<T>(
        id: 'release_title',
        label: 'Edition title',
        value: (draft) => values(draft).title,
        setValue: (draft, value) => values(draft).title = value,
      ),
      _vocabulary<T>(
        id: 'publisher',
        label: 'Publisher',
        value: (draft) => values(draft).publisher,
        setValue: (draft, value) => values(draft).publisher = value ?? '',
        options: publisherOptions ?? ComicVocabularies.publisher.builtIns,
      ),
      _vocabulary<T>(
        id: 'imprint',
        label: 'Imprint',
        value: (draft) => values(draft).imprint,
        setValue: (draft, value) => values(draft).imprint = value ?? '',
        options: imprintOptions ?? ComicVocabularies.imprint.builtIns,
      ),
      _text<T>(
        id: 'isbn',
        label: 'ISBN',
        value: (draft) => values(draft).isbn,
        setValue: (draft, value) => values(draft).isbn = value,
      ),
      _text<T>(
        id: 'upc',
        label: 'UPC',
        value: (draft) => values(draft).upc,
        setValue: (draft, value) => values(draft).upc = value,
      ),
      LibraryDateFieldSpec<T>(
        id: 'release_date',
        label: 'Release date',
        value: (draft) => values(draft).releaseDate,
        setValue: (draft, value) => values(draft).releaseDate = value,
      ),
      LibraryImageFieldSpec<T, String>(
        id: 'cover_image_url',
        label: 'Cover image',
        value: (draft) => _nullable(values(draft).coverImageUrl),
        setValue: (draft, value) => values(draft).coverImageUrl = value ?? '',
      ),
    ];

LibraryTextFieldSpec<T> _text<T>({
  required String id,
  required String label,
  required String Function(T draft) value,
  required void Function(T draft, String value) setValue,
}) =>
    LibraryTextFieldSpec<T>(
      id: id,
      label: label,
      value: value,
      setValue: setValue,
    );

LibraryVocabularyFieldSpec<T, String> _vocabulary<T>({
  required String id,
  required String label,
  required String Function(T draft) value,
  required void Function(T draft, String?) setValue,
  required Iterable<String> options,
  FutureOr<void> Function()? onManage,
}) =>
    LibraryVocabularyFieldSpec<T, String>(
      id: id,
      label: label,
      value: (draft) => _nullable(value(draft)),
      setValue: setValue,
      options: _options(options),
      onManage: onManage == null ? null : (_) => onManage(),
    );

String? _nullable(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);

List<LibraryFieldOption<String>> _options(Iterable<String> values) => [
      for (final value in values)
        LibraryFieldOption(value: value, label: value),
    ];
