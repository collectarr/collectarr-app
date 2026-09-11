import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_snapshot.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/tracking/tracking_lifecycle_codec.dart';

/// Structural cells contributed by a kind to the collection CSV host.
///
/// The collection feature owns the CSV wire layout and file mechanics. A kind
/// owns the meaning of the cells it contributes. The lists are deliberately
/// positional because the format is a serialization boundary, not a domain
/// model shared by kinds.
abstract interface class LibraryCollectionCsvProjection {
  CatalogMediaKind get kind;

  TrackingLifecycleCodec get trackingLifecycleCodec;

  String importDisplayTitle(List<String> catalogCells);

  String importDisplaySubtitle(List<String> catalogCells);

  /// Returns the kind-defined value used for title/identifier matching at the
  /// import boundary. The collection host does not call this field an issue,
  /// volume, edition or version because that meaning belongs to the kind.
  String? importPrimaryLookupValue(List<String> catalogCells);

  /// Returns the kind-defined barcode/ISBN/UPC value, when the kind supports
  /// one. The collection host only uses the normalized lookup value.
  String? importBarcode(List<String> catalogCells);

  CatalogImportSnapshot? catalogItemFromImportCells(List<String> catalogCells);

  /// Builds the kind-owned JSON payload at the CSV serialization boundary.
  ///
  /// Collection does not inspect this map. It passes it immediately to the
  /// generated kind persistence dispatcher, which decodes it into the
  /// concrete Owned aggregate and returns only a structural mutation result.
  JsonMap ownedItemImportPayload(
    LibraryCollectionCsvOwnedImport input,
  );

  /// Creates the universal lifecycle record at the CSV serialization
  /// boundary. The host supplies only structural refs and decoded lifecycle
  /// values; the owning kind decides whether this import is applicable.
  TrackingLifecycle? trackingLifecycleFromImport({
    required String entryId,
    required CatalogEntityRef catalogRef,
    required OwnedItemRef ownedRef,
    required DateTime now,
    required int? rating,
    required String? status,
    required DateTime? startedAt,
    required DateTime? finishedAt,
    TrackingLifecycle? existing,
  });

  /// The complete CLZ header for a single-kind export.

  ///
  /// A null value means that the generic host should keep its transitional
  /// header. The header is a wire-format concern, so owning it here keeps
  /// kind-specific labels and columns out of Collection.
  List<String>? get clzFriendlyHeader;

  List<String>? importCatalogCells({
    required List<String> header,
    required List<String> values,
  });

  List<String>? importOwnedCells({
    required List<String> header,
    required List<String> values,
  });

  Map<String, List<String>> get columnAliases;

  List<String> catalogCells(LibraryWorkspaceSource entry);

  /// Serializes the owning kind's collection-value column at the CSV boundary.
  ///
  /// The collection row intentionally has no canonical grade field. A kind
  /// decides whether and how its Owned aggregate contributes this column.
  String? ownedCollectionValue(LibraryWorkspaceSource entry);

  /// Schema-v1 personal cells whose meaning is owned by the selected kind.
  /// The Collection host only places these values in the wire row.
  String? ownedCondition(LibraryWorkspaceSource entry);

  int? ownedIndexNumber(LibraryWorkspaceSource entry);

  String? ownedTags(LibraryWorkspaceSource entry);

  List<String> ownedCellsBeforeQuantity(
    LibraryWorkspaceSource entry, {
    required bool clzFriendly,
  });

  List<String> ownedCellsAfterIndex(
    LibraryWorkspaceSource entry, {
    required bool clzFriendly,
  });
}

/// Values carried from the schema-v1 CSV boundary into one owning kind.
///
/// This is an import command, not a common Owned domain model. It contains
/// only transport columns shared by the file format; the owning projection
/// decides how they become its concrete Owned aggregate.
final class LibraryCollectionCsvOwnedImport {
  const LibraryCollectionCsvOwnedImport({
    required this.id,
    required this.catalogRef,
    required this.now,
    required this.kindOwnedCells,
    this.existingPayload,
    this.condition,
    this.purchaseDate,
    this.pricePaidCents,
    this.currency,
    this.personalNotes,
    this.quantity = 1,
    this.locationId,
    this.indexNumber,
    this.tags,
    this.soldAt,
    this.sellPriceCents,
    this.soldTo,
  });

  final String id;
  final CatalogEntityRef catalogRef;
  final DateTime now;
  final JsonMap? existingPayload;
  final String? condition;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? personalNotes;
  final int quantity;
  final String? locationId;
  final int? indexNumber;
  final String? tags;
  final DateTime? soldAt;
  final int? sellPriceCents;
  final String? soldTo;
  final List<String> kindOwnedCells;
}

/// Optional kind-owned decoder for the positional owned cells emitted by a
/// collection CSV projection.
///
/// The Collection host may carry these cells through its transitional row
/// model, but it must not interpret their meaning. Kinds that currently have
/// semantic owned cells implement this contract next to their CSV profile.
abstract interface class LibraryCollectionCsvOwnedDetailsDecoder {
  JsonEncodable? decodeOwnedDetails(List<String> cells);
}

/// Shared serialization-boundary mechanics for kind-owned CSV import.
///
/// The helper writes only schema-v1 personal columns. Concrete projections
/// still choose the final Owned type and decode their own kind cells.
mixin LibraryCollectionCsvOwnedImportSupport {
  JsonMap ownedItemImportPayload(
    LibraryCollectionCsvOwnedImport input,
  ) {
    final payload = collectionCsvOwnedImportPayload(input);
    final details = decodeOwnedDetails(input.kindOwnedCells);
    if (details != null) {
      payload.addAll(details.toJson());
    }
    return payload;
  }

  JsonEncodable? decodeOwnedDetails(List<String> cells);
}

Map<String, dynamic> collectionCsvOwnedImportPayload(
  LibraryCollectionCsvOwnedImport input,
) {
  final payload = input.existingPayload == null
      ? <String, dynamic>{
          'id': input.id,
          'created_at': input.now.toUtc().toIso8601String(),
          'quantity': input.quantity,
        }
      : Map<String, dynamic>.from(input.existingPayload!);

  payload['catalog_ref'] = input.catalogRef.toJson();
  payload['updated_at'] = input.now.toUtc().toIso8601String();
  if (input.condition != null) payload['condition'] = input.condition;
  if (input.purchaseDate != null) {
    payload['purchase_date'] = input.purchaseDate!.toUtc().toIso8601String();
  }
  if (input.pricePaidCents != null) {
    payload['price_paid_cents'] = input.pricePaidCents;
  }
  if (input.currency != null) payload['currency'] = input.currency;
  if (input.personalNotes != null) {
    payload['personal_notes'] = input.personalNotes;
  }
  if (input.quantity != 1 || input.existingPayload == null) {
    payload['quantity'] = input.quantity;
  }
  if (input.locationId != null) payload['location_id'] = input.locationId;
  if (input.indexNumber != null) {
    payload['index_number'] = input.indexNumber;
  }
  if (input.tags != null) payload['tags'] = input.tags;
  if (input.soldAt != null) {
    payload['sold_at'] = input.soldAt!.toUtc().toIso8601String();
  }
  if (input.sellPriceCents != null) {
    payload['sell_price_cents'] = input.sellPriceCents;
  }
  if (input.soldTo != null) payload['sold_to'] = input.soldTo;
  return payload;
}

/// Shared structural lifecycle import mechanics used by each kind-owned CSV
/// projection. Kind projections opt into this behavior explicitly; the
/// Collection import host does not construct or interpret tracking records.
mixin LibraryCollectionCsvTrackingImport
    implements LibraryCollectionCsvProjection {
  @override
  TrackingLifecycleCodec get trackingLifecycleCodec;

  @override
  TrackingLifecycle? trackingLifecycleFromImport({
    required String entryId,
    required CatalogEntityRef catalogRef,
    required OwnedItemRef ownedRef,
    required DateTime now,
    required int? rating,
    required String? status,
    required DateTime? startedAt,
    required DateTime? finishedAt,
    TrackingLifecycle? existing,
  }) {
    final resolvedStatus = mediaTrackingStatusFromValue(status);
    if (existing != null) {
      return existing.copyWith(
        catalogRef: catalogRef,
        ownedRef: ownedRef,
        status: resolvedStatus ?? existing.status,
        rating: rating ?? existing.rating,
        startedAt: startedAt ?? existing.startedAt,
        finishedAt: finishedAt ?? existing.finishedAt,
        updatedAt: now,
      );
    }
    return trackingLifecycleCodec.create(
      id: entryId,
      catalogRef: catalogRef,
      ownedRef: ownedRef,
      status: resolvedStatus ?? MediaTrackingStatus.planned,
      rating: rating,
      startedAt: startedAt,
      finishedAt: finishedAt,
      updatedAt: now,
    );
  }
}

const libraryCollectionCsvCatalogCellCount = 11;
const libraryCollectionCsvOwnedCellCount = 9;
