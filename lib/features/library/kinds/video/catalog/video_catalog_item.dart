import 'package:collectarr_app/features/library/kinds/video/catalog/video_catalog_release.dart';

class VideoWorkMetadata {
  const VideoWorkMetadata({
    required this.title,
    this.originalTitle,
    this.synopsis,
    this.releaseDate,
    this.originalLanguage,
    this.genres = const [],
  });

  final String title;
  final String? originalTitle;
  final String? synopsis;
  final DateTime? releaseDate;
  final String? originalLanguage;
  final List<String> genres;
}

class VideoTechnicalMetadata {
  const VideoTechnicalMetadata({
    this.runtimeMinutes,
    this.color,
    this.screenRatio,
    this.audioTracks,
    this.subtitles,
    this.ageRating,
    this.audienceRating,
  });

  final int? runtimeMinutes;
  final String? color;
  final String? screenRatio;
  final String? audioTracks;
  final String? subtitles;
  final String? ageRating;
  final String? audienceRating;
}

class VideoCatalogItem {
  const VideoCatalogItem({
    required this.id,
    required this.work,
    required this.technical,
    required this.releases,
  });

  final String id;
  final VideoWorkMetadata work;
  final VideoTechnicalMetadata technical;
  final List<VideoRelease> releases;
}
