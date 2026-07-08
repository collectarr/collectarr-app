import 'library_add_pane_dependencies.dart';

// Comic candidate helper utilities (used by unified search and legacy code)

class LibraryAddComicTitleIssueMetadata {
  const LibraryAddComicTitleIssueMetadata({
    required this.seriesTitle,
    required this.issueNumber,
  });

  final String seriesTitle;
  final String issueNumber;
}

LibraryAddComicTitleIssueMetadata? comicTitleIssueMetadata(String title) {
  final trimmed = title.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  final match = RegExp(r'^(.*?)\s+#\s*([^\s\[]+)').firstMatch(trimmed);
  if (match == null) {
    return null;
  }
  final seriesTitle = (match.group(1) ?? '').trim();
  final issueNumber = (match.group(2) ?? '').trim();
  if (seriesTitle.isEmpty || issueNumber.isEmpty) {
    return null;
  }
  return LibraryAddComicTitleIssueMetadata(
    seriesTitle: seriesTitle,
    issueNumber: issueNumber,
  );
}

int compareComicIssueCandidates(
  ProviderCandidate left,
  ProviderCandidate right,
) {
  final byIssue = compareComicIssueNumbers(
    left.issueNumber,
    right.issueNumber,
  );
  if (byIssue != 0) {
    return byIssue;
  }
  return left.title.toLowerCase().compareTo(right.title.toLowerCase());
}

int compareComicIssueNumbers(String? left, String? right) {
  final normalizedLeft = left?.trim();
  final normalizedRight = right?.trim();
  if (normalizedLeft == null || normalizedLeft.isEmpty) {
    return normalizedRight == null || normalizedRight.isEmpty ? 0 : 1;
  }
  if (normalizedRight == null || normalizedRight.isEmpty) {
    return -1;
  }
  final issuePattern = RegExp(r'^(\d+)([A-Za-z]*)$');
  final leftMatch = issuePattern.firstMatch(normalizedLeft);
  final rightMatch = issuePattern.firstMatch(normalizedRight);
  if (leftMatch != null && rightMatch != null) {
    final leftNumber = int.parse(leftMatch.group(1)!);
    final rightNumber = int.parse(rightMatch.group(1)!);
    if (leftNumber != rightNumber) {
      return leftNumber.compareTo(rightNumber);
    }
    return (leftMatch.group(2) ?? '')
        .toLowerCase()
        .compareTo((rightMatch.group(2) ?? '').toLowerCase());
  }
  return normalizedLeft.toLowerCase().compareTo(normalizedRight.toLowerCase());
}
