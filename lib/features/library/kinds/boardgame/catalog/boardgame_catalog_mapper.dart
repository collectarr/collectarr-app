import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_release.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

class BoardGameCatalogMapper {
  const BoardGameCatalogMapper._();

  static BoardGameCatalogItem mapDtoToBoardGame(CatalogItemDto dto) {
    final payload = dto.toSyncPayload();
    final boardGameStats = _asMap(payload['board_game_stats']);

    final work = BoardGameWorkMetadata(
      title: dto.title,
      originalTitle: dto.originalTitle,
      synopsis: dto.synopsis,
      releaseDate: dto.releaseDate,
      yearPublished: dto.releaseYear ??
          _intValue(_valueForKeys(payload, boardGameStats, ['year_published'])),
      originalLanguage: _textValue(
          _valueForKeys(payload, boardGameStats, ['original_language'])),
      publisher:
          _textValue(_valueForKeys(payload, boardGameStats, ['publisher'])),
      subtitle:
          _textValue(_valueForKeys(payload, boardGameStats, ['subtitle'])),
      platforms: _stringList(payload['platforms']),
      identifiers: _stringList(payload['identifiers']),
      contributors: _stringList(payload['contributors']),
      rankings: _stringList(payload['rankings']),
      searchAliases: _stringList(payload['search_aliases']),
      minPlayers:
          _intValue(_valueForKeys(boardGameStats, payload, ['min_players'])),
      maxPlayers:
          _intValue(_valueForKeys(boardGameStats, payload, ['max_players'])),
      recommendedPlayers: _textValue(
          _valueForKeys(payload, boardGameStats, ['recommended_players'])),
      bestPlayers:
          _textValue(_valueForKeys(payload, boardGameStats, ['best_players'])),
      playingTimeMinutes: _intValue(
          _valueForKeys(boardGameStats, payload, ['playing_time_minutes'])),
      minPlaytimeMinutes: _intValue(
          _valueForKeys(boardGameStats, payload, ['min_playtime_minutes'])),
      maxPlaytimeMinutes: _intValue(
          _valueForKeys(boardGameStats, payload, ['max_playtime_minutes'])),
      minAge: _intValue(
          _valueForKeys(boardGameStats, payload, ['min_age', 'minimum_age'])),
      complexityWeight: _doubleValue(_valueForKeys(boardGameStats, payload,
          ['complexity_weight', 'bgg_weight', 'weight'])),
      designers:
          _stringList(_valueForKeys(payload, boardGameStats, ['designers'])),
      artists: _stringList(_valueForKeys(payload, boardGameStats, ['artists'])),
      publishers: _publisherList(payload, boardGameStats),
      mechanics:
          _stringList(_valueForKeys(payload, boardGameStats, ['mechanics'])),
      categories:
          _stringList(_valueForKeys(payload, boardGameStats, ['categories'])),
      families:
          _stringList(_valueForKeys(payload, boardGameStats, ['families'])),
      themes: _stringList(_valueForKeys(payload, boardGameStats, ['themes'])),
      expansions:
          _stringList(_valueForKeys(payload, boardGameStats, ['expansions'])),
      languages:
          _stringList(_valueForKeys(payload, boardGameStats, ['languages'])),
      genres: _stringList(payload['genres']),
    );

    final stats = BoardGameStatsMetadata(
      bggRank: _intValue(
          _valueForKeys(boardGameStats, payload, ['bgg_rank', 'rank'])),
      bggRating: _doubleValue(
          _valueForKeys(boardGameStats, payload, ['bgg_rating', 'rating'])),
      bggRatingCount: _intValue(_valueForKeys(boardGameStats, payload,
          ['bgg_rating_count', 'rating_count', 'users_rated'])),
      bggWeight: _doubleValue(
          _valueForKeys(boardGameStats, payload, ['bgg_weight', 'weight'])),
    );

    final rawEditions = _rawEditionMaps(payload['editions']);
    final editionDtos = dto.editions.isNotEmpty
        ? dto.editions
        : rawEditions.map(CatalogEditionDto.fromJson).toList(growable: false);
    final rawEditionsById = {
      for (final edition in rawEditions)
        if (edition['id']?.toString().isNotEmpty == true)
          edition['id'].toString(): edition,
    };
    final releases = editionDtos
        .map(
          (edition) => _mapEdition(
            edition,
            rawEditionsById[edition.id] ?? edition.toJson(),
            workId: dto.id,
          ),
        )
        .toList(growable: false);

    return BoardGameCatalogItem(
      id: dto.id,
      work: work,
      stats: stats,
      releases: releases,
    );
  }

  static BoardGameCatalogItem mapMetadataItemToBoardGame(
      LibraryMetadataItem item) {
    return mapDtoToBoardGame(CatalogItemDto.fromJson(item.toSyncPayload()));
  }

  static BoardGameRelease _mapEdition(
      CatalogEditionDto edition, Map<String, dynamic> raw,
      {required String workId}) {
    final metadata = edition.metadata ?? const <String, dynamic>{};
    Object? value(List<String> keys) => _editionValue(raw, metadata, keys);

    return BoardGameRelease(
      id: edition.id,
      title: _textValue(value(['edition_title', 'title', 'name'])) ??
          edition.title,
      titleValue: _textValue(value(['title_value', 'title'])) ?? edition.title,
      workId: _textValue(value(['work_id'])) ?? workId,
      editionTitle: _textValue(value(['edition_title'])),
      ageRating: _textValue(value(['age_rating'])),
      audienceRating: _textValue(value(['audience_rating'])),
      barcode: _textValue(value(['barcode', 'upc', 'isbn'])) ??
          edition.upc ??
          edition.isbn,
      catalogNumber: _textValue(value(['catalog_number'])),
      country: _textValue(value(['country', 'region'])) ?? edition.region,
      coverImageUrl: _textValue(value(['cover_image_url'])),
      description: _textValue(value(['description', 'synopsis'])),
      format: _textValue(value(['format', 'physical_format'])) ??
          edition.format ??
          edition.physicalFormat,
      language: _textValue(value(['language'])) ?? edition.language,
      maxPlayers: _intValue(value(['max_players'])),
      minAge: _intValue(value(['min_age', 'minimum_age'])),
      minPlayers: _intValue(value(['min_players'])),
      playingTimeMinutes: _intValue(value(['playing_time_minutes'])),
      publisher: _textValue(value(['publisher'])) ?? edition.publisher,
      releaseDate: _dateValue(value(['release_date'])) ?? edition.releaseDate,
      releaseStatus: _textValue(value(['release_status'])),
      rawPayload: Map<String, dynamic>.from(raw),
    );
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is! Map) return const <String, dynamic>{};
    return Map<String, dynamic>.from(value);
  }

  static List<Map<String, dynamic>> _rawEditionMaps(Object? value) {
    if (value is! List) return const <Map<String, dynamic>>[];
    return [
      for (final entry in value)
        if (entry is Map) Map<String, dynamic>.from(entry),
    ];
  }

  static Object? _valueForKeys(
    Map<String, dynamic> primary,
    Map<String, dynamic> fallback,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = primary[key];
      if (_hasValue(value)) return value;
    }
    for (final key in keys) {
      final value = fallback[key];
      if (_hasValue(value)) return value;
    }
    return null;
  }

  static Object? _editionValue(
    Map<String, dynamic> raw,
    Map<String, dynamic> metadata,
    List<String> keys,
  ) {
    return _valueForKeys(raw, metadata, keys);
  }

  static List<String> _publisherList(
    Map<String, dynamic> payload,
    Map<String, dynamic> boardGameStats,
  ) {
    final publishers = _stringList(
      _valueForKeys(payload, boardGameStats, ['publishers']),
    );
    if (publishers.isNotEmpty) return publishers;
    final publisher = _textValue(
      _valueForKeys(payload, boardGameStats, ['publisher']),
    );
    return publisher == null ? const [] : [publisher];
  }

  static bool _hasValue(Object? value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is List) return value.isNotEmpty;
    return true;
  }

  static String? _textValue(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static int? _intValue(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static double? _doubleValue(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static DateTime? _dateValue(Object? value) {
    return DateTime.tryParse(value?.toString() ?? '');
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) return const <String>[];
    return [
      for (final entry in value)
        if (_textValue(entry) case final text?) text,
    ];
  }
}
