import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

typedef LibraryAddMetadataSearchScore = int Function(
  LibraryMetadataItem item,
  LibraryAddSearchContext context,
);

typedef LibraryAddProviderSearchScore = int Function(
  ProviderCandidate candidate,
  LibraryAddSearchContext context,
);

class LibraryAddSearchRankField {
  const LibraryAddSearchRankField({
    required this.id,
    required this.exactWeight,
    required this.containsWeight,
    required this.metadataValues,
    required this.providerValues,
  });

  final LibraryAddFilterId id;
  final int exactWeight;
  final int containsWeight;
  final Iterable<Object?> Function(LibraryMetadataItem item) metadataValues;
  final Iterable<Object?> Function(ProviderCandidate candidate) providerValues;
}

class LibraryAddSearchRanking {
  const LibraryAddSearchRanking({
    required this.scoreMetadata,
    required this.scoreProvider,
    required this.maxScore,
  });

  final LibraryAddMetadataSearchScore scoreMetadata;
  final LibraryAddProviderSearchScore scoreProvider;
  final int Function(LibraryAddSearchContext context) maxScore;

  List<LibraryMetadataItem> rankMetadata(
    List<LibraryMetadataItem> items,
    LibraryAddSearchContext context,
  ) {
    if (items.length < 2 || !context.hasAnyInput) {
      return items;
    }
    return _stableRank(items, (item) => scoreMetadata(item, context));
  }

  List<ProviderCandidate> rankProvider(
    List<ProviderCandidate> items,
    LibraryAddSearchContext context,
  ) {
    if (items.length < 2 || !context.hasAnyInput) {
      return items;
    }
    return _stableRank(items, (candidate) => scoreProvider(candidate, context));
  }

  bool shouldSearchProviderForCoreResults(
    List<LibraryMetadataItem> items,
    LibraryAddSearchContext context, {
    double confidenceThreshold = libraryAddProviderFallbackConfidenceThreshold,
  }) {
    if (items.isEmpty) {
      return true;
    }
    final possibleScore = maxScore(context);
    if (possibleScore <= 0) {
      return true;
    }
    final confidence = scoreMetadata(items.first, context) / possibleScore;
    return confidence < confidenceThreshold;
  }
}

const libraryAddProviderFallbackConfidenceThreshold = 0.72;

LibraryAddSearchRanking buildLibraryAddSearchRanking({
  required List<LibraryAddSearchRankField> fields,
}) {
  int scoreMetadata(
    LibraryMetadataItem item,
    LibraryAddSearchContext context,
  ) {
    var score = _scoreText(
      item.title,
      context.query,
      exactWeight: 100,
      containsWeight: 36,
    );
    for (final field in fields) {
      score += _scoreField(
        context.valueFor(field.id),
        field.metadataValues(item),
        exactWeight: field.exactWeight,
        containsWeight: field.containsWeight,
      );
    }
    return score;
  }

  int scoreProvider(
    ProviderCandidate candidate,
    LibraryAddSearchContext context,
  ) {
    var score = _scoreText(
      candidate.title,
      context.query,
      exactWeight: 100,
      containsWeight: 36,
    );
    for (final field in fields) {
      score += _scoreField(
        context.valueFor(field.id),
        field.providerValues(candidate),
        exactWeight: field.exactWeight,
        containsWeight: field.containsWeight,
      );
    }
    return score;
  }

  int maxScore(LibraryAddSearchContext context) {
    var score = context.query.trim().isEmpty ? 0 : 100;
    for (final field in fields) {
      if (_normalize(context.valueFor(field.id)).isNotEmpty) {
        score += field.exactWeight;
      }
    }
    return score;
  }

  return LibraryAddSearchRanking(
    scoreMetadata: scoreMetadata,
    scoreProvider: scoreProvider,
    maxScore: maxScore,
  );
}

List<T> _stableRank<T>(List<T> items, int Function(T item) score) {
  final indexed = items.indexed.toList(growable: false);
  indexed.sort((left, right) {
    final leftScore = score(left.$2);
    final rightScore = score(right.$2);
    if (leftScore != rightScore) {
      return rightScore.compareTo(leftScore);
    }
    return left.$1.compareTo(right.$1);
  });
  return indexed.map((entry) => entry.$2).toList(growable: false);
}

int _scoreField(
  Object? hint,
  Iterable<Object?> values, {
  required int exactWeight,
  required int containsWeight,
}) {
  var best = 0;
  for (final value in values) {
    final score = _scoreText(
      value?.toString(),
      hint?.toString(),
      exactWeight: exactWeight,
      containsWeight: containsWeight,
    );
    if (score > best) best = score;
  }
  return best;
}

int _scoreText(
  String? candidate,
  String? hint, {
  required int exactWeight,
  required int containsWeight,
}) {
  final normalizedCandidate = _normalize(candidate);
  final normalizedHint = _normalize(hint);
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
  final candidateTokens = normalizedCandidate.split(' ');
  final hintTokens = normalizedHint.split(' ');
  if (candidateTokens.any(hintTokens.contains)) {
    return (containsWeight / 2).round().clamp(1, containsWeight);
  }
  return 0;
}

String _normalize(Object? value) {
  return value
          ?.toString()
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim() ??
      '';
}

List<LibraryMetadataItem> filterAndRankLibraryMetadataItems(
  List<LibraryMetadataItem> items,
  LibraryAddSearchRanking ranking,
  LibraryAddSearchContext context, {
  int minimumScore = 1,
}) {
  if (items.isEmpty || !context.hasAnyInput) {
    return items;
  }
  final ranked = ranking.rankMetadata(items, context);
  return [
    for (final item in ranked)
      if (ranking.scoreMetadata(item, context) >= minimumScore) item,
  ];
}
