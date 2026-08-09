class LibrarySeriesGapAnalyzer {
  const LibrarySeriesGapAnalyzer();

  List<int> calculateMissingIssues({
    required List<int> ownedIssues,
    int? maxIssue,
  }) {
    if (ownedIssues.isEmpty) return const [];
    final sorted = List<int>.from(ownedIssues)..sort();
    final limit = maxIssue ?? sorted.last;
    final ownedSet = sorted.toSet();
    final gaps = <int>[];
    for (var i = 1; i <= limit; i++) {
      if (!ownedSet.contains(i)) {
        gaps.add(i);
      }
    }
    return gaps;
  }
}
