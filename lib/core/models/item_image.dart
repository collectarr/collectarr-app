import 'dart:convert';
import 'dart:typed_data';

import 'package:collectarr_app/core/models/owned_item_projection.dart';

class ItemImage {
  const ItemImage({
    required this.id,
    required this.ownedRef,
    this.imageType = 'front_cover',
    required this.imageData,
    this.caption,
    this.sortOrder = 0,
    required this.createdAt,
  });

  final String id;
  final OwnedItemRef ownedRef;
  final String imageType; // front_cover, back_cover, auxiliary
  final Uint8List imageData;
  final String? caption;
  final int sortOrder;
  final DateTime createdAt;

  factory ItemImage.fromJson(Map<String, Object?> json) {
    return ItemImage(
      id: json['id'] as String,
      ownedRef: ownedItemRefFromSerialized(json['owned_ref'])!,
      imageType: json['image_type'] as String? ?? 'front_cover',
      imageData: base64Decode(json['image_data'] as String),
      caption: json['caption'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, Object?> toSyncPayload() {
    return {
      'owned_ref': ownedRef.toJson(),
      'image_type': imageType,
      'image_data': base64Encode(imageData),
      'caption': caption,
      'sort_order': sortOrder,
    };
  }

  ItemImage copyWith({
    String? id,
    OwnedItemRef? ownedRef,
    String? imageType,
    Uint8List? imageData,
    String? caption,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return ItemImage(
      id: id ?? this.id,
      ownedRef: ownedRef ?? this.ownedRef,
      imageType: imageType ?? this.imageType,
      imageData: imageData ?? this.imageData,
      caption: caption ?? this.caption,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
