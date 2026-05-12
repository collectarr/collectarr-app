import 'package:csv/csv.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';

class CollectionCsvRow {
  const CollectionCsvRow({
    required this.itemId,
    required this.status,
    this.condition,
    this.grade,
    this.purchaseDate,
    this.pricePaidCents,
    this.currency,
    this.notes,
    this.quantity,
    this.storageBox,
    this.indexNumber,
    this.coverPriceCents,
    this.rawOrSlabbed,
    this.gradingCompany,
    this.graderNotes,
    this.signedBy,
    this.keyComic = false,
    this.keyReason,
    this.rating,
    this.readStatus,
    this.tags,
  });

  final String itemId;
  final String status;
  final String? condition;
  final String? grade;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? notes;
  final int? quantity;
  final String? storageBox;
  final int? indexNumber;
  final int? coverPriceCents;
  final String? rawOrSlabbed;
  final String? gradingCompany;
  final String? graderNotes;
  final String? signedBy;
  final bool keyComic;
  final String? keyReason;
  final int? rating;
  final String? readStatus;
  final String? tags;

  bool get isOwned => status == 'owned' || status == 'both';
  bool get isWishlisted => status == 'wishlist' || status == 'both';
}

class CollectionCsv {
  static const header = [
    'item_id',
    'title',
    'item_number',
    'status',
    'condition',
    'grade',
    'purchase_date',
    'price_paid_cents',
    'currency',
    'notes',
    'quantity',
    'storage_box',
    'index_number',
    'cover_price_cents',
    'raw_or_slabbed',
    'grading_company',
    'grader_notes',
    'signed_by',
    'key_comic',
    'key_reason',
    'rating',
    'read_status',
    'tags',
  ];

  String exportShelf(List<ShelfEntry> entries) {
    final rows = [
      header,
      for (final entry in entries)
        [
          entry.itemId,
          entry.catalogItem?.title ?? '',
          entry.catalogItem?.itemNumber ?? '',
          _status(entry),
          entry.ownedItem?.condition ?? '',
          entry.ownedItem?.grade ?? '',
          entry.ownedItem?.purchaseDate?.toUtc().toIso8601String() ?? '',
          entry.ownedItem?.pricePaidCents?.toString() ?? '',
          entry.ownedItem?.currency ?? entry.wishlistItem?.currency ?? '',
          entry.ownedItem?.personalNotes ?? entry.wishlistItem?.notes ?? '',
          entry.ownedItem?.quantity.toString() ?? '',
          entry.ownedItem?.storageBox ?? '',
          entry.ownedItem?.indexNumber?.toString() ?? '',
          entry.ownedItem?.coverPriceCents?.toString() ?? '',
          entry.ownedItem?.rawOrSlabbed ?? '',
          entry.ownedItem?.gradingCompany ?? '',
          entry.ownedItem?.graderNotes ?? '',
          entry.ownedItem?.signedBy ?? '',
          entry.ownedItem == null ? '' : entry.ownedItem!.keyComic.toString(),
          entry.ownedItem?.keyReason ?? '',
          entry.ownedItem?.rating?.toString() ?? '',
          entry.ownedItem?.readStatus ?? '',
          entry.ownedItem?.tags ?? '',
        ],
    ];
    return const CsvEncoder(lineDelimiter: '\n').convert(rows);
  }

  List<CollectionCsvRow> parse(String csv) {
    final rows = const CsvDecoder(
      fieldDelimiter: ',',
      dynamicTyping: false,
    ).convert(csv);
    if (rows.length <= 1) {
      return const [];
    }
    final parsedHeader = rows.first.map(_cellValue).toList(growable: false);
    if (parsedHeader.isNotEmpty) {
      parsedHeader[0] = parsedHeader[0].replaceFirst('\ufeff', '');
    }
    final index = {
      for (var i = 0; i < parsedHeader.length; i++) parsedHeader[i]: i,
    };
    return [
      for (final row in rows.skip(1))
        _rowFromValues(index, row.map(_cellValue).toList(growable: false)),
    ].where((row) => row.itemId.isNotEmpty).toList(growable: false);
  }

  String _status(ShelfEntry entry) {
    if (entry.isOwned && entry.isWishlisted) {
      return 'both';
    }
    if (entry.isOwned) {
      return 'owned';
    }
    return 'wishlist';
  }

  CollectionCsvRow _rowFromValues(Map<String, int> index, List<String> values) {
    return CollectionCsvRow(
      itemId: _value(index, values, 'item_id'),
      status: _value(index, values, 'status').toLowerCase(),
      condition: _optionalValue(index, values, 'condition'),
      grade: _optionalValue(index, values, 'grade'),
      purchaseDate:
          DateTime.tryParse(_value(index, values, 'purchase_date'))?.toUtc(),
      pricePaidCents: int.tryParse(_value(index, values, 'price_paid_cents')),
      currency: _optionalValue(index, values, 'currency'),
      notes: _optionalValue(index, values, 'notes'),
      quantity: int.tryParse(_value(index, values, 'quantity')),
      storageBox: _optionalValue(index, values, 'storage_box'),
      indexNumber: int.tryParse(_value(index, values, 'index_number')),
      coverPriceCents: int.tryParse(_value(index, values, 'cover_price_cents')),
      rawOrSlabbed: _optionalValue(index, values, 'raw_or_slabbed'),
      gradingCompany: _optionalValue(index, values, 'grading_company'),
      graderNotes: _optionalValue(index, values, 'grader_notes'),
      signedBy: _optionalValue(index, values, 'signed_by'),
      keyComic: _boolValue(index, values, 'key_comic'),
      keyReason: _optionalValue(index, values, 'key_reason'),
      rating: int.tryParse(_value(index, values, 'rating')),
      readStatus: _optionalValue(index, values, 'read_status'),
      tags: _optionalValue(index, values, 'tags'),
    );
  }

  String _value(Map<String, int> index, List<String> values, String column) {
    final columnIndex = index[column];
    if (columnIndex == null || columnIndex >= values.length) {
      return '';
    }
    return values[columnIndex];
  }

  String? _optionalValue(
      Map<String, int> index, List<String> values, String column) {
    final value = _value(index, values, column).trim();
    return value.isEmpty ? null : value;
  }

  bool _boolValue(Map<String, int> index, List<String> values, String column) {
    return switch (_value(index, values, column).trim().toLowerCase()) {
      '1' || 'true' || 'yes' || 'y' => true,
      _ => false,
    };
  }

  String _cellValue(dynamic value) => value?.toString() ?? '';
}
