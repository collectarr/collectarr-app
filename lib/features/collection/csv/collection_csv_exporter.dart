import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_v1_schema.dart';
import 'package:collectarr_app/features/collection/csv/csv_mechanics.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';

/// Schema-v1 collection export mechanics.
///
/// Kind projections own the meaning of catalog and kind-owned cells.
final class CollectionCsvExporter {
  String exportShelf(
    List<LibraryWorkspaceSource> entries, {
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
    List<LibraryWorkspaceSource> entries, {
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

  List<String> _catalogFields(LibraryWorkspaceSource entry) {
    final catalog = entry.catalogTransport;
    final projection = libraryCollectionCsvProjectionForKind(
      catalog?.mediaKind ?? CatalogMediaKind.unknown,
    );
    if (projection != null) {
      return _validatedCatalogCells(projection.catalogCells(entry));
    }

    // Unknown kinds get only structural catalog cells. Semantic
    // columns are supplied by a kind-owned projection when supported.
    return [
      entry.itemId,
      catalog?.mediaKind.apiValue ?? '',
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
    LibraryWorkspaceSource entry, {
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

  String _ownedCollectionValue(LibraryWorkspaceSource entry) {
    final projection = libraryCollectionCsvProjectionForKind(entry.mediaKind);
    return projection?.ownedCollectionValue(entry) ?? '';
  }

  String _ownedCondition(LibraryWorkspaceSource entry) {
    final projection = libraryCollectionCsvProjectionForKind(entry.mediaKind);
    return projection?.ownedCondition(entry) ?? '';
  }

  String _ownedIndexNumber(LibraryWorkspaceSource entry) {
    final projection = libraryCollectionCsvProjectionForKind(entry.mediaKind);
    return projection?.ownedIndexNumber(entry)?.toString() ?? '';
  }

  String _ownedTags(LibraryWorkspaceSource entry) {
    final projection = libraryCollectionCsvProjectionForKind(entry.mediaKind);
    return projection?.ownedTags(entry) ?? '';
  }

  List<String> _kindOwnedCellsAfterIndex(
    LibraryWorkspaceSource entry, {
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
    LibraryWorkspaceSource entry, {
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
    LibraryWorkspaceSource entry, {
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

  String _locationCell(LibraryWorkspaceSource entry) {
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
