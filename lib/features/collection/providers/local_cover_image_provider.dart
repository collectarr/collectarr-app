import 'dart:typed_data';

import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/collection/repositories/item_images_cache_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef LocalItemImageRequest = ({OwnedItemRef ownedRef, String imageType});

final localItemImageProvider =
    FutureProvider.family<Uint8List?, LocalItemImageRequest>(
        (ref, request) async {
  final db = ref.watch(localDatabaseProvider);
  final image = await ItemImagesCacheRepository(db).primaryImageForItem(
    request.ownedRef,
    imageType: request.imageType,
  );
  return image?.imageData;
});

/// Provides front cover bytes for an owned item, looked up from local DB.
final localCoverImageProvider = FutureProvider.family<Uint8List?, OwnedItemRef>(
  (ref, ownedRef) async {
    return ref.watch(
      localItemImageProvider((
        ownedRef: ownedRef,
        imageType: 'front_cover',
      )).future,
    );
  },
);
