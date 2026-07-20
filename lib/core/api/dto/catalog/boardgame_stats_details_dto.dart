class BoardGameStatsDetailsDto {
  const BoardGameStatsDetailsDto({
    this.bggRank,
    this.bggRating,
    this.playCount,
    this.lastPlayed,
    this.favoritePlayerCount,
    this.playerStats = const <Map<String, dynamic>>[],
  });

  final int? bggRank;
  final double? bggRating;
  final int? playCount;
  final DateTime? lastPlayed;
  final int? favoritePlayerCount;
  final List<Map<String, dynamic>> playerStats;

  factory BoardGameStatsDetailsDto.fromJson(Map<String, dynamic> json) {
    return BoardGameStatsDetailsDto(
      bggRank: _boardGameIntOrNull(
        json['bgg_rank'] ?? json['bggRank'] ?? json['rank'] ?? json['rank_value'],
      ),
      bggRating: _boardGameDoubleOrNull(
        json['bgg_rating'] ?? json['bggRating'] ?? json['rating'],
      ),
      playCount: _boardGameIntOrNull(
        json['play_count'] ?? json['playCount'] ?? json['plays'],
      ),
      lastPlayed: _boardGameDateOrNull(
        json['last_played'] ?? json['lastPlayed'] ?? json['last_played_at'],
      ),
      favoritePlayerCount: _boardGameIntOrNull(
        json['favorite_player_count'] ??
            json['favoritePlayerCount'] ??
            json['favorite_players'],
      ),
      playerStats: (json['player_stats'] as List<dynamic>? ??
                  json['playerStats'] as List<dynamic>? ??
                  json['stats'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((entry) => Map<String, dynamic>.from(entry))
              .toList(growable: false) ??
          const <Map<String, dynamic>>[],
    );
  }

  bool get hasData =>
      bggRank != null ||
      bggRating != null ||
      playCount != null ||
      lastPlayed != null ||
      favoritePlayerCount != null ||
      playerStats.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      if (bggRank != null) 'bgg_rank': bggRank,
      if (bggRating != null) 'bgg_rating': bggRating,
      if (playCount != null) 'play_count': playCount,
      if (lastPlayed != null) 'last_played': lastPlayed!.toUtc().toIso8601String(),
      if (favoritePlayerCount != null)
        'favorite_player_count': favoritePlayerCount,
      if (playerStats.isNotEmpty) 'player_stats': playerStats,
    };
  }
}

int? _boardGameIntOrNull(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double? _boardGameDoubleOrNull(Object? value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

DateTime? _boardGameDateOrNull(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;
  return DateTime.tryParse(text);
}
