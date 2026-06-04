enum LibrarySearchTarget {
  all,
  mediaOnly,
  tracksOnly,
}

extension LibrarySearchTargetX on LibrarySearchTarget {
  bool get includesMedia => this != LibrarySearchTarget.tracksOnly;

  bool get includesTracks => this != LibrarySearchTarget.mediaOnly;
}
