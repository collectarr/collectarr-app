import 'package:collectarr_app/features/library/add/services/library_cover_scan_service.dart';

final class ComicCoverScanHints {
  const ComicCoverScanHints({
    this.series,
    this.issueNumber,
    this.publisher,
    this.year,
  });

  final String? series;
  final String? issueNumber;
  final String? publisher;
  final int? year;
}

ComicCoverScanHints parseComicCoverScanHints(LibraryCoverScanResult result) {
  final cleaned = result.query?.trim();
  if (cleaned == null || cleaned.isEmpty) {
    return ComicCoverScanHints(year: result.year);
  }

  var remainder = cleaned;
  final issueMatches = RegExp(r'(?:(?<=\s)|^)#?(\d{1,4}[A-Za-z]?)\b')
      .allMatches(remainder)
      .toList(growable: false);
  final issueNumber = issueMatches.isEmpty ? null : issueMatches.last.group(1);
  if (issueMatches.isNotEmpty) {
    remainder = remainder.replaceFirst(issueMatches.last.group(0)!, ' ');
  }

  final publisher = _extractPublisher(remainder);
  if (publisher != null) {
    remainder = remainder.replaceFirst(
      RegExp(r'\b' + RegExp.escape(publisher) + r'\b', caseSensitive: false),
      ' ',
    );
  }

  final series = remainder.replaceAll(RegExp(r'\s+'), ' ').trim();
  return ComicCoverScanHints(
    series: series.isEmpty ? cleaned : series,
    issueNumber: issueNumber,
    publisher: publisher,
    year: result.year,
  );
}

String? _extractPublisher(String value) {
  const publishers = <String>['DC', 'Marvel', 'Image', 'Dark Horse', 'Boom'];
  for (final publisher in publishers) {
    if (RegExp(r'\b' + RegExp.escape(publisher) + r'\b', caseSensitive: false)
        .hasMatch(value)) {
      return publisher;
    }
  }
  return null;
}
