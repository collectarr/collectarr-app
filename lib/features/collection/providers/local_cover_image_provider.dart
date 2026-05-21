import 'package:collectarr_app/features/collection/repositories/item_images_cache_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides base64 front cover bytes for an owned item, looked up from local DB.
final localCoverImageProvider = FutureProvider.family<String?, String>(
  (ref, ownedItemId) async {
    final db = ref.watch(localDatabaseProvider);
    return ItemImagesCacheRepository(db).frontCoverBase64(ownedItemId);
  },
);
