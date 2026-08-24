class VideoCatalogDetailsDto {
  const VideoCatalogDetailsDto({
    this.runtimeMinutes,
    this.color,
    this.nrDiscs,
    this.screenRatio,
    this.audioTracks,
    this.subtitles,
    this.layers,
    this.ageRating,
    this.audienceRating,
  });

  final int? runtimeMinutes;
  final String? color;
  final int? nrDiscs;
  final String? screenRatio;
  final String? audioTracks;
  final String? subtitles;
  final String? layers;
  final String? ageRating;
  final String? audienceRating;

  bool get hasData =>
      runtimeMinutes != null ||
      (color != null && color!.isNotEmpty) ||
      nrDiscs != null ||
      (screenRatio != null && screenRatio!.isNotEmpty) ||
      (audioTracks != null && audioTracks!.isNotEmpty) ||
      (subtitles != null && subtitles!.isNotEmpty) ||
      (layers != null && layers!.isNotEmpty) ||
      (ageRating != null && ageRating!.isNotEmpty) ||
      (audienceRating != null && audienceRating!.isNotEmpty);

  factory VideoCatalogDetailsDto.fromJson(Map<String, dynamic> json) {
    return VideoCatalogDetailsDto(
      runtimeMinutes: json['runtime_minutes'] as int?,
      color: json['color'] as String?,
      nrDiscs: json['nr_discs'] as int?,
      screenRatio: json['screen_ratio'] as String?,
      audioTracks: json['audio_tracks'] as String?,
      subtitles: json['subtitles'] as String?,
      layers: json['layers'] as String?,
      ageRating: json['age_rating'] as String?,
      audienceRating: json['audience_rating'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (runtimeMinutes != null) 'runtime_minutes': runtimeMinutes,
        if (color != null) 'color': color,
        if (nrDiscs != null) 'nr_discs': nrDiscs,
        if (screenRatio != null) 'screen_ratio': screenRatio,
        if (audioTracks != null) 'audio_tracks': audioTracks,
        if (subtitles != null) 'subtitles': subtitles,
        if (layers != null) 'layers': layers,
        if (ageRating != null) 'age_rating': ageRating,
        if (audienceRating != null) 'audience_rating': audienceRating,
      };
}

typedef VideoCatalogDetails = VideoCatalogDetailsDto;
