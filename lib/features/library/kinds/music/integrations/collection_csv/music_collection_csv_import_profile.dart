import 'package:collectarr_app/features/collection/csv/collection_csv_columns.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';

/// Music-entry aliases for the collection CSV boundary.
final class MusicCollectionCsvImportProfile {
  const MusicCollectionCsvImportProfile();

  /// Canonical schema-v1 header entry by this kind's CSV integration.
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
    'Release',
    'Catalog no.',
    'Format / Edition',
    'Edition Title',
    'Physical Format',
    'Physical Format Label',
    'Label',
    'Release Date',
    'Barcode / Catalog no.',
    'Collection Status',
    'Condition',
    'Grade',
    'Purchase Date',
    'Purchase Price',
    'Currency',
    'Cover Price',
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
    'title': ['Release', 'Title', 'Album', 'Full Title'],
    'item_number': [
      'Catalog no.',
      'Catalog Number',
      'Disc / Volume',
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
      'Disc Format',
    ],
    'physical_format_label': [
      'Physical Format Label',
      'Format Label',
      'Disc Format Label',
    ],
    'publisher': [
      'Label',
      'Record Label',
      'Publisher',
      'Studio',
    ],
    'release_date': [
      'Release Date',
      'Original Release Date',
      'Publication Date',
    ],
    'barcode': [
      'Barcode / Catalog no.',
      'Barcode',
      'EAN',
      'UPC',
    ],
    'grade': ['Grade', 'Grade and Value'],
  };

  List<String>? importCatalogCells({
    required List<String> header,
    required List<String> values,
  }) {
    final index = collectionCsvHeaderIndex(header, columnAliases);
    if (!_isMusicRow(index, header, values)) return null;
    return [
      collectionCsvValue(index, values, 'item_id'),
      collectionCsvValue(index, values, 'kind'),
      collectionCsvValue(index, values, 'title'),
      collectionCsvValue(index, values, 'item_number'),
      collectionCsvValue(index, values, 'variant'),
      collectionCsvValue(index, values, 'edition_title'),
      collectionCsvValue(index, values, 'physical_format'),
      collectionCsvValue(index, values, 'physical_format_label'),
      collectionCsvValue(index, values, 'publisher'),
      collectionCsvValue(index, values, 'release_date'),
      collectionCsvValue(index, values, 'barcode'),
    ];
  }

  List<String>? importEntryCells({
    required List<String> header,
    required List<String> values,
  }) {
    final index = collectionCsvHeaderIndex(header, columnAliases);
    if (!_isMusicRow(index, header, values)) return null;
    return [
      collectionCsvValue(index, values, 'grade'),
      ...List<String>.filled(8, ''),
    ];
  }

  bool _isMusicRow(
    Map<String, int> index,
    List<String> header,
    List<String> values,
  ) {
    final kind =
        collectionCsvOptionalValue(index, values, 'kind')?.toLowerCase();
    if (kind != null) {
      return catalogMediaKindFromValue(kind) == CatalogMediaKind.music;
    }
    final normalizedHeader = header.map(normalizeCollectionCsvColumn).toSet();
    return normalizedHeader.contains('catalog_no') &&
        normalizedHeader.contains('label') &&
        normalizedHeader.contains('barcode_catalog_no');
  }
}
