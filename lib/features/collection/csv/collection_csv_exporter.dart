import 'dart:convert';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_v1_schema.dart';
import 'package:collectarr_app/features/collection/csv/csv_mechanics.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_kind_profile.dart';

/// Schema-v1 collection export mechanics.
///
/// Kind projections own the meaning of catalog and kind-owned cells.
final class CollectionCsvExporter {
  CollectionCsvExporter({required Iterable<CollectionCsvKindProfile> profiles})
      : _profilesByKind = {
          for (final profile in profiles) profile.kind: profile,
        };

  final Map<CatalogMediaKind, CollectionCsvKindProfile> _profilesByKind;

  String exportShelf(
    List<LibraryWorkspaceSource> entries, {
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<CustomFieldValue>> customFieldValuesByItem = const {},
  }) {
    final cfNames = [
      for (final def in customFieldDefinitions) 'cf_${def.name}',
    ];
    final structural = _requiresStructuralExport(entries);
    final rows = [
      [
        ...(structural ? CollectionCsvV1Schema.header : _v1Header(entries)),
        ...cfNames,
      ],
      for (final entry in entries)
        structural
            ? _entryToStructuralRow(
                entry,
                customFieldDefinitions: customFieldDefinitions,
                customFieldValuesByItem: customFieldValuesByItem,
              )
            : _entryToRow(
                entry,
                customFieldDefinitions: customFieldDefinitions,
                customFieldValuesByItem: customFieldValuesByItem,
              ),
    ];
    return const CsvWriter(lineDelimiter: '\n').write(rows);
  }

  String exportClzFriendlyShelf(
    List<LibraryWorkspaceSource> entries, {
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<CustomFieldValue>> customFieldValuesByItem = const {},
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
              )
            : _entryToClzRow(
                entry,
                customFieldDefinitions: customFieldDefinitions,
                customFieldValuesByItem: customFieldValuesByItem,
              ),
    ];
    return const CsvWriter(lineDelimiter: '\n').write(rows);
  }

  List<String> _catalogFields(LibraryWorkspaceSource entry) {
    final projection = _profileForKind(
      entry.mediaKind,
    );
    if (projection != null) {
      return _validatedCatalogCells(projection.catalogCells(entry));
    }

    // Unknown kinds get only structural catalog cells. Semantic
    // columns are supplied by a kind-owned projection when supported.
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
      _formatDate(entry.catalogData?.releaseDate),
      '',
    ];
  }

  List<String> _entryToStructuralRow(
    LibraryWorkspaceSource entry, {
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<CustomFieldValue>> customFieldValuesByItem = const {},
  }) {
    final customFields = entry.ownedRef == null
        ? List<String>.filled(customFieldDefinitions.length, '')
        : _customFieldCells(
            entry.ownedRef!.key,
            customFieldDefinitions,
            customFieldValuesByItem,
          );
    return [
      entry.catalogRef == null ? '' : jsonEncode(entry.catalogRef!.toJson()),
      entry.mediaKind.apiValue,
      entry.title,
      _status(entry),
      entry.quantity.toString(),
      _locationCell(entry),
      entry.personalNotes ?? entry.wishlistItem?.notes ?? '',
      ...customFields,
    ];
  }

  List<String> _v1Header(List<LibraryWorkspaceSource> entries) {
    final kinds = {
      for (final entry in entries)
        if (!entry.mediaKind.isUnknown) entry.mediaKind,
    };
    if (kinds.length != 1) return CollectionCsvV1Schema.header;
    return _profileForKind(kinds.single)?.v1Header ??
        CollectionCsvV1Schema.header;
  }

  bool _requiresStructuralExport(List<LibraryWorkspaceSource> entries) {
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

  List<String> _kindOwnedCellsBeforeQuantity(
    LibraryWorkspaceSource entry, {
    required bool clzFriendly,
  }) {
    final projection = _profileForKind(entry.mediaKind);
    if (projection == null) {
      return clzFriendly ? const [''] : const [];
    }
    final cells = projection.ownedCellsBeforeQuantity(
      entry,
      clzFriendly: clzFriendly,
    );
    return cells;
  }

  String _ownedCollectionValue(LibraryWorkspaceSource entry) {
    final projection = _profileForKind(entry.mediaKind);
    return projection?.ownedCollectionValue(entry) ?? '';
  }

  String _ownedCondition(LibraryWorkspaceSource entry) {
    final projection = _profileForKind(entry.mediaKind);
    return projection?.ownedCondition(entry) ?? '';
  }

  String _ownedIndexNumber(LibraryWorkspaceSource entry) {
    final projection = _profileForKind(entry.mediaKind);
    return projection?.ownedIndexNumber(entry)?.toString() ?? '';
  }

  String _ownedTags(LibraryWorkspaceSource entry) {
    final projection = _profileForKind(entry.mediaKind);
    return projection?.ownedTags(entry) ?? '';
  }

  List<String> _kindOwnedCellsAfterIndex(
    LibraryWorkspaceSource entry, {
    required bool clzFriendly,
  }) {
    final projection = _profileForKind(entry.mediaKind);
    if (projection == null) {
      return List<String>.filled(
        clzFriendly
            ? collectionCsvV1OwnedCellCount - 1
            : collectionCsvV1OwnedCellCount,
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
    if (beforeQuantity.length + cells.length != collectionCsvV1OwnedCellCount) {
      throw StateError(
        'Collection CSV owned projection for ${projection.kind.apiValue} '
        'returned ${beforeQuantity.length + cells.length} cells; expected '
        '$collectionCsvV1OwnedCellCount.',
      );
    }
    return cells;
  }

  List<String> _entryToRow(
    LibraryWorkspaceSource entry, {
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<CustomFieldValue>> customFieldValuesByItem = const {},
  }) {
    final cfValues = entry.ownedRef != null
        ? _customFieldCells(
            entry.ownedRef!.key,
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
    LibraryWorkspaceSource entry, {
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<CustomFieldValue>> customFieldValuesByItem = const {},
  }) {
    final cfValues = entry.ownedRef != null
        ? _customFieldCells(
            entry.ownedRef!.key,
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

  String _locationCell(LibraryWorkspaceSource entry) {
    return entry.locationPath ?? entry.ownedSummary?.locationLabel ?? '';
  }

  List<String> _customFieldCells(
    String ownedRefKey,
    List<CustomFieldDefinition> definitions,
    Map<String, List<CustomFieldValue>> valuesByItem,
  ) {
    final values = valuesByItem[ownedRefKey] ?? const [];
    final byDefId = {
      for (final v in values) v.fieldDefinitionId: v.value ?? '',
    };
    return [
      for (final def in definitions) byDefId[def.id] ?? '',
    ];
  }

  String _status(LibraryWorkspaceSource entry) {
    if (entry.isOwned && entry.isWishlisted) {
      return 'both';
    }
    if (entry.isOwned) {
      return 'owned';
    }
    return 'wishlist';
  }

  String _clzStatus(LibraryWorkspaceSource entry) {
    if (entry.isOwned && entry.isWishlisted) {
      return 'In Collection + Wishlist';
    }
    if (entry.isOwned) {
      return 'In Collection';
    }
    return 'Wishlist';
  }

  List<String> _clzFriendlyHeaderForEntries(
      List<LibraryWorkspaceSource> entries) {
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
    final mediaKind = catalogMediaKindFromValue(kind);
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
