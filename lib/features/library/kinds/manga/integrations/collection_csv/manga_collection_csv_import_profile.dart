import 'package:collectarr_app/core/models/catalog_media_kind.dart';

/// Manga-owned aliases for the legacy collection CSV boundary.
final class MangaCollectionCsvImportProfile {
  const MangaCollectionCsvImportProfile();

  static const clzFriendlyHeader = [
    'Collectarr Item ID',
    'Media Type',
    'Series',
    'Chapter / Vol.',
    'Edition / Variant / Format',
    'Edition Title',
    'Physical Format',
    'Physical Format Label',
    'Publisher / Studio / Creator',
    'Release Date',
    'Barcode / UPC / ISBN',
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
      'Chapter / Vol.',
      'Chapter',
      'Volume',
      'Chapter / Volume',
    ],
    'variant': [
      'Edition / Variant / Format',
      'Edition / Variant',
      'Variant',
      'Edition Format',
    ],
    'edition_title': ['Edition Title', 'Edition Name', 'Release Title'],
    'physical_format': [
      'Physical Format',
      'Format ID',
      'Media Format',
    ],
    'physical_format_label': [
      'Physical Format Label',
      'Format',
      'Format Label',
    ],
    'publisher': [
      'Publisher / Studio / Creator',
      'Publisher',
      'Original Publisher',
      'Localized Publisher',
    ],
    'release_date': [
      'Release Date',
      'Localized Release Date',
      'Publication Date',
    ],
    'barcode': [
      'Barcode / UPC / ISBN',
      'ISBN',
      'Barcode',
      'UPC',
      'ISBN / Barcode',
    ],
  };

  List<String>? importCatalogCells({
    required List<String> header,
    required List<String> values,
  }) {
    final index = _headerIndex(header);
    if (!_isMangaRow(index, header, values)) return null;
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
    if (!_isMangaRow(index, header, values)) return null;
    return List<String>.filled(9, '');
  }

  bool _isMangaRow(
    Map<String, int> index,
    List<String> header,
    List<String> values,
  ) {
    final kind = _optionalValue(index, values, 'kind')?.toLowerCase();
    if (kind != null) {
      return catalogMediaKindFromValue(kind) == CatalogMediaKind.manga;
    }

    // Kind-less exports need both Manga's chapter/volume and combined
    // barcode labels to avoid claiming another publishing kind's row.
    final normalizedHeader = header.map(_normalizeColumn).toSet();
    return normalizedHeader.contains('chapter_vol') &&
        normalizedHeader.contains('barcode_upc_isbn');
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
