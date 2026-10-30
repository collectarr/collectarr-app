import 'dart:async';

import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/forms/library_field_spec.dart';
import 'package:collectarr_app/features/library/kinds/comic/config/comic_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';

String? validateComicCatalogItem(ComicCatalogItemFormValues values) {
  final pageCount = values.pageCount;
  if (pageCount != null && pageCount < 0) {
    return 'Page count cannot be negative';
  }
  return null;
}

List<LibraryFieldSpec<T>> comicCatalogItemIdentityFields<T>({
  required ComicCatalogItemValuesReader<T> values,
  Iterable<String>? physicalFormatOptions,
  FutureOr<void> Function()? onManagePhysicalFormat,
  bool includeTitle = true,
  bool includeSeries = true,
}) =>
    [
      if (includeTitle)
        _text<T>(
          id: 'title',
          label: 'Title',
          value: (draft) => values(draft).title,
          setValue: (draft, value) => values(draft).title = value,
        ),
      if (includeSeries)
        _text<T>(
          id: ComicFieldIdentities.seriesId,
          label: ComicFieldIdentities.seriesLabel,
          value: (draft) => values(draft).seriesTitle,
          setValue: (draft, value) => values(draft).seriesTitle = value,
        ),
      _text<T>(
        id: ComicFieldIdentities.issueNumberId,
        label: ComicFieldIdentities.issueNumberLabel,
        value: (draft) => values(draft).issueNumber,
        setValue: (draft, value) => values(draft).issueNumber = value,
      ),
      _text<T>(
        id: ComicFieldIdentities.variantId,
        label: ComicFieldIdentities.variantLabel,
        value: (draft) => values(draft).variant,
        setValue: (draft, value) => values(draft).variant = value,
      ),
      _text<T>(
        id: 'variant_description',
        label: 'Variant Description',
        value: (draft) => values(draft).variantDescription,
        setValue: (draft, value) => values(draft).variantDescription = value,
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
        pickListKey: ComicVocabularyIds.physicalFormat.value,
        onManage: onManagePhysicalFormat == null
            ? null
            : (_) => onManagePhysicalFormat(),
      ),
      LibraryPartialDateFieldSpec<T>(
        id: 'cover_date',
        label: 'Cover Date',
        value: (draft) =>
            values(draft).coverDateParts ??
            (values(draft).coverDate == null
                ? null
                : PartialDate.fromDateTime(values(draft).coverDate!)),
        setValue: (draft, value) {
          values(draft).coverDateParts = value;
          values(draft).coverDate = value?.asDateTime;
        },
      ),
      LibraryPartialDateFieldSpec<T>(
        id: 'release_date',
        label: 'Release Date',
        value: (draft) =>
            values(draft).releaseDateParts ??
            (values(draft).releaseDate == null
                ? null
                : PartialDate.fromDateTime(values(draft).releaseDate!)),
        setValue: (draft, value) {
          values(draft).releaseDateParts = value;
          values(draft).releaseDate = value?.asDateTime;
        },
      ),
    ];

List<LibraryFieldSpec<T>> comicCatalogItemPublicationFields<T>({
  required ComicCatalogItemValuesReader<T> values,
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
        pickListKey: ComicVocabularyIds.publisher.value,
        onManage: onManagePublisher,
      ),
      _vocabulary<T>(
        id: ComicFieldIdentities.imprintId,
        label: ComicFieldIdentities.imprintLabel,
        value: (draft) => values(draft).imprint,
        setValue: (draft, value) => values(draft).imprint = value ?? '',
        options: imprintOptions ?? ComicVocabularies.imprint.builtIns,
        pickListKey: ComicVocabularyIds.imprint.value,
        onManage: onManageImprint,
      ),
      _vocabulary<T>(
        id: 'series_group',
        label: 'Series Group',
        value: (draft) => values(draft).seriesGroup,
        setValue: (draft, value) => values(draft).seriesGroup = value ?? '',
        options: seriesGroupOptions ?? ComicVocabularies.seriesGroup.builtIns,
        pickListKey: ComicVocabularyIds.seriesGroup.value,
        onManage: onManageSeriesGroup,
      ),
      LibraryNumberFieldSpec<T>(
        id: ComicFieldIdentities.pageCountId,
        label: 'No. of Pages',
        value: (draft) => values(draft).pageCount,
        setValue: (draft, value) => values(draft).pageCount = value?.round(),
        minimum: 0,
      ),
      _text<T>(
        id: 'subtitle',
        label: 'Subtitle',
        value: (draft) => values(draft).subtitle,
        setValue: (draft, value) => values(draft).subtitle = value,
      ),
      _vocabulary<T>(
        id: 'publication_age',
        label: 'Age',
        value: (draft) => values(draft).publicationAge,
        setValue: (draft, value) => values(draft).publicationAge = value ?? '',
        options: const [],
        pickListKey: ComicVocabularyIds.publicationAge.value,
      ),
      LibraryMultiVocabularyFieldSpec<T, String>(
        id: 'genres',
        label: 'Genre',
        values: (draft) => values(draft).genres.toSet(),
        setValues: (draft, next) => values(draft).genres = next.toList(),
        options: const [],
      ),
      _vocabulary<T>(
        id: 'language',
        label: 'Language',
        value: (draft) => values(draft).language,
        setValue: (draft, value) => values(draft).language = value ?? '',
        options: const [],
        pickListKey: ComicVocabularyIds.language.value,
      ),
      _vocabulary<T>(
        id: 'country',
        label: 'Country',
        value: (draft) => values(draft).country,
        setValue: (draft, value) => values(draft).country = value ?? '',
        options: const [],
        pickListKey: ComicVocabularyIds.country.value,
      ),
      _vocabulary<T>(
        id: 'crossover',
        label: 'Crossover',
        value: (draft) => values(draft).crossover,
        setValue: (draft, value) => values(draft).crossover = value ?? '',
        options: const [],
        pickListKey: ComicVocabularyIds.crossover.value,
      ),
      _vocabulary<T>(
        id: 'story_arcs',
        label: 'Story Arc',
        value: (draft) => values(draft).storyArc,
        setValue: (draft, value) => values(draft).storyArc = value ?? '',
        options: const [],
        pickListKey: ComicVocabularyIds.storyArc.value,
      ),
      ...comicCatalogItemCoverFields(values: values),
    ];

List<LibraryFieldSpec<T>> comicCatalogItemCoverFields<T>({
  required ComicCatalogItemValuesReader<T> values,
}) =>
    [
      _text<T>(
        id: 'cover_image_url',
        label: 'Cover image URL',
        value: (draft) => values(draft).coverImageUrl,
        setValue: (draft, value) => values(draft).coverImageUrl = value,
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
  required String pickListKey,
  FutureOr<void> Function()? onManage,
}) =>
    LibraryVocabularyFieldSpec<T, String>(
      id: id,
      label: label,
      value: (draft) => _nullable(value(draft)),
      setValue: setValue,
      options: _options(options),
      pickListKey: pickListKey,
      onManage: onManage == null ? null : (_) => onManage(),
    );

String? _nullable(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

List<LibraryFieldOption<String>> _options(Iterable<String> values) => [
      for (final value in values)
        LibraryFieldOption(value: value, label: value),
    ];
