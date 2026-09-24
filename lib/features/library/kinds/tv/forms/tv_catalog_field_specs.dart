import 'dart:async';

import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:collectarr_app/features/library/kinds/tv/forms/tv_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/tv/vocabulary/tv_vocabularies.dart';

typedef TvSeriesValuesReader<T> = TvSeriesFormValues Function(T value);
typedef TvReleaseValuesReader<T> = TvReleaseFormValues Function(T value);

List<LibraryFieldSpec<T>> tvSeriesIdentityFields<T>({
  required TvSeriesValuesReader<T> values,
  bool includeTitle = true,
}) =>
    [
      if (includeTitle)
        LibraryTextFieldSpec<T>(
          id: 'title',
          label: 'Title',
          value: (draft) => values(draft).title,
          setValue: (draft, value) => values(draft).title = value,
        ),
      LibraryTextFieldSpec<T>(
        id: 'sort_title',
        label: 'Sort title',
        value: (draft) => values(draft).sortTitle,
        setValue: (draft, value) => values(draft).sortTitle = value,
      ),
      LibraryTextFieldSpec<T>(
        id: 'description',
        label: 'Synopsis',
        value: (draft) => values(draft).description,
        setValue: (draft, value) => values(draft).description = value,
        maxLines: 4,
      ),
    ];

List<LibraryFieldSpec<T>> tvSeriesBroadcastFields<T>({
  required TvSeriesValuesReader<T> values,
  Iterable<String>? networkOptions,
  FutureOr<void> Function()? onManageNetwork,
}) =>
    [
      LibraryVocabularyFieldSpec<T, String>(
        id: 'network',
        label: 'Network / studio',
        value: (draft) => _nullable(values(draft).network),
        setValue: (draft, value) => values(draft).network = value ?? '',
        options: _options(
          networkOptions ?? TvVocabularies.network.builtIns,
        ),
        onManage: onManageNetwork == null ? null : (_) => onManageNetwork(),
      ),
      LibraryTextFieldSpec<T>(
        id: 'status',
        label: 'Status',
        value: (draft) => values(draft).status,
        setValue: (draft, value) => values(draft).status = value,
      ),
      LibraryTextFieldSpec<T>(
        id: 'streaming_service',
        label: 'Streaming service',
        value: (draft) => values(draft).streamingService,
        setValue: (draft, value) => values(draft).streamingService = value,
      ),
      LibraryTextFieldSpec<T>(
        id: 'original_language',
        label: 'Original language',
        value: (draft) => values(draft).originalLanguage,
        setValue: (draft, value) => values(draft).originalLanguage = value,
      ),
    ];

List<LibraryFieldSpec<T>> tvSeriesClassificationFields<T>({
  required TvSeriesValuesReader<T> values,
}) =>
    [
      LibraryTextFieldSpec<T>(
        id: 'genres',
        label: 'Genres',
        value: (draft) => values(draft).genres.join(', '),
        setValue: (draft, value) => values(draft).genres = _split(value),
      ),
      LibraryTextFieldSpec<T>(
        id: 'content_rating',
        label: 'Content rating',
        value: (draft) => values(draft).contentRating,
        setValue: (draft, value) => values(draft).contentRating = value,
      ),
      LibraryDateFieldSpec<T>(
        id: 'first_air_date',
        label: 'First air date',
        value: (draft) => values(draft).originalAirDate,
        setValue: (draft, value) => values(draft).originalAirDate = value,
      ),
      LibraryDateFieldSpec<T>(
        id: 'end_date',
        label: 'End date',
        value: (draft) => values(draft).endDate,
        setValue: (draft, value) => values(draft).endDate = value,
      ),
    ];

List<LibraryFieldSpec<T>> tvReleaseIdentityFields<T>({
  required TvReleaseValuesReader<T> values,
  Iterable<String>? formatOptions,
  Iterable<String>? regionOptions,
  FutureOr<void> Function()? onManageFormat,
  FutureOr<void> Function()? onManageRegion,
}) =>
    [
      LibraryTextFieldSpec<T>(
        id: 'title',
        label: 'Title',
        value: (draft) => values(draft).title,
        setValue: (draft, value) => values(draft).title = value,
      ),
      LibraryTextFieldSpec<T>(
        id: 'sort_title',
        label: 'Sort title',
        value: (draft) => values(draft).sortTitle,
        setValue: (draft, value) => values(draft).sortTitle = value,
      ),
      LibraryVocabularyFieldSpec<T, String>(
        id: 'format',
        label: 'Format',
        value: (draft) => _nullable(values(draft).format),
        setValue: (draft, value) => values(draft).format = value ?? '',
        options: _options(
          formatOptions ?? TvVocabularies.physicalFormat.builtIns,
        ),
        onManage: onManageFormat == null ? null : (_) => onManageFormat(),
      ),
      LibraryVocabularyFieldSpec<T, String>(
        id: 'region',
        label: 'Region',
        value: (draft) => _nullable(values(draft).region),
        setValue: (draft, value) => values(draft).region = value ?? '',
        options: _options(regionOptions ?? TvVocabularies.region.builtIns),
        onManage: onManageRegion == null ? null : (_) => onManageRegion(),
      ),
      LibraryDateFieldSpec<T>(
        id: 'release_date',
        label: 'Release date',
        value: (draft) => values(draft).releaseDate,
        setValue: (draft, value) => values(draft).releaseDate = value,
      ),
    ];

List<LibraryFieldSpec<T>> tvReleasePublishingFields<T>({
  required TvReleaseValuesReader<T> values,
}) =>
    [
      _text<T>(
        id: 'publisher',
        label: 'Publisher',
        value: (draft) => values(draft).publisher,
        setValue: (draft, value) => values(draft).publisher = value,
      ),
      _text<T>(
        id: 'barcode',
        label: 'SKU / barcode',
        value: (draft) => values(draft).barcode,
        setValue: (draft, value) => values(draft).barcode = value,
      ),
      _text<T>(
        id: 'case_type',
        label: 'Case type',
        value: (draft) => values(draft).caseType,
        setValue: (draft, value) => values(draft).caseType = value,
      ),
      _text<T>(
        id: 'description',
        label: 'Description',
        value: (draft) => values(draft).description,
        setValue: (draft, value) => values(draft).description = value,
        maxLines: 4,
      ),
      _text<T>(
        id: 'content_rating',
        label: 'Content rating',
        value: (draft) => values(draft).contentRating,
        setValue: (draft, value) => values(draft).contentRating = value,
      ),
      _text<T>(
        id: 'audio',
        label: 'Audio languages',
        value: (draft) => values(draft).audioLanguages.join(', '),
        setValue: (draft, value) =>
            values(draft).audioLanguages = _split(value),
      ),
      _text<T>(
        id: 'subtitles',
        label: 'Subtitle languages',
        value: (draft) => values(draft).subtitleLanguages.join(', '),
        setValue: (draft, value) =>
            values(draft).subtitleLanguages = _split(value),
      ),
      LibraryImageFieldSpec<T, String>(
        id: 'cover_image_url',
        label: 'Cover image URL',
        value: (draft) => _nullable(values(draft).coverImageUrl),
        setValue: (draft, value) => values(draft).coverImageUrl = value ?? '',
      ),
    ];

LibraryTextFieldSpec<T> _text<T>({
  required String id,
  required String label,
  required String Function(T draft) value,
  required void Function(T draft, String value) setValue,
  int maxLines = 1,
}) =>
    LibraryTextFieldSpec<T>(
      id: id,
      label: label,
      value: value,
      setValue: setValue,
      maxLines: maxLines,
    );

String? _nullable(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
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
