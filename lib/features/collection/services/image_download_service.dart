import 'dart:convert';
import 'dart:developer' as developer;

import 'package:collectarr_app/features/collection/repositories/item_images_cache_repository.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Downloads processed cover images from URLs and stores them locally.
class ImageDownloadService {
  const ImageDownloadService({
    required this.imagesRepo,
  });

  final ItemImagesCacheRepository imagesRepo;

  /// Download the cover image at [url] and store it locally for [ownedItemId].
  ///
  /// Skips silently if the URL is null/empty or if the download fails.
  /// Returns the stored base64 data, or null on failure.
  Future<String?> downloadAndStoreCover({
    required String ownedItemId,
    required String? coverImageUrl,
    String imageType = 'front_cover',
  }) async {
    if (coverImageUrl == null || coverImageUrl.isEmpty) {
      return null;
    }
    // Skip if image already cached locally for this item+type.
    final existing = await imagesRepo.primaryImageForItem(
      ownedItemId,
      imageType: imageType,
    );
    if (existing != null) {
      return existing.imageData;
    }
    try {
      final uri = Uri.tryParse(coverImageUrl);
      if (uri == null || !uri.hasScheme) {
        return null;
      }
      final response = await http.get(uri).timeout(
            const Duration(seconds: 20),
          );
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        return null;
      }
      final base64Data = base64Encode(response.bodyBytes);
      await imagesRepo.upsert(
        id: _uuid.v4(),
        ownedItemId: ownedItemId,
        imageType: imageType,
        imageData: base64Data,
      );
      return base64Data;
    } catch (error, stack) {
      developer.log(
        'Failed to download cover image',
        name: 'collectarr.images',
        error: error,
        stackTrace: stack,
      );
      return null;
    }
  }

  /// Download cover images for a batch of items.
  ///
  /// Returns a map of ownedItemId → base64 image data for successful downloads.
  Future<Map<String, String>> downloadCoversForItems(
    Map<String, String?> ownedItemIdToCoverUrl, {
    String imageType = 'front_cover',
  }) async {
    final results = <String, String>{};
    for (final entry in ownedItemIdToCoverUrl.entries) {
      final data = await downloadAndStoreCover(
        ownedItemId: entry.key,
        coverImageUrl: entry.value,
        imageType: imageType,
      );
      if (data != null) {
        results[entry.key] = data;
      }
    }
    return results;
  }
}
