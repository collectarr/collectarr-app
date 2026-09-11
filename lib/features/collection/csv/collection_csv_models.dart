import 'package:collectarr_app/core/models/catalog_media_kind.dart';

class CollectionImportRow {
  const CollectionImportRow({
    required this.itemId,
    required this.status,
    this.mediaKind = CatalogMediaKind.unknown,
    this.title,
    this.personal = const CollectionImportPersonalValues(),
    this.tracking = const CollectionImportTrackingValues(),
    this.kindCatalogCells = const [],
    this.kindOwnedCells = const [],
    this.customFieldValues = const {},
  });

  final String itemId;
  final String status;

  /// Typed immediately after the CSV wire boundary. The raw API value is
  /// serialized only when writing the schema-v1 wire format.
  final CatalogMediaKind mediaKind;
  final String? title;

  /// Values decoded from the shared personal columns at the file boundary.
  ///
  /// This is deliberately a transport value object, not a common Owned or
  /// Tracking domain aggregate. Catalog and kind-owned details remain opaque
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

  /// Positional cells owned by the selected kind at the CSV serialization
  /// boundary. Collection carries them without interpreting their meaning.
  final List<String> kindOwnedCells;
  final Map<String, String?> customFieldValues;

  bool get isOwned => status == 'owned' || status == 'both';
  bool get isWishlisted => status == 'wishlist' || status == 'both';

  CollectionImportRow copyWith({
    String? itemId,
    String? status,
    CatalogMediaKind? mediaKind,
    String? title,
    CollectionImportPersonalValues? personal,
    CollectionImportTrackingValues? tracking,
    List<String>? kindCatalogCells,
    List<String>? kindOwnedCells,
    Map<String, String?>? customFieldValues,
  }) {
    return CollectionImportRow(
      itemId: itemId ?? this.itemId,
      status: status ?? this.status,
      mediaKind: mediaKind ?? this.mediaKind,
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
final class CollectionImportPersonalValues {
  const CollectionImportPersonalValues({
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
