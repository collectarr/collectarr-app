import 'package:collectarr_app/features/collection/csv/collection_csv_columns.dart';
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
    this.grade,
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
  final String? grade;

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
        formatCollectionCsvDate(releaseDate),
        barcode ?? '',
      ];

  List<String> get entryCells => [grade ?? '', ...List<String>.filled(8, '')];
}

/// Movie's CLZ labels and aliases for collection CSV import.
final class MovieCollectionCsvImportProfile {
  const MovieCollectionCsvImportProfile();

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
    'grade': ['Grade', 'Grade and Value'],
  };

  MovieCollectionCsvImportRow? parseRow({
    required List<String> header,
    required List<String> values,
  }) {
    final index = collectionCsvHeaderIndex(header, columnAliases);
    if (!_isMovieRow(index, header, values)) return null;

    return MovieCollectionCsvImportRow(
      itemId: collectionCsvValue(index, values, 'item_id'),
      kind: collectionCsvOptionalValue(index, values, 'kind'),
      title: collectionCsvOptionalValue(index, values, 'title'),
      itemNumber: collectionCsvOptionalValue(index, values, 'item_number'),
      variant: collectionCsvOptionalValue(index, values, 'variant'),
      editionTitle: collectionCsvOptionalValue(index, values, 'edition_title'),
      physicalFormat:
          collectionCsvOptionalValue(index, values, 'physical_format'),
      physicalFormatLabel:
          collectionCsvOptionalValue(index, values, 'physical_format_label'),
      studio: collectionCsvOptionalValue(index, values, 'publisher'),
      releaseDate:
          _parseDate(collectionCsvValue(index, values, 'release_date')),
      barcode: collectionCsvOptionalValue(index, values, 'barcode'),
      grade: collectionCsvOptionalValue(index, values, 'grade'),
    );
  }

  bool _isMovieRow(
    Map<String, int> index,
    List<String> header,
    List<String> values,
  ) {
    final kind =
        collectionCsvOptionalValue(index, values, 'kind')?.toLowerCase();
    if (kind != null) {
      return catalogMediaKindFromValue(kind) == CatalogMediaKind.movie;
    }

    // A kind-less CLZ export is accepted only when it carries Movie's
    // unambiguous Studio + UPC labels. Other rows are handled by another
    // kind-entry profile.
    final normalizedHeader = header.map(normalizeCollectionCsvColumn).toSet();
    return normalizedHeader.contains('studio') &&
        normalizedHeader.contains('upc_barcode');
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
}
