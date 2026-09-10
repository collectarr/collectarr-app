import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';

/// Test-only fixture used by mixed-kind tests while constructing the concrete
/// kind aggregate is not the subject of the test.
///
/// This intentionally lives under `lib/test` and is never used by
/// production code. It is not a domain model or a compatibility API.
final class TestOwnedItem {
  const TestOwnedItem({
    required this.id,
    required this.catalogRef,
    required this.details,
    this.createdAt,
    this.isDigital,
    this.targetRef,
    this.condition,
    this.collectionValue,
    this.purchaseDate,
    this.pricePaidCents,
    this.currency,
    this.personalNotes,
    this.quantity = 1,
    this.indexNumber,
    this.tags,
    required this.updatedAt,
    this.deletedAt,
    this.soldAt,
    this.sellPriceCents,
    this.soldTo,
    this.ownerUserId,
    this.ownerLabel,
    this.locationId,
    this.purchaseStore,
    this.collectionStatus,
    this.marketValueCents,
  });

  final String id;
  final CatalogEntityRef catalogRef;
  final DateTime? createdAt;
  final bool? isDigital;
  final CatalogEntityRef? targetRef;
  final String? condition;
  final String? collectionValue;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? personalNotes;
  final int quantity;
  final int? indexNumber;
  final String? tags;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? soldAt;
  final int? sellPriceCents;
  final String? soldTo;
  final String? ownerUserId;
  final String? ownerLabel;
  final String? locationId;
  final String? purchaseStore;
  final String? collectionStatus;
  final int? marketValueCents;
  final JsonEncodable details;

  String get itemId => catalogRef.id;

  OwnedItemRef get ref => OwnedItemRef(
        kind: catalogRef.mediaKind,
        id: OwnedItemId(id),
      );

  JsonMap toSyncPayload() => {
        'catalog_ref': catalogRef.toJson(),
        if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
        if (isDigital != null) 'is_digital': isDigital,
        'target_ref': targetRef?.toJson(),
        'condition': condition,
        'grade': collectionValue,
        'purchase_date': purchaseDate?.toUtc().toIso8601String(),
        'price_paid_cents': pricePaidCents,
        'currency': currency,
        'personal_notes': personalNotes,
        'quantity': quantity,
        'index_number': indexNumber,
        'tags': tags,
        'sold_at': soldAt?.toUtc().toIso8601String(),
        'sell_price_cents': sellPriceCents,
        'sold_to': soldTo,
        if (ownerUserId != null) 'owner_user_id': ownerUserId,
        if (ownerLabel != null) 'owner_label': ownerLabel,
        'location_id': locationId,
        if (purchaseStore != null) 'purchase_store': purchaseStore,
        if (collectionStatus != null) 'collection_status': collectionStatus,
        if (marketValueCents != null) 'market_value_cents': marketValueCents,
        ...details.toJson(),
      };

  JsonMap toJson() => {
        'id': id,
        'catalog_ref': catalogRef.toJson(),
        'created_at': createdAt?.toUtc().toIso8601String(),
        'is_digital': isDigital,
        'target_ref': targetRef?.toJson(),
        'condition': condition,
        'grade': collectionValue,
        'purchase_date': purchaseDate?.toUtc().toIso8601String(),
        'price_paid_cents': pricePaidCents,
        'currency': currency,
        'personal_notes': personalNotes,
        'quantity': quantity,
        'index_number': indexNumber,
        'tags': tags,
        'updated_at': updatedAt.toUtc().toIso8601String(),
        'deleted_at': deletedAt?.toUtc().toIso8601String(),
        'sold_at': soldAt?.toUtc().toIso8601String(),
        'sell_price_cents': sellPriceCents,
        'sold_to': soldTo,
        'owner_user_id': ownerUserId,
        'owner_label': ownerLabel,
        'location_id': locationId,
        'purchase_store': purchaseStore,
        'collection_status': collectionStatus,
        'market_value_cents': marketValueCents,
        ...details.toJson(),
      };
}
