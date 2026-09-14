import 'package:flutter/foundation.dart';

@immutable
class MangaChapterHierarchyNode {
  const MangaChapterHierarchyNode({
    required this.chapterId,
    required this.chapterNumber,
    this.title,
    this.pageCount,
    this.releaseDate,
  });

  final String chapterId;
  final int chapterNumber;
  final String? title;
  final int? pageCount;
  final String? releaseDate;
}

@immutable
class MangaVolumeHierarchyNode {
  const MangaVolumeHierarchyNode({
    required this.volumeId,
    required this.volumeNumber,
    this.title,
    this.chapterCount,
    this.chapters = const [],
    this.releases = const [],
  });

  final String volumeId;
  final int volumeNumber;
  final String? title;
  final int? chapterCount;
  final List<MangaChapterHierarchyNode> chapters;
  final List<String> releases;
}

@immutable
class MangaSeriesHierarchy {
  const MangaSeriesHierarchy({
    required this.seriesId,
    required this.seriesTitle,
    this.volumes = const [],
    this.boxSets = const [],
  });

  final String seriesId;
  final String seriesTitle;
  final List<MangaVolumeHierarchyNode> volumes;
  final List<String> boxSets;
}
