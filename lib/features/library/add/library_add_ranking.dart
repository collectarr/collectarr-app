import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

class LibraryAddLocalRerankHints {
  const LibraryAddLocalRerankHints({
    this.query = '',
    this.series = '',
    this.issueNumber = '',
    this.publisher = '',
    this.year,
  });

  final String query;
  final String series;
  final String issueNumber;
  final String publisher;
  final int? year;

  bool get hasAnyHint {
    return query.trim().isNotEmpty ||
        series.trim().isNotEmpty ||
        issueNumber.trim().isNotEmpty ||
        publisher.trim().isNotEmpty ||
        year != null;
  }
}

List<LibraryMetadataItem> rerankLibraryMetadataItems(
  List<LibraryMetadataItem> items,
  LibraryAddLocalRerankHints hints,
) {
  if (items.length < 2 || !hints.hasAnyHint) {
    return items;
  }
  final indexed = items.indexed.toList(growable: false);
  indexed.sort((left, right) {
    final leftScore = _scoreMetadataItem(left.$2, hints);
    final rightScore = _scoreMetadataItem(right.$2, hints);
    if (leftScore != rightScore) {
      return rightScore.compareTo(leftScore);
    }
    return left.$1.compareTo(right.$1);
  });
  return indexed.map((entry) => entry.$2).toList(growable: false);
}

List<ProviderCandidate> rerankProviderCandidates(
  List<ProviderCandidate> items,
  LibraryAddLocalRerankHints hints,
) {
  if (items.length < 2 || !hints.hasAnyHint) {
    return items;
  }
  final indexed = items.indexed.toList(growable: false);
  indexed.sort((left, right) {
    final leftScore = _scoreProviderCandidate(left.$2, hints);
    final rightScore = _scoreProviderCandidate(right.$2, hints);
    if (leftScore != rightScore) {
      return rightScore.compareTo(leftScore);
    }
    return left.$1.compareTo(right.$1);
  });
  return indexed.map((entry) => entry.$2).toList(growable: false);
}

const libraryAddProviderFallbackConfidenceThreshold = 0.72;

bool shouldSearchProviderForCoreResults(
  List<LibraryMetadataItem> items,
  LibraryAddLocalRerankHints hints, {
  double confidenceThreshold = libraryAddProviderFallbackConfidenceThreshold,
}) {
  if (items.isEmpty) {
    return true;
  }
  return _topMetadataMatchConfidence(items, hints) < confidenceThreshold;
}

double _topMetadataMatchConfidence(
  List<LibraryMetadataItem> items,
  LibraryAddLocalRerankHints hints,
) {
  if (items.isEmpty || !hints.hasAnyHint) {
    return 0;
  }
  final maxScore = _maxPossibleMatchScore(hints);
  if (maxScore <= 0) {
    return 0;
  }
  final topScore = _scoreMetadataItem(items.first, hints);
  return (topScore / maxScore).clamp(0, 1).toDouble();
}

int _scoreMetadataItem(LibraryMetadataItem item, LibraryAddLocalRerankHints hints) {
  return _scoreMatchFields(
    title: item.title,
    series: item.series?.seriesTitle,
    issueNumber: item.itemNumber,
    publisher: item.publisher,
    year: item.releaseYear ?? item.series?.volumeStartYear,
    hints: hints,
  );
}

int _scoreProviderCandidate(ProviderCandidate item, LibraryAddLocalRerankHints hints) {
  return _scoreMatchFields(
    title: item.title,
    series: item.series?.seriesTitle,
    issueNumber: item.issueNumber,
    publisher: item.publisher,
    year: item.series?.volumeStartYear,
    hints: hints,
  );
}

int _maxPossibleMatchScore(LibraryAddLocalRerankHints hints) {
  var score = 0;
  if (_normalizeHint(hints.query).isNotEmpty) {
    score += 100;
  }
  if (_normalizeHint(hints.series).isNotEmpty) {
    score += 120;
  }
  if (_normalizeHint(hints.publisher).isNotEmpty) {
    score += 60;
  }
  if (_normalizeHint(hints.issueNumber).isNotEmpty) {
    score += 75;
  }
  if (hints.year != null) {
    score += 55;
  }
  return score;
}

int _scoreMatchFields({
  required String title,
  required String? series,
  required String? issueNumber,
  required String? publisher,
  required int? year,
  required LibraryAddLocalRerankHints hints,
}) {
  var score = 0;
  score += _scoreTextHint(title, hints.query, exactWeight: 100, containsWeight: 36);
  score += _scoreTextHint(
    series ?? title,
    hints.series,
    exactWeight: 120,
    containsWeight: 48,
  );
  score += _scoreTextHint(
    publisher,
    hints.publisher,
    exactWeight: 60,
    containsWeight: 24,
  );
  if (_normalizeHint(issueNumber).isNotEmpty &&
      _normalizeHint(issueNumber) == _normalizeHint(hints.issueNumber)) {
    score += 75;
  }
  if (hints.year != null && year == hints.year) {
    score += 55;
  }
  return score;
}

int _scoreTextHint(
  String? candidate,
  String? hint, {
  required int exactWeight,
  required int containsWeight,
}) {
  final normalizedCandidate = _normalizeHint(candidate);
  final normalizedHint = _normalizeHint(hint);
  if (normalizedCandidate.isEmpty || normalizedHint.isEmpty) {
    return 0;
  }
  if (normalizedCandidate == normalizedHint) {
    return exactWeight;
  }
  if (normalizedCandidate.contains(normalizedHint) ||
      normalizedHint.contains(normalizedCandidate)) {
    return containsWeight;
  }
  return 0;
}

String _normalizeHint(String? value) {
  return value
          ?.trim()
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim() ??
      '';
}
