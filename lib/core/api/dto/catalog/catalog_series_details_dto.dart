class CatalogSeriesDetailsDto {
  const CatalogSeriesDetailsDto({
    this.seriesId,
    this.seriesTitle,
    this.volumeName,
    this.volumeNumber,
    this.volumeStartYear,
    this.seasonNumber,
    this.episodeNumber,
    this.tags,
  });

  final String? seriesId;
  final String? seriesTitle;
  final String? volumeName;
  final String? volumeNumber;
  final int? volumeStartYear;
  final int? seasonNumber;
  final int? episodeNumber;
  final String? tags;

  bool get hasData =>
      (seriesId != null && seriesId!.isNotEmpty) ||
      (seriesTitle != null && seriesTitle!.isNotEmpty) ||
      (volumeName != null && volumeName!.isNotEmpty) ||
      volumeNumber != null ||
      volumeStartYear != null ||
      seasonNumber != null ||
      episodeNumber != null ||
      (tags != null && tags!.isNotEmpty);

  bool get hasVolume =>
      (volumeName != null && volumeName!.isNotEmpty) || volumeNumber != null;
  bool get hasSeason => seasonNumber != null;
  bool get hasEpisode => episodeNumber != null;

  factory CatalogSeriesDetailsDto.fromJson(Map<String, dynamic> json) {
    return CatalogSeriesDetailsDto(
      seriesId: json['series_id'] as String?,
      seriesTitle: json['series_title'] as String?,
      volumeName: json['volume_name'] as String?,
      volumeNumber: json['volume_number']?.toString(),
      volumeStartYear: json['volume_start_year'] as int?,
      seasonNumber: json['season_number'] as int?,
      episodeNumber: json['episode_number'] as int?,
      tags: json['tags'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (seriesId != null) 'series_id': seriesId,
        if (seriesTitle != null) 'series_title': seriesTitle,
        if (volumeName != null) 'volume_name': volumeName,
        if (volumeNumber != null) 'volume_number': volumeNumber,
        if (volumeStartYear != null) 'volume_start_year': volumeStartYear,
        if (seasonNumber != null) 'season_number': seasonNumber,
        if (episodeNumber != null) 'episode_number': episodeNumber,
        if (tags != null) 'tags': tags,
      };
}

typedef CatalogSeriesDetails = CatalogSeriesDetailsDto;

