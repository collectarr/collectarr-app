class CatalogSeriesDetailsDto {
  const CatalogSeriesDetailsDto({
    this.seriesId,
    this.seriesTitle,
    this.volumeName,
    this.volumeNumber,
    this.volumeStartYear,
    this.seasonNumber,
    this.episodeNumber,
    this.tags = const <String>[],
  });

  final String? seriesId;
  final String? seriesTitle;
  final String? volumeName;
  final double? volumeNumber;
  final int? volumeStartYear;
  final int? seasonNumber;
  final int? episodeNumber;
  final List<String> tags;

  bool get hasData =>
      seriesId != null ||
      seriesTitle != null ||
      volumeName != null ||
      volumeNumber != null ||
      volumeStartYear != null ||
      seasonNumber != null ||
      episodeNumber != null ||
      tags.isNotEmpty;

  bool get hasVolume => volumeName != null || volumeNumber != null;
  bool get hasSeason => seasonNumber != null;
  bool get hasEpisode => episodeNumber != null;
}
