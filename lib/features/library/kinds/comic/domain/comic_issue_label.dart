/// The reference Issue value: issue number followed by the variant ("2A").
String? comicIssueText(String? issueNumber, String? variant) {
  final value = '${issueNumber?.trim() ?? ''}${variant?.trim() ?? ''}';
  return value.isEmpty ? null : value;
}

/// Series and issue ("Absolute Batman #2A"), then the issue's own title
/// unless it only repeats them, as the reference's Full Title.
String? comicHeadline({
  required String? series,
  required String? issueNumber,
  required String? variant,
  required String title,
}) {
  final seriesText = series?.trim() ?? '';
  final issue = comicIssueText(issueNumber, variant);
  final head = [
    if (seriesText.isNotEmpty) seriesText,
    if (issue != null) '#$issue',
  ].join(' ');
  final own = title.trim();
  if (own.isEmpty || own == seriesText || own == head) {
    return head.isEmpty ? null : head;
  }
  return head.isEmpty ? own : '$head - $own';
}
