import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/collection/csv/csv_mechanics.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/config/library_collection_csv_projection.dart';

class CollectionCsvRow {
  const CollectionCsvRow({
    required this.itemId,
    required this.status,
    this.kind,
    this.title,
    this.itemNumber,
    this.variant,
    this.editionTitle,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.publisher,
    this.releaseDate,
    this.barcode,
    this.condition,
    this.grade,
    this.purchaseDate,
    this.pricePaidCents,
    this.currency,
    this.notes,
    this.quantity,
    this.locationId,
    this.indexNumber,
    this.coverPriceCents,
    this.rawOrSlabbed,
    this.gradingCompany,
    this.graderNotes,
    this.signedBy,
    this.labelType,
    this.certificationNumber,
    this.keyComic = false,
    this.keyReason,
    this.rating,
    this.readStatus,
    this.startedAt,
    this.finishedAt,
    this.tags,
    this.soldAt,
    this.sellPriceCents,
    this.soldTo,
    this.customFieldValues = const {},
  });

  final String itemId;
  final String status;
  final String? kind;
  final String? title;
  final String? itemNumber;
  final String? variant;
  final String? editionTitle;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final String? publisher;
  final DateTime? releaseDate;
  final String? barcode;
  final String? condition;
  final String? grade;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? notes;
  final int? quantity;
  final String? locationId;
  final int? indexNumber;
  final int? coverPriceCents;
  final String? rawOrSlabbed;
  final String? gradingCompany;
  final String? graderNotes;
  final String? signedBy;
  final String? labelType;
  final String? certificationNumber;
  final bool keyComic;
  final String? keyReason;
  final int? rating;
  final String? readStatus;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final String? tags;
  final DateTime? soldAt;
  final int? sellPriceCents;
  final String? soldTo;
  final Map<String, String?> customFieldValues;

  bool get isOwned => status == 'owned' || status == 'both';
  bool get isWishlisted => status == 'wishlist' || status == 'both';

  CollectionCsvRow copyWith({
    String? itemId,
    String? status,
    String? kind,
    String? title,
    String? itemNumber,
    String? variant,
    String? editionTitle,
    String? physicalFormat,
    String? physicalFormatLabel,
    String? publisher,
    DateTime? releaseDate,
    String? barcode,
    String? condition,
    String? grade,
    DateTime? purchaseDate,
    int? pricePaidCents,
    String? currency,
    String? notes,
    int? quantity,
    String? locationId,
    int? indexNumber,
    int? coverPriceCents,
    String? rawOrSlabbed,
    String? gradingCompany,
    String? graderNotes,
    String? signedBy,
    String? labelType,
    String? certificationNumber,
    bool? keyComic,
    String? keyReason,
    int? rating,
    String? readStatus,
    DateTime? startedAt,
    DateTime? finishedAt,
    String? tags,
    DateTime? soldAt,
    int? sellPriceCents,
    String? soldTo,
    Map<String, String?>? customFieldValues,
  }) {
    return CollectionCsvRow(
      itemId: itemId ?? this.itemId,
      status: status ?? this.status,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      itemNumber: itemNumber ?? this.itemNumber,
      variant: variant ?? this.variant,
      editionTitle: editionTitle ?? this.editionTitle,
      physicalFormat: physicalFormat ?? this.physicalFormat,
      physicalFormatLabel: physicalFormatLabel ?? this.physicalFormatLabel,
      publisher: publisher ?? this.publisher,
      releaseDate: releaseDate ?? this.releaseDate,
      barcode: barcode ?? this.barcode,
      condition: condition ?? this.condition,
      grade: grade ?? this.grade,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      pricePaidCents: pricePaidCents ?? this.pricePaidCents,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      quantity: quantity ?? this.quantity,
      locationId: locationId ?? this.locationId,
      indexNumber: indexNumber ?? this.indexNumber,
      coverPriceCents: coverPriceCents ?? this.coverPriceCents,
      rawOrSlabbed: rawOrSlabbed ?? this.rawOrSlabbed,
      gradingCompany: gradingCompany ?? this.gradingCompany,
      graderNotes: graderNotes ?? this.graderNotes,
      signedBy: signedBy ?? this.signedBy,
      labelType: labelType ?? this.labelType,
      certificationNumber: certificationNumber ?? this.certificationNumber,
      keyComic: keyComic ?? this.keyComic,
      keyReason: keyReason ?? this.keyReason,
      rating: rating ?? this.rating,
      readStatus: readStatus ?? this.readStatus,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      tags: tags ?? this.tags,
      soldAt: soldAt ?? this.soldAt,
      sellPriceCents: sellPriceCents ?? this.sellPriceCents,
      soldTo: soldTo ?? this.soldTo,
      customFieldValues: customFieldValues ?? this.customFieldValues,
    );
  }
}

class CollectionCsv {
  static const header = [
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
    'Issue',
    'Variant Description',
    'Edition Title',
    'Physical Format',
    'Physical Format Label',
    'Publisher',
    'Release Date',
    'Barcode',
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

  String exportShelf(
    List<ShelfEntry> entries, {
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<CustomFieldValue>> customFieldValuesByItem = const {},
  }) {
    final cfNames = [
      for (final def in customFieldDefinitions) 'cf_${def.name}',
    ];
    final rows = [
      [...header, ...cfNames],
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

    final payload = catalog?.payload ?? const <String, dynamic>{};
    final pub = payload['publishing'] as Map?;
    final itemNumber =
        (payload['item_number'] ?? pub?['issue_number'])?.toString() ?? '';
    final variant = (payload['variant'] ?? pub?['variant'])?.toString() ?? '';
    final editionTitle =
        (payload['edition_title'] ?? pub?['edition_title'])?.toString() ?? '';
    final physicalFormat =
        (payload['physical_format'] ?? pub?['physical_format'])?.toString() ??
            '';
    final physicalFormatLabel =
        (payload['physical_format_label'] ?? pub?['physical_format_label'])
                ?.toString() ??
            '';
    final publisher =
        (payload['publisher'] ?? pub?['original_publisher'])?.toString() ?? '';
    final barcode = (payload['barcode'] ?? pub?['barcode'])?.toString() ?? '';

    return [
      entry.itemId,
      catalog?.kind ?? '',
      catalog?.title ?? '',
      itemNumber,
      variant,
      editionTitle,
      physicalFormat,
      physicalFormatLabel,
      publisher,
      _formatDate(_parseDate(payload['release_date']?.toString() ?? '')),
      barcode,
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
      catalogMediaKindFromValue(entry.catalogItem?.kind),
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

  List<String> _kindOwnedCellsAfterIndex(
    ShelfEntry entry, {
    required bool clzFriendly,
  }) {
    final projection = libraryCollectionCsvProjectionForKind(
      catalogMediaKindFromValue(entry.catalogItem?.kind),
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
    final o = entry.ownedItem;
    final tracking = entry.trackingEntry;
    final cfValues = o != null
        ? _customFieldCells(
            o.id, customFieldDefinitions, customFieldValuesByItem)
        : List.filled(customFieldDefinitions.length, '');
    return [
      ..._catalogFields(entry),
      _status(entry),
      o?.condition ?? '',
      o?.grade ?? '',
      _formatDate(o?.purchaseDate),
      o?.pricePaidCents?.toString() ?? '',
      o?.currency ?? entry.wishlistItem?.currency ?? '',
      o?.personalNotes ?? entry.wishlistItem?.notes ?? '',
      o?.quantity.toString() ?? '',
      _locationCell(entry),
      o?.indexNumber?.toString() ?? '',
      ..._kindOwnedCellsAfterIndex(entry, clzFriendly: false),
      (tracking == null ? o?.rating : tracking.rating)?.toString() ?? '',
      (tracking == null ? o?.readStatus : tracking.statusStorageValue) ?? '',
      _formatDate(tracking == null ? o?.startedAt : tracking.startedAt),
      _formatDate(tracking == null ? o?.finishedAt : tracking.finishedAt),
      o?.tags ?? '',
      _formatDate(o?.soldAt),
      o?.sellPriceCents?.toString() ?? '',
      o?.soldTo ?? '',
      ...cfValues,
    ];
  }

  List<String> _entryToClzRow(
    ShelfEntry entry, {
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<CustomFieldValue>> customFieldValuesByItem = const {},
  }) {
    final o = entry.ownedItem;
    final tracking = entry.trackingEntry;
    final cfValues = o != null
        ? _customFieldCells(
            o.id, customFieldDefinitions, customFieldValuesByItem)
        : List.filled(customFieldDefinitions.length, '');
    return [
      ..._catalogFields(entry),
      _clzStatus(entry),
      o?.condition ?? '',
      o?.grade ?? '',
      _formatDate(o?.purchaseDate),
      _formatMoney(o?.pricePaidCents),
      o?.currency ?? entry.wishlistItem?.currency ?? '',
      ..._kindOwnedCellsBeforeQuantity(entry, clzFriendly: true),
      o?.quantity.toString() ?? '',
      _locationCell(entry),
      o?.indexNumber?.toString() ?? '',
      ..._kindOwnedCellsAfterIndex(entry, clzFriendly: true),
      (tracking == null ? o?.rating : tracking.rating)?.toString() ?? '',
      (tracking == null ? o?.readStatus : tracking.statusStorageValue) ?? '',
      _formatDate(tracking == null ? o?.startedAt : tracking.startedAt),
      _formatDate(tracking == null ? o?.finishedAt : tracking.finishedAt),
      o?.tags ?? '',
      o?.personalNotes ?? entry.wishlistItem?.notes ?? '',
      _formatDate(o?.soldAt),
      _formatMoney(o?.sellPriceCents),
      o?.soldTo ?? '',
      ...cfValues,
    ];
  }

  String _locationCell(ShelfEntry entry) {
    return entry.locationPath ?? entry.ownedItem?.locationId ?? '';
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
        if ((entry.catalogItem?.kind.trim().isNotEmpty ?? false))
          entry.catalogItem!.kind.trim().toLowerCase(),
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
    final module = defaultLibraryKindRegistry.tryGet(mediaKind);
    if (module == null) {
      return clzFriendlyHeader;
    }
    final labels = module.presentation.previewLabels;
    return _clzFriendlyHeader(
      title: labels.labelFor('export_title', fallback: 'Title'),
      number: labels.labelFor('item_number', fallback: 'Number'),
      variant: labels.labelFor('variant', fallback: 'Variant'),
      editionTitle: 'Edition Title',
      physicalFormat: 'Physical Format',
      publisher: labels.labelFor('publisher', fallback: 'Publisher'),
      barcode: labels.labelFor('barcode', fallback: 'Barcode'),
    );
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
    return [
      'Collectarr Item ID',
      'Media Type',
      title,
      number,
      variant,
      editionTitle,
      physicalFormat,
      'Physical Format Label',
      publisher,
      'Release Date',
      barcode,
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
      'Tags',
      'Notes',
      'Sold Date',
      'Sell Price',
      'Sold To',
    ];
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
    if (ownedCells.length != libraryCollectionCsvOwnedCellCount) {
      throw StateError(
        'Collection CSV import owned projection returned ${ownedCells.length} '
        'cells; expected $libraryCollectionCsvOwnedCellCount.',
      );
    }
    return CollectionCsvRow(
      itemId: catalogCells[0],
      status: _normalizedStatus(_value(index, values, 'status')),
      kind: _optionalCell(catalogCells[1]),
      title: _optionalCell(catalogCells[2]),
      itemNumber: _optionalCell(catalogCells[3]),
      variant: _optionalCell(catalogCells[4]),
      editionTitle: _optionalCell(catalogCells[5]),
      physicalFormat: _optionalCell(catalogCells[6]),
      physicalFormatLabel: _optionalCell(catalogCells[7]),
      publisher: _optionalCell(catalogCells[8]),
      releaseDate: _parseDate(catalogCells[9]),
      barcode: _optionalCell(catalogCells[10]),
      condition: _optionalValue(index, values, 'condition'),
      grade: _optionalValue(index, values, 'grade'),
      purchaseDate: _parseDate(_value(index, values, 'purchase_date')),
      pricePaidCents: _moneyCents(_value(index, values, 'price_paid_cents')),
      currency: _optionalValue(index, values, 'currency'),
      notes: _optionalValue(index, values, 'notes'),
      quantity: int.tryParse(_value(index, values, 'quantity')),
      locationId: _optionalValue(index, values, 'location_id'),
      indexNumber: int.tryParse(_value(index, values, 'index_number')),
      coverPriceCents: _moneyCents(ownedCells[0]),
      rawOrSlabbed: _optionalCell(ownedCells[1]),
      gradingCompany: _optionalCell(ownedCells[2]),
      graderNotes: _optionalCell(ownedCells[3]),
      signedBy: _optionalCell(ownedCells[4]),
      labelType: _optionalCell(ownedCells[5]),
      certificationNumber: _optionalCell(ownedCells[6]),
      keyComic: _boolCell(ownedCells[7]),
      keyReason: _optionalCell(ownedCells[8]),
      rating: int.tryParse(_value(index, values, 'rating')),
      readStatus: _optionalValue(index, values, 'read_status'),
      startedAt: _parseDate(_value(index, values, 'started_at')),
      finishedAt: _parseDate(_value(index, values, 'finished_at')),
      tags: _optionalValue(index, values, 'tags'),
      soldAt: _parseDate(_value(index, values, 'sold_at')),
      sellPriceCents: _moneyCents(_value(index, values, 'sell_price_cents')),
      soldTo: _optionalValue(index, values, 'sold_to'),
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

  List<String> _genericOwnedCells(
    Map<String, int> index,
    List<String> values,
  ) {
    return [
      _value(index, values, 'cover_price_cents'),
      _value(index, values, 'raw_or_slabbed'),
      _value(index, values, 'grading_company'),
      _value(index, values, 'grader_notes'),
      _value(index, values, 'signed_by'),
      _value(index, values, 'label_type'),
      _value(index, values, 'certification_number'),
      _value(index, values, 'key_comic'),
      _value(index, values, 'key_reason'),
    ];
  }

  String? _optionalCell(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  bool _boolCell(String value) {
    return switch (value.trim().toLowerCase()) {
      '1' || 'true' || 'yes' || 'y' => true,
      _ => false,
    };
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
        (row.itemNumber?.trim().isNotEmpty ?? false) ||
        (row.editionTitle?.trim().isNotEmpty ?? false) ||
        (row.physicalFormat?.trim().isNotEmpty ?? false) ||
        (row.locationId?.trim().isNotEmpty ?? false) ||
        (row.publisher?.trim().isNotEmpty ?? false) ||
        (row.barcode?.trim().isNotEmpty ?? false);
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
    'item_number': [
      'No. / Vol.',
      'Volume',
      'Season / Volume',
      'Edition no.',
      'Version',
    ],
    'variant': [
      'Variant',
      'Format / Edition',
      'Platform / Edition',
      'Edition / Binding',
      'Edition / Variant',
      'Edition / Variant / Format',
      'Expansion / Edition',
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
      'Format',
      'Format Label',
      'Video Format Label',
    ],
    'publisher': [
      'Publisher',
      'Studio',
      'Network / Studio',
      'Studio / Publisher',
      'Publisher / Studio',
      'Publisher / Designer',
      'Label / Artist',
      'Publisher / Studio / Creator',
    ],
    'release_date': ['Release Date', 'Cover Date'],
    'barcode': [
      'Barcode',
      'UPC',
      'ISBN',
      'UPC / Barcode',
      'ISBN / Barcode',
      'Barcode / Catalog no.',
      'Barcode / UPC / ISBN',
    ],
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
