import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/collection/csv/csv_mechanics.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_v1_schema.dart';
import 'package:collectarr_app/features/library/config/library_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';

class CollectionCsvRow {
  const CollectionCsvRow({
    required this.itemId,
    required this.status,
    this.kind,
    this.title,
    this.personal = const CollectionCsvPersonalValues(),
    this.tracking = const CollectionCsvTrackingValues(),
    this.kindCatalogCells = const [],
    this.kindOwnedCells = const [],
    this.customFieldValues = const {},
  });

  final String itemId;
  final String status;
  final String? kind;
  final String? title;

  /// Values decoded from the shared personal columns at the file boundary.
  ///
  /// This is deliberately a transport value object, not a common Owned or
  /// Tracking domain aggregate. Catalog and kind-owned details remain opaque
  /// positional cells and are interpreted only by the owning kind profile.
  final CollectionCsvPersonalValues personal;

  /// Tracking values decoded at the file boundary. The import host forwards
  /// them to the selected kind's tracking integration and does not turn them
  /// into a universal tracking domain object here.
  final CollectionCsvTrackingValues tracking;

  /// Positional catalog cells contributed by the selected kind at the CSV
  /// serialization boundary. Collection carries them without interpreting
  /// their meaning.
  final List<String> kindCatalogCells;

  /// Positional cells owned by the selected kind at the CSV serialization
  /// boundary. Collection carries them without interpreting their meaning.
  final List<String> kindOwnedCells;
  final Map<String, String?> customFieldValues;

  bool get isOwned => status == 'owned' || status == 'both';
  bool get isWishlisted => status == 'wishlist' || status == 'both';

  CollectionCsvRow copyWith({
    String? itemId,
    String? status,
    String? kind,
    String? title,
    CollectionCsvPersonalValues? personal,
    CollectionCsvTrackingValues? tracking,
    List<String>? kindCatalogCells,
    List<String>? kindOwnedCells,
    Map<String, String?>? customFieldValues,
  }) {
    return CollectionCsvRow(
      itemId: itemId ?? this.itemId,
      status: status ?? this.status,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      personal: personal ?? this.personal,
      tracking: tracking ?? this.tracking,
      kindCatalogCells: kindCatalogCells ?? this.kindCatalogCells,
      kindOwnedCells: kindOwnedCells ?? this.kindOwnedCells,
      customFieldValues: customFieldValues ?? this.customFieldValues,
    );
  }
}

/// Shared personal CSV columns represented as a serialization-boundary value.
///
/// The object is intentionally not reusable as a domain model. Import code
/// may carry these values until it dispatches to the selected kind's typed
/// mutation/codec.
final class CollectionCsvPersonalValues {
  const CollectionCsvPersonalValues({
    this.condition,
    this.purchaseDate,
    this.pricePaidCents,
    this.currency,
    this.notes,
    this.quantity,
    this.locationId,
    this.indexNumber,
    this.tags,
    this.soldAt,
    this.sellPriceCents,
    this.soldTo,
  });

  final String? condition;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? notes;
  final int? quantity;
  final String? locationId;
  final int? indexNumber;
  final String? tags;
  final DateTime? soldAt;
  final int? sellPriceCents;
  final String? soldTo;

  bool get isEmpty =>
      condition == null &&
      purchaseDate == null &&
      pricePaidCents == null &&
      currency == null &&
      notes == null &&
      quantity == null &&
      locationId == null &&
      indexNumber == null &&
      tags == null &&
      soldAt == null &&
      sellPriceCents == null &&
      soldTo == null;
}

final class CollectionCsvTrackingValues {
  const CollectionCsvTrackingValues({
    this.rating,
    this.status,
    this.startedAt,
    this.finishedAt,
  });

  final int? rating;
  final String? status;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  bool get isEmpty =>
      rating == null &&
      status == null &&
      startedAt == null &&
      finishedAt == null;
}

class CollectionCsv {
  String exportShelf(
    List<ShelfEntry> entries, {
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<CustomFieldValue>> customFieldValuesByItem = const {},
  }) {
    final cfNames = [
      for (final def in customFieldDefinitions) 'cf_${def.name}',
    ];
    final rows = [
      [...CollectionCsvV1Schema.header, ...cfNames],
      for (final entry in entries)
        _entryToRow(
          entry,
          customFieldDefinitions: customFieldDefinitions,
          customFieldValuesByItem: customFieldValuesByItem,
        ),
    ];
    return const CsvWriter(lineDelimiter: '\n').write(rows);
  }

  String exportClzFriendlyShelf(
    List<ShelfEntry> entries, {
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<CustomFieldValue>> customFieldValuesByItem = const {},
  }) {
    final cfNames = [
      for (final def in customFieldDefinitions) def.name,
    ];
    final header = [
      ..._clzFriendlyHeaderForEntries(entries),
      ...cfNames,
    ];
    final rows = [
      header,
      for (final entry in entries)
        _entryToClzRow(
          entry,
          customFieldDefinitions: customFieldDefinitions,
          customFieldValuesByItem: customFieldValuesByItem,
        ),
    ];
    return const CsvWriter(lineDelimiter: '\n').write(rows);
  }

  List<String> _catalogFields(ShelfEntry entry) {
    final catalog = entry.catalogItem;
    final projection = libraryCollectionCsvProjectionForKind(
      catalogMediaKindFromValue(catalog?.kind),
    );
    if (projection != null) {
      return _validatedCatalogCells(projection.catalogCells(entry));
    }

    // Unknown kinds get only structural catalog cells. Semantic
    // columns are supplied by a kind-owned projection when supported.
    return [
      entry.itemId,
      catalog?.kind ?? '',
      catalog?.title ?? '',
      '',
      '',
      '',
      '',
      '',
      '',
      _formatDate(catalog?.releaseDate),
      '',
    ];
  }

  List<String> _validatedCatalogCells(List<String> cells) {
    if (cells.length != libraryCollectionCsvCatalogCellCount) {
      throw StateError(
        'Collection CSV catalog projection returned ${cells.length} cells; '
        'expected $libraryCollectionCsvCatalogCellCount.',
      );
    }
    return cells;
  }

  List<String> _kindOwnedCellsBeforeQuantity(
    ShelfEntry entry, {
    required bool clzFriendly,
  }) {
    final projection = libraryCollectionCsvProjectionForKind(
      entry.mediaKind,
    );
    if (projection == null) {
      return clzFriendly ? const [''] : const [];
    }
    final cells = projection.ownedCellsBeforeQuantity(
      entry,
      clzFriendly: clzFriendly,
    );
    return cells;
  }

  String _ownedCollectionValue(ShelfEntry entry) {
    final projection = libraryCollectionCsvProjectionForKind(entry.mediaKind);
    return projection?.ownedCollectionValue(entry) ?? '';
  }

  String _ownedCondition(ShelfEntry entry) {
    final projection = libraryCollectionCsvProjectionForKind(entry.mediaKind);
    return projection?.ownedCondition(entry) ?? '';
  }

  String _ownedIndexNumber(ShelfEntry entry) {
    final projection = libraryCollectionCsvProjectionForKind(entry.mediaKind);
    return projection?.ownedIndexNumber(entry)?.toString() ?? '';
  }

  String _ownedTags(ShelfEntry entry) {
    final projection = libraryCollectionCsvProjectionForKind(entry.mediaKind);
    return projection?.ownedTags(entry) ?? '';
  }

  List<String> _kindOwnedCellsAfterIndex(
    ShelfEntry entry, {
    required bool clzFriendly,
  }) {
    final projection = libraryCollectionCsvProjectionForKind(
      entry.mediaKind,
    );
    if (projection == null) {
      return List<String>.filled(
        clzFriendly
            ? libraryCollectionCsvOwnedCellCount - 1
            : libraryCollectionCsvOwnedCellCount,
        '',
      );
    }
    final beforeQuantity = projection.ownedCellsBeforeQuantity(
      entry,
      clzFriendly: clzFriendly,
    );
    final cells = projection.ownedCellsAfterIndex(
      entry,
      clzFriendly: clzFriendly,
    );
    if (beforeQuantity.length + cells.length !=
        libraryCollectionCsvOwnedCellCount) {
      throw StateError(
        'Collection CSV owned projection for ${projection.kind.apiValue} '
        'returned ${beforeQuantity.length + cells.length} cells; expected '
        '$libraryCollectionCsvOwnedCellCount.',
      );
    }
    return cells;
  }

  List<String> _entryToRow(
    ShelfEntry entry, {
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<CustomFieldValue>> customFieldValuesByItem = const {},
  }) {
    final cfValues = entry.ownedRef != null
        ? _customFieldCells(
            entry.ownedRef!.id.value,
            customFieldDefinitions,
            customFieldValuesByItem,
          )
        : List.filled(customFieldDefinitions.length, '');
    return [
      ..._catalogFields(entry),
      _status(entry),
      _ownedCondition(entry),
      _ownedCollectionValue(entry),
      _formatDate(entry.purchaseDate),
      entry.pricePaidCents?.toString() ?? '',
      entry.currency ?? entry.wishlistItem?.currency ?? '',
      entry.personalNotes ?? entry.wishlistItem?.notes ?? '',
      entry.quantity.toString(),
      _locationCell(entry),
      _ownedIndexNumber(entry),
      ..._kindOwnedCellsAfterIndex(entry, clzFriendly: false),
      entry.trackingRating?.toString() ?? '',
      mediaTrackingStatusToStorageValue(entry.trackingStatus) ?? '',
      _formatDate(entry.trackingStartedAt),
      _formatDate(entry.trackingCompletedAt),
      _ownedTags(entry),
      _formatDate(entry.soldAt),
      entry.sellPriceCents?.toString() ?? '',
      entry.soldTo ?? '',
      ...cfValues,
    ];
  }

  List<String> _entryToClzRow(
    ShelfEntry entry, {
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<CustomFieldValue>> customFieldValuesByItem = const {},
  }) {
    final cfValues = entry.ownedRef != null
        ? _customFieldCells(
            entry.ownedRef!.id.value,
            customFieldDefinitions,
            customFieldValuesByItem,
          )
        : List.filled(customFieldDefinitions.length, '');
    return [
      ..._catalogFields(entry),
      _clzStatus(entry),
      _ownedCondition(entry),
      _ownedCollectionValue(entry),
      _formatDate(entry.purchaseDate),
      _formatMoney(entry.pricePaidCents),
      entry.currency ?? entry.wishlistItem?.currency ?? '',
      ..._kindOwnedCellsBeforeQuantity(entry, clzFriendly: true),
      entry.quantity.toString(),
      _locationCell(entry),
      _ownedIndexNumber(entry),
      ..._kindOwnedCellsAfterIndex(entry, clzFriendly: true),
      entry.trackingRating?.toString() ?? '',
      mediaTrackingStatusToStorageValue(entry.trackingStatus) ?? '',
      _formatDate(entry.trackingStartedAt),
      _formatDate(entry.trackingCompletedAt),
      _ownedTags(entry),
      entry.personalNotes ?? entry.wishlistItem?.notes ?? '',
      _formatDate(entry.soldAt),
      _formatMoney(entry.sellPriceCents),
      entry.soldTo ?? '',
      ...cfValues,
    ];
  }

  String _locationCell(ShelfEntry entry) {
    return entry.locationPath ?? entry.ownedSummary?.locationLabel ?? '';
  }

  List<String> _customFieldCells(
    String ownedItemId,
    List<CustomFieldDefinition> definitions,
    Map<String, List<CustomFieldValue>> valuesByItem,
  ) {
    final values = valuesByItem[ownedItemId] ?? const [];
    final byDefId = {
      for (final v in values) v.fieldDefinitionId: v.value ?? '',
    };
    return [
      for (final def in definitions) byDefId[def.id] ?? '',
    ];
  }

  List<CollectionCsvRow> parse(String csv) {
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

  String _status(ShelfEntry entry) {
    if (entry.isOwned && entry.isWishlisted) {
      return 'both';
    }
    if (entry.isOwned) {
      return 'owned';
    }
    return 'wishlist';
  }

  String _clzStatus(ShelfEntry entry) {
    if (entry.isOwned && entry.isWishlisted) {
      return 'In Collection + Wishlist';
    }
    if (entry.isOwned) {
      return 'In Collection';
    }
    return 'Wishlist';
  }

  List<String> _clzFriendlyHeaderForEntries(List<ShelfEntry> entries) {
    final kinds = {
      for (final entry in entries)
        if (entry.mediaKind != CatalogMediaKind.unknown)
          entry.mediaKind.apiValue,
    };
    if (kinds.length == 1) {
      return _clzFriendlyHeaderForKind(kinds.single);
    }
    return _clzFriendlyHeader(
      title: 'Title / Series',
      number: 'No. / Vol.',
      variant: 'Edition / Variant / Format',
      editionTitle: 'Edition Title',
      physicalFormat: 'Physical Format',
      publisher: 'Publisher / Studio / Creator',
      barcode: 'Barcode / UPC / ISBN',
    );
  }

  List<String> _clzFriendlyHeaderForKind(String kind) {
    final mediaKind = catalogMediaKindFromValue(kind);
    final projection = libraryCollectionCsvProjectionForKind(mediaKind);
    if (projection?.clzFriendlyHeader case final header?) {
      return header;
    }
    return CollectionCsvV1Schema.clzFriendlyHeader;
  }

  List<String> _clzFriendlyHeader({
    required String title,
    required String number,
    required String variant,
    required String editionTitle,
    required String physicalFormat,
    required String publisher,
    required String barcode,
  }) {
    final schema = [...CollectionCsvV1Schema.clzFriendlyHeader];
    schema[2] = title;
    schema[3] = number;
    schema[4] = variant;
    schema[5] = editionTitle;
    schema[6] = physicalFormat;
    schema[8] = publisher;
    schema[10] = barcode;
    return schema;
  }

  CollectionCsvRow _rowFromValues(
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
    return CollectionCsvRow(
      itemId: catalogCells[0],
      status: _normalizedStatus(_value(index, values, 'status')),
      kind: _optionalCell(catalogCells[1]),
      title: _optionalCell(catalogCells[2]),
      personal: CollectionCsvPersonalValues(
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
      tracking: CollectionCsvTrackingValues(
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

  bool _isMeaningfulRow(CollectionCsvRow row) {
    return row.itemId.trim().isNotEmpty ||
        (row.kind?.trim().isNotEmpty ?? false) ||
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

  String _formatMoney(int? cents) {
    if (cents == null) {
      return '';
    }
    final absolute = cents.abs();
    final sign = cents < 0 ? '-' : '';
    final whole = absolute ~/ 100;
    final fraction = (absolute % 100).toString().padLeft(2, '0');
    return '$sign$whole.$fraction';
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '';
    }
    final utc = value.toUtc();
    return '${utc.year.toString().padLeft(4, '0')}-'
        '${utc.month.toString().padLeft(2, '0')}-'
        '${utc.day.toString().padLeft(2, '0')}';
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
