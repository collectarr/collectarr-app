import 'dart:convert';

import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_v1_schema.dart';
import 'package:collectarr_app/features/collection/csv/csv_mechanics.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_kind_profile.dart';

/// Schema-v1 collection export mechanics.
///
/// Kind projections own the meaning of catalog and kind-entry cells.
final class CollectionCsvExporter {
  CollectionCsvExporter({required Iterable<CollectionCsvKindProfile> profiles})
      : _profilesByKind = {
          for (final profile in profiles) profile.kind: profile,
        };

  final Map<CatalogMediaKind, CollectionCsvKindProfile> _profilesByKind;

  String exportShelf(
    List<LibraryWorkspaceContext> entries, {
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<CustomFieldValue>> customFieldValuesByItem = const {},
    Map<LibraryEntryRef, LibraryEntryRecord> entryRecordsByRef = const {},
  }) {
    final cfNames = [
      for (final def in customFieldDefinitions) 'cf_${def.name}',
    ];
    final structural = _requiresStructuralExport(entries);
    final rows = [
      [
        ...(structural ? CollectionCsvV1Schema.header : _v1Header(entries)),
        ...cfNames,
        if (!structural) 'quantity',
        if (!structural) 'library_entry_json',
      ],
      for (final entry in entries)
        structural
            ? _entryToStructuralRow(
                entry,
                customFieldDefinitions: customFieldDefinitions,
                customFieldValuesByItem: customFieldValuesByItem,
                entryRecordsByRef: entryRecordsByRef,
                includeCompleteEntry: true,
              )
            : _entryToRow(
                entry,
                customFieldDefinitions: customFieldDefinitions,
                customFieldValuesByItem: customFieldValuesByItem,
                entryRecordsByRef: entryRecordsByRef,
                includeCompleteEntry: true,
              ),
    ];
    return const CsvWriter(lineDelimiter: '\n').write(rows);
  }

  String exportClzFriendlyShelf(
    List<LibraryWorkspaceContext> entries, {
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<CustomFieldValue>> customFieldValuesByItem = const {},
    Map<LibraryEntryRef, LibraryEntryRecord> entryRecordsByRef = const {},
  }) {
    final cfNames = [
      for (final def in customFieldDefinitions) def.name,
    ];
    final structural = _requiresStructuralExport(entries);
    final header = [
      ...(structural
          ? CollectionCsvV1Schema.clzFriendlyHeader
          : _clzFriendlyHeaderForEntries(entries)),
      ...cfNames,
    ];
    final rows = [
      header,
      for (final entry in entries)
        structural
            ? _entryToStructuralRow(
                entry,
                customFieldDefinitions: customFieldDefinitions,
                customFieldValuesByItem: customFieldValuesByItem,
                entryRecordsByRef: entryRecordsByRef,
              )
            : _entryToClzRow(
                entry,
                customFieldDefinitions: customFieldDefinitions,
                customFieldValuesByItem: customFieldValuesByItem,
                entryRecordsByRef: entryRecordsByRef,
              ),
    ];
    return const CsvWriter(lineDelimiter: '\n').write(rows);
  }

  List<String> _catalogFields(LibraryWorkspaceContext entry) {
    final projection = _profileForKind(
      entry.mediaKind,
    );
    if (projection != null) {
      return _validatedCatalogCells(projection.catalogCells(entry));
    }

    // Unknown kinds get only structural catalog cells. Semantic
    // columns are supplied by a kind-entry projection when supported.
    return [
      entry.itemId,
      entry.mediaKind.apiValue,
      entry.title,
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ];
  }

  List<String> _entryToStructuralRow(
    LibraryWorkspaceContext entry, {
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<CustomFieldValue>> customFieldValuesByItem = const {},
    Map<LibraryEntryRef, LibraryEntryRecord> entryRecordsByRef = const {},
    bool includeCompleteEntry = false,
  }) {
    final customFields = entry.libraryEntryRef == null
        ? List<String>.filled(customFieldDefinitions.length, '')
        : _customFieldCells(
            entry.libraryEntryRef!.key,
            customFieldDefinitions,
            customFieldValuesByItem,
          );
    return [
      _catalogItemRefForExport(entry, entryRecordsByRef) == null
          ? ''
          : jsonEncode(
              _catalogItemRefForExport(entry, entryRecordsByRef)!.toJson(),
            ),
      entry.mediaKind.apiValue,
      entry.title,
      _status(entry),
      _locationCell(entry),
      entry.personalNotes ?? entry.wishlistItem?.notes ?? '',
      _entryQuantity(entry, entryRecordsByRef),
      if (includeCompleteEntry)
        _completeEntryCell(entry, customFieldValuesByItem, entryRecordsByRef),
      ...customFields,
    ];
  }

  List<String> _v1Header(List<LibraryWorkspaceContext> entries) {
    final kinds = {
      for (final entry in entries)
        if (!entry.mediaKind.isUnknown) entry.mediaKind,
    };
    if (kinds.length != 1) return CollectionCsvV1Schema.header;
    return _profileForKind(kinds.single)?.v1Header ??
        CollectionCsvV1Schema.header;
  }

  bool _requiresStructuralExport(List<LibraryWorkspaceContext> entries) {
    final kinds = {
      for (final entry in entries)
        if (!entry.mediaKind.isUnknown) entry.mediaKind,
    };
    return kinds.length != 1;
  }

  List<String> _validatedCatalogCells(List<String> cells) {
    if (cells.length != collectionCsvV1CatalogCellCount) {
      throw StateError(
        'Collection CSV catalog projection returned ${cells.length} cells; '
        'expected $collectionCsvV1CatalogCellCount.',
      );
    }
    return cells;
  }

  List<String> _kindEntryCellsBeforeLocation(
    LibraryWorkspaceContext entry, {
    required bool clzFriendly,
  }) {
    final projection = _profileForKind(entry.mediaKind);
    if (projection == null) {
      return const [];
    }
    final cells = projection.entryCellsBeforeLocation(
      entry,
      clzFriendly: clzFriendly,
    );
    return cells;
  }

  String _entryCollectionValue(LibraryWorkspaceContext entry) {
    final projection = _profileForKind(entry.mediaKind);
    return projection?.entryCollectionValue(entry) ?? '';
  }

  String _entryCondition(LibraryWorkspaceContext entry) {
    final projection = _profileForKind(entry.mediaKind);
    return projection?.entryCondition(entry) ?? '';
  }

  String _entryIndexNumber(LibraryWorkspaceContext entry) {
    final projection = _profileForKind(entry.mediaKind);
    return projection?.entryIndexNumber(entry)?.toString() ?? '';
  }

  String _entryTags(LibraryWorkspaceContext entry) {
    final projection = _profileForKind(entry.mediaKind);
    return projection?.entryTags(entry) ?? '';
  }

  List<String> _kindEntryCellsAfterIndex(
    LibraryWorkspaceContext entry, {
    required bool clzFriendly,
  }) {
    final projection = _profileForKind(entry.mediaKind);
    if (projection == null) {
      return List<String>.filled(collectionCsvV1EntryCellCount, '');
    }
    final beforeLocation = projection.entryCellsBeforeLocation(
      entry,
      clzFriendly: clzFriendly,
    );
    final cells = projection.entryCellsAfterIndex(
      entry,
      clzFriendly: clzFriendly,
    );
    if (beforeLocation.length + cells.length != collectionCsvV1EntryCellCount) {
      throw StateError(
        'Collection CSV entry projection for ${projection.kind.apiValue} '
        'returned ${beforeLocation.length + cells.length} cells; expected '
        '$collectionCsvV1EntryCellCount.',
      );
    }
    return cells;
  }

  List<String> _entryToRow(
    LibraryWorkspaceContext entry, {
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<CustomFieldValue>> customFieldValuesByItem = const {},
    Map<LibraryEntryRef, LibraryEntryRecord> entryRecordsByRef = const {},
    bool includeCompleteEntry = false,
  }) {
    final cfValues = entry.libraryEntryRef != null
        ? _customFieldCells(
            entry.libraryEntryRef!.key,
            customFieldDefinitions,
            customFieldValuesByItem,
          )
        : List.filled(customFieldDefinitions.length, '');
    return [
      ..._catalogFields(entry),
      _status(entry),
      _entryCondition(entry),
      _entryCollectionValue(entry),
      _formatDate(entry.purchaseDate),
      entry.pricePaidCents?.toString() ?? '',
      entry.currency ?? entry.wishlistItem?.currency ?? '',
      entry.personalNotes ?? entry.wishlistItem?.notes ?? '',
      _locationCell(entry),
      _entryIndexNumber(entry),
      ..._kindEntryCellsAfterIndex(entry, clzFriendly: false),
      entry.trackingRating?.toString() ?? '',
      mediaTrackingStatusToStorageValue(entry.trackingStatus) ?? '',
      _formatDate(entry.trackingStartedAt),
      _formatDate(entry.trackingCompletedAt),
      _entryTags(entry),
      _formatDate(entry.soldAt),
      entry.sellPriceCents?.toString() ?? '',
      entry.soldTo ?? '',
      ...cfValues,
      _entryQuantity(entry, entryRecordsByRef),
      if (includeCompleteEntry)
        _completeEntryCell(entry, customFieldValuesByItem, entryRecordsByRef),
    ];
  }

  List<String> _entryToClzRow(
    LibraryWorkspaceContext entry, {
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<CustomFieldValue>> customFieldValuesByItem = const {},
    Map<LibraryEntryRef, LibraryEntryRecord> entryRecordsByRef = const {},
  }) {
    final cfValues = entry.libraryEntryRef != null
        ? _customFieldCells(
            entry.libraryEntryRef!.key,
            customFieldDefinitions,
            customFieldValuesByItem,
          )
        : List.filled(customFieldDefinitions.length, '');
    return [
      ..._catalogFields(entry),
      _clzStatus(entry),
      _entryCondition(entry),
      _entryCollectionValue(entry),
      _formatDate(entry.purchaseDate),
      _formatMoney(entry.pricePaidCents),
      entry.currency ?? entry.wishlistItem?.currency ?? '',
      ..._kindEntryCellsBeforeLocation(entry, clzFriendly: true),
      _locationCell(entry),
      _entryIndexNumber(entry),
      ..._kindEntryCellsAfterIndex(entry, clzFriendly: true),
      entry.trackingRating?.toString() ?? '',
      mediaTrackingStatusToStorageValue(entry.trackingStatus) ?? '',
      _formatDate(entry.trackingStartedAt),
      _formatDate(entry.trackingCompletedAt),
      _entryTags(entry),
      entry.personalNotes ?? entry.wishlistItem?.notes ?? '',
      _formatDate(entry.soldAt),
      _formatMoney(entry.sellPriceCents),
      entry.soldTo ?? '',
      ...cfValues,
    ];
  }

  String _completeEntryCell(
    LibraryWorkspaceContext entry,
    Map<String, List<CustomFieldValue>> customFieldValuesByItem,
    Map<LibraryEntryRef, LibraryEntryRecord> entryRecordsByRef,
  ) {
    final ref = entry.libraryEntryRef;
    final source = ref == null ? null : entryRecordsByRef[ref]?.toJson();
    if (source == null || ref == null) return '';
    final JsonMap payload = JsonMap.from(source);
    final JsonMap personal = JsonMap.from(
      source['personal_data'] is Map
          ? source['personal_data'] as Map
          : const <String, dynamic>{},
    );
    personal['__sync_item_images'] = [
      for (final image in entry.itemImages)
        {
          'id': image.id,
          'image_type': image.imageType,
          'image_data': base64Encode(image.imageData),
          'caption': image.caption,
          'sort_order': image.sortOrder,
          'created_at': image.createdAt.toUtc().toIso8601String(),
        },
    ];
    personal['__sync_custom_fields'] = [
      for (final field
          in customFieldValuesByItem[ref.key] ?? const <CustomFieldValue>[])
        {
          'id': field.id,
          'field_definition_id': field.fieldDefinitionId,
          'value': field.value,
          'updated_at': field.updatedAt.toUtc().toIso8601String(),
        },
    ];
    personal['__sync_external_links'] = [
      for (final link in entry.userExternalLinks) link.toJson(),
    ];
    personal[libraryEntrySyncLoansKey] = [
      for (final loan in entry.loans) loan.toJson(),
    ];
    personal[libraryEntrySyncFolderMembershipsKey] = [
      for (final membership in entry.folderMemberships)
        {
          'folder_id': membership.folderId,
          'sort_order': membership.sortOrder,
        },
    ];
    personal[libraryEntrySyncReadingQueuePositionKey] =
        entry.readingQueuePosition;
    personal[libraryEntryCsvFolderDefinitionsKey] = [
      for (final folder in entry.folderDefinitions)
        {'id': folder.id, ...folder.toSyncPayload()},
    ];
    payload['personal_data'] = personal;
    return jsonEncode(payload);
  }

  CatalogItemRef? _catalogItemRefForExport(
    LibraryWorkspaceContext entry,
    Map<LibraryEntryRef, LibraryEntryRecord> entryRecordsByRef,
  ) {
    final wishlistRef = entry.wishlistItem?.catalogRef;
    if (wishlistRef != null) {
      return wishlistRef;
    }
    final entryRef = entry.libraryEntryRef;
    if (entryRef != null) return entryRecordsByRef[entryRef]?.sourceCatalogRef;
    // A local entry owns its own identity. Its derived cache reference is not
    // provenance and must not be exported as a Core catalog target.
    return null;
  }

  String _entryQuantity(
    LibraryWorkspaceContext entry,
    Map<LibraryEntryRef, LibraryEntryRecord> entryRecordsByRef,
  ) {
    final entryRef = entry.libraryEntryRef;
    final quantity = entryRef == null
        ? null
        : entryRecordsByRef[entryRef]?.personalData['quantity'];
    return quantity is num ? quantity.toString() : '';
  }

  String _locationCell(LibraryWorkspaceContext entry) {
    return entry.locationPath ?? entry.libraryEntrySummary?.locationLabel ?? '';
  }

  List<String> _customFieldCells(
    String libraryEntryRefKey,
    List<CustomFieldDefinition> definitions,
    Map<String, List<CustomFieldValue>> valuesByItem,
  ) {
    final values = valuesByItem[libraryEntryRefKey] ?? const [];
    final byDefId = {
      for (final v in values) v.fieldDefinitionId: v.value ?? '',
    };
    return [
      for (final def in definitions) byDefId[def.id] ?? '',
    ];
  }

  String _status(LibraryWorkspaceContext entry) {
    if (entry.isEntry && entry.isWishlisted) {
      return 'both';
    }
    if (entry.isEntry) {
      return 'entry';
    }
    return 'wishlist';
  }

  String _clzStatus(LibraryWorkspaceContext entry) {
    if (entry.isEntry && entry.isWishlisted) {
      return 'In Collection + Wishlist';
    }
    if (entry.isEntry) {
      return 'In Collection';
    }
    return 'Wishlist';
  }

  List<String> _clzFriendlyHeaderForEntries(
      List<LibraryWorkspaceContext> entries) {
    final kinds = {
      for (final entry in entries)
        if (!entry.mediaKind.isUnknown) entry.mediaKind.apiValue,
    };
    if (kinds.length == 1) {
      return _clzFriendlyHeaderForKind(kinds.single);
    }
    return CollectionCsvV1Schema.clzFriendlyHeader;
  }

  List<String> _clzFriendlyHeaderForKind(String kind) {
    final mediaKind = catalogMediaKindFromApiValue(kind);
    final projection = _profileForKind(mediaKind);
    if (projection?.clzFriendlyHeader case final header?) {
      return header;
    }
    return CollectionCsvV1Schema.clzFriendlyHeader;
  }

  CollectionCsvKindProfile? _profileForKind(CatalogMediaKind kind) =>
      _profilesByKind[kind];

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
}
