import 'dart:async';

import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/vocabulary/boardgame_vocabularies.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec.dart';

typedef BoardGameFormValuesReader<TDraft> = BoardGameCatalogFormValues
    Function(TDraft draft);

List<LibraryFieldSpec<TDraft>> boardGameWorkFields<TDraft>({
  required BoardGameFormValuesReader<TDraft> values,
  bool includeTitle = true,
  Set<String>? include,
  Iterable<String>? publisherOptions,
  Iterable<String>? categoryOptions,
  FutureOr<void> Function()? onManagePublisher,
}) =>
    [
      if (includeTitle)
        LibraryTextFieldSpec<TDraft>(
          id: 'title', label: 'Title',
          value: (draft) => values(draft).title,
          setValue: (draft, value) => values(draft).title = value,
        ),
      LibraryTextFieldSpec<TDraft>(
        id: 'original_title', label: 'Original title',
        value: (draft) => values(draft).originalTitle,
        setValue: (draft, value) => values(draft).originalTitle = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'sort_title', label: 'Sort title',
        value: (draft) => values(draft).sortTitle,
        setValue: (draft, value) => values(draft).sortTitle = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'subtitle', label: 'Subtitle',
        value: (draft) => values(draft).subtitle,
        setValue: (draft, value) => values(draft).subtitle = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'description', label: 'Description', maxLines: 4,
        value: (draft) => values(draft).description,
        setValue: (draft, value) => values(draft).description = value,
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'publisher', label: 'Publisher',
        value: (draft) => _nullable(values(draft).publisher),
        setValue: (draft, value) => values(draft).publisher = value ?? '',
        options: _options(publisherOptions ?? BoardGameVocabularies.publisher.builtIns),
        pickListKey: BoardGameVocabularyIds.publisher.value,
        onManage: onManagePublisher == null ? null : (_) => onManagePublisher(),
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'platforms', label: 'Platforms',
        value: (draft) => values(draft).platforms.join(', '),
        setValue: (draft, value) => values(draft).platforms = _split(value),
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'identifiers', label: 'Identifiers',
        value: (draft) => values(draft).identifiers.join(', '),
        setValue: (draft, value) => values(draft).identifiers = _split(value),
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'contributors', label: 'Contributors',
        value: (draft) => values(draft).contributors.join(', '),
        setValue: (draft, value) => values(draft).contributors = _split(value),
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'designers', label: 'Designer(s)',
        value: (draft) => values(draft).designers.join(', '),
        setValue: (draft, value) => values(draft).designers = _split(value),
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'artists', label: 'Artists',
        value: (draft) => values(draft).artists.join(', '),
        setValue: (draft, value) => values(draft).artists = _split(value),
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'characters', label: 'Characters',
        value: (draft) => values(draft).characters.join(', '),
        setValue: (draft, value) => values(draft).characters = _split(value),
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'mechanics', label: 'Mechanics',
        value: (draft) => values(draft).mechanics.join(', '),
        setValue: (draft, value) => values(draft).mechanics = _split(value),
      ),
      LibraryMultiVocabularyFieldSpec<TDraft, String>(
        id: 'categories', label: 'Categories',
        values: (draft) => values(draft).categories.toSet(),
        setValues: (draft, next) => values(draft).categories = next.toList(growable: false),
        options: _options(categoryOptions ?? BoardGameVocabularies.category.builtIns),
        pickListKey: BoardGameVocabularyIds.category.value,
        allowCustomValues: true,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'families', label: 'Families',
        value: (draft) => values(draft).families.join(', '),
        setValue: (draft, value) => values(draft).families = _split(value),
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'themes', label: 'Themes',
        value: (draft) => values(draft).themes.join(', '),
        setValue: (draft, value) => values(draft).themes = _split(value),
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'expansions', label: 'Expansions',
        value: (draft) => values(draft).expansions.join(', '),
        setValue: (draft, value) => values(draft).expansions = _split(value),
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'expansion_for', label: 'Expansion for',
        value: (draft) => values(draft).expansionFor,
        setValue: (draft, value) => values(draft).expansionFor = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'rankings', label: 'Rankings',
        value: (draft) => values(draft).rankings.join(', '),
        setValue: (draft, value) => values(draft).rankings = _split(value),
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'search_aliases', label: 'Search aliases',
        value: (draft) => values(draft).searchAliases.join(', '),
        setValue: (draft, value) => values(draft).searchAliases = _split(value),
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'original_language', label: 'Original language',
        value: (draft) => values(draft).originalLanguage,
        setValue: (draft, value) => values(draft).originalLanguage = value,
      ),
      LibraryDateFieldSpec<TDraft>(
        id: 'work_release_date', label: 'First publication date',
        value: (draft) => values(draft).workReleaseDate,
        setValue: (draft, value) => values(draft).workReleaseDate = value,
      ),
      LibraryNumberFieldSpec<TDraft>(
        id: 'year_published', label: 'Year published', minimum: 1,
        value: (draft) => values(draft).yearPublished,
        setValue: (draft, value) => values(draft).yearPublished = value?.toInt(),
      ),
      _number<TDraft>(id: 'min_players', label: 'Minimum players', read: (draft) => values(draft).minPlayers, write: (draft, value) => values(draft).minPlayers = value, minimum: 1),
      _number<TDraft>(id: 'max_players', label: 'Maximum players', read: (draft) => values(draft).maxPlayers, write: (draft, value) => values(draft).maxPlayers = value, minimum: 1),
      LibraryTextFieldSpec<TDraft>(
        id: 'recommended_players', label: 'Recommended players',
        value: (draft) => values(draft).recommendedPlayers,
        setValue: (draft, value) => values(draft).recommendedPlayers = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'best_players', label: 'Best player count',
        value: (draft) => values(draft).bestPlayers,
        setValue: (draft, value) => values(draft).bestPlayers = value,
      ),
      _number<TDraft>(id: 'min_playtime_minutes', label: 'Minimum play time (minutes)', read: (draft) => values(draft).minPlaytimeMinutes, write: (draft, value) => values(draft).minPlaytimeMinutes = value, minimum: 0),
      _number<TDraft>(id: 'max_playtime_minutes', label: 'Maximum play time (minutes)', read: (draft) => values(draft).maxPlaytimeMinutes, write: (draft, value) => values(draft).maxPlaytimeMinutes = value, minimum: 0),
      _number<TDraft>(id: 'minimum_age', label: 'Minimum age', read: (draft) => values(draft).minimumAge, write: (draft, value) => values(draft).minimumAge = value, minimum: 0),
      LibraryNumberFieldSpec<TDraft>(
        id: 'complexity_weight', label: 'Complexity weight', minimum: 0,
        value: (draft) => values(draft).complexityWeight,
        setValue: (draft, value) => values(draft).complexityWeight = value?.toDouble(),
      ),
      LibraryNumberFieldSpec<TDraft>(
        id: 'bgg_rating', label: 'BoardGameGeek rating', minimum: 0,
        value: (draft) => values(draft).bggRating,
        setValue: (draft, value) => values(draft).bggRating = value?.toDouble(),
      ),
      _number<TDraft>(id: 'bgg_rating_count', label: 'Rating count', read: (draft) => values(draft).bggRatingCount, write: (draft, value) => values(draft).bggRatingCount = value, minimum: 0),
      _number<TDraft>(id: 'bgg_rank', label: 'BoardGameGeek rank', read: (draft) => values(draft).bggRank, write: (draft, value) => values(draft).bggRank = value, minimum: 1),
      LibraryTextFieldSpec<TDraft>(
        id: 'series_title', label: 'Series',
        value: (draft) => values(draft).seriesTitle,
        setValue: (draft, value) => values(draft).seriesTitle = value,
      ),
    ].where((field) => include == null || include.contains(field.id)).toList();

List<LibraryFieldSpec<TDraft>> boardGameEditionFields<TDraft>({
  required BoardGameFormValuesReader<TDraft> values,
  Set<String>? include,
  Iterable<String>? publisherOptions,
  Iterable<String>? formatOptions,
  FutureOr<void> Function()? onManagePublisher,
}) =>
    [
      LibraryTextFieldSpec<TDraft>(
        id: 'title', label: 'Title',
        value: (draft) => values(draft).releaseTitle,
        setValue: (draft, value) => values(draft).releaseTitle = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'edition_title', label: 'Edition title',
        value: (draft) => values(draft).editionTitle,
        setValue: (draft, value) => values(draft).editionTitle = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'barcode', label: 'Barcode',
        value: (draft) => values(draft).barcode,
        setValue: (draft, value) => values(draft).barcode = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'catalog_number', label: 'Catalog number',
        value: (draft) => values(draft).catalogNumber,
        setValue: (draft, value) => values(draft).catalogNumber = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'item_number', label: 'Item number',
        value: (draft) => values(draft).itemNumber,
        setValue: (draft, value) => values(draft).itemNumber = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'variant', label: 'Variant',
        value: (draft) => values(draft).variant,
        setValue: (draft, value) => values(draft).variant = value,
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'format', label: 'Format',
        value: (draft) => _nullable(values(draft).format),
        setValue: (draft, value) => values(draft).format = value ?? '',
        options: _options(formatOptions ?? BoardGameVocabularies.format.builtIns),
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'publisher', label: 'Publisher',
        value: (draft) => _nullable(values(draft).editionPublisher),
        setValue: (draft, value) => values(draft).editionPublisher = value ?? '',
        options: _options(publisherOptions ?? BoardGameVocabularies.publisher.builtIns),
        pickListKey: BoardGameVocabularyIds.publisher.value,
        onManage: onManagePublisher == null ? null : (_) => onManagePublisher(),
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'country', label: 'Country / region',
        value: (draft) => values(draft).country,
        setValue: (draft, value) => values(draft).country = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'language', label: 'Language',
        value: (draft) => values(draft).language,
        setValue: (draft, value) => values(draft).language = value,
      ),
      LibraryDateFieldSpec<TDraft>(
        id: 'release_date', label: 'Release date',
        value: (draft) => values(draft).releaseDate,
        setValue: (draft, value) => values(draft).releaseDate = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'release_status', label: 'Release status',
        value: (draft) => values(draft).releaseStatus,
        setValue: (draft, value) => values(draft).releaseStatus = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'age_rating', label: 'Age rating',
        value: (draft) => values(draft).ageRating,
        setValue: (draft, value) => values(draft).ageRating = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'audience_rating', label: 'Audience rating',
        value: (draft) => values(draft).audienceRating,
        setValue: (draft, value) => values(draft).audienceRating = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'cover_image_url', label: 'Cover image URL',
        value: (draft) => values(draft).coverImageUrl,
        setValue: (draft, value) => values(draft).coverImageUrl = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'back_cover_image_url', label: 'Back cover image URL',
        value: (draft) => values(draft).backCoverImageUrl,
        setValue: (draft, value) => values(draft).backCoverImageUrl = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'description', label: 'Description', maxLines: 4,
        value: (draft) => values(draft).editionDescription,
        setValue: (draft, value) => values(draft).editionDescription = value,
      ),
      _number<TDraft>(id: 'min_players', label: 'Minimum players', read: (draft) => values(draft).editionMinPlayers, write: (draft, value) => values(draft).editionMinPlayers = value, minimum: 1),
      _number<TDraft>(id: 'max_players', label: 'Maximum players', read: (draft) => values(draft).editionMaxPlayers, write: (draft, value) => values(draft).editionMaxPlayers = value, minimum: 1),
      _number<TDraft>(id: 'min_age', label: 'Minimum age', read: (draft) => values(draft).editionMinAge, write: (draft, value) => values(draft).editionMinAge = value, minimum: 0),
      _number<TDraft>(id: 'playing_time_minutes', label: 'Playing time (minutes)', read: (draft) => values(draft).playingTimeMinutes, write: (draft, value) => values(draft).playingTimeMinutes = value, minimum: 0),
    ].where((field) => include == null || include.contains(field.id)).toList();

LibraryNumberFieldSpec<TDraft> _number<TDraft>({
  required String id,
  required String label,
  required int? Function(TDraft draft) read,
  required void Function(TDraft draft, int? value) write,
  double? minimum,
}) =>
    LibraryNumberFieldSpec<TDraft>(
      id: id,
      label: label,
      value: (draft) => read(draft)?.toDouble(),
      setValue: (draft, value) => write(draft, value?.toInt()),
      minimum: minimum,
    );

String? _nullable(String value) => value.trim().isEmpty ? null : value;

List<LibraryFieldOption<String>> _options(Iterable<String> values) => [
      for (final value in values) LibraryFieldOption(value: value, label: value),
    ];

List<String> _split(String value) => value
    .split(RegExp(r'[,;\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);
