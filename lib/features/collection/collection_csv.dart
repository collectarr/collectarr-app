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
  });

  final String itemId;
  final String status;
  final String? condition;
  final String? grade;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? notes;

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
        ],
    ];
    return rows.map((row) => row.map(_escape).join(',')).join('\n');
  }

  List<CollectionCsvRow> parse(String csv) {
    final lines = csv
        .split(RegExp(r'\r?\n'))
        .where((line) => line.trim().isNotEmpty)
        .toList(growable: false);
    if (lines.length <= 1) {
      return const [];
    }
    final parsedHeader = _parseLine(lines.first);
    final index = {
      for (var i = 0; i < parsedHeader.length; i++) parsedHeader[i]: i,
    };
    return [
      for (final line in lines.skip(1))
        CollectionCsvRow(
          itemId: _value(index, line, 'item_id'),
          status: _value(index, line, 'status').toLowerCase(),
          condition: _optionalValue(index, line, 'condition'),
          grade: _optionalValue(index, line, 'grade'),
          purchaseDate:
              DateTime.tryParse(_value(index, line, 'purchase_date'))?.toUtc(),
          pricePaidCents: int.tryParse(_value(index, line, 'price_paid_cents')),
          currency: _optionalValue(index, line, 'currency'),
          notes: _optionalValue(index, line, 'notes'),
        ),
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

  String _value(Map<String, int> index, String line, String column) {
    final values = _parseLine(line);
    final columnIndex = index[column];
    if (columnIndex == null || columnIndex >= values.length) {
      return '';
    }
    return values[columnIndex];
  }

  String? _optionalValue(Map<String, int> index, String line, String column) {
    final value = _value(index, line, column).trim();
    return value.isEmpty ? null : value;
  }

  String _escape(String value) {
    if (!value.contains(RegExp('[",\n\r]'))) {
      return value;
    }
    return '"${value.replaceAll('"', '""')}"';
  }

  List<String> _parseLine(String line) {
    final values = <String>[];
    final buffer = StringBuffer();
    var quoted = false;
    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        if (quoted && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          quoted = !quoted;
        }
      } else if (char == ',' && !quoted) {
        values.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    values.add(buffer.toString());
    return values;
  }
}
