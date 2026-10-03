import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';

class CollectionImportRow {
  const CollectionImportRow({
    required this.itemId,
    required this.status,
    this.catalogItemRef,
    this.mediaKind = CatalogMediaKind.unknown,
    this.title,
    this.kindDisplayTitle,
    this.kindDisplaySubtitle,
    this.kindIdentifier,
    this.personal = const CollectionImportPersonalValues(),
    this.tracking = const CollectionImportTrackingValues(),
    this.kindCatalogCells = const [],
    this.kindEntryCells = const [],
    this.customFieldValues = const {},
    this.fullEntryPayload,
  });

  final String itemId;
  final String status;

  /// Optional Core Catalog Item reference (wishlist target or source hint).
  /// A local entry's identity is carried only by `library_entry_json.id`.
  final CatalogItemRef? catalogItemRef;

  /// Typed immediately after the CSV wire boundary. The raw API value is
  /// serialized only when writing the schema-v1 wire format.
  final CatalogMediaKind mediaKind;
  final String? title;

  /// Kind-entry preview values prepared while decoding the CSV boundary.
  ///
  /// Collection UI can display and search these values without importing or
  /// interpreting a kind CSV profile itself.
  final String? kindDisplayTitle;
  final String? kindDisplaySubtitle;
  final String? kindIdentifier;

  /// Values decoded from the shared personal columns at the file boundary.
  ///
  /// This is deliberately a transport value object, not a common Entry or
  /// Tracking domain aggregate. Catalog and kind-entry details remain opaque
  /// positional cells and are interpreted only by the owning kind profile.
  final CollectionImportPersonalValues personal;

  /// Tracking values decoded at the file boundary. The import host forwards
  /// them to the selected kind's tracking integration and does not turn them
  /// into a universal tracking domain object here.
  final CollectionImportTrackingValues tracking;

  /// Positional catalog cells contributed by the selected kind at the CSV
  /// serialization boundary. Collection carries them without interpreting
  /// their meaning.
  final List<String> kindCatalogCells;

  /// Positional cells entry by the selected kind at the CSV serialization
  /// boundary. Collection carries them without interpreting their meaning.
  final List<String> kindEntryCells;
  final Map<String, String?> customFieldValues;
  final Map<String, dynamic>? fullEntryPayload;

  bool get isEntry => status == 'entry' || status == 'both';
  bool get isWishlisted => status == 'wishlist' || status == 'both';

  CollectionImportRow copyWith({
    String? itemId,
    String? status,
    CatalogItemRef? catalogItemRef,
    CatalogMediaKind? mediaKind,
    String? title,
    String? kindDisplayTitle,
    String? kindDisplaySubtitle,
    String? kindIdentifier,
    CollectionImportPersonalValues? personal,
    CollectionImportTrackingValues? tracking,
    List<String>? kindCatalogCells,
    List<String>? kindEntryCells,
    Map<String, String?>? customFieldValues,
    Map<String, dynamic>? fullEntryPayload,
  }) {
    return CollectionImportRow(
      itemId: itemId ?? this.itemId,
      status: status ?? this.status,
      catalogItemRef: catalogItemRef ?? this.catalogItemRef,
      mediaKind: mediaKind ?? this.mediaKind,
      title: title ?? this.title,
      kindDisplayTitle: kindDisplayTitle ?? this.kindDisplayTitle,
      kindDisplaySubtitle: kindDisplaySubtitle ?? this.kindDisplaySubtitle,
      kindIdentifier: kindIdentifier ?? this.kindIdentifier,
      personal: personal ?? this.personal,
      tracking: tracking ?? this.tracking,
      kindCatalogCells: kindCatalogCells ?? this.kindCatalogCells,
      kindEntryCells: kindEntryCells ?? this.kindEntryCells,
      customFieldValues: customFieldValues ?? this.customFieldValues,
      fullEntryPayload: fullEntryPayload ?? this.fullEntryPayload,
    );
  }
}

/// Shared personal CSV columns represented as a serialization-boundary value.
///
/// The object is intentionally not reusable as a domain model. Import code
/// may carry these values until it dispatches to the selected kind's typed
/// mutation/codec.
final class CollectionImportPersonalValues {
  const CollectionImportPersonalValues({
    this.condition,
    this.purchaseDate,
    this.pricePaidCents,
    this.currency,
    this.notes,
    this.locationId,
    this.indexNumber,
    this.tags,
    this.soldAt,
    this.sellPriceCents,
    this.soldTo,
    this.quantity,
  });

  final String? condition;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? notes;
  final String? locationId;
  final int? indexNumber;
  final String? tags;
  final DateTime? soldAt;
  final int? sellPriceCents;
  final String? soldTo;
  final int? quantity;

  bool get isEmpty =>
      condition == null &&
      purchaseDate == null &&
      pricePaidCents == null &&
      currency == null &&
      notes == null &&
      locationId == null &&
      indexNumber == null &&
      tags == null &&
      soldAt == null &&
      sellPriceCents == null &&
      soldTo == null &&
      quantity == null;
}

final class CollectionImportTrackingValues {
  const CollectionImportTrackingValues({
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
