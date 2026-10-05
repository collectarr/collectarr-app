import 'dart:typed_data';

enum MusicAlbumImagePurpose {
  cover('cover'),
  personal('personal');

  const MusicAlbumImagePurpose(this.storageValue);

  final String storageValue;
}

/// Locally managed image attached to one exact Music album.
///
/// Front/back artwork is distinct from personal booklet, signature, and other
/// reference images, even though both are stored in the same album-entry
/// table.
final class MusicAlbumImage {
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

  final String id;
  final String albumId;
  final MusicAlbumImagePurpose purpose;
  final String imageType;
  final Uint8List imageData;
  final String? description;
  final int sortOrder;
  final DateTime createdAt;

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
