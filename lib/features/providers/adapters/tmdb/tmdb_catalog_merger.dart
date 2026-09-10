import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/providers/adapters/tmdb/tmdb_import_service.dart';

/// Provider-layer adapter responsible for building synthetic catalog items
/// and merging TMDB metadata into catalog DTOs.
class TmdbCatalogMerger {
  const TmdbCatalogMerger();

  String localSyntheticItemId(TmdbImportEntry entry) {
    return 'tmdb-local:${entry.mediaType.name}:${entry.tmdbId}';
  }

  CatalogItemDto localSyntheticCatalogItem(TmdbImportEntry entry) {
    final kind = entry.looksLikeAnime
        ? CatalogMediaKind.anime
        : entry.mediaType == TmdbMediaType.tv
            ? CatalogMediaKind.tv
            : CatalogMediaKind.movie;
    final common = CatalogCommonDto(
      title: entry.title,
      displayTitle: entry.title,
      localizedTitle: entry.title,
      originalTitle: entry.originalTitle,
      searchAliases: [
        entry.title,
        if (entry.originalTitle?.trim().isNotEmpty == true)
          entry.originalTitle!,
      ],
      synopsis: entry.overview,
      coverImageUrl: entry.posterUrl,
      thumbnailImageUrl: entry.posterUrl,
      releaseDate: entry.releaseDate,
      releaseYear: entry.releaseYear,
    );
    return CatalogItemDto.raw(
      id: localSyntheticItemId(entry),
      mediaKind: kind,
      common: common,
      payload: const {},
    );
  }

  String localSyntheticSeasonItemId(
    TmdbImportEntry seriesEntry,
    TmdbImportEntry seasonEntry,
  ) {
    final seasonNumber =
        (seasonEntry.rawPayload['season_number'] as num?)?.toInt() ??
            seasonEntry.tmdbId;
    return 'tmdb-local:${seriesEntry.mediaType.name}:${seriesEntry.tmdbId}:season:$seasonNumber';
  }

  CatalogItemDto localSyntheticSeasonCatalogItem(
    TmdbImportEntry seriesEntry,
    TmdbImportEntry seasonEntry,
  ) {
    final seasonNumber =
        (seasonEntry.rawPayload['season_number'] as num?)?.toInt() ??
            seasonEntry.tmdbId;
    final common = CatalogCommonDto(
      title: seasonEntry.title,
      displayTitle: seasonEntry.title,
      localizedTitle: seasonEntry.title,
      originalTitle: seasonEntry.originalTitle,
      searchAliases: [
        seasonEntry.title,
        if (seasonEntry.originalTitle?.trim().isNotEmpty == true)
          seasonEntry.originalTitle!,
        'Season $seasonNumber',
      ],
      synopsis: seasonEntry.overview,
      coverImageUrl: seasonEntry.posterUrl,
      thumbnailImageUrl: seasonEntry.posterUrl,
      releaseDate: seasonEntry.releaseDate,
      releaseYear: seasonEntry.releaseYear,
    );
    return CatalogItemDto.raw(
      id: localSyntheticSeasonItemId(seriesEntry, seasonEntry),
      mediaKind: CatalogMediaKind.tv,
      common: common,
      payload: {
        'item_number': 'Season $seasonNumber',
      },
    );
  }

  CatalogItemDto mergeMatchedCatalogItem(
    CatalogItemDto item,
    TmdbImportEntry entry,
  ) {
    final aliases = <String>{
      if (item.searchAliases case final currentAliases?) ...currentAliases,
      if (item.title.trim().isNotEmpty) item.title.trim(),
      if (item.displayTitle?.trim().isNotEmpty == true)
        item.displayTitle!.trim(),
      if (item.localizedTitle?.trim().isNotEmpty == true)
        item.localizedTitle!.trim(),
      if (item.originalTitle?.trim().isNotEmpty == true)
        item.originalTitle!.trim(),
      if (entry.title.trim().isNotEmpty) entry.title.trim(),
      if (entry.originalTitle?.trim().isNotEmpty == true)
        entry.originalTitle!.trim(),
    }.toList(growable: false);
    final currentPayload = item.toSyncPayload();
    final tmdbGenres = _distinctNonEmptyStrings([
      ...?((currentPayload['genres'] as List?)?.map((e) => e.toString())),
      ..._tmdbNamedValues(entry.rawPayload['genres']),
    ]);
    final tmdbStudios =
        _tmdbNamedValues(entry.rawPayload['production_companies']);
    final tmdbCountries = _distinctNonEmptyStrings([
      ..._tmdbNamedValues(entry.rawPayload['production_countries']),
      ..._tmdbStringValues(entry.rawPayload['origin_country']),
    ]);
    final tmdbLanguages = _distinctNonEmptyStrings([
      ..._tmdbNamedValues(entry.rawPayload['spoken_languages']),
      _normalizedText(entry.rawPayload['original_language'] as String?),
    ]);
    final runtimeMinutes = _runtimeMinutesFromRawJson(entry.rawPayload);
    final videoPayload = (currentPayload['video'] as Map?) ?? currentPayload;
    final mergedVideo = <String, dynamic>{
      if (currentPayload['video'] is Map)
        ...Map<String, dynamic>.from(currentPayload['video'] as Map),
      if (runtimeMinutes != null || videoPayload['runtime_minutes'] != null)
        'runtime_minutes': videoPayload['runtime_minutes'] ?? runtimeMinutes,
    };
    final mergedPayload = <String, dynamic>{
      ...item.payload,
      if (runtimeMinutes != null || currentPayload['video'] != null)
        'video': mergedVideo,
      if (tmdbGenres.isNotEmpty) 'genres': tmdbGenres,
      if (tmdbCountries.isNotEmpty)
        'country': _firstNonEmptyText(
            currentPayload['country'] as String?, tmdbCountries.join(', ')),
      if (tmdbLanguages.isNotEmpty)
        'language': _firstNonEmptyText(
            currentPayload['language'] as String?, tmdbLanguages.join(', ')),
      if (tmdbStudios.isNotEmpty)
        'publisher': _firstNonEmptyText(
            currentPayload['publisher'] as String?, tmdbStudios.join(', ')),
    };
    final common = CatalogCommonDto(
      title: item.title,
      displayTitle: item.displayTitle ?? entry.title,
      localizedTitle: item.localizedTitle ?? entry.title,
      originalTitle: item.originalTitle ?? entry.originalTitle,
      searchAliases: aliases,
      synopsis: _firstNonEmptyText(item.synopsis, entry.overview),
      coverImageUrl: _firstNonEmptyText(item.coverImageUrl, entry.posterUrl),
      thumbnailImageUrl: _firstNonEmptyText(
        item.thumbnailImageUrl,
        item.coverImageUrl,
        entry.posterUrl,
      ),
      coverImageData: item.coverImageData,
      releaseDate: item.releaseDate ?? entry.releaseDate,
      releaseYear: item.releaseYear ?? entry.releaseYear,
      editions: item.editions,
    );
    return CatalogItemDto.raw(
      id: item.id,
      mediaKind: item.mediaKind,
      common: common,
      payload: mergedPayload,
    );
  }

  bool hasMeaningfulChanges(
    CatalogItemDto current,
    CatalogItemDto next,
  ) {
    return current.displayTitle != next.displayTitle ||
        current.localizedTitle != next.localizedTitle ||
        current.originalTitle != next.originalTitle ||
        current.synopsis != next.synopsis ||
        current.coverImageUrl != next.coverImageUrl ||
        current.thumbnailImageUrl != next.thumbnailImageUrl ||
        current.releaseDate != next.releaseDate ||
        current.releaseYear != next.releaseYear ||
        current.payload != next.payload ||
        current.displayCoverUrl != next.displayCoverUrl;
  }

  static String? _normalizedText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  static List<String> _distinctNonEmptyStrings(Iterable<String?> values) {
    final normalized = <String>{};
    for (final value in values) {
      final trimmed = _normalizedText(value);
      if (trimmed != null) {
        normalized.add(trimmed);
      }
    }
    return normalized.toList(growable: false);
  }

  static List<String> _tmdbNamedValues(Object? value) {
    if (value is! List) {
      return const <String>[];
    }
    return _distinctNonEmptyStrings(
      value.whereType<Map<dynamic, dynamic>>().map(
            (row) => _normalizedText(row['name'] as String?),
          ),
    );
  }

  static List<String> _tmdbStringValues(Object? value) {
    if (value is! List) {
      return const <String>[];
    }
    return _distinctNonEmptyStrings(value.whereType<String>());
  }

  static int? _runtimeMinutesFromRawJson(Map<String, dynamic> rawJson) {
    final runtime = rawJson['runtime'];
    if (runtime is num) {
      return runtime.round();
    }
    return null;
  }

  static String? _firstNonEmptyText(String? first,
      [String? second, String? third]) {
    for (final candidate in [first, second, third]) {
      final normalized = _normalizedText(candidate);
      if (normalized != null) {
        return normalized;
      }
    }
    return null;
  }
}
