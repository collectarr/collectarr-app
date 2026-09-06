import 'package:collectarr_app/core/models/catalog_media_kind.dart';

/// TV-owned aliases for the legacy collection CSV boundary.
final class TvCollectionCsvImportProfile {
  const TvCollectionCsvImportProfile();

  static const clzFriendlyHeader = [
    'Collectarr Item ID',
    'Media Type',
    'Series',
    'Season / Episode',
    'Format / Edition',
    'Edition Title',
    'Physical Format',
    'Physical Format Label',
    'Network',
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
    'title': ['Series', 'Title', 'Full Title'],
    'item_number': [
      'Season / Episode',
      'Season/Episode',
      'Edition no.',
      'Episode Number',
      'Release Number',
    ],
    'variant': [
      'Format / Edition',
      'Format',
      'Edition / Variant',
      'Variant',
    ],
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
      'Format Label',
      'Video Format Label',
    ],
    'publisher': [
      'Network',
      'Studio',
      'Publisher',
      'Streaming Service',
      'Distributor',
    ],
    'release_date': [
      'Release Date',
      'First Air Date',
      'Air Date',
      'Premiere Date',
    ],
    'barcode': [
      'UPC / Barcode',
      'Barcode',
      'UPC',
      'Barcode / UPC',
    ],
  };

  List<String>? importCatalogCells({
    required List<String> header,
    required List<String> values,
  }) {
    final index = _headerIndex(header);
    if (!_isTvRow(index, header, values)) return null;
    return [
      _value(index, values, 'item_id'),
      _value(index, values, 'kind'),
      _value(index, values, 'title'),
      _value(index, values, 'item_number'),
      _value(index, values, 'variant'),
      _value(index, values, 'edition_title'),
      _value(index, values, 'physical_format'),
      _value(index, values, 'physical_format_label'),
      _value(index, values, 'publisher'),
      _value(index, values, 'release_date'),
      _value(index, values, 'barcode'),
    ];
  }

  List<String>? importOwnedCells({
    required List<String> header,
    required List<String> values,
  }) {
    final index = _headerIndex(header);
    if (!_isTvRow(index, header, values)) return null;
    return List<String>.filled(9, '');
  }

  bool _isTvRow(
    Map<String, int> index,
    List<String> header,
    List<String> values,
  ) {
    final kind = _optionalValue(index, values, 'kind')?.toLowerCase();
    if (kind != null) {
      return catalogMediaKindFromValue(kind) == CatalogMediaKind.tv;
    }
    final normalizedHeader = header.map(_normalizeColumn).toSet();
    return normalizedHeader.contains('format_edition') &&
        normalizedHeader.contains('network') &&
        normalizedHeader.contains('upc_barcode');
  }

  Map<String, int> _headerIndex(List<String> header) {
    final index = <String, int>{};
    for (var i = 0; i < header.length; i++) {
      index[_canonicalColumn(header[i])] = i;
    }
    return index;
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

  String _normalizeColumn(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }
}
