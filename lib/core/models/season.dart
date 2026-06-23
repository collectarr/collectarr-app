class Episode {
  final int episodeNumber;
  final String title;
  final String? providerItemId;
  final String? overview;
  final String? airDate;
  final int? runtimeMinutes;
  final int? pageCount;

  Episode({
    required this.episodeNumber,
    required this.title,
    this.providerItemId,
    this.overview,
    this.airDate,
    this.runtimeMinutes,
    this.pageCount,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      episodeNumber: json['episode_number'] as int,
      title: json['title'] as String,
      providerItemId: json['provider_item_id'] as String?,
      overview: json['overview'] as String?,
      airDate: json['air_date'] as String?,
      runtimeMinutes: json['runtime_minutes'] as int?,
      pageCount: json['page_count'] as int?,
    );
  }
}

class Season {
  final int seasonNumber;
  final String title;
  final String? providerItemId;
  final String? overview;
  final String? airDate;
  final int? episodeCount;
  final String? posterUrl;
  final List<Episode> episodes;

  Season({
    required this.seasonNumber,
    required this.title,
    this.providerItemId,
    this.overview,
    this.airDate,
    this.episodeCount,
    this.posterUrl,
    this.episodes = const [],
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      seasonNumber: json['season_number'] as int,
      title: json['title'] as String,
      providerItemId: json['provider_item_id'] as String?,
      overview: json['overview'] as String?,
      airDate: json['air_date'] as String?,
      episodeCount: json['episode_count'] as int?,
      posterUrl: json['poster_url'] as String?,
      episodes: (json['episodes'] as List<dynamic>?)
              ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
