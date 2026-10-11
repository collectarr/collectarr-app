import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_duplicate_presentation.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';

class LibraryDuplicateGroup {
  const LibraryDuplicateGroup({
    required this.key,
    required this.label,
    required this.reason,
    required this.confidenceScore,
    required this.entries,
    this.entryLabels = const {},
  });

  final String key;
  final String label;
  final String reason;
  final int confidenceScore;
  final List<LibraryWorkspaceContext> entries;
  final Map<LibraryWorkspaceContext, String> entryLabels;

  int get count => entries.length;
}

List<LibraryDuplicateGroup> findDuplicateShelfGroups(
  List<LibraryWorkspaceContext> entries, {
  LibraryDuplicateCriterion criterion = LibraryDuplicateCriterion.automatic,
}) {
  final candidatesByKey = <String, List<_CandidateEntry>>{};
  for (final entry in entries) {
    final registration = defaultLibraryKindRegistry.tryGet(entry.mediaKind);
    if (registration == null) continue;
    final candidates = [
      ...libraryPresentationForKind(registration.kind)
          .builder
          .buildDuplicateCandidates(entry)
    ];
    final title = normalizeLibraryDuplicateToken(entry.title);
    if (criterion == LibraryDuplicateCriterion.title && title != null) {
      candidates.add(LibraryDuplicateCandidate(
          key: 'title:$title',
          label: entry.title,
          reason: 'Same title',
          confidenceScore: 70,
          criterion: criterion));
    }
    for (final candidate in candidates) {
      if (criterion != LibraryDuplicateCriterion.automatic &&
          candidate.criterion != criterion) {
        continue;
      }
      candidatesByKey
          .putIfAbsent(candidate.key, () => [])
          .add(_CandidateEntry(candidate, entry));
    }
  }

  final buckets = <String, _DuplicateBucket>{};
  final occupiedByStrongerMatch = <LibraryWorkspaceContext>{};
  final orderedCandidates = candidatesByKey.values.toList()
    ..sort((left, right) =>
        _candidateScore(right).compareTo(_candidateScore(left)));
  for (final candidateEntries in orderedCandidates) {
    final distinctEntries = candidateEntries.map((item) => item.entry).toSet();
    if (distinctEntries.length < 2) continue;
    final score = _candidateScore(candidateEntries);
    if (score < 70 && distinctEntries.every(occupiedByStrongerMatch.contains)) {
      continue;
    }
    for (final candidateEntry in candidateEntries) {
      _addToBucket(
        buckets,
        candidate: candidateEntry.candidate,
        entry: candidateEntry.entry,
      );
    }
    if (score >= 70) {
      occupiedByStrongerMatch.addAll(distinctEntries);
    }
  }

  final groups = _duplicateGroups(buckets);
  groups.sort((a, b) {
    final scoreOrder = b.confidenceScore.compareTo(a.confidenceScore);
    if (scoreOrder != 0) {
      return scoreOrder;
    }
    final reasonOrder = _duplicateReasonOrder(a.reason).compareTo(
      _duplicateReasonOrder(b.reason),
    );
    if (reasonOrder != 0) {
      return reasonOrder;
    }
    return a.label.toLowerCase().compareTo(b.label.toLowerCase());
  });
  return groups;
}

class _DuplicateBucket {
  _DuplicateBucket({
    required this.label,
    required this.reason,
    required this.confidenceScore,
  });

  final String label;
  final String reason;
  int confidenceScore;
  final List<LibraryWorkspaceContext> entries = [];
  final Map<LibraryWorkspaceContext, String> entryLabels = {};
}

final class _CandidateEntry {
  const _CandidateEntry(this.candidate, this.entry);

  final LibraryDuplicateCandidate candidate;
  final LibraryWorkspaceContext entry;
}

int _candidateScore(List<_CandidateEntry> candidates) {
  return candidates.fold<int>(
      0,
      (score, candidate) => candidate.candidate.confidenceScore > score
          ? candidate.candidate.confidenceScore
          : score);
}

void _addToBucket(
  Map<String, _DuplicateBucket> buckets, {
  required LibraryDuplicateCandidate candidate,
  required LibraryWorkspaceContext entry,
}) {
  final bucket = buckets.putIfAbsent(
    candidate.key,
    () => _DuplicateBucket(
      label: candidate.label,
      reason: candidate.reason,
      confidenceScore: candidate.confidenceScore,
    ),
  );
  if (candidate.confidenceScore > bucket.confidenceScore) {
    bucket.confidenceScore = candidate.confidenceScore;
  }
  bucket.entries.add(entry);
  if (candidate.entryLabel case final label?) {
    bucket.entryLabels[entry] = label;
  }
}

List<LibraryDuplicateGroup> _duplicateGroups(
  Map<String, _DuplicateBucket> buckets,
) {
  return [
    for (final bucket in buckets.entries)
      if (bucket.value.entries.length > 1)
        LibraryDuplicateGroup(
          key: bucket.key,
          label: bucket.value.label,
          reason: bucket.value.reason,
          confidenceScore: _duplicateConfidenceScore(bucket.value),
          entries: _sortedEntries(bucket.value.entries),
          entryLabels: Map.unmodifiable(bucket.value.entryLabels),
        ),
  ];
}

int _duplicateConfidenceScore(_DuplicateBucket bucket) {
  var score = bucket.confidenceScore;
  final entryCount = bucket.entries.where((entry) => entry.isEntry).length;
  if (entryCount > 0 && entryCount < bucket.entries.length) {
    score += 2;
  }

  score += bucket.entries.length > 2 ? 2 : 0;
  return score.clamp(0, 99);
}

List<LibraryWorkspaceContext> _sortedEntries(
    List<LibraryWorkspaceContext> entries) {
  return entries.toList(growable: false)
    ..sort((a, b) {
      final title = a.title.toLowerCase().compareTo(b.title.toLowerCase());
      if (title != 0) {
        return title;
      }
      return a.itemId.compareTo(b.itemId);
    });
}

int _duplicateReasonOrder(String reason) {
  return switch (reason) {
    'Same barcode' => 0,
    'Same issue metadata' => 1,
    _ => 2,
  };
}
