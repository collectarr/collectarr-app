enum VideoDisplayLevel {
  titleWork,
  series,
  season,
  episode,
  release,
}

enum VideoGroupingDefault {
  none,
  bySeries,
}

class LibraryKindWorkspaceBehavior {
  const LibraryKindWorkspaceBehavior({
    this.supportsTrackSearch = false,
    this.supportsSeriesIssueJump = false,
    this.usesTrackListCard = false,
    this.showsSeasonGroupProgress = false,
    this.defaultVideoDisplayLevel,
    this.defaultVideoGrouping = VideoGroupingDefault.none,
    this.videoSeriesEntryTypes = const {},
    this.videoShelfDrilldownEntryTypes = const {},
    this.issueSortNumber,
  });

  final bool supportsTrackSearch;
  final bool supportsSeriesIssueJump;
  final bool usesTrackListCard;
  final bool showsSeasonGroupProgress;
  final VideoDisplayLevel? defaultVideoDisplayLevel;
  final VideoGroupingDefault defaultVideoGrouping;
  final Set<String> videoSeriesEntryTypes;
  final Set<String> videoShelfDrilldownEntryTypes;
  final int? Function(String? raw)? issueSortNumber;
}
