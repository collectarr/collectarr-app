import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:csv/csv.dart';
import 'package:dio/dio.dart';

enum TmdbImportCollection {
  ratedMovies,
  watchlistMovies;

  String get label {
    return switch (this) {
      TmdbImportCollection.ratedMovies => 'Rated movies',
      TmdbImportCollection.watchlistMovies => 'Watchlist movies',
    };
  }

  String get path {
    return switch (this) {
      TmdbImportCollection.ratedMovies => 'rated/movies',
      TmdbImportCollection.watchlistMovies => 'watchlist/movies',
    };
  }

  String get storageValue {
    return switch (this) {
      TmdbImportCollection.ratedMovies => 'rated_movies',
      TmdbImportCollection.watchlistMovies => 'watchlist_movies',
    };
  }

  static TmdbImportCollection fromStorageValue(String value) {
    return switch (value.trim().toLowerCase()) {
      'watchlist_movies' => TmdbImportCollection.watchlistMovies,
      _ => TmdbImportCollection.ratedMovies,
    };
  }
}

class TmdbImportCredentials {
  const TmdbImportCredentials({
    required this.apiKey,
    required this.accountId,
    required this.sessionId,
  });

  final String apiKey;
  final String accountId;
  final String sessionId;

  TmdbImportCredentials normalized() {
    return TmdbImportCredentials(
      apiKey: apiKey.trim(),
      accountId: accountId.trim(),
      sessionId: sessionId.trim(),
    );
  }

  bool get isComplete {
    final normalized = this.normalized();
    return normalized.apiKey.isNotEmpty &&
        normalized.accountId.isNotEmpty &&
        normalized.sessionId.isNotEmpty;
  }
}

class TmdbImportEntry {
  const TmdbImportEntry({
    required this.tmdbId,
    required this.collection,
    required this.title,
    required this.rawPayload,
    this.originalTitle,
    this.overview,
    this.posterPath,
    this.releaseDate,
    this.rating,
  });

  final int tmdbId;
  final TmdbImportCollection collection;
  final String title;
  final String? originalTitle;
  final String? overview;
  final String? posterPath;
  final DateTime? releaseDate;
  final num? rating;
  final Map<String, dynamic> rawPayload;

  int? get releaseYear => releaseDate?.year;

  String get query {
    final year = releaseYear;
    if (year == null) {
      return title;
    }
    return '$title $year';
  }

  String? get posterUrl {
    final path = posterPath?.trim();
    if (path == null || path.isEmpty) {
      return null;
    }
    return 'https://image.tmdb.org/t/p/w500$path';
  }

  TmdbImportEntry copyWith({
    int? tmdbId,
    TmdbImportCollection? collection,
    String? title,
    String? originalTitle,
    String? overview,
    String? posterPath,
    DateTime? releaseDate,
    num? rating,
    Map<String, dynamic>? rawPayload,
  }) {
    return TmdbImportEntry(
      tmdbId: tmdbId ?? this.tmdbId,
      collection: collection ?? this.collection,
      title: title ?? this.title,
      originalTitle: originalTitle ?? this.originalTitle,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      releaseDate: releaseDate ?? this.releaseDate,
      rating: rating ?? this.rating,
      rawPayload: rawPayload ?? this.rawPayload,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tmdb_id': tmdbId,
      'collection': collection.storageValue,
      'title': title,
      if (originalTitle != null) 'original_title': originalTitle,
      if (overview != null) 'overview': overview,
      if (posterPath != null) 'poster_path': posterPath,
      if (releaseDate != null)
        'release_date': releaseDate!.toUtc().toIso8601String(),
      if (rating != null) 'rating': rating,
      'raw_payload': rawPayload,
    };
  }

  factory TmdbImportEntry.fromJson(Map<String, dynamic> json) {
    final rawPayload = json['raw_payload'];
    return TmdbImportEntry(
      tmdbId: (json['tmdb_id'] as num?)?.toInt() ?? 0,
      collection: TmdbImportCollection.fromStorageValue(
        json['collection'] as String? ?? 'rated_movies',
      ),
      title: json['title'] as String? ?? 'Untitled',
      originalTitle: json['original_title'] as String?,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      releaseDate: TmdbImportService._parseDate(
        json['release_date'] as String?,
      ),
      rating: json['rating'] as num?,
      rawPayload: rawPayload is Map<String, dynamic>
          ? rawPayload
          : rawPayload is Map
              ? Map<String, dynamic>.from(rawPayload)
              : const <String, dynamic>{},
    );
  }
}

enum TmdbImportMatchQuality {
  exactTitleAndYear,
  exactTitle,
  singleResult,
  none;
}

class TmdbImportMatch {
  const TmdbImportMatch({
    required this.entry,
    required this.quality,
    this.catalogItem,
    this.candidates = const <CatalogItem>[],
  });

  final TmdbImportEntry entry;
  final CatalogItem? catalogItem;
  final TmdbImportMatchQuality quality;
  final List<CatalogItem> candidates;

  bool get isMatched => catalogItem != null;
}

class TmdbImportPreview {
  const TmdbImportPreview({
    required this.collection,
    required this.matches,
  });

  final TmdbImportCollection collection;
  final List<TmdbImportMatch> matches;

  List<TmdbImportMatch> get matched =>
      matches.where((match) => match.isMatched).toList(growable: false);

  List<TmdbImportMatch> get unmatched =>
      matches.where((match) => !match.isMatched).toList(growable: false);
}

class TmdbImportExecutionResult {
  const TmdbImportExecutionResult({
    required this.importedCount,
    required this.proposedCount,
  });

  final int importedCount;
  final int proposedCount;
}

class TmdbImportService {
  TmdbImportService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://api.themoviedb.org',
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                sendTimeout: const Duration(seconds: 30),
              ),
            );

  final Dio _dio;

  Future<List<TmdbImportEntry>> fetchCollection(
    TmdbImportCredentials credentials,
    TmdbImportCollection collection,
  ) async {
    final normalized = credentials.normalized();
    if (!normalized.isComplete) {
      throw ArgumentError(
        'TMDB import requires api key, account id, and session id.',
      );
    }
    final entries = <TmdbImportEntry>[];
    var page = 1;
    while (true) {
      final response = await _dio.get<Map<String, dynamic>>(
        '/3/account/${normalized.accountId}/${collection.path}',
        queryParameters: {
          'api_key': normalized.apiKey,
          'session_id': normalized.sessionId,
          'page': page,
          'sort_by': 'created_at.asc',
          'language': 'en-US',
        },
      );
      final data = response.data;
      if (data == null) {
        throw StateError('TMDB import returned an empty response body.');
      }
      entries.addAll(_parseEntries(data, collection: collection));
      final totalPages = (data['total_pages'] as num?)?.toInt() ?? page;
      if (page >= totalPages) {
        break;
      }
      page += 1;
    }
    return entries;
  }

  List<TmdbImportEntry> parseCollectionPayload(
    String text, {
    required TmdbImportCollection collection,
  }) {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      throw const FormatException('TMDB import payload cannot be empty.');
    }
    if (_looksLikeJson(normalized)) {
      final payload = jsonDecode(normalized);
      if (payload is Map<String, dynamic>) {
        return _parseEntries(payload, collection: collection);
      }
      if (payload is List<dynamic>) {
        return _entriesFromList(payload, collection: collection);
      }
      throw const FormatException(
        'TMDB JSON input must be a JSON object or array.',
      );
    }
    return _parseCsvEntries(normalized, collection: collection);
  }

  List<TmdbImportEntry> parseCollectionFileBytes(
    Uint8List bytes, {
    required String fileName,
    required TmdbImportCollection collection,
  }) {
    final normalizedFileName = fileName.trim().toLowerCase();
    if (normalizedFileName.endsWith('.zip')) {
      final archive = ZipDecoder().decodeBytes(bytes);
      final csvFile = _selectCsvArchiveFile(
        archive,
        collection: collection,
      );
      if (csvFile == null) {
        throw const FormatException(
          'TMDB ZIP export does not contain a CSV file.',
        );
      }
      final csvBytes = Uint8List.fromList(csvFile.content);
      final text = utf8.decode(csvBytes, allowMalformed: true);
      return _parseCsvEntries(text, collection: collection);
    }
    final text = utf8.decode(bytes, allowMalformed: true);
    return parseCollectionPayload(text, collection: collection);
  }

  Future<TmdbImportPreview> previewImport({
    required TmdbImportCollection collection,
    required List<TmdbImportEntry> entries,
    required Future<List<CatalogItem>> Function(TmdbImportEntry entry)
        searchCatalog,
  }) async {
    final matches = <TmdbImportMatch>[];
    for (final entry in entries) {
      final candidates = await searchCatalog(entry);
      matches.add(_matchEntry(entry, candidates));
    }
    return TmdbImportPreview(collection: collection, matches: matches);
  }

  Future<TmdbImportEntry> enrichEntry({
    required String apiKey,
    required TmdbImportEntry entry,
  }) async {
    final normalizedApiKey = apiKey.trim();
    if (normalizedApiKey.isEmpty) {
      return entry;
    }
    final response = await _dio.get<Map<String, dynamic>>(
      '/3/movie/${entry.tmdbId}',
      queryParameters: {
        'api_key': normalizedApiKey,
        'append_to_response': 'credits',
        'language': 'en-US',
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError('TMDB details response was empty for movie ${entry.tmdbId}.');
    }
    final detailedTitle = (data['title'] as String?)?.trim();
    final detailedOriginalTitle = (data['original_title'] as String?)?.trim();
    final detailedOverview = (data['overview'] as String?)?.trim();
    final detailedPosterPath = (data['poster_path'] as String?)?.trim();
    final detailedReleaseDate = _parseDate(data['release_date'] as String?);
    final rawPayload = <String, dynamic>{
      ...Map<String, dynamic>.from(data),
      'id': entry.tmdbId,
      'media_type': 'movie',
      'tmdb_import': {
        'collection': entry.collection.storageValue,
        if (entry.rating != null) 'user_rating': entry.rating,
      },
      'source_export_payload': entry.rawPayload,
    };
    return entry.copyWith(
      title: detailedTitle == null || detailedTitle.isEmpty
          ? entry.title
          : detailedTitle,
      originalTitle: detailedOriginalTitle == null ||
              detailedOriginalTitle.isEmpty
          ? entry.originalTitle
          : detailedOriginalTitle,
      overview: detailedOverview == null || detailedOverview.isEmpty
          ? entry.overview
          : detailedOverview,
      posterPath: detailedPosterPath == null || detailedPosterPath.isEmpty
          ? entry.posterPath
          : detailedPosterPath,
      releaseDate: detailedReleaseDate ?? entry.releaseDate,
      rawPayload: rawPayload,
    );
  }

  CatalogItem mergeMatchedCatalogItem(CatalogItem item, TmdbImportEntry entry) {
    final aliases = <String>{
      if (item.searchAliases case final currentAliases?) ...currentAliases,
      if (item.title.trim().isNotEmpty) item.title.trim(),
      if (item.displayTitle?.trim().isNotEmpty == true) item.displayTitle!.trim(),
      if (item.localizedTitle?.trim().isNotEmpty == true)
        item.localizedTitle!.trim(),
      if (item.originalTitle?.trim().isNotEmpty == true)
        item.originalTitle!.trim(),
      if (entry.title.trim().isNotEmpty) entry.title.trim(),
      if (entry.originalTitle?.trim().isNotEmpty == true)
        entry.originalTitle!.trim(),
    }.toList(growable: false);
    final tmdbGenres = _distinctNonEmptyStrings([
      ...?item.genres,
      ..._tmdbNamedValues(entry.rawPayload['genres']),
    ]);
    final tmdbStudios = _tmdbNamedValues(entry.rawPayload['production_companies']);
    final tmdbCountries = _distinctNonEmptyStrings([
      ..._tmdbNamedValues(entry.rawPayload['production_countries']),
      ..._tmdbStringValues(entry.rawPayload['origin_country']),
    ]);
    final tmdbLanguages = _distinctNonEmptyStrings([
      ..._tmdbNamedValues(entry.rawPayload['spoken_languages']),
      _normalizedText(entry.rawPayload['original_language'] as String?),
    ]);
    final runtimeMinutes = _runtimeMinutesFromPayload(entry.rawPayload);
    final mergedVideo = runtimeMinutes == null && item.video == null
        ? null
        : VideoCatalogDetails(
            runtimeMinutes: item.video?.runtimeMinutes ?? runtimeMinutes,
          );
    return CatalogItem(
      id: item.id,
      mediaKind: item.mediaKind,
      title: item.title,
      displayTitle: item.displayTitle ?? entry.title,
      localizedTitle: item.localizedTitle ?? entry.title,
      originalTitle: item.originalTitle ?? entry.originalTitle,
      searchAliases: aliases,
      sortKey: item.sortKey,
      itemNumber: item.itemNumber,
      synopsis: _firstNonEmptyText(item.synopsis, entry.overview),
      coverImageUrl: _firstNonEmptyText(item.coverImageUrl, entry.posterUrl),
      thumbnailImageUrl: _firstNonEmptyText(
        item.thumbnailImageUrl,
        item.coverImageUrl,
        entry.posterUrl,
      ),
      coverImageData: item.coverImageData,
      editionTitle: item.editionTitle,
      physicalFormat: item.physicalFormat,
      physicalFormatLabel: item.physicalFormatLabel,
      publisher: _firstNonEmptyText(item.publisher, tmdbStudios.join(', ')),
      releaseDate: item.releaseDate ?? entry.releaseDate,
      releaseYear: item.releaseYear ?? entry.releaseYear,
      barcode: item.barcode,
      variant: item.variant,
      series: item.series,
      video: mergedVideo,
      music: item.music,
      game: item.game,
      publishing: item.publishing,
      creators: item.creators,
      characters: item.characters,
      storyArcs: item.storyArcs,
      rawPlatforms: item.rawPlatforms,
      genres: tmdbGenres.isEmpty ? item.genres : tmdbGenres,
      editions: item.editions,
      country: _firstNonEmptyText(item.country, tmdbCountries.join(', ')),
      language: _firstNonEmptyText(item.language, tmdbLanguages.join(', ')),
      ageRating: item.ageRating,
    );
  }

  Future<TmdbImportExecutionResult> importPreview({
    required TmdbImportPreview preview,
    required Future<void> Function(CatalogItem item, TmdbImportEntry entry)
        importMatch,
    required Future<void> Function(TmdbImportEntry entry) proposeUnmatched,
  }) async {
    var importedCount = 0;
    var proposedCount = 0;
    for (final match in preview.matches) {
      final item = match.catalogItem;
      if (item != null) {
        await importMatch(item, match.entry);
        importedCount += 1;
        continue;
      }
      await proposeUnmatched(match.entry);
      proposedCount += 1;
    }
    return TmdbImportExecutionResult(
      importedCount: importedCount,
      proposedCount: proposedCount,
    );
  }

  String localSyntheticItemId(TmdbImportEntry entry) {
    return 'tmdb-local:movie:${entry.tmdbId}';
  }

  CatalogItem localSyntheticCatalogItem(TmdbImportEntry entry) {
    return CatalogItem(
      id: localSyntheticItemId(entry),
      kind: CatalogMediaKind.movie.apiValue,
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
  }

  static String? _firstNonEmptyText(String? first, [String? second, String? third]) {
    for (final candidate in [first, second, third]) {
      final normalized = _normalizedText(candidate);
      if (normalized != null) {
        return normalized;
      }
    }
    return null;
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
      value.whereType<Map>().map(
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

  static int? _runtimeMinutesFromPayload(Map<String, dynamic> payload) {
    final runtime = payload['runtime'];
    if (runtime is num) {
      return runtime.round();
    }
    return null;
  }

  List<TmdbImportEntry> _parseEntries(
    Map<String, dynamic> payload, {
    required TmdbImportCollection collection,
  }) {
    final results = payload['results'];
    if (results is! List<dynamic>) {
      throw const FormatException(
        'TMDB import payload must contain a results array.',
      );
    }
    return _entriesFromList(results, collection: collection);
  }

  List<TmdbImportEntry> _entriesFromList(
    List<dynamic> results, {
    required TmdbImportCollection collection,
  }) {
    return results
        .whereType<Map<String, dynamic>>()
        .map((entry) => _entryFromJson(entry, collection: collection))
        .toList(growable: false);
  }

  TmdbImportEntry _entryFromJson(
    Map<String, dynamic> json, {
    required TmdbImportCollection collection,
  }) {
    final id = (json['id'] as num?)?.toInt();
    final title = (json['title'] as String?)?.trim();
    if (id == null || title == null || title.isEmpty) {
      throw const FormatException(
        'Each TMDB import entry must include id and title.',
      );
    }
    return TmdbImportEntry(
      tmdbId: id,
      collection: collection,
      title: title,
      originalTitle: (json['original_title'] as String?)?.trim(),
      overview: (json['overview'] as String?)?.trim(),
      posterPath: (json['poster_path'] as String?)?.trim(),
      releaseDate: _parseDate(json['release_date'] as String?),
      rating: json['rating'] as num?,
      rawPayload: Map<String, dynamic>.from(json),
    );
  }

  List<TmdbImportEntry> _parseCsvEntries(
    String csvText, {
    required TmdbImportCollection collection,
  }) {
    final rows = const CsvDecoder(
      fieldDelimiter: ',',
      dynamicTyping: false,
    ).convert(csvText);
    if (rows.length <= 1) {
      return const <TmdbImportEntry>[];
    }
    final header = rows.first.map(_stringCell).toList(growable: false);
    if (header.isNotEmpty) {
      header[0] = header[0].replaceFirst('\ufeff', '');
    }
    final index = _csvHeaderIndex(header);
    final entries = rows
        .skip(1)
        .map((row) => row.map(_stringCell).toList(growable: false))
        .where((row) => row.any((value) => value.trim().isNotEmpty))
        .map((row) => _entryFromCsvRow(index, row, collection: collection))
        .whereType<TmdbImportEntry>()
        .toList(growable: false);
    if (entries.isEmpty && rows.length > 1) {
      throw const FormatException(
        'TMDB CSV input did not contain any movie rows to import.',
      );
    }
    return entries;
  }

  TmdbImportEntry? _entryFromCsvRow(
    Map<String, int> index,
    List<String> values, {
    required TmdbImportCollection collection,
  }) {
    final mediaType =
        _csvOptionalValue(index, values, 'media_type')?.trim().toLowerCase();
    if (mediaType != null && mediaType.isNotEmpty && mediaType != 'movie') {
      return null;
    }
    final tmdbId = _parseTmdbId(_csvValue(index, values, 'id'));
    final title = _csvValue(index, values, 'title').trim();
    if (tmdbId == null || title.isEmpty) {
      return null;
    }
    final originalTitle = _csvOptionalValue(index, values, 'original_title');
    final overview = _csvOptionalValue(index, values, 'overview');
    final posterValue = _csvOptionalValue(index, values, 'poster_path');
    final releaseDate =
        _parseDate(_csvOptionalValue(index, values, 'release_date'));
    final rating = _parseRating(
      _csvOptionalValue(index, values, 'user_rating') ??
          _csvOptionalValue(index, values, 'rating'),
    );
    final posterPath = _posterPathFromCsvValue(posterValue);
    return TmdbImportEntry(
      tmdbId: tmdbId,
      collection: collection,
      title: title,
      originalTitle: originalTitle,
      overview: overview,
      posterPath: posterPath,
      releaseDate: releaseDate,
      rating: rating,
      rawPayload: <String, dynamic>{
        'id': tmdbId,
        'title': title,
        if (originalTitle != null) 'original_title': originalTitle,
        if (overview != null) 'overview': overview,
        if (posterPath != null) 'poster_path': posterPath,
        if (releaseDate != null)
          'release_date': releaseDate.toUtc().toIso8601String(),
        if (mediaType != null) 'type': mediaType,
        if (rating != null) 'rating': rating,
      },
    );
  }

  ArchiveFile? _selectCsvArchiveFile(
    Archive archive, {
    required TmdbImportCollection collection,
  }) {
    final csvFiles = archive.files
        .where(
          (file) =>
              !file.isDirectory && file.name.toLowerCase().endsWith('.csv'),
        )
        .toList(growable: false);
    if (csvFiles.isEmpty) {
      return null;
    }

    final preferredKeywords = switch (collection) {
      TmdbImportCollection.ratedMovies => ['rating', 'ratings', 'rated'],
      TmdbImportCollection.watchlistMovies => ['watchlist'],
    };
    for (final keyword in preferredKeywords) {
      for (final file in csvFiles) {
        if (file.name.toLowerCase().contains(keyword)) {
          return file;
        }
      }
    }
    return csvFiles.first;
  }

  TmdbImportMatch _matchEntry(
    TmdbImportEntry entry,
    List<CatalogItem> candidates,
  ) {
    if (candidates.isEmpty) {
      return TmdbImportMatch(
        entry: entry,
        quality: TmdbImportMatchQuality.none,
      );
    }
    final normalizedTitle = _normalizeTitle(entry.title);
    final releaseYear = entry.releaseYear;
    final exactTitle = candidates
        .where(
            (candidate) => _normalizeTitle(candidate.title) == normalizedTitle)
        .toList(growable: false);
    if (releaseYear != null) {
      final exactTitleAndYear = exactTitle
          .where((candidate) => candidate.releaseYear == releaseYear)
          .toList(growable: false);
      if (exactTitleAndYear.length == 1) {
        return TmdbImportMatch(
          entry: entry,
          catalogItem: exactTitleAndYear.single,
          candidates: candidates,
          quality: TmdbImportMatchQuality.exactTitleAndYear,
        );
      }
    }
    if (exactTitle.length == 1) {
      return TmdbImportMatch(
        entry: entry,
        catalogItem: exactTitle.single,
        candidates: candidates,
        quality: TmdbImportMatchQuality.exactTitle,
      );
    }
    if (candidates.length == 1) {
      return TmdbImportMatch(
        entry: entry,
        catalogItem: candidates.single,
        candidates: candidates,
        quality: TmdbImportMatchQuality.singleResult,
      );
    }
    return TmdbImportMatch(
      entry: entry,
      candidates: candidates,
      quality: TmdbImportMatchQuality.none,
    );
  }

  static DateTime? _parseDate(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return DateTime.tryParse(normalized);
  }

  static String _normalizeTitle(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  }

  static bool _looksLikeJson(String value) {
    return value.startsWith('{') || value.startsWith('[');
  }

  static String _stringCell(Object? value) {
    return switch (value) {
      null => '',
      _ => value.toString(),
    };
  }

  static Map<String, int> _csvHeaderIndex(List<String> header) {
    final index = <String, int>{};
    for (var i = 0; i < header.length; i++) {
      final normalized = _normalizeCsvHeader(header[i]);
      if (normalized.isEmpty) {
        continue;
      }
      index.putIfAbsent(normalized, () => i);
    }
    return index;
  }

  static String _normalizeCsvHeader(String value) {
    final normalized =
        value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    return switch (normalized) {
      'tmdb_id' || 'movie_id' || 'movie_tmdb_id' || 'id' => 'id',
      'type' || 'media_type' => 'media_type',
      'title' || 'movie_title' || 'name' => 'title',
      'original_title' || 'original_name' => 'original_title',
      'overview' || 'description' || 'summary' => 'overview',
      'poster_path' ||
      'poster' ||
      'poster_url' ||
      'poster_image' =>
        'poster_path',
      'release_date' || 'released' || 'first_air_date' => 'release_date',
      'your_rating' || 'user_rating' => 'user_rating',
      'rating' || 'score' || 'vote' => 'rating',
      _ => normalized,
    };
  }

  static String _csvValue(
    Map<String, int> index,
    List<String> values,
    String key,
  ) {
    final position = index[key];
    if (position == null || position >= values.length) {
      return '';
    }
    return values[position].trim();
  }

  static String? _csvOptionalValue(
    Map<String, int> index,
    List<String> values,
    String key,
  ) {
    final value = _csvValue(index, values, key);
    return value.isEmpty ? null : value;
  }

  static int? _parseTmdbId(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    final direct = int.tryParse(normalized);
    if (direct != null) {
      return direct;
    }
    final match = RegExp(r'(?:movie|tv)/(\d+)').firstMatch(normalized);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  static num? _parseRating(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return num.tryParse(normalized);
  }

  static String? _posterPathFromCsvValue(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    if (normalized.startsWith('/')) {
      return normalized;
    }
    final match = RegExp(r'/t/p/[^/]+(/.+)$').firstMatch(normalized);
    if (match != null) {
      return match.group(1);
    }
    return normalized;
  }
}
