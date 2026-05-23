import 'package:collectarr_app/core/models/personal_item_anchor.dart';

class WishlistItem {
  const WishlistItem({
    required this.id,
    required this.itemId,
    this.anchorType,
    this.editionId,
    this.variantId,
    this.bundleReleaseId,
    this.targetPriceCents,
    this.currency,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String itemId;
  final String? anchorType;
  final String? editionId;
  final String? variantId;
  final String? bundleReleaseId;
  final int? targetPriceCents;
  final String? currency;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  PersonalItemAnchorType? get personalAnchor =>
      PersonalItemAnchorType.fromApiValue(
        normalizePersonalItemAnchorType(anchorType) ??
            _inferredAnchorType?.apiValue,
      );

  PersonalItemAnchorType? get _inferredAnchorType {
    if (bundleReleaseId != null && bundleReleaseId!.trim().isNotEmpty) {
      return PersonalItemAnchorType.bundleRelease;
    }
    if ((editionId != null && editionId!.trim().isNotEmpty) ||
        (variantId != null && variantId!.trim().isNotEmpty)) {
      return PersonalItemAnchorType.variant;
    }
    return PersonalItemAnchorType.item;
  }

  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toSyncPayload() {
    return {
      'item_id': itemId,
        'anchor_type':
          normalizePersonalItemAnchorType(anchorType) ?? _inferredAnchorType?.apiValue,
      'edition_id': editionId,
      'variant_id': variantId,
        'bundle_release_id': bundleReleaseId,
      'target_price_cents': targetPriceCents,
      'currency': currency,
      'notes': notes,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      anchorType: normalizePersonalItemAnchorType(json['anchor_type'] as String?),
      editionId: json['edition_id'] as String?,
      variantId: json['variant_id'] as String?,
      bundleReleaseId: json['bundle_release_id'] as String?,
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
    return WishlistItem(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      anchorType: anchorType ?? this.anchorType,
      editionId: editionId ?? this.editionId,
      variantId: variantId ?? this.variantId,
      bundleReleaseId: bundleReleaseId ?? this.bundleReleaseId,
      targetPriceCents: targetPriceCents ?? this.targetPriceCents,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
