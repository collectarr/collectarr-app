class ItemImage {
  const ItemImage({
    required this.id,
    required this.ownedItemId,
    this.imageType = 'front_cover',
    required this.imageData,
    this.caption,
    this.sortOrder = 0,
    required this.createdAt,
  });

  final String id;
  final String ownedItemId;
  final String imageType; // front_cover, back_cover, auxiliary
  final String imageData; // base64-encoded
  final String? caption;
  final int sortOrder;
  final DateTime createdAt;

  factory ItemImage.fromJson(Map<String, dynamic> json) {
    return ItemImage(
      id: json['id'] as String,
      ownedItemId: json['owned_item_id'] as String,
      imageType: json['image_type'] as String? ?? 'front_cover',
      imageData: json['image_data'] as String,
      caption: json['caption'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toSyncPayload() {
    return {
      'owned_item_id': ownedItemId,
      'image_type': imageType,
      'image_data': imageData,
      'caption': caption,
      'sort_order': sortOrder,
    };
  }

  ItemImage copyWith({
    String? id,
    String? ownedItemId,
    String? imageType,
    String? imageData,
    String? caption,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return ItemImage(
      id: id ?? this.id,
      ownedItemId: ownedItemId ?? this.ownedItemId,
      imageType: imageType ?? this.imageType,
      imageData: imageData ?? this.imageData,
      caption: caption ?? this.caption,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
