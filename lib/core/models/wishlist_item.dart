import 'package:collectarr_app/core/models/catalog_entity_ref.dart';

const Object _wishlistItemUnset = Object();

class WishlistItem {
  WishlistItem({
    required this.id,
    required this.catalogRef,
    this.targetPriceCents,
    this.currency,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final CatalogEntityRef catalogRef;
  final int? targetPriceCents;
  final String? currency;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  String get itemId => catalogRef.rootId ?? catalogRef.id;

  bool get isDeleted => deletedAt != null;

  Map<String, Object?> toSyncPayload() {
    return {
      'catalog_ref': catalogRef.toJson(),
      'target_price_cents': targetPriceCents,
      'currency': currency,
      'notes': notes,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  factory WishlistItem.fromJson(Map<String, Object?> json) {
    final catalogRefJson =
        Map<String, Object?>.from(json['catalog_ref'] as Map);
    return WishlistItem(
      id: json['id'] as String,
      catalogRef: CatalogEntityRef.fromJson(catalogRefJson),
      targetPriceCents: json['target_price_cents'] as int?,
      currency: json['currency'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );
  }

  WishlistItem copyWith({
    String? id,
    CatalogEntityRef? catalogRef,
    Object? targetPriceCents = _wishlistItemUnset,
    Object? currency = _wishlistItemUnset,
    Object? notes = _wishlistItemUnset,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _wishlistItemUnset,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      catalogRef: catalogRef ?? this.catalogRef,
      targetPriceCents: identical(targetPriceCents, _wishlistItemUnset)
          ? this.targetPriceCents
          : targetPriceCents as int?,
      currency: identical(currency, _wishlistItemUnset)
          ? this.currency
          : currency as String?,
      notes:
          identical(notes, _wishlistItemUnset) ? this.notes : notes as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, _wishlistItemUnset)
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }
}
