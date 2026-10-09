import 'dart:typed_data';

import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/collection/repositories/item_images_cache_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef LocalItemImageRequest = ({
  LibraryEntryRef libraryEntryRef,
  String imageType
});

final localItemImageProvider =
    FutureProvider.family<Uint8List?, LocalItemImageRequest>(
        (ref, request) async {
  final db = ref.watch(localDatabaseProvider);
  final image = await ItemImagesCacheRepository(db).primaryImageForItem(
    request.libraryEntryRef,
    imageType: request.imageType,
  );
  return image?.imageData;
});

/// Provides front cover bytes for a collection item, looked up from local DB.
final localCoverImageProvider =
    FutureProvider.family<Uint8List?, LibraryEntryRef>(
  (ref, libraryEntryRef) async {
    return ref.watch(
      localItemImageProvider((
        libraryEntryRef: libraryEntryRef,
        imageType: 'front_cover',
      )).future,
    );
  },
);
