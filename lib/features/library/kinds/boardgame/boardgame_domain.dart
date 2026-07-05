import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';

final class BoardGamePlayerStat {
  const BoardGamePlayerStat({
    required this.name,
    this.plays,
    this.wins,
    this.losses,
    this.favoriteCount,
    this.score,
  });

  final String name;
  final int? plays;
  final int? wins;
  final int? losses;
  final int? favoriteCount;
  final double? score;

  factory BoardGamePlayerStat.fromJson(Map<String, dynamic> json) {
    return BoardGamePlayerStat(
      name: _stringOrEmpty(json['name'] ?? json['player'] ?? json['label']),
      plays: _intOrNull(json['plays'] ?? json['play_count'] ?? json['playCount']),
      wins: _intOrNull(json['wins']),
      losses: _intOrNull(json['losses']),
      favoriteCount: _intOrNull(
        json['favorite_count'] ?? json['favoriteCount'] ?? json['favorites'],
      ),
      score: _doubleOrNull(json['score'] ?? json['rating']),
    );
  }

  String toSummary() {
    final parts = <String>[name];
    if (plays != null) parts.add('plays $plays');
    if (wins != null || losses != null) {
      parts.add('W ${wins ?? 0} / L ${losses ?? 0}');
    }
    if (favoriteCount != null) parts.add('fav $favoriteCount');
    if (score != null) parts.add(score!.toStringAsFixed(1));
    return parts.join(' · ');
  }
}

final class BoardGamePlayStats {
  const BoardGamePlayStats({
    this.bggRank,
    this.bggRating,
    this.playCount,
    this.lastPlayed,
    this.favoritePlayerCount,
    this.playerStats = const <BoardGamePlayerStat>[],
  });

  final int? bggRank;
  final double? bggRating;
  final int? playCount;
  final DateTime? lastPlayed;
  final int? favoritePlayerCount;
  final List<BoardGamePlayerStat> playerStats;

  factory BoardGamePlayStats.fromJson(Map<String, dynamic> json) {
    return BoardGamePlayStats(
      bggRank: _intOrNull(
        json['bgg_rank'] ?? json['bggRank'] ?? json['rank'] ?? json['rank_value'],
      ),
      bggRating: _doubleOrNull(
        json['bgg_rating'] ?? json['bggRating'] ?? json['rating'],
      ),
      playCount: _intOrNull(
        json['play_count'] ?? json['playCount'] ?? json['plays'],
      ),
      lastPlayed: _dateOrNull(
        json['last_played'] ?? json['lastPlayed'] ?? json['last_played_at'],
      ),
      favoritePlayerCount: _intOrNull(
        json['favorite_player_count'] ??
            json['favoritePlayerCount'] ??
            json['favorite_players'],
      ),
      playerStats: _playerStatList(
        json['player_stats'] ?? json['playerStats'] ?? json['stats'],
      ),
    );
  }

  factory BoardGamePlayStats.fromDetails(BoardGameStatsDetails details) {
    return BoardGamePlayStats(
      bggRank: details.bggRank,
      bggRating: details.bggRating,
      playCount: details.playCount,
      lastPlayed: details.lastPlayed,
      favoritePlayerCount: details.favoritePlayerCount,
      playerStats: [
        for (final entry in details.playerStats)
          BoardGamePlayerStat.fromJson(entry),
      ],
    );
  }

  bool get hasData =>
      bggRank != null ||
      bggRating != null ||
      playCount != null ||
      lastPlayed != null ||
      favoritePlayerCount != null ||
      playerStats.isNotEmpty;
}

final class BoardGameEdition {
  const BoardGameEdition({
    required this.id,
    required this.title,
    this.editionTitle,
    this.format,
    this.publisher,
    this.catalogNumber,
    this.barcode,
    this.releaseStatus,
    this.releaseDate,
    this.language,
    this.country,
    this.ageRating,
    this.audienceRating,
    this.minPlayers,
    this.maxPlayers,
    this.bestPlayers,
    this.playingTimeMinutes,
    this.minAge,
    this.coverImageUrl,
  });

  final String id;
  final String title;
  final String? editionTitle;
  final String? format;
  final String? publisher;
  final String? catalogNumber;
  final String? barcode;
  final String? releaseStatus;
  final DateTime? releaseDate;
  final String? language;
  final String? country;
  final String? ageRating;
  final String? audienceRating;
  final int? minPlayers;
  final int? maxPlayers;
  final int? bestPlayers;
  final int? playingTimeMinutes;
  final int? minAge;
  final String? coverImageUrl;

  factory BoardGameEdition.fromDto(BoardGameEditionDto dto) {
    return BoardGameEdition(
      id: dto.id,
      title: dto.title,
      editionTitle: dto.editionTitle,
      format: dto.format,
      publisher: dto.publisher,
      catalogNumber: dto.catalogNumber,
      barcode: dto.barcode,
      releaseStatus: dto.releaseStatus,
      releaseDate: dto.releaseDate,
      language: dto.language,
      country: dto.country,
      ageRating: dto.ageRating,
      audienceRating: dto.audienceRating,
      minPlayers: dto.minPlayers,
      maxPlayers: dto.maxPlayers,
      bestPlayers: _intOrNull(dto.raw['best_players'] ?? dto.raw['bestPlayers']),
      playingTimeMinutes: dto.playingTimeMinutes,
      minAge: dto.minAge,
      coverImageUrl: dto.coverImageUrl,
    );
  }

}

final class BoardGameWork {
  const BoardGameWork({
    required this.id,
    required this.title,
    this.identifiers = const <String>[],
    this.contributors = const <String>[],
    this.mechanics = const <String>[],
    this.categories = const <String>[],
    this.families = const <String>[],
    this.expansions = const <String>[],
    this.rankings = const <String>[],
    this.editions = const <BoardGameEdition>[],
    this.playStats,
  });
  final String id;
  final String title;
  final List<String> identifiers;
  final List<String> contributors;
  final List<String> mechanics;
  final List<String> categories;
  final List<String> families;
  final List<String> expansions;
  final List<String> rankings;
  final List<BoardGameEdition> editions;
  final BoardGamePlayStats? playStats;

  factory BoardGameWork.fromDto(BoardGameWorkDto dto) {
    return BoardGameWork(
      id: dto.id,
      title: dto.title,
      identifiers: List<String>.unmodifiable(dto.identifiers),
      contributors: List<String>.unmodifiable(dto.contributors),
      mechanics: List<String>.unmodifiable(dto.mechanics),
      categories: List<String>.unmodifiable(dto.categories),
      families: List<String>.unmodifiable(dto.families),
      expansions: List<String>.unmodifiable(dto.expansions),
      rankings: List<String>.unmodifiable(dto.rankings),
      playStats: _playStatsFromJson(dto.raw),
    );
  }
}

BoardGamePlayStats? _playStatsFromJson(Map<String, dynamic> raw) {
  final stats = raw['play_stats'] ?? raw['playStats'];
  if (stats is Map<String, dynamic>) {
    final parsed = BoardGamePlayStats.fromJson(stats);
    return parsed.hasData ? parsed : null;
  }
  final parsed = BoardGamePlayStats.fromJson(raw);
  return parsed.hasData ? parsed : null;
}

List<BoardGamePlayerStat> _playerStatList(Object? value) {
  if (value is! List) {
    return const <BoardGamePlayerStat>[];
  }
  final stats = <BoardGamePlayerStat>[];
  for (final entry in value) {
    if (entry is Map<String, dynamic>) {
      stats.add(BoardGamePlayerStat.fromJson(entry));
    } else if (entry != null) {
      stats.add(BoardGamePlayerStat(name: entry.toString()));
    }
  }
  return stats;
}

double? _doubleOrNull(Object? value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

String _stringOrEmpty(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? 'Unknown' : text;
}

int? _intOrNull(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

DateTime? _dateOrNull(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;
  return DateTime.tryParse(text);
}
