import 'package:collectarr_app/features/collection/repositories/item_images_cache_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef LocalItemImageRequest = ({String ownedItemId, String imageType});

final localItemImageProvider =
    FutureProvider.autoDispose.family<String?, LocalItemImageRequest>((ref, request) async {
  final db = ref.watch(localDatabaseProvider);
  final image = await ItemImagesCacheRepository(db).primaryImageForItem(
    request.ownedItemId,
    imageType: request.imageType,
  );
  return image?.imageData;
});

/// Provides base64 front cover bytes for an owned item, looked up from local DB.
final localCoverImageProvider = FutureProvider.autoDispose.family<String?, String>(
  (ref, ownedItemId) async {
    return ref.watch(
      localItemImageProvider((
        ownedItemId: ownedItemId,
        imageType: 'front_cover',
      )).future,
    );
  },
);
