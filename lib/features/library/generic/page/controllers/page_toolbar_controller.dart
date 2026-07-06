part of '../library_page.dart';

abstract final class _LibraryToolbarControllerOps {
  static List<LibraryToolbarSearchSuggestion> buildSearchSuggestions(
    LibraryProjection projection,
    String query,
  ) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return const <LibraryToolbarSearchSuggestion>[];
    }
    final ranked = <(int, LibraryToolbarSearchSuggestion)>[];
    for (final item in projection.allItems) {
      final entry = item.entry;
      final title = entry.resolvedTitle.trim().isEmpty
          ? entry.title.trim()
          : entry.resolvedTitle.trim();
      if (title.isEmpty) {
        continue;
      }
      final normalizedTitle = title.toLowerCase();
      final itemNumber = entry.itemNumber?.trim();
      final publisher = entry.publisher?.trim();
      final subtitleParts = <String>[
        if (itemNumber != null && itemNumber.isNotEmpty) '#$itemNumber',
        if (publisher != null && publisher.isNotEmpty) publisher,
      ];
      final subtitle = subtitleParts.isEmpty ? null : subtitleParts.join(' • ');
      var score = 0;
      if (normalizedTitle.startsWith(normalizedQuery)) {
        score = 3;
      } else if (normalizedTitle.contains(normalizedQuery)) {
        score = 2;
      } else if ((itemNumber?.toLowerCase().contains(normalizedQuery) ?? false) ||
          (publisher?.toLowerCase().contains(normalizedQuery) ?? false)) {
        score = 1;
      }
      if (score == 0) {
        continue;
      }
      ranked.add((
        score,
        LibraryToolbarSearchSuggestion(
          id: entry.id,
          title: title,
          subtitle: subtitle,
        ),
      ));
    }
    ranked.sort((left, right) {
      final byScore = right.$1.compareTo(left.$1);
      if (byScore != 0) {
        return byScore;
      }
      return left.$2.title
          .toLowerCase()
          .compareTo(right.$2.title.toLowerCase());
    });
    return ranked.map((value) => value.$2).take(8).toList(growable: false);
  }
}

typedef LibraryToolbarSearchSuggestionsInput = ({
  LibraryProjection? projection,
  String query,
});

final libraryToolbarSearchSuggestionsProvider =
    Provider.autoDispose.family<List<LibraryToolbarSearchSuggestion>,
        LibraryToolbarSearchSuggestionsInput>((ref, input) {
  final projection = input.projection;
  if (projection == null) {
    return const <LibraryToolbarSearchSuggestion>[];
  }
  return _LibraryToolbarControllerOps.buildSearchSuggestions(
    projection,
    input.query,
  );
});
