class WishlistItem {
  const WishlistItem({
    required this.id,
    required this.itemId,
    this.editionId,
    this.variantId,
    this.targetPriceCents,
    this.currency,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String itemId;
  final String? editionId;
  final String? variantId;
  final int? targetPriceCents;
  final String? currency;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  WishlistItem copyWith({
    String? id,
    String? itemId,
    String? editionId,
    String? variantId,
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
      editionId: editionId ?? this.editionId,
      variantId: variantId ?? this.variantId,
      targetPriceCents: targetPriceCents ?? this.targetPriceCents,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
