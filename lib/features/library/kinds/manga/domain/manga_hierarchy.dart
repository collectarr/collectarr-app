import 'package:flutter/foundation.dart';

@immutable
class MangaVolumeHierarchyNode {
  const MangaVolumeHierarchyNode({
    required this.volumeId,
    required this.volumeNumber,
    this.title,
    this.chapterCount,
    this.releases = const [],
  });

  final String volumeId;
  final int volumeNumber;
  final String? title;
  final int? chapterCount;
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
