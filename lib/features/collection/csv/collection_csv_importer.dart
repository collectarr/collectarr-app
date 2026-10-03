import 'dart:convert';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/structural_ref_validation.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/collection/csv/csv_mechanics.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_kind_profile.dart';

/// Schema-v1 collection import mechanics.
///
/// Kind projections interpret positional semantic cells after this boundary.
final class CollectionCsvImporter {
  CollectionCsvImporter({required Iterable<CollectionCsvKindProfile> profiles})
      : _profiles = List.unmodifiable(profiles);

  final List<CollectionCsvKindProfile> _profiles;

  List<CollectionImportRow> parse(String csv) {
    final rows = const CsvReader(
      fieldDelimiter: ',',
      dynamicTyping: false,
    ).read(csv);
    if (rows.length <= 1) {
      return const [];
    }
    final parsedHeader = rows.first.toList(growable: false);
    if (parsedHeader.any((column) => _normalizeColumn(column) == 'catalog_ref')) {
      throw const FormatException(
        'This CSV uses the removed catalog_ref entry format. Export it again '
        'with the current Collectarr schema-v1 format.',
      );
    }
    final index = _headerIndex(parsedHeader);
    final cfColumns = _customFieldColumns(parsedHeader);
    final structuralOnly = _isStructuralHeader(parsedHeader);
    return [
      for (final row in rows.skip(1))
        if (structuralOnly)
          _rowFromValues(
            index,
            row,
            cfColumns: cfColumns,
            structuralOnly: true,
          )
        else
          _rowFromKindOrStructuralValues(
            index,
            row,
            header: parsedHeader,
            cfColumns: cfColumns,
          ),
    ].where(_isMeaningfulRow).toList(growable: false);
  }

  CollectionImportRow _rowFromKindOrStructuralValues(
    Map<String, int> index,
    List<String> values, {
    required List<String> header,
    required Map<String, int> cfColumns,
  }) {
    final kindImportCells = _kindImportCells(header, values);
    return _rowFromValues(
      index,
      values,
      cfColumns: cfColumns,
      structuralOnly: kindImportCells == null,
      kindImportCells: kindImportCells,
    );
  }

  CollectionImportRow _rowFromValues(
    Map<String, int> index,
    List<String> values, {
    Map<String, int> cfColumns = const {},
    bool structuralOnly = false,
    ({List<String> catalog, List<String> entry})? kindImportCells,
  }) {
    final cfValues = <String, String?>{};
    for (final entry in cfColumns.entries) {
      final v = entry.value < values.length ? values[entry.value].trim() : '';
      if (v.isNotEmpty) {
        cfValues[entry.key] = v;
      }
    }
    final catalogItemRef =
        _parseCatalogItemRef(_value(index, values, 'catalog_item_ref'));
    final completeEntry = _parseCompleteEntry(
      _value(index, values, 'library_entry_json'),
    );
    final catalogCells = kindImportCells?.catalog ??
        _genericCatalogCells(index, values, catalogItemRef);
    final entryCells = kindImportCells?.entry ?? const <String>[];
    final mediaKind = completeEntry?.kind ??
        (catalogItemRef?.kind ?? catalogMediaKindFromApiValue(catalogCells[1]));
    final profile = _profileForKind(mediaKind);
    if (catalogCells.length != collectionCsvV1CatalogCellCount) {
      throw StateError(
        'Collection CSV import catalog projection returned '
        '${catalogCells.length} cells; expected '
        '$collectionCsvV1CatalogCellCount.',
      );
    }
    if (entryCells.isEmpty && !structuralOnly) {
      throw StateError(
        'Collection CSV import entry projection returned no cells.',
      );
    }
    return CollectionImportRow(
      // The complete envelope identifies the local entry. Its source catalog
      // reference is provenance only and must not be used as the entry ID.
      itemId: completeEntry?.id ?? catalogItemRef?.id ?? catalogCells[0],
      status: _normalizedStatus(_value(index, values, 'status')),
      catalogItemRef: catalogItemRef,
      mediaKind: mediaKind,
      title: _optionalCell(catalogCells[2]),
      kindDisplayTitle: profile?.importDisplayTitle(catalogCells),
      kindDisplaySubtitle: profile?.importDisplaySubtitle(catalogCells),
      kindIdentifier: profile?.importBarcode(catalogCells),
      personal: CollectionImportPersonalValues(
        condition: _optionalValue(index, values, 'condition'),
        purchaseDate: _parseDate(_value(index, values, 'purchase_date')),
        pricePaidCents: _moneyCents(_value(index, values, 'price_paid_cents')),
        currency: _optionalValue(index, values, 'currency'),
        notes: _optionalValue(index, values, 'notes'),
        locationId: _optionalValue(index, values, 'location_id'),
        indexNumber: int.tryParse(_value(index, values, 'index_number')),
        tags: _optionalValue(index, values, 'tags'),
        soldAt: _parseDate(_value(index, values, 'sold_at')),
        sellPriceCents: _moneyCents(_value(index, values, 'sell_price_cents')),
        soldTo: _optionalValue(index, values, 'sold_to'),
        quantity: int.tryParse(_value(index, values, 'quantity').trim()),
      ),
      tracking: CollectionImportTrackingValues(
        rating: int.tryParse(_value(index, values, 'rating')),
        status: _optionalValue(index, values, 'read_status'),
        startedAt: _parseDate(_value(index, values, 'started_at')),
        finishedAt: _parseDate(_value(index, values, 'finished_at')),
      ),
      kindCatalogCells: catalogCells,
      kindEntryCells: entryCells,
      customFieldValues: cfValues,
      fullEntryPayload: completeEntry?.toJson(),
    );
  }

  LibraryEntryRecord? _parseCompleteEntry(String value) {
    if (value.trim().isEmpty) return null;
    final decoded = jsonDecode(value);
    if (decoded is! Map) {
      throw const FormatException('library_entry_json must be a JSON object.');
    }
    final record = LibraryEntryRecord.fromJson(
      Map<String, dynamic>.from(decoded),
    );
    requireKnownLibraryEntryRef(
      LibraryEntryRef(kind: record.kind, id: LibraryEntryId(record.id)),
      'library_entry_json.id',
    );
    return record;
  }

  ({List<String> catalog, List<String> entry})? _kindImportCells(
    List<String> header,
    List<String> values,
  ) {
    for (final projection in _profiles) {
      final catalog = projection.importCatalogCells(
        header: header,
        values: values,
      );
      if (catalog == null) continue;
      final entry = projection.importEntryCells(
            header: header,
            values: values,
          ) ??
          const <String>[];
      return (catalog: catalog, entry: entry);
    }
    return null;
  }

  CollectionCsvKindProfile? _profileForKind(CatalogMediaKind kind) {
    for (final profile in _profiles) {
      if (profile.kind == kind) return profile;
    }
    return null;
  }

  List<String> _genericCatalogCells(
    Map<String, int> index,
    List<String> values,
    CatalogItemRef? catalogItemRef,
  ) {
    return [
      catalogItemRef?.id ?? _value(index, values, 'item_id'),
      catalogItemRef?.kind.apiValue ?? _value(index, values, 'kind'),
      _value(index, values, 'title'),
      ...List<String>.filled(
        collectionCsvV1CatalogCellCount - 3,
        '',
      ),
    ];
  }

  bool _isStructuralHeader(List<String> header) {
    final columns = header.map(_normalizeColumn).toSet();
    return columns.contains('catalog_item_ref') ||
        columns.contains('library_entry_json');
  }

  CatalogItemRef? _parseCatalogItemRef(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final decoded = jsonDecode(trimmed);
    if (decoded is! Map) {
      throw const FormatException('catalog_item_ref must be a JSON object');
    }
    return CatalogItemRef.fromJson(Map<String, Object?>.from(decoded));
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
        row.kindEntryCells.any((cell) => cell.trim().isNotEmpty) ||
        row.fullEntryPayload != null;
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
      'in collection + wishlist' || 'entry + wishlist' => 'both',
      'in collection' || 'collection' || 'entry' => 'entry',
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
    for (final projection in _profiles) {
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
    'catalog_item_ref': ['Catalog Item Ref', 'Catalog Item Reference'],
    'kind': ['Media Type', 'Kind', 'Type', 'Library', 'Media Kind'],
    'title': ['Title', 'Full Title'],
    'status': ['Collection Status', 'Status'],
    'condition': ['Condition'],
    'purchase_date': ['Purchase Date', 'Bought Date'],
    'price_paid_cents': ['Purchase Price', 'Price Paid', 'Value'],
    'currency': ['Currency'],
    'notes': ['Notes', 'Personal Notes'],
    'location_id': ['Location ID', 'Location Id'],
    'index_number': ['Index', 'Index Number'],
    'rating': ['Rating'],
    'read_status': ['Read It', 'Read Status', 'Read'],
    'tags': ['Tags'],
  };
}
