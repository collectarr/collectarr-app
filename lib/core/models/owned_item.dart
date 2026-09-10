import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';

export 'package:collectarr_app/core/models/money.dart';
export 'package:collectarr_app/core/models/json_encodable.dart';

const Object _ownedItemUnset = Object();

class OwnedItem<TDetails extends JsonEncodable> {
  OwnedItem({
    required this.id,
    required this.catalogRef,
    this.createdAt,
    this.isDigital,
    CatalogEntityRef? targetRef,
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    required TDetails this.details,
    this.condition,
    this.grade,
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
  }) : targetRef = targetRef ??
            _targetRefFromLegacy(
              catalogRef,
              anchorType: anchorType,
              editionId: editionId,
              variantId: variantId,
              bundleReleaseId: bundleReleaseId,
            );

  final String id;
  final CatalogEntityRef catalogRef;
  final DateTime? createdAt;
  final bool? isDigital;

  /// Canonical in-memory target for this owned copy.
  ///
  /// The v1 anchor fields are intentionally not stored as a second domain
  /// representation. They are reconstructed only by the compatibility
  /// accessors and serializers below.
  final CatalogEntityRef? targetRef;
  final String? condition;
  final String? grade;
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
  final TDetails details;

  String get itemId => catalogRef.id;

  OwnedItemRef get ref => OwnedItemRef(
        kind: catalogRef.mediaKind,
        id: OwnedItemId(id),
      );

  OwnedItemId get typedId => OwnedItemId(id);
  Money? get pricePaid => Money.fromCents(pricePaidCents, currency);
  Money? get sellPrice => Money.fromCents(sellPriceCents, currency);
  Money? get marketValue => Money.fromCents(marketValueCents, currency);

  String? get anchorType => _legacyAnchorTypeFromTarget(targetRef);
  String? get editionId => _legacyEditionIdFromTarget(targetRef);
  String? get variantId => _legacyVariantIdFromTarget(targetRef);
  String? get bundleReleaseId => _legacyBundleReleaseIdFromTarget(targetRef);

  bool get isDeleted => deletedAt != null;
  bool get isSold => soldAt != null;

  Map<String, dynamic> toSyncPayload() {
    return {
      'catalog_ref': catalogRef.toJson(),
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if (isDigital != null) 'is_digital': isDigital,
      ..._legacyTargetPayload(targetRef),
      'condition': condition,
      'grade': grade,
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
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'catalog_ref': catalogRef.toJson(),
      'created_at': createdAt?.toUtc().toIso8601String(),
      'is_digital': isDigital,
      'anchor_type': anchorType,
      'edition_id': editionId,
      'variant_id': variantId,
      'bundle_release_id': bundleReleaseId,
      'condition': condition,
      'grade': grade,
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
      if (ownerLabel != null) 'owner_label': ownerLabel,
      'location_id': locationId,
      if (purchaseStore != null) 'purchase_store': purchaseStore,
      if (collectionStatus != null) 'collection_status': collectionStatus,
      if (marketValueCents != null) 'market_value_cents': marketValueCents,
      ...details.toJson(),
    };
  }

  factory OwnedItem.fromJson(
    Map<String, dynamic> json, {
    required TDetails Function(Map<String, dynamic> json) decodeDetails,
  }) {
    final catalogRefJson = json['catalog_ref'] as Map<String, dynamic>;
    final catalogRef = CatalogEntityRef.fromJson(catalogRefJson);
    final details = decodeDetails(json);

    return OwnedItem<TDetails>(
      id: json['id'] as String,
      catalogRef: catalogRef,
      details: details as TDetails,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      isDigital: json['is_digital'] as bool?,
      targetRef: _targetRefFromLegacy(
        catalogRef,
        anchorType: json['anchor_type'] as String?,
        editionId: json['edition_id'] as String?,
        variantId: json['variant_id'] as String?,
        bundleReleaseId: json['bundle_release_id'] as String?,
      ),
      condition: json['condition'] as String?,
      grade: json['grade'] as String?,
      purchaseDate: json['purchase_date'] == null
          ? null
          : DateTime.parse(json['purchase_date'] as String),
      pricePaidCents: json['price_paid_cents'] as int?,
      currency: json['currency'] as String?,
      personalNotes: json['personal_notes'] as String?,
      quantity: json['quantity'] as int? ?? 1,
      indexNumber: json['index_number'] as int?,
      tags: json['tags'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      soldAt: json['sold_at'] == null
          ? null
          : DateTime.parse(json['sold_at'] as String),
      sellPriceCents: json['sell_price_cents'] as int?,
      soldTo: json['sold_to'] as String?,
      ownerUserId: json['owner_user_id'] as String?,
      ownerLabel: json['owner_label'] as String?,
      locationId: json['location_id'] as String?,
      purchaseStore: json['purchase_store'] as String?,
      collectionStatus: json['collection_status'] as String?,
      marketValueCents: json['market_value_cents'] as int?,
    );
  }

  OwnedItem copyWith({
    String? id,
    CatalogEntityRef? catalogRef,
    Object? createdAt = _ownedItemUnset,
    Object? isDigital = _ownedItemUnset,
    Object? targetRef = _ownedItemUnset,
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    TDetails? details,
    Object? condition = _ownedItemUnset,
    Object? grade = _ownedItemUnset,
    Object? purchaseDate = _ownedItemUnset,
    Object? pricePaidCents = _ownedItemUnset,
    Object? currency = _ownedItemUnset,
    Object? personalNotes = _ownedItemUnset,
    int? quantity,
    Object? indexNumber = _ownedItemUnset,
    Object? tags = _ownedItemUnset,
    DateTime? updatedAt,
    Object? deletedAt = _ownedItemUnset,
    Object? soldAt = _ownedItemUnset,
    Object? sellPriceCents = _ownedItemUnset,
    Object? soldTo = _ownedItemUnset,
    Object? ownerUserId = _ownedItemUnset,
    Object? ownerLabel = _ownedItemUnset,
    Object? locationId = _ownedItemUnset,
    Object? purchaseStore = _ownedItemUnset,
    Object? collectionStatus = _ownedItemUnset,
    Object? marketValueCents = _ownedItemUnset,
  }) {
    final resolvedTargetRef = identical(targetRef, _ownedItemUnset)
        ? _targetRefFromLegacy(
            catalogRef ?? this.catalogRef,
            anchorType: anchorType ?? this.anchorType,
            editionId: editionId ?? this.editionId,
            variantId: variantId ?? this.variantId,
            bundleReleaseId: bundleReleaseId ?? this.bundleReleaseId,
          )
        : targetRef as CatalogEntityRef?;

    return OwnedItem<TDetails>(
      id: id ?? this.id,
      catalogRef: catalogRef ?? this.catalogRef,
      createdAt: identical(createdAt, _ownedItemUnset)
          ? this.createdAt
          : createdAt as DateTime?,
      isDigital: identical(isDigital, _ownedItemUnset)
          ? this.isDigital
          : isDigital as bool?,
      targetRef: resolvedTargetRef,
      details: details ?? this.details,
      condition: identical(condition, _ownedItemUnset)
          ? this.condition
          : condition as String?,
      grade: identical(grade, _ownedItemUnset) ? this.grade : grade as String?,
      purchaseDate: identical(purchaseDate, _ownedItemUnset)
          ? this.purchaseDate
          : purchaseDate as DateTime?,
      pricePaidCents: identical(pricePaidCents, _ownedItemUnset)
          ? this.pricePaidCents
          : pricePaidCents as int?,
      currency: identical(currency, _ownedItemUnset)
          ? this.currency
          : currency as String?,
      personalNotes: identical(personalNotes, _ownedItemUnset)
          ? this.personalNotes
          : personalNotes as String?,
      quantity: quantity ?? this.quantity,
      indexNumber: identical(indexNumber, _ownedItemUnset)
          ? this.indexNumber
          : indexNumber as int?,
      tags: identical(tags, _ownedItemUnset) ? this.tags : tags as String?,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, _ownedItemUnset)
          ? this.deletedAt
          : deletedAt as DateTime?,
      soldAt: identical(soldAt, _ownedItemUnset)
          ? this.soldAt
          : soldAt as DateTime?,
      sellPriceCents: identical(sellPriceCents, _ownedItemUnset)
          ? this.sellPriceCents
          : sellPriceCents as int?,
      soldTo:
          identical(soldTo, _ownedItemUnset) ? this.soldTo : soldTo as String?,
      ownerUserId: identical(ownerUserId, _ownedItemUnset)
          ? this.ownerUserId
          : ownerUserId as String?,
      ownerLabel: identical(ownerLabel, _ownedItemUnset)
          ? this.ownerLabel
          : ownerLabel as String?,
      locationId: identical(locationId, _ownedItemUnset)
          ? this.locationId
          : locationId as String?,
      purchaseStore: identical(purchaseStore, _ownedItemUnset)
          ? this.purchaseStore
          : purchaseStore as String?,
      collectionStatus: identical(collectionStatus, _ownedItemUnset)
          ? this.collectionStatus
          : collectionStatus as String?,
      marketValueCents: identical(marketValueCents, _ownedItemUnset)
          ? this.marketValueCents
          : marketValueCents as int?,
    );
  }
}

CatalogEntityRef? _targetRefFromLegacy(
  CatalogEntityRef catalogRef, {
  String? anchorType,
  String? editionId,
  String? variantId,
  String? bundleReleaseId,
}) {
  final normalizedType = anchorType?.trim().toLowerCase();
  final rootId = catalogRef.rootId ?? catalogRef.id;
  if (normalizedType == 'item') {
    return catalogRef.copyWith(
      id: rootId,
      entityType: const CatalogEntityTypeId('work'),
      rootId: null,
    );
  }
  if (bundleReleaseId != null || normalizedType == 'bundle_release') {
    return bundleReleaseId == null
        ? null
        : CatalogEntityRef(
            kind: catalogRef.kind,
            entityType: const CatalogEntityTypeId('bundle_release'),
            id: bundleReleaseId,
            rootId: rootId,
          );
  }
  if (variantId != null || normalizedType == 'variant') {
    return variantId == null
        ? editionId == null
            ? null
            : CatalogEntityRef(
                kind: catalogRef.kind,
                entityType: const CatalogEntityTypeId('edition'),
                id: editionId,
                rootId: rootId,
              )
        : CatalogEntityRef(
            kind: catalogRef.kind,
            entityType: const CatalogEntityTypeId('release'),
            id: variantId,
            rootId: rootId,
            parentId: editionId,
          );
  }
  if (editionId != null || normalizedType == 'edition') {
    return editionId == null
        ? null
        : CatalogEntityRef(
            kind: catalogRef.kind,
            entityType: const CatalogEntityTypeId('edition'),
            id: editionId,
            rootId: rootId,
          );
  }
  return null;
}

Map<String, Object?> _legacyTargetPayload(CatalogEntityRef? targetRef) {
  if (targetRef == null) return const <String, Object?>{};
  return {
    'anchor_type': _legacyAnchorTypeFromTarget(targetRef),
    'edition_id': _legacyEditionIdFromTarget(targetRef),
    'variant_id': _legacyVariantIdFromTarget(targetRef),
    'bundle_release_id': _legacyBundleReleaseIdFromTarget(targetRef),
  };
}

String? _legacyAnchorTypeFromTarget(CatalogEntityRef? targetRef) {
  if (targetRef == null) return null;
  return switch (targetRef.entityType.apiValue) {
    'edition' => 'edition',
    'release' => 'variant',
    'bundle_release' => 'bundle_release',
    _ => 'item',
  };
}

String? _legacyEditionIdFromTarget(CatalogEntityRef? targetRef) {
  return switch (targetRef?.entityType.apiValue) {
    'edition' => targetRef?.id,
    'release' => targetRef?.parentId,
    _ => null,
  };
}

String? _legacyVariantIdFromTarget(CatalogEntityRef? targetRef) {
  return targetRef?.entityType.apiValue == 'release' ? targetRef?.id : null;
}

String? _legacyBundleReleaseIdFromTarget(CatalogEntityRef? targetRef) {
  return targetRef?.entityType.apiValue == 'bundle_release'
      ? targetRef?.id
      : null;
}
