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
}

typedef VideoCatalogDetails = VideoCatalogDetailsDto;
