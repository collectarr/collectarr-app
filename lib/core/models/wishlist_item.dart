import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';

const Object _wishlistItemUnset = Object();

class WishlistItem {
  WishlistItem({
    required this.id,
    required this.catalogRef,
    PersonalItemAnchor? anchor,
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    this.targetPriceCents,
    this.currency,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  }) : anchor = anchor ??
            PersonalItemAnchor.fromRaw(
              anchorType: anchorType,
              editionId: editionId,
              variantId: variantId,
              bundleReleaseId: bundleReleaseId,
            );

  final String id;
  final CatalogEntityRef catalogRef;
  final PersonalItemAnchor? anchor;
  final int? targetPriceCents;
  final String? currency;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  String get itemId => catalogRef.id;

  String? get anchorType => anchor?.apiValue;
  String? get editionId => anchor?.editionId;
  String? get variantId => anchor?.variantId;
  String? get bundleReleaseId => anchor?.bundleReleaseId;

  PersonalItemAnchorType? get personalAnchor => anchor?.type;

  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toSyncPayload() {
    return {
      'catalog_ref': catalogRef.toJson(),
      ...?anchor?.toSyncPayload(),
      'target_price_cents': targetPriceCents,
      'currency': currency,
      'notes': notes,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    final catalogRefJson = json['catalog_ref'] as Map<String, dynamic>;
    return WishlistItem(
      id: json['id'] as String,
      catalogRef: CatalogEntityRef.fromJson(catalogRefJson),
      anchor: PersonalItemAnchor.fromRaw(
        anchorType: json['anchor_type'] as String?,
        editionId: json['edition_id'] as String?,
        variantId: json['variant_id'] as String?,
        bundleReleaseId: json['bundle_release_id'] as String?,
      ),
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
    Object? anchor = _wishlistItemUnset,
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    Object? targetPriceCents = _wishlistItemUnset,
    Object? currency = _wishlistItemUnset,
    Object? notes = _wishlistItemUnset,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _wishlistItemUnset,
  }) {
    final resolvedAnchor = identical(anchor, _wishlistItemUnset)
        ? PersonalItemAnchor.fromRaw(
            anchorType: anchorType ?? this.anchorType,
            editionId: editionId ?? this.editionId,
            variantId: variantId ?? this.variantId,
            bundleReleaseId: bundleReleaseId ?? this.bundleReleaseId,
          )
        : anchor as PersonalItemAnchor?;

    return WishlistItem(
      id: id ?? this.id,
      catalogRef: catalogRef ?? this.catalogRef,
      anchor: resolvedAnchor,
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
