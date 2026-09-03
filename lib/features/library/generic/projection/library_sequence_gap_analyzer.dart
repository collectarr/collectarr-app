class LibrarySequenceGapAnalyzer {
  const LibrarySequenceGapAnalyzer();

  List<int> calculateMissingSequence({
    required List<int> ownedValues,
    int? maxValue,
  }) {
    if (ownedValues.isEmpty) return const [];
    final sorted = List<int>.from(ownedValues)..sort();
    final limit = maxValue ?? sorted.last;
    final ownedSet = sorted.toSet();
    final gaps = <int>[];
    for (var i = 1; i <= limit; i++) {
      if (!ownedSet.contains(i)) {
        gaps.add(i);
      }
    }
    return gaps;
  }

  List<int> calculateGapsForBucket({
    required Set<int> ownedNumbers,
    required Set<int> bucketNumbers,
    int maxGapCount = 1000,
  }) {
    if (ownedNumbers.length < 2 || bucketNumbers.length < 2) {
      return const [];
    }
    final sortedOwned = ownedNumbers.toList(growable: false)..sort();
    final sortedExisting = bucketNumbers.toList(growable: false)..sort();
    final missing = <int>[];

    for (final number in sortedExisting) {
      if (number < sortedOwned.first || number > sortedOwned.last) continue;
      if (ownedNumbers.contains(number)) continue;
      missing.add(number);
      if (missing.length > maxGapCount) break;
    }
    return missing;
  }
}
