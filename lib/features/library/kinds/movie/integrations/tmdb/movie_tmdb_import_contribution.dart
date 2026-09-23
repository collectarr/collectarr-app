import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/movie/catalog/movie_catalog_fields.dart';
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
    final metadata = MovieCatalogMetadata(
      title: entry.title,
      originalTitle: entry.originalTitle,
      synopsis: entry.overview,
      releaseDate: entry.releaseDate,
    );
    return CatalogSearchCandidate.fromItem(
      CatalogItemDto.raw(
        id: _localItemId(entry),
        mediaKind: kind,
        common: CatalogCommonDto(
          title: entry.title,
          displayTitle: entry.title,
          localizedTitle: entry.title,
          originalTitle: entry.originalTitle,
          synopsis: entry.overview,
          coverImageUrl: entry.posterUrl,
          releaseDate: entry.releaseDate,
          releaseYear: entry.releaseYear,
          searchAliases: [
            entry.title,
            if (entry.originalTitle != null) entry.originalTitle!,
          ],
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
    throw UnsupportedError('Movie imports do not have season entities.');
  }

  @override
  CatalogSearchCandidate mergeMatchedCatalogItem(
    CatalogSearchCandidate item,
    TmdbImportEntry entry,
  ) {
    final current = requireProviderKindMetadata<MovieCatalogMetadata>(item);
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
    final metadata = current.copyWith(
      genres: genres,
      country: countries.isNotEmpty
          ? _first(current.country, countries.join(', '))
          : current.country,
      language: languages.isNotEmpty
          ? _first(current.language, languages.join(', '))
          : current.language,
      publisher: companies.isNotEmpty
          ? _first(current.publisher, companies.join(', '))
          : current.publisher,
      runtimeMinutes: runtimeMinutes ?? current.runtimeMinutes,
    );
    final aliases = _distinct([
      ...item.movieCatalogFields.searchAliases,
      item.primaryLabel,
      item.movieCatalogFields.displayTitle,
      item.movieCatalogFields.localizedTitle,
      item.movieCatalogFields.originalTitle,
      entry.title,
      entry.originalTitle,
    ]);
    final mergedItem = CatalogSearchCandidate.fromItem(
      item.mapTransport(
        (transport) => transport.copyWith(
          displayTitle: item.movieCatalogFields.displayTitle ?? entry.title,
          localizedTitle: item.movieCatalogFields.localizedTitle ?? entry.title,
          originalTitle:
              item.movieCatalogFields.originalTitle ?? entry.originalTitle,
          searchAliases: aliases,
          synopsis: _first(item.movieCatalogFields.synopsis, entry.overview),
          coverImageUrl:
              _first(item.movieCatalogFields.coverImageUrl, entry.posterUrl),
          thumbnailImageUrl: _first(
            item.movieCatalogFields.thumbnailImageUrl,
            item.movieCatalogFields.coverImageUrl,
            entry.posterUrl,
          ),
          releaseDate: item.movieCatalogFields.releaseDate ?? entry.releaseDate,
          releaseYear: item.movieCatalogFields.releaseYear ?? entry.releaseYear,
        ),
      ),
    );
    return mergedItem.withKindMetadata(metadata);
  }

  @override
  bool hasMeaningfulChanges(
    CatalogSearchCandidate current,
    CatalogSearchCandidate next,
  ) {
    return current.movieCatalogFields.displayTitle !=
            next.movieCatalogFields.displayTitle ||
        current.movieCatalogFields.localizedTitle !=
            next.movieCatalogFields.localizedTitle ||
        current.movieCatalogFields.originalTitle !=
            next.movieCatalogFields.originalTitle ||
        current.movieCatalogFields.synopsis !=
            next.movieCatalogFields.synopsis ||
        current.movieCatalogFields.coverImageUrl !=
            next.movieCatalogFields.coverImageUrl ||
        current.movieCatalogFields.thumbnailImageUrl !=
            next.movieCatalogFields.thumbnailImageUrl ||
        current.movieCatalogFields.releaseDate !=
            next.movieCatalogFields.releaseDate ||
        current.movieCatalogFields.releaseYear !=
            next.movieCatalogFields.releaseYear ||
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
