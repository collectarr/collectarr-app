import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/collection/csv/csv_mechanics.dart';
import 'package:collectarr_app/features/library/config/library_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';

/// Schema-v1 collection import mechanics.
///
/// Kind projections interpret positional semantic cells after this boundary.
final class CollectionCsvImporter {
  List<CollectionImportRow> parse(String csv) {
    final rows = const CsvReader(
      fieldDelimiter: ',',
      dynamicTyping: false,
    ).read(csv);
    if (rows.length <= 1) {
      return const [];
    }
    final parsedHeader = rows.first.toList(growable: false);
    final index = _headerIndex(parsedHeader);
    final cfColumns = _customFieldColumns(parsedHeader);
    return [
      for (final row in rows.skip(1))
        _rowFromValues(
          index,
          row,
          cfColumns: cfColumns,
          kindImportCells: _kindImportCells(parsedHeader, row),
        ),
    ].where(_isMeaningfulRow).toList(growable: false);
  }

  CollectionImportRow _rowFromValues(
    Map<String, int> index,
    List<String> values, {
    Map<String, int> cfColumns = const {},
    ({List<String> catalog, List<String> owned})? kindImportCells,
  }) {
    final cfValues = <String, String?>{};
    for (final entry in cfColumns.entries) {
      final v = entry.value < values.length ? values[entry.value].trim() : '';
      if (v.isNotEmpty) {
        cfValues[entry.key] = v;
      }
    }
    final catalogCells =
        kindImportCells?.catalog ?? _genericCatalogCells(index, values);
    final ownedCells =
        kindImportCells?.owned ?? _genericOwnedCells(index, values);
    if (catalogCells.length != libraryCollectionCsvCatalogCellCount) {
      throw StateError(
        'Collection CSV import catalog projection returned '
        '${catalogCells.length} cells; expected '
        '$libraryCollectionCsvCatalogCellCount.',
      );
    }
    if (ownedCells.isEmpty) {
      throw StateError(
        'Collection CSV import owned projection returned no cells.',
      );
    }
    return CollectionImportRow(
      itemId: catalogCells[0],
      status: _normalizedStatus(_value(index, values, 'status')),
      mediaKind: catalogMediaKindFromValue(catalogCells[1]),
      title: _optionalCell(catalogCells[2]),
      personal: CollectionImportPersonalValues(
        condition: _optionalValue(index, values, 'condition'),
        purchaseDate: _parseDate(_value(index, values, 'purchase_date')),
        pricePaidCents: _moneyCents(_value(index, values, 'price_paid_cents')),
        currency: _optionalValue(index, values, 'currency'),
        notes: _optionalValue(index, values, 'notes'),
        quantity: int.tryParse(_value(index, values, 'quantity')),
        locationId: _optionalValue(index, values, 'location_id'),
        indexNumber: int.tryParse(_value(index, values, 'index_number')),
        tags: _optionalValue(index, values, 'tags'),
        soldAt: _parseDate(_value(index, values, 'sold_at')),
        sellPriceCents: _moneyCents(_value(index, values, 'sell_price_cents')),
        soldTo: _optionalValue(index, values, 'sold_to'),
      ),
      tracking: CollectionImportTrackingValues(
        rating: int.tryParse(_value(index, values, 'rating')),
        status: _optionalValue(index, values, 'read_status'),
        startedAt: _parseDate(_value(index, values, 'started_at')),
        finishedAt: _parseDate(_value(index, values, 'finished_at')),
      ),
      kindCatalogCells: catalogCells,
      kindOwnedCells: ownedCells,
      customFieldValues: cfValues,
    );
  }

  ({List<String> catalog, List<String> owned})? _kindImportCells(
    List<String> header,
    List<String> values,
  ) {
    for (final projection in libraryCollectionCsvProjections) {
      final catalog = projection.importCatalogCells(
        header: header,
        values: values,
      );
      if (catalog == null) continue;
      final owned = projection.importOwnedCells(
            header: header,
            values: values,
          ) ??
          const <String>[];
      return (catalog: catalog, owned: owned);
    }
    return null;
  }

  List<String> _genericCatalogCells(
    Map<String, int> index,
    List<String> values,
  ) {
    return [
      _value(index, values, 'item_id'),
      _value(index, values, 'kind'),
      _value(index, values, 'title'),
      ...List<String>.filled(
        libraryCollectionCsvCatalogCellCount - 3,
        '',
      ),
    ];
  }

  List<String> _genericOwnedCells(
    Map<String, int> index,
    List<String> values,
  ) {
    return List<String>.filled(libraryCollectionCsvOwnedCellCount, '');
  }

  String? _optionalCell(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Extracts custom field column names and their indices from the header.
  /// Columns with `cf_` prefix are treated as custom field columns.
  Map<String, int> _customFieldColumns(List<String> header) {
    final columns = <String, int>{};
    for (var i = 0; i < header.length; i++) {
      final normalized = header[i].trim();
      if (normalized.toLowerCase().startsWith('cf_')) {
        columns[normalized.substring(3)] = i;
      }
    }
    return columns;
  }

  bool _isMeaningfulRow(CollectionImportRow row) {
    return row.itemId.trim().isNotEmpty ||
        !row.mediaKind.isUnknown ||
        row.status.trim().isNotEmpty ||
        (row.title?.trim().isNotEmpty ?? false) ||
        (row.personal.locationId?.trim().isNotEmpty ?? false) ||
        row.kindCatalogCells.any((cell) => cell.trim().isNotEmpty) ||
        row.kindOwnedCells.any((cell) => cell.trim().isNotEmpty);
  }

  Map<String, int> _headerIndex(List<String> header) {
    final index = <String, int>{};
    for (var i = 0; i < header.length; i++) {
      final canonical = _canonicalColumn(header[i]);
      index[canonical] = i;
    }
    return index;
  }

  String _value(Map<String, int> index, List<String> values, String column) {
    final columnIndex = index[_normalizeColumn(column)];
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

  String _normalizedStatus(String value) {
    final normalized = value.trim().toLowerCase();
    return switch (normalized) {
      'in collection + wishlist' || 'owned + wishlist' => 'both',
      'in collection' || 'collection' || 'owned' => 'owned',
      'wanted' || 'wish list' || 'wishlist' => 'wishlist',
      'both' => 'both',
      _ => normalized,
    };
  }

  int? _moneyCents(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final asInt = int.tryParse(trimmed);
    if (asInt != null) {
      return asInt;
    }
    final cleaned = _normalizeMoney(trimmed);
    final parsed = double.tryParse(cleaned);
    return parsed == null ? null : (parsed * 100).round();
  }

  String _normalizeMoney(String value) {
    final isNegative = value.contains('-') ||
        (value.trim().startsWith('(') && value.trim().endsWith(')'));
    final numeric = value.replaceAll(RegExp(r'[^0-9,.]'), '');
    if (numeric.isEmpty) {
      return '';
    }
    final decimalSeparatorIndex = _decimalSeparatorIndex(numeric);
    final buffer = StringBuffer();
    for (var i = 0; i < numeric.length; i++) {
      final char = numeric[i];
      if (char == '.' || char == ',') {
        if (decimalSeparatorIndex != null && i == decimalSeparatorIndex) {
          buffer.write('.');
        }
      } else {
        buffer.write(char);
      }
    }
    final normalized = buffer.toString();
    return isNegative ? '-$normalized' : normalized;
  }

  int? _decimalSeparatorIndex(String value) {
    final lastComma = value.lastIndexOf(',');
    final lastDot = value.lastIndexOf('.');
    final separatorIndex = lastComma > lastDot ? lastComma : lastDot;
    if (separatorIndex < 0) {
      return null;
    }
    final separator = value[separatorIndex];
    final separatorCount =
        RegExp(RegExp.escape(separator)).allMatches(value).length;
    final digitsAfter = value.length - separatorIndex - 1;
    if (separatorCount > 1) {
      return null;
    }
    if (lastComma >= 0 && lastDot >= 0) {
      return separatorIndex;
    }
    if (digitsAfter == 1 || digitsAfter == 2) {
      return separatorIndex;
    }
    return null;
  }

  DateTime? _parseDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) {
      return DateTime.utc(parsed.year, parsed.month, parsed.day);
    }
    final yearFirst =
        RegExp(r'^(\d{4})[/-](\d{1,2})[/-](\d{1,2})$').firstMatch(trimmed);
    if (yearFirst != null) {
      return _dateFromParts(
        yearFirst.group(1)!,
        yearFirst.group(2)!,
        yearFirst.group(3)!,
      );
    }
    final shortDate =
        RegExp(r'^(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})$').firstMatch(trimmed);
    if (shortDate == null) {
      return null;
    }
    final first = int.parse(shortDate.group(1)!);
    final second = int.parse(shortDate.group(2)!);
    final year = _fourDigitYear(shortDate.group(3)!);
    final month = first > 12 ? second : first;
    final day = first > 12 ? first : second;
    return _validDate(year, month, day);
  }

  DateTime? _dateFromParts(String year, String month, String day) {
    return _validDate(
      int.parse(year),
      int.parse(month),
      int.parse(day),
    );
  }

  int _fourDigitYear(String value) {
    final parsed = int.parse(value);
    if (value.length == 4) {
      return parsed;
    }
    return parsed >= 70 ? 1900 + parsed : 2000 + parsed;
  }

  DateTime? _validDate(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1 || day > 31) {
      return null;
    }
    final value = DateTime.utc(year, month, day);
    if (value.year != year || value.month != month || value.day != day) {
      return null;
    }
    return value;
  }

  String _normalizeColumn(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  String _canonicalColumn(String value) {
    final normalized = _normalizeColumn(value);
    if (_columnAliases.containsKey(normalized)) {
      return normalized;
    }
    for (final entry in _columnAliases.entries) {
      for (final alias in entry.value) {
        if (_normalizeColumn(alias) == normalized) {
          return entry.key;
        }
      }
    }
    for (final projection in libraryCollectionCsvProjections) {
      if (projection.columnAliases.containsKey(normalized)) {
        return normalized;
      }
      for (final entry in projection.columnAliases.entries) {
        for (final alias in entry.value) {
          if (_normalizeColumn(alias) == normalized) {
            return entry.key;
          }
        }
      }
    }
    return normalized;
  }

  static const Map<String, List<String>> _columnAliases = {
    'item_id': [
      'Collectarr Item ID',
    ],
    'kind': ['Media Type', 'Kind', 'Type', 'Library', 'Media Kind'],
    'title': ['Series', 'Show', 'Release', 'Full Title'],
    'status': ['Collection Status', 'Status'],
    'condition': ['Condition'],
    'grade': ['Grade', 'Grade and Value'],
    'purchase_date': ['Purchase Date', 'Bought Date'],
    'price_paid_cents': ['Purchase Price', 'Price Paid', 'Value'],
    'currency': ['Currency'],
    'notes': ['Notes', 'Personal Notes'],
    'quantity': ['Quantity', 'Qty'],
    'location_id': ['Location ID', 'Location Id'],
    'index_number': ['Index', 'Index Number'],
    'rating': ['Rating'],
    'read_status': ['Read It', 'Read Status', 'Read'],
    'tags': ['Tags'],
  };
}
