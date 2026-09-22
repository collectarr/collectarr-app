import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/providers/adapters/tmdb/tmdb_import_kind_contribution.dart';
import 'package:collectarr_app/features/providers/adapters/tmdb/tmdb_import_service.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';

/// TMDb import mapping owned by Anime.
final class AnimeTmdbImportContribution implements TmdbImportKindContribution {
  const AnimeTmdbImportContribution();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.anime;

  @override
  bool accepts(TmdbImportEntry entry) =>
      entry.mediaType == TmdbMediaType.tv && _looksLikeAnime(entry);

  @override
  CatalogSearchCandidate localSyntheticCatalogItem(TmdbImportEntry entry) {
    final metadata = AnimeMetadata(
      title: entry.title,
      startDate: entry.releaseDate,
      seasonYear: entry.releaseYear,
    );
    return CatalogSearchCandidate.fromItem(
      CatalogItemDto.raw(
        id: _localItemId(entry),
        mediaKind: kind,
        common: CatalogCommonDto(
          title: entry.title,
          originalTitle: entry.originalTitle,
          synopsis: entry.overview,
          coverImageUrl: entry.posterUrl,
          releaseDate: entry.releaseDate,
          releaseYear: entry.releaseYear,
        ),
        kindMetadata: metadata,
      ),
    );
  }

  @override
  CatalogSearchCandidate localSyntheticSeasonCatalogItem(
    TmdbImportEntry seriesEntry,
    TmdbImportEntry seasonEntry,
  ) {
    throw UnsupportedError('Anime imports do not use TMDb seasons.');
  }

  @override
  CatalogSearchCandidate mergeMatchedCatalogItem(
    CatalogSearchCandidate item,
    TmdbImportEntry entry,
  ) {
    final current = requireProviderKindMetadata<AnimeMetadata>(item);
    final genres = _distinct([
      ...current.genres,
      ..._namedValues(entry.rawPayload['genres']),
    ]);
    final studios = _namedValues(entry.rawPayload['production_companies']);
    final countries = _distinct([
      ..._namedValues(entry.rawPayload['production_countries']),
      ..._stringValues(entry.rawPayload['origin_country']),
    ]);
    final languages = _distinct([
      ..._namedValues(entry.rawPayload['spoken_languages']),
      _text(entry.rawPayload['original_language']),
    ]);
    final runtimeMinutes = _runtimeMinutes(entry.rawPayload);
    final metadata = current.copyWith(
      genres: genres,
      studios: studios.isNotEmpty ? studios : current.studios,
      country: countries.isNotEmpty
          ? _first(current.country, countries.join(', '))
          : current.country,
      language: languages.isNotEmpty
          ? _first(current.language, languages.join(', '))
          : current.language,
      publisher: studios.isNotEmpty
          ? _first(current.publisher, studios.join(', '))
          : current.publisher,
      episodeRuntimeMinutes: runtimeMinutes ?? current.episodeRuntimeMinutes,
    );
    final aliases = _distinct([
      ...item.editMetadata.searchAliases,
      item.title,
      item.editMetadata.displayTitle,
      item.editMetadata.localizedTitle,
      item.editMetadata.originalTitle,
      entry.title,
      entry.originalTitle,
    ]);
    return item
        .copyWith(
          displayTitle: item.editMetadata.displayTitle ?? entry.title,
          localizedTitle: item.editMetadata.localizedTitle ?? entry.title,
          originalTitle: item.editMetadata.originalTitle ?? entry.originalTitle,
          searchAliases: aliases,
          synopsis: _first(item.editMetadata.synopsis, entry.overview),
          coverImageUrl:
              _first(item.editMetadata.coverImageUrl, entry.posterUrl),
          thumbnailImageUrl: _first(
            item.editMetadata.thumbnailImageUrl,
            item.editMetadata.coverImageUrl,
            entry.posterUrl,
          ),
          releaseDate: item.editMetadata.releaseDate ?? entry.releaseDate,
          releaseYear: item.editMetadata.releaseYear ?? entry.releaseYear,
        )
        .withKindMetadata(metadata);
  }

  @override
  bool hasMeaningfulChanges(
    CatalogSearchCandidate current,
    CatalogSearchCandidate next,
  ) {
    return current.editMetadata.displayTitle !=
            next.editMetadata.displayTitle ||
        current.editMetadata.localizedTitle !=
            next.editMetadata.localizedTitle ||
        current.editMetadata.originalTitle != next.editMetadata.originalTitle ||
        current.editMetadata.synopsis != next.editMetadata.synopsis ||
        current.editMetadata.coverImageUrl != next.editMetadata.coverImageUrl ||
        current.editMetadata.thumbnailImageUrl !=
            next.editMetadata.thumbnailImageUrl ||
        current.editMetadata.releaseDate != next.editMetadata.releaseDate ||
        current.editMetadata.releaseYear != next.editMetadata.releaseYear ||
        !_deepEqual(current.toSyncPayload(), next.toSyncPayload());
  }

  @override
  ProviderPersonalEntry personalEntryFor(TmdbImportEntry entry) {
    return ProviderPersonalEntry(
      provider: ProviderId.tmdb,
      remoteItemId: entry.providerItemId,
      kind: kind,
      title: entry.title,
      status: entry.collection.isRated
          ? ProviderEntryStatus.completed
          : ProviderEntryStatus.planning,
      rating: entry.rating == null
          ? null
          : (entry.rating!.toDouble() * 10).round().clamp(0, 100).toDouble(),
      externalIds: <String, String>{'tmdb': entry.tmdbId.toString()},
      rawPayload: entry.toJson(),
    );
  }

  static String _localItemId(TmdbImportEntry entry) =>
      'tmdb-local:${entry.mediaType.name}:${entry.tmdbId}';

  static bool _looksLikeAnime(TmdbImportEntry entry) {
    final raw = entry.rawPayload;
    var hasAnimation = false;
    final genreIds = raw['genre_ids'];
    if (genreIds is List) hasAnimation = genreIds.contains(16);
    final genres = raw['genres'];
    if (!hasAnimation && genres is List) {
      hasAnimation = genres.any(
        (value) =>
            value is Map && (value['id'] == 16 || value['name'] == 'Animation'),
      );
    }
    if (!hasAnimation) return false;
    if (raw['original_language'] == 'ja') return true;
    final originCountry = raw['origin_country'];
    if (originCountry is List && originCountry.contains('JP')) return true;
    final productionCountries = raw['production_countries'];
    return productionCountries is List &&
        productionCountries.any(
          (value) =>
              value is Map &&
              (value['iso_3166_1'] == 'JP' || value['name'] == 'Japan'),
        );
  }

  static List<String> _namedValues(Object? value) {
    if (value is! List) return const <String>[];
    return _distinct(
      value.whereType<Map<Object?, Object?>>().map((row) => _text(row['name'])),
    );
  }

  static List<String> _stringValues(Object? value) {
    if (value is! List) return const <String>[];
    return _distinct(value.whereType<String>());
  }

  static int? _runtimeMinutes(Map<String, dynamic> raw) {
    final runtime = raw['runtime'];
    return runtime is num ? runtime.round() : null;
  }

  static List<String> _distinct(Iterable<String?> values) {
    final result = <String>{};
    for (final value in values) {
      final normalized = _text(value);
      if (normalized != null) result.add(normalized);
    }
    return result.toList(growable: false);
  }

  static String? _first(String? first, [String? second, String? third]) {
    for (final value in [first, second, third]) {
      final normalized = _text(value);
      if (normalized != null) return normalized;
    }
    return null;
  }

  static String? _text(Object? value) {
    final normalized = value?.toString().trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  static bool _deepEqual(Object? left, Object? right) {
    if (identical(left, right)) return true;
    if (left is Map && right is Map) {
      if (left.length != right.length) return false;
      for (final entry in left.entries) {
        if (!right.containsKey(entry.key) ||
            !_deepEqual(entry.value, right[entry.key])) {
          return false;
        }
      }
      return true;
    }
    if (left is List && right is List) {
      if (left.length != right.length) return false;
      for (var index = 0; index < left.length; index++) {
        if (!_deepEqual(left[index], right[index])) return false;
      }
      return true;
    }
    return left == right;
  }
}
