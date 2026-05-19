import 'dart:convert';

import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

/// Downloads remote cover images and stores them locally as base64 in the
/// item_images_cache table for fully offline access.
class CoverOfflineStorage {
  const CoverOfflineStorage(this._repo, this._dio);

  final ItemImageRepository _repo;
  final Dio _dio;

  static const _coverCaption = '__offline_cover__';

  /// Download the cover at [url] and store it for [ownedItemId].
  /// Returns the created [ItemImage], or null if the download failed.
  Future<ItemImage?> saveCoverOffline({
    required String ownedItemId,
    required String url,
  }) async {
    final bytes = await _downloadBytes(url);
    if (bytes == null || bytes.isEmpty) {
      return null;
    }
    // Remove existing offline cover for this item
    final existing = await _repo.listForItem(ownedItemId);
    for (final img in existing) {
      if (img.caption == _coverCaption) {
        await _repo.delete(img.id);
      }
    }
    final image = ItemImage(
      id: const Uuid().v4(),
      ownedItemId: ownedItemId,
      imageData: base64Encode(bytes),
      caption: _coverCaption,
      sortOrder: -1, // always first
      createdAt: DateTime.now(),
    );
    await _repo.add(image);
    return image;
  }

  /// Check if an offline cover exists for the given item.
  Future<String?> offlineCoverBase64(String ownedItemId) async {
    final images = await _repo.listForItem(ownedItemId);
    for (final img in images) {
      if (img.caption == _coverCaption) {
        return img.imageData;
      }
    }
    return null;
  }

  /// Remove the offline cover for the given item.
  Future<void> removeOfflineCover(String ownedItemId) async {
    final images = await _repo.listForItem(ownedItemId);
    for (final img in images) {
      if (img.caption == _coverCaption) {
        await _repo.delete(img.id);
      }
    }
  }

  Future<List<int>?> _downloadBytes(String url) async {
    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (_) {
      return null;
    }
  }
}
