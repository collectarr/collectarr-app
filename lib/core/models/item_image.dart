import 'dart:convert';
import 'dart:typed_data';

import 'package:collectarr_app/core/models/library_entry_projection.dart';

abstract interface class ItemImageContent {
  String get id;
  String get imageType;
  Uint8List get imageData;
  String? get caption;
  int get sortOrder;
  DateTime get createdAt;
}

/// Persisted personal image entry by one Collection Item.
class ItemImage implements ItemImageContent {
  const ItemImage({
    required this.id,
    required this.libraryEntryRef,
    this.imageType = 'front_cover',
    required this.imageData,
    this.caption,
    this.sortOrder = 0,
    required this.createdAt,
  });

  final String id;
  final LibraryEntryRef libraryEntryRef;
  final String imageType; // front_cover, back_cover, auxiliary
  final Uint8List imageData;
  final String? caption;
  final int sortOrder;
  final DateTime createdAt;

  factory ItemImage.fromJson(Map<String, Object?> json) {
    return ItemImage(
      id: json['id'] as String,
      libraryEntryRef:
          libraryEntryRefFromSerialized(json['library_entry_ref'])!,
      imageType: json['image_type'] as String? ?? 'front_cover',
      imageData: base64Decode(json['image_data'] as String),
      caption: json['caption'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, Object?> toSyncPayload() {
    return {
      'library_entry_ref': libraryEntryRef.toJson(),
      'image_type': imageType,
      'image_data': base64Encode(imageData),
      'caption': caption,
      'sort_order': sortOrder,
    };
  }

  ItemImage copyWith({
    String? id,
    LibraryEntryRef? libraryEntryRef,
    String? imageType,
    Uint8List? imageData,
    String? caption,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return ItemImage(
      id: id ?? this.id,
      libraryEntryRef: libraryEntryRef ?? this.libraryEntryRef,
      imageType: imageType ?? this.imageType,
      imageData: imageData ?? this.imageData,
      caption: caption ?? this.caption,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Image data edited during manual Add before a Collection Item exists.
///
/// This deliberately has no owner reference. The Add flow binds the image to
/// the newly created Collection Item only after its identity is known.
class ItemImageDraft implements ItemImageContent {
  const ItemImageDraft({
    required this.id,
    this.imageType = 'front_cover',
    required this.imageData,
    this.caption,
    this.sortOrder = 0,
    required this.createdAt,
  });

  factory ItemImageDraft.fromImage(ItemImage image) => ItemImageDraft(
        id: image.id,
        imageType: image.imageType,
        imageData: image.imageData,
        caption: image.caption,
        sortOrder: image.sortOrder,
        createdAt: image.createdAt,
      );

  @override
  final String id;
  @override
  final String imageType;
  @override
  final Uint8List imageData;
  @override
  final String? caption;
  @override
  final int sortOrder;
  @override
  final DateTime createdAt;

  ItemImage toEntryImage(LibraryEntryRef libraryEntryRef) => ItemImage(
        id: id,
        libraryEntryRef: libraryEntryRef,
        imageType: imageType,
        imageData: imageData,
        caption: caption,
        sortOrder: sortOrder,
        createdAt: createdAt,
      );
}
