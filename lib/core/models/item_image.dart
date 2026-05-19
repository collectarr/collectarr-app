class ItemImage {
  const ItemImage({
    required this.id,
    required this.ownedItemId,
    required this.imageData,
    this.caption,
    this.sortOrder = 0,
    required this.createdAt,
  });

  final String id;
  final String ownedItemId;
  final String imageData; // base64-encoded
  final String? caption;
  final int sortOrder;
  final DateTime createdAt;

  factory ItemImage.fromJson(Map<String, dynamic> json) {
    return ItemImage(
      id: json['id'] as String,
      ownedItemId: json['owned_item_id'] as String,
      imageData: json['image_data'] as String,
      caption: json['caption'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toSyncPayload() {
    return {
      'owned_item_id': ownedItemId,
      'image_data': imageData,
      'caption': caption,
      'sort_order': sortOrder,
    };
  }

  ItemImage copyWith({
    String? id,
    String? ownedItemId,
    String? imageData,
    String? caption,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return ItemImage(
      id: id ?? this.id,
      ownedItemId: ownedItemId ?? this.ownedItemId,
      imageData: imageData ?? this.imageData,
      caption: caption ?? this.caption,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
