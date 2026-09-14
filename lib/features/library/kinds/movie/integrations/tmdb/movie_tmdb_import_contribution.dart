import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/providers/adapters/tmdb/tmdb_import_kind_contribution.dart';
import 'package:collectarr_app/features/providers/adapters/tmdb/tmdb_import_service.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';

/// TMDb import mapping owned by Movie.
final class MovieTmdbImportContribution implements TmdbImportKindContribution {
  const MovieTmdbImportContribution();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.movie;

  @override
  bool accepts(TmdbImportEntry entry) => entry.mediaType == TmdbMediaType.movie;

  @override
  CatalogSearchCandidate localSyntheticCatalogItem(TmdbImportEntry entry) {
    final metadata = MovieCatalogMetadata.fromJson(_entryPayload(entry));
    return providerCandidateFromTypedPayload(
      kind: kind,
      id: _localItemId(entry),
      payload: metadata.toJson(),
      typedMetadata: metadata,
    );
  }

  @override
  CatalogSearchCandidate localSyntheticSeasonCatalogItem(
    TmdbImportEntry seriesEntry,
    TmdbImportEntry seasonEntry,
  ) {
    throw UnsupportedError('Movie imports do not have season entities.');
  }

  @override
  CatalogSearchCandidate mergeMatchedCatalogItem(
    CatalogSearchCandidate item,
    TmdbImportEntry entry,
  ) {
    final current = MovieCatalogMetadata.fromJson(item.toSyncPayload());
    final genres = _distinct([
      ...current.genres,
      ..._namedValues(entry.rawPayload['genres']),
    ]);
    final companies = _namedValues(entry.rawPayload['production_companies']);
    final countries = _distinct([
      ..._namedValues(entry.rawPayload['production_countries']),
      ..._stringValues(entry.rawPayload['origin_country']),
    ]);
    final languages = _distinct([
      ..._namedValues(entry.rawPayload['spoken_languages']),
      _text(entry.rawPayload['original_language']),
    ]);
    final runtimeMinutes = _runtimeMinutes(entry.rawPayload);
    final payload = <String, dynamic>{
      ...current.toJson(),
      if (genres.isNotEmpty) 'genres': genres,
      if (countries.isNotEmpty)
        'country': _first(current.country, countries.join(', ')),
      if (languages.isNotEmpty)
        'language': _first(current.language, languages.join(', ')),
      if (companies.isNotEmpty)
        'publisher': _first(current.publisher, companies.join(', ')),
      if (runtimeMinutes != null) 'runtime_minutes': runtimeMinutes,
    };
    final metadata = MovieCatalogMetadata.fromJson(payload);
    final aliases = _distinct([
      ...(item.searchAliases ?? const <String>[]),
      item.title,
      item.displayTitle,
      item.localizedTitle,
      item.originalTitle,
      entry.title,
      entry.originalTitle,
    ]);
    return item
        .copyWith(
          displayTitle: item.displayTitle ?? entry.title,
          localizedTitle: item.localizedTitle ?? entry.title,
          originalTitle: item.originalTitle ?? entry.originalTitle,
          searchAliases: aliases,
          synopsis: _first(item.synopsis, entry.overview),
          coverImageUrl: _first(item.coverImageUrl, entry.posterUrl),
          thumbnailImageUrl: _first(
            item.thumbnailImageUrl,
            item.coverImageUrl,
            entry.posterUrl,
          ),
          releaseDate: item.releaseDate ?? entry.releaseDate,
          releaseYear: item.releaseYear ?? entry.releaseYear,
        )
        .withKindMetadata(metadata);
  }

  @override
  bool hasMeaningfulChanges(
    CatalogSearchCandidate current,
    CatalogSearchCandidate next,
  ) {
    return current.displayTitle != next.displayTitle ||
        current.localizedTitle != next.localizedTitle ||
        current.originalTitle != next.originalTitle ||
        current.synopsis != next.synopsis ||
        current.coverImageUrl != next.coverImageUrl ||
        current.thumbnailImageUrl != next.thumbnailImageUrl ||
        current.releaseDate != next.releaseDate ||
        current.releaseYear != next.releaseYear ||
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

  static Map<String, dynamic> _entryPayload(TmdbImportEntry entry) => {
        'title': entry.title,
        if (entry.originalTitle != null) 'original_title': entry.originalTitle,
        if (entry.overview != null) 'synopsis': entry.overview,
        if (entry.posterUrl != null) 'cover_image_url': entry.posterUrl,
        if (entry.releaseDate != null)
          'release_date': entry.releaseDate!.toIso8601String(),
        if (entry.releaseYear != null) 'release_year': entry.releaseYear,
      };

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
