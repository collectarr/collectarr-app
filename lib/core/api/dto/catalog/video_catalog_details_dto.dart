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
      color != null ||
      nrDiscs != null ||
      screenRatio != null ||
      audioTracks != null ||
      subtitles != null ||
      layers != null ||
      ageRating != null ||
      audienceRating != null;
}
