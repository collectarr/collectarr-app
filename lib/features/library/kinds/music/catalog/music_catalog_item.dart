import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_release.dart';

class MusicWorkMetadata {
  const MusicWorkMetadata({
    required this.title,
    this.originalTitle,
    this.synopsis,
    this.artist,
    this.genres = const [],
  });

  final String title;
  final String? originalTitle;
  final String? synopsis;
  final String? artist;
  final List<String> genres;
}

class MusicRecordingMetadata {
  const MusicRecordingMetadata({
    this.trackCount,
    this.studio,
    this.originalReleaseDate,
    this.recordingDate,
    this.isLive,
    this.composition,
  });

  final int? trackCount;
  final String? studio;
  final DateTime? originalReleaseDate;
  final DateTime? recordingDate;
  final bool? isLive;
  final String? composition;
}

class MusicCatalogItem {
  const MusicCatalogItem({
    required this.id,
    required this.work,
    required this.recording,
    required this.releases,
  });

  final String id;
  final MusicWorkMetadata work;
  final MusicRecordingMetadata recording;
  final List<MusicRelease> releases;
}
