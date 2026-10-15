/// Automatic sort titles, matching Core's catalog rule.
///
/// A leading English article moves to the end ("The Wall" -> "Wall, The") so
/// titles sort by their first significant word; other titles sort as written.
library;

final _leadingArticle = RegExp(r'^(the|a|an)\s+(?=\S)', caseSensitive: false);

String automaticSortTitle(String title) {
  final match = _leadingArticle.firstMatch(title);
  if (match == null) return title;
  return '${title.substring(match.end)}, ${match.group(1)}';
}

/// The explicit sort title, or one derived from [title].
String resolveSortTitle(String title, String? explicit) =>
    explicit == null || explicit.isEmpty ? automaticSortTitle(title) : explicit;

/// Keeps an automatic sort title in step with an edited title, while a sort
/// title someone typed (one that differs from the old automatic value) stays.
String followTitleChange(String oldTitle, String newTitle, String? current) =>
    current == null ||
            current.isEmpty ||
            current == automaticSortTitle(oldTitle)
        ? automaticSortTitle(newTitle)
        : current;
