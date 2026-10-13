final class MetadataSearchQuery {
  const MetadataSearchQuery({
    this.query,
    this.kind,
    this.series,
    this.issueNumber,
    this.publisher,
    this.year,
    this.barcode,
    this.limit,
    this.offset,
  });

  final String? query;
  final String? kind;
  final String? series;
  final String? issueNumber;
  final String? publisher;
  final int? year;
  final String? barcode;
  final int? limit;
  final int? offset;

  MetadataSearchQuery withOffset(int value) => MetadataSearchQuery(
        query: query,
        kind: kind,
        series: series,
        issueNumber: issueNumber,
        publisher: publisher,
        year: year,
        barcode: barcode,
        limit: limit,
        offset: value,
      );

  bool get isEmpty {
    return !_hasText(query) &&
        !_hasText(series) &&
        !_hasText(issueNumber) &&
        !_hasText(publisher) &&
        !_hasText(barcode) &&
        year == null;
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      if (_hasText(query)) 'q': query!.trim(),
      if (kind != null) 'kind': kind,
      if (_hasText(series)) 'series': series!.trim(),
      if (_hasText(issueNumber)) 'issue_number': issueNumber!.trim(),
      if (_hasText(publisher)) 'publisher': publisher!.trim(),
      if (year != null) 'year': year,
      if (_hasText(barcode)) 'barcode': normalizeBarcode(barcode!),
      if (limit != null) 'limit': limit,
      if (offset != null) 'offset': offset,
    };
  }

  static String normalizeBarcode(String value) {
    return value.replaceAll(RegExp(r'[^0-9Xx]'), '');
  }

  static bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
