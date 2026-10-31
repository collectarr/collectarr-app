class LibrarySequenceGapAnalyzer {
  const LibrarySequenceGapAnalyzer();

  List<int> calculateMissingSequence({
    required List<int> entryValues,
    int? maxValue,
  }) {
    if (entryValues.isEmpty) return const [];
    final sorted = List<int>.from(entryValues)..sort();
    final limit = maxValue ?? sorted.last;
    final entrySet = sorted.toSet();
    final gaps = <int>[];
    for (var i = 1; i <= limit; i++) {
      if (!entrySet.contains(i)) {
        gaps.add(i);
      }
    }
    return gaps;
  }

  List<int> calculateGapsForBucket({
    required Set<int> entryNumbers,
    required Set<int> bucketNumbers,
    int maxGapCount = 1000,
  }) {
    if (entryNumbers.length < 2 || bucketNumbers.length < 2) {
      return const [];
    }
    final sortedEntry = entryNumbers.toList(growable: false)..sort();
    final sortedExisting = bucketNumbers.toList(growable: false)..sort();
    final missing = <int>[];

    for (final number in sortedExisting) {
      if (number < sortedEntry.first || number > sortedEntry.last) continue;
      if (entryNumbers.contains(number)) continue;
      missing.add(number);
      if (missing.length > maxGapCount) break;
    }
    return missing;
  }
}
