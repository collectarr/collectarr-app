import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';

const Object _wishlistItemUnset = Object();

class WishlistItem {
  WishlistItem({
    required this.id,
    CatalogEntityRef? catalogRef,
    String? itemId,
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
  })  : catalogRef = catalogRef ??
            CatalogEntityRef(
              kind: 'unknown',
              entityType: CatalogEntityType.unknown,
              id: itemId ?? '',
            ),
        anchor = anchor ??
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
    final catalogRefJson = json['catalog_ref'];
    final catalogRef = catalogRefJson is Map<String, dynamic>
        ? CatalogEntityRef.fromJson(catalogRefJson)
        : CatalogEntityRef(
            kind: 'unknown',
            entityType: CatalogEntityType.unknown,
            id: json['item_id'] as String? ?? '',
          );
    return WishlistItem(
      id: json['id'] as String,
      catalogRef: catalogRef,
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
    String? itemId,
    CatalogEntityRef? catalogRef,
    Object? anchor = _wishlistItemUnset,
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    int? targetPriceCents,
    String? currency,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
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
      catalogRef: catalogRef ??
          (itemId != null ? this.catalogRef.copyWith(id: itemId) : this.catalogRef),
      anchor: resolvedAnchor,
      targetPriceCents: targetPriceCents ?? this.targetPriceCents,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
