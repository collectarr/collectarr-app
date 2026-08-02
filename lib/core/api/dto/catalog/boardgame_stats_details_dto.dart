class BoardGameStatsDetailsDto {
  const BoardGameStatsDetailsDto({
    this.minPlayers,
    this.maxPlayers,
    this.playingTimeMinutes,
    this.minPlayingTimeMinutes,
    this.maxPlayingTimeMinutes,
    this.minAgeYears,
    this.complexityRating,
    this.bggRating,
    this.bggId,
    this.bggRank,
    this.bggWeight,
    this.mechanics = const <String>[],
    this.designers = const <String>[],
    this.artists = const <String>[],
  });

  final int? minPlayers;
  final int? maxPlayers;
  final int? playingTimeMinutes;
  final int? minPlayingTimeMinutes;
  final int? maxPlayingTimeMinutes;
  final int? minAgeYears;
  final double? complexityRating;
  final double? bggRating;
  final String? bggId;
  final int? bggRank;
  final double? bggWeight;
  final List<String> mechanics;
  final List<String> designers;
  final List<String> artists;

  bool get hasData =>
      minPlayers != null ||
      maxPlayers != null ||
      playingTimeMinutes != null ||
      minPlayingTimeMinutes != null ||
      maxPlayingTimeMinutes != null ||
      minAgeYears != null ||
      complexityRating != null ||
      bggRating != null ||
      (bggId != null && bggId!.isNotEmpty) ||
      bggRank != null ||
      bggWeight != null ||
      mechanics.isNotEmpty ||
      designers.isNotEmpty ||
      artists.isNotEmpty;

  factory BoardGameStatsDetailsDto.fromJson(Map<String, dynamic> json) {
    return BoardGameStatsDetailsDto(
      minPlayers: json['min_players'] as int?,
      maxPlayers: json['max_players'] as int?,
      playingTimeMinutes: json['playing_time_minutes'] as int?,
      minPlayingTimeMinutes: json['min_playing_time_minutes'] as int?,
      maxPlayingTimeMinutes: json['max_playing_time_minutes'] as int?,
      minAgeYears: json['min_age_years'] as int?,
      complexityRating: (json['complexity_rating'] as num?)?.toDouble(),
      bggRating: (json['bgg_rating'] as num?)?.toDouble(),
      bggId: json['bgg_id']?.toString(),
      bggRank: json['bgg_rank'] as int?,
      bggWeight: (json['bgg_weight'] as num?)?.toDouble(),
      mechanics: (json['mechanics'] as List<dynamic>?)
              ?.whereType<String>()
              .toList(growable: false) ??
          const <String>[],
      designers: (json['designers'] as List<dynamic>?)
              ?.whereType<String>()
              .toList(growable: false) ??
          const <String>[],
      artists: (json['artists'] as List<dynamic>?)
              ?.whereType<String>()
              .toList(growable: false) ??
          const <String>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (minPlayers != null) 'min_players': minPlayers,
      if (maxPlayers != null) 'max_players': maxPlayers,
      if (playingTimeMinutes != null)
        'playing_time_minutes': playingTimeMinutes,
      if (minPlayingTimeMinutes != null)
        'min_playing_time_minutes': minPlayingTimeMinutes,
      if (maxPlayingTimeMinutes != null)
        'max_playing_time_minutes': maxPlayingTimeMinutes,
      if (minAgeYears != null) 'min_age_years': minAgeYears,
      if (complexityRating != null) 'complexity_rating': complexityRating,
      if (bggRating != null) 'bgg_rating': bggRating,
      if (bggId != null) 'bgg_id': bggId,
      if (bggRank != null) 'bgg_rank': bggRank,
      if (bggWeight != null) 'bgg_weight': bggWeight,
      if (mechanics.isNotEmpty) 'mechanics': mechanics,
      if (designers.isNotEmpty) 'designers': designers,
      if (artists.isNotEmpty) 'artists': artists,
    };
  }
}

typedef BoardGameStatsDetails = BoardGameStatsDetailsDto;
