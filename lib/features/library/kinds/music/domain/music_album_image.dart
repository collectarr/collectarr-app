import 'dart:typed_data';

import 'package:collectarr_app/core/models/item_image.dart';

enum MusicAlbumImagePurpose { cover, personal }

/// Locally managed image attached to one exact Music album.
///
/// Front/back artwork is distinct from personal booklet, signature, and other
/// reference images, even though both are stored in the same album-entry
/// table.
final class MusicAlbumImage implements ItemImageContent {
  const MusicAlbumImage({
    required this.id,
    required this.albumId,
    required this.purpose,
    required this.imageType,
    required this.imageData,
    required this.sortOrder,
    required this.createdAt,
    this.description,
  });

  factory MusicAlbumImage.fromItemImageContent({
    required String albumId,
    required ItemImageContent image,
  }) {
    final isPersonal = isPersonalStorageImageType(image.imageType);
    final imageType = imageTypeFromStorageValue(image.imageType);
    return MusicAlbumImage(
      id: image.id,
      albumId: albumId,
      purpose: isPersonal ||
              (imageType != 'front_cover' && imageType != 'back_cover')
          ? MusicAlbumImagePurpose.personal
          : MusicAlbumImagePurpose.cover,
      imageType: imageType,
      imageData: image.imageData,
      description: image.caption,
      sortOrder: image.sortOrder,
      createdAt: image.createdAt,
    );
  }

  static bool isPersonalStorageImageType(String value) =>
      value.startsWith('personal:');

  static String imageTypeFromStorageValue(String value) =>
      isPersonalStorageImageType(value) ? value.substring(9) : value;

  @override
  final String id;
  final String albumId;
  final MusicAlbumImagePurpose purpose;
  @override
  final String imageType;
  @override
  final Uint8List imageData;
  final String? description;
  @override
  final int sortOrder;
  @override
  final DateTime createdAt;

  @override
  String? get caption => description;

  String get storageImageType => purpose == MusicAlbumImagePurpose.cover
      ? imageType
      : 'personal:$imageType';

  MusicAlbumImage copyWith({
    String? imageType,
    Uint8List? imageData,
    Object? description = _unsetImageDescription,
    int? sortOrder,
  }) =>
      MusicAlbumImage(
        id: id,
        albumId: albumId,
        purpose: purpose,
        imageType: imageType ?? this.imageType,
        imageData: imageData ?? this.imageData,
        description: identical(description, _unsetImageDescription)
            ? this.description
            : description as String?,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt,
      );
}

const Object _unsetImageDescription = Object();
