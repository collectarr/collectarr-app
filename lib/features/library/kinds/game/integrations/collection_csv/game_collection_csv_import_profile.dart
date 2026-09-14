import 'package:collectarr_app/core/models/catalog_media_kind.dart';

/// Game-owned aliases for the collection CSV boundary.
final class GameCollectionCsvImportProfile {
  const GameCollectionCsvImportProfile();

  /// Canonical schema-v1 header owned by this kind's CSV integration.
  ///
  /// The same wire positions may be duplicated between kinds intentionally;
  /// Collection never interprets these labels as a shared domain schema.
  static const v1Header = <String>[
    'item_id',
    'kind',
    'title',
    'item_number',
    'variant',
    'edition_title',
    'physical_format',
    'physical_format_label',
    'publisher',
    'release_date',
    'barcode',
    'status',
    'condition',
    'grade',
    'purchase_date',
    'price_paid_cents',
    'currency',
    'notes',
    'quantity',
    'location_id',
    'index_number',
    'cover_price_cents',
    'raw_or_slabbed',
    'grading_company',
    'grader_notes',
    'signed_by',
    'label_type',
    'certification_number',
    'key_comic',
    'key_reason',
    'rating',
    'read_status',
    'started_at',
    'finished_at',
    'tags',
    'sold_at',
    'sell_price_cents',
    'sold_to',
  ];
  static const clzFriendlyHeader = [
    'Collectarr Item ID',
    'Media Type',
    'Series',
    'Version',
    'Platform / Edition',
    'Edition Title',
    'Physical Format',
    'Physical Format Label',
    'Publisher / Studio',
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
    'item_number': ['Version', 'Version Number', 'Build'],
    'variant': [
      'Platform / Edition',
      'Platform',
      'Edition / Variant',
      'Variant',
    ],
    'edition_title': ['Edition Title', 'Edition Name', 'Release Title'],
    'physical_format': [
      'Physical Format',
      'Format ID',
      'Media Format',
      'Disc Format',
    ],
    'physical_format_label': [
      'Physical Format Label',
      'Format',
      'Format Label',
    ],
    'publisher': [
      'Publisher / Studio',
      'Publisher',
      'Developer',
      'Developer / Publisher',
    ],
    'release_date': ['Release Date', 'Published Date'],
    'barcode': [
      'UPC / Barcode',
      'Barcode',
      'UPC',
      'Product Code',
    ],
    'grade': ['Grade', 'Grade and Value'],
  };

  List<String>? importCatalogCells({
    required List<String> header,
    required List<String> values,
  }) {
    final index = _headerIndex(header);
    if (!_isGameRow(index, header, values)) return null;
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
    if (!_isGameRow(index, header, values)) return null;
    return [
      _value(index, values, 'grade'),
      ...List<String>.filled(8, ''),
    ];
  }

  bool _isGameRow(
    Map<String, int> index,
    List<String> header,
    List<String> values,
  ) {
    final kind = _optionalValue(index, values, 'kind')?.toLowerCase();
    if (kind != null) {
      return catalogMediaKindFromValue(kind) == CatalogMediaKind.game;
    }
    final normalizedHeader = header.map(_normalizeColumn).toSet();
    return normalizedHeader.contains('platform_edition') &&
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
