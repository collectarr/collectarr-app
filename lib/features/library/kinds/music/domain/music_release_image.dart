import 'dart:typed_data';

enum MusicReleaseImagePurpose {
  cover('cover'),
  personal('personal');

  const MusicReleaseImagePurpose(this.storageValue);

  final String storageValue;
}

/// Locally managed image attached to one exact Music release.
///
/// Front/back artwork is distinct from personal booklet, signature, and other
/// reference images, even though both are stored in the same release-owned
/// table.
final class MusicReleaseImage {
  const MusicReleaseImage({
    required this.id,
    required this.releaseId,
    required this.purpose,
    required this.imageType,
    required this.imageData,
    required this.sortOrder,
    required this.createdAt,
    this.description,
  });

  final String id;
  final String releaseId;
  final MusicReleaseImagePurpose purpose;
  final String imageType;
  final Uint8List imageData;
  final String? description;
  final int sortOrder;
  final DateTime createdAt;

  MusicReleaseImage copyWith({
    String? imageType,
    Uint8List? imageData,
    String? description,
    int? sortOrder,
  }) =>
      MusicReleaseImage(
        id: id,
        releaseId: releaseId,
        purpose: purpose,
        imageType: imageType ?? this.imageType,
        imageData: imageData ?? this.imageData,
        description: description ?? this.description,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt,
      );
}
