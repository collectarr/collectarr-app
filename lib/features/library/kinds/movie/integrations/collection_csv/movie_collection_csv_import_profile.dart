import 'package:collectarr_app/core/models/catalog_media_kind.dart';

/// Typed Movie interpretation of the collection CSV boundary.
///
/// The generic Collection host owns the wire row shape. This profile owns
/// Movie's labels and the translation of those labels into the host's
/// positional cells.
final class MovieCollectionCsvImportRow {
  const MovieCollectionCsvImportRow({
    required this.itemId,
    this.kind,
    this.title,
    this.itemNumber,
    this.variant,
    this.editionTitle,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.studio,
    this.releaseDate,
    this.barcode,
  });

  final String itemId;
  final String? kind;
  final String? title;
  final String? itemNumber;
  final String? variant;
  final String? editionTitle;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final String? studio;
  final DateTime? releaseDate;
  final String? barcode;

  List<String> get catalogCells => [
        itemId,
        kind ?? '',
        title ?? '',
        itemNumber ?? '',
        variant ?? '',
        editionTitle ?? '',
        physicalFormat ?? '',
        physicalFormatLabel ?? '',
        studio ?? '',
        _formatDate(releaseDate),
        barcode ?? '',
      ];

  List<String> get ownedCells => List<String>.filled(9, '');

  static String _formatDate(DateTime? value) {
    if (value == null) return '';
    final utc = value.toUtc();
    return '${utc.year.toString().padLeft(4, '0')}-'
        '${utc.month.toString().padLeft(2, '0')}-'
        '${utc.day.toString().padLeft(2, '0')}';
  }
}

/// Movie's CLZ labels and aliases for collection CSV import.
final class MovieCollectionCsvImportProfile {
  const MovieCollectionCsvImportProfile();

  static const clzFriendlyHeader = [
    'Collectarr Item ID',
    'Media Type',
    'Title',
    'Edition no.',
    'Variant',
    'Edition Title',
    'Physical Format',
    'Physical Format Label',
    'Studio',
    'Release Date',
    'UPC / Barcode',
    'Collection Status',
    'Condition',
    'Grade',
    'Purchase Date',
    'Purchase Price',
    'Currency',
    'Cover Price',
    'Quantity',
    'Location ID',
    'Index',
    'Raw / Slabbed',
    'Grading Company',
    'Grader Notes',
    'Signed By',
    'Label Type',
    'Certification Number',
    'Key Comic',
    'Key Reason',
    'Rating',
    'Read It',
    'Started',
    'Finished',
    'Tags',
    'Notes',
    'Sold Date',
    'Sell Price',
    'Sold To',
  ];

  static const columnAliases = <String, List<String>>{
    'item_id': ['Collectarr Item ID'],
    'kind': ['Media Type', 'Kind', 'Type', 'Library', 'Media Kind'],
    'title': ['Title', 'Full Title'],
    'item_number': ['Edition no.', 'Edition Number', 'Release Number'],
    'variant': ['Variant', 'Edition / Variant'],
    'edition_title': ['Edition Title', 'Edition Name', 'Release Title'],
    'physical_format': [
      'Physical Format',
      'Format ID',
      'Media Format',
      'Video Format',
      'Disc Format',
    ],
    'physical_format_label': [
      'Physical Format Label',
      'Format',
      'Format Label',
      'Video Format Label',
    ],
    'publisher': [
      'Studio',
      'Publisher',
      'Network / Studio',
      'Studio / Publisher',
    ],
    'release_date': ['Release Date'],
    'barcode': [
      'UPC / Barcode',
      'Barcode',
      'UPC',
      'Barcode / UPC',
    ],
  };

  MovieCollectionCsvImportRow? parseRow({
    required List<String> header,
    required List<String> values,
  }) {
    final index = _headerIndex(header);
    if (!_isMovieRow(index, header, values)) return null;

    return MovieCollectionCsvImportRow(
      itemId: _value(index, values, 'item_id'),
      kind: _optionalValue(index, values, 'kind'),
      title: _optionalValue(index, values, 'title'),
      itemNumber: _optionalValue(index, values, 'item_number'),
      variant: _optionalValue(index, values, 'variant'),
      editionTitle: _optionalValue(index, values, 'edition_title'),
      physicalFormat: _optionalValue(index, values, 'physical_format'),
      physicalFormatLabel:
          _optionalValue(index, values, 'physical_format_label'),
      studio: _optionalValue(index, values, 'publisher'),
      releaseDate: _parseDate(_value(index, values, 'release_date')),
      barcode: _optionalValue(index, values, 'barcode'),
    );
  }

  Map<String, int> _headerIndex(List<String> header) {
    final index = <String, int>{};
    for (var i = 0; i < header.length; i++) {
      index[_canonicalColumn(header[i])] = i;
    }
    return index;
  }

  bool _isMovieRow(
    Map<String, int> index,
    List<String> header,
    List<String> values,
  ) {
    final kind = _optionalValue(index, values, 'kind')?.toLowerCase();
    if (kind != null) {
      return catalogMediaKindFromValue(kind) == CatalogMediaKind.movie;
    }

    // A kind-less CLZ export is accepted only when it carries Movie's
    // unambiguous Studio + UPC labels. Other rows are handled by another
    // kind-owned profile.
    final normalizedHeader = header.map(_normalizeColumn).toSet();
    return normalizedHeader.contains('studio') &&
        normalizedHeader.contains('upc_barcode');
  }

  String _canonicalColumn(String value) {
    final normalized = _normalizeColumn(value);
    if (columnAliases.containsKey(normalized)) return normalized;
    for (final entry in columnAliases.entries) {
      if (entry.value.any(
        (alias) => _normalizeColumn(alias) == normalized,
      )) {
        return entry.key;
      }
    }
    return normalized;
  }

  String _value(Map<String, int> index, List<String> values, String column) {
    final valueIndex = index[_normalizeColumn(column)];
    if (valueIndex == null || valueIndex >= values.length) return '';
    return values[valueIndex];
  }

  String? _optionalValue(
    Map<String, int> index,
    List<String> values,
    String column,
  ) {
    final value = _value(index, values, column).trim();
    return value.isEmpty ? null : value;
  }

  DateTime? _parseDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) {
      return DateTime.utc(parsed.year, parsed.month, parsed.day);
    }
    final match =
        RegExp(r'^(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})$').firstMatch(trimmed);
    if (match == null) return null;
    final first = int.parse(match.group(1)!);
    final second = int.parse(match.group(2)!);
    final rawYear = match.group(3)!;
    final year = rawYear.length == 4
        ? int.parse(rawYear)
        : (int.parse(rawYear) >= 70
            ? 1900 + int.parse(rawYear)
            : 2000 + int.parse(rawYear));
    final month = first > 12 ? second : first;
    final day = first > 12 ? first : second;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    final date = DateTime.utc(year, month, day);
    return date.year == year && date.month == month && date.day == day
        ? date
        : null;
  }

  String _normalizeColumn(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }
}
