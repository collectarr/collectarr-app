class VideoEpisodeIdentity {
  const VideoEpisodeIdentity({
    required this.seasonNumber,
    required this.episodeNumber,
    this.title,
    this.airDate,
    this.runtimeMinutes,
  });

  final int seasonNumber;
  final int episodeNumber;
  final String? title;
  final DateTime? airDate;
  final int? runtimeMinutes;

  String get code {
    return 'S${seasonNumber.toString().padLeft(2, '0')}E${episodeNumber.toString().padLeft(2, '0')}';
  }
}
