import 'package:csv/csv.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/config/library_media_field_labels.dart';

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
    String? storageBox,
    int? indexNumber,
    int? coverPriceCents,
    String? rawOrSlabbed,
    String? gradingCompany,
    String? graderNotes,
    String? signedBy,
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
      storageBox: storageBox ?? this.storageBox,
      indexNumber: indexNumber ?? this.indexNumber,
      coverPriceCents: coverPriceCents ?? this.coverPriceCents,
      rawOrSlabbed: rawOrSlabbed ?? this.rawOrSlabbed,
      gradingCompany: gradingCompany ?? this.gradingCompany,
      graderNotes: graderNotes ?? this.graderNotes,
      signedBy: signedBy ?? this.signedBy,
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
    'Storage Box',
    'Index',
    'Raw / Slabbed',
    'Grading Company',
    'Grader Notes',
    'Signed By',
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
    return const CsvEncoder(lineDelimiter: '\n').convert(rows);
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
    return const CsvEncoder(lineDelimiter: '\n').convert(rows);
  }

  List<String> _catalogFields(ShelfEntry entry) => [
        entry.itemId,
        entry.catalogItem?.kind ?? '',
        entry.catalogItem?.title ?? '',
        entry.catalogItem?.itemNumber ?? '',
        entry.catalogItem?.variant ?? '',
        entry.catalogItem?.editionTitle ?? '',
        entry.catalogItem?.physicalFormat ?? '',
        entry.catalogItem?.physicalFormatLabel ?? '',
        entry.catalogItem?.publisher ?? '',
        _formatDate(entry.catalogItem?.releaseDate),
        entry.catalogItem?.barcode ?? '',
      ];

  List<String> _entryToRow(
    ShelfEntry entry, {
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<CustomFieldValue>> customFieldValuesByItem = const {},
  }) {
    final o = entry.ownedItem;
    final cfValues = o != null
        ? _customFieldCells(o.id, customFieldDefinitions, customFieldValuesByItem)
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
      o?.storageBox ?? '',
      o?.indexNumber?.toString() ?? '',
      o?.coverPriceCents?.toString() ?? '',
      o?.rawOrSlabbed ?? '',
      o?.gradingCompany ?? '',
      o?.graderNotes ?? '',
      o?.signedBy ?? '',
      o == null ? '' : o.keyComic.toString(),
      o?.keyReason ?? '',
      o?.rating?.toString() ?? '',
      o?.readStatus ?? '',
      _formatDate(o?.startedAt),
      _formatDate(o?.finishedAt),
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
    final cfValues = o != null
        ? _customFieldCells(o.id, customFieldDefinitions, customFieldValuesByItem)
        : List.filled(customFieldDefinitions.length, '');
    return [
      ..._catalogFields(entry),
      _clzStatus(entry),
      o?.condition ?? '',
      o?.grade ?? '',
      _formatDate(o?.purchaseDate),
      _formatMoney(o?.pricePaidCents),
      o?.currency ?? entry.wishlistItem?.currency ?? '',
      _formatMoney(o?.coverPriceCents),
      o?.quantity.toString() ?? '',
      o?.storageBox ?? '',
      o?.indexNumber?.toString() ?? '',
      o?.rawOrSlabbed ?? '',
      o?.gradingCompany ?? '',
      o?.graderNotes ?? '',
      o?.signedBy ?? '',
      o == null ? '' : o.keyComic.toString(),
      o?.keyReason ?? '',
      o?.rating?.toString() ?? '',
      o?.readStatus ?? '',
      _formatDate(o?.startedAt),
      _formatDate(o?.finishedAt),
      o?.tags ?? '',
      o?.personalNotes ?? entry.wishlistItem?.notes ?? '',
      _formatDate(o?.soldAt),
      _formatMoney(o?.sellPriceCents),
      o?.soldTo ?? '',
      ...cfValues,
    ];
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
    final index = _headerIndex(parsedHeader);
    final cfColumns = _customFieldColumns(parsedHeader);
    return [
      for (final row in rows.skip(1))
        _rowFromValues(
          index,
          row.map(_cellValue).toList(growable: false),
          cfColumns: cfColumns,
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
    final type = collectarrLibraryTypes.byKind(kind);
    if (type == null) {
      return clzFriendlyHeader;
    }
    final labels = libraryMediaFieldLabels(type);
    final title = switch (type.workspace.kind) {
      'comic' || 'manga' => 'Series',
      'tv' => 'Show',
      'music' => 'Release',
      _ => 'Title',
    };
    return _clzFriendlyHeader(
      title: title,
      number: labels.number,
      variant: labels.variant,
      editionTitle: 'Edition Title',
      physicalFormat: 'Physical Format',
      publisher: labels.publisher,
      barcode: labels.barcode,
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
      'Storage Box',
      'Index',
      'Raw / Slabbed',
      'Grading Company',
      'Grader Notes',
      'Signed By',
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
  }) {
    final cfValues = <String, String?>{};
    for (final entry in cfColumns.entries) {
      final v =
          entry.value < values.length ? values[entry.value].trim() : '';
      if (v.isNotEmpty) {
        cfValues[entry.key] = v;
      }
    }
    return CollectionCsvRow(
      itemId: _value(index, values, 'item_id'),
      status: _normalizedStatus(_value(index, values, 'status')),
      kind: _optionalValue(index, values, 'kind'),
      title: _optionalValue(index, values, 'title'),
      itemNumber: _optionalValue(index, values, 'item_number'),
      variant: _optionalValue(index, values, 'variant'),
      editionTitle: _optionalValue(index, values, 'edition_title'),
      physicalFormat: _optionalValue(index, values, 'physical_format'),
      physicalFormatLabel:
          _optionalValue(index, values, 'physical_format_label'),
      publisher: _optionalValue(index, values, 'publisher'),
      releaseDate: _parseDate(_value(index, values, 'release_date')),
      barcode: _optionalValue(index, values, 'barcode'),
      condition: _optionalValue(index, values, 'condition'),
      grade: _optionalValue(index, values, 'grade'),
      purchaseDate: _parseDate(_value(index, values, 'purchase_date')),
      pricePaidCents: _moneyCents(_value(index, values, 'price_paid_cents')),
      currency: _optionalValue(index, values, 'currency'),
      notes: _optionalValue(index, values, 'notes'),
      quantity: int.tryParse(_value(index, values, 'quantity')),
      storageBox: _optionalValue(index, values, 'storage_box'),
      indexNumber: int.tryParse(_value(index, values, 'index_number')),
      coverPriceCents: _moneyCents(_value(index, values, 'cover_price_cents')),
      rawOrSlabbed: _optionalValue(index, values, 'raw_or_slabbed'),
      gradingCompany: _optionalValue(index, values, 'grading_company'),
      graderNotes: _optionalValue(index, values, 'grader_notes'),
      signedBy: _optionalValue(index, values, 'signed_by'),
      keyComic: _boolValue(index, values, 'key_comic'),
      keyReason: _optionalValue(index, values, 'key_reason'),
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

  bool _boolValue(Map<String, int> index, List<String> values, String column) {
    return switch (_value(index, values, column).trim().toLowerCase()) {
      '1' || 'true' || 'yes' || 'y' => true,
      _ => false,
    };
  }

  String _cellValue(dynamic value) => value?.toString() ?? '';

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
    return normalized;
  }

  static const _columnAliases = {
    'item_id': [
      'Collectarr Item ID',
      'Core ComicID',
      'Core SeriesID',
      'ComicID',
    ],
    'kind': ['Media Type', 'Kind', 'Type', 'Library', 'Media Kind'],
    'title': ['Series', 'Show', 'Release', 'Full Title'],
    'item_number': [
      'Issue',
      'Issue No.',
      'Issue Number',
      'No. / Vol.',
      'Volume',
      'Season / Volume',
      'Edition no.',
      'Version',
    ],
    'variant': [
      'Variant',
      'Variant Description',
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
    'storage_box': ['Storage Box', 'Storage'],
    'index_number': ['Index', 'Index Number'],
    'cover_price_cents': ['Cover Price'],
    'raw_or_slabbed': ['Raw / Slabbed', 'Grade Status'],
    'grading_company': ['Grading Company'],
    'grader_notes': ['Grader Notes'],
    'signed_by': ['Signed By'],
    'key_comic': ['Key Comic'],
    'key_reason': ['Key Reason'],
    'rating': ['Rating'],
    'read_status': ['Read It', 'Read Status', 'Read'],
    'tags': ['Tags'],
  };
}
