import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

class LibraryAddDefaults {
  const LibraryAddDefaults({
    this.condition,
    this.grade,
    this.purchaseDate,
    this.storageBox,
  });

  final String? condition;
  final String? grade;
  final DateTime? purchaseDate;
  final String? storageBox;

  String? get normalizedStorageBox {
    final value = storageBox?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }
}

Future<void> addLibraryItemsToTarget({
  required CatalogCacheRepository catalog,
  required CollectionMutations mutations,
  required Iterable<LibraryMetadataItem> items,
  required LibraryAddTarget target,
  LibraryAddDefaults defaults = const LibraryAddDefaults(),
}) async {
  final values = items.toList(growable: false);
  if (values.isEmpty) {
    return;
  }

  final catalogItems = [for (final item in values) item.toCatalogItem()];

  await catalog.upsertAll(catalogItems);
  for (final item in values) {
    switch (target) {
      case LibraryAddTarget.owned:
        await mutations.addItem(
          item.id,
          condition: defaults.condition,
          grade: defaults.grade,
          purchaseDate: defaults.purchaseDate,
          storageBox: defaults.normalizedStorageBox,
        );
        break;
      case LibraryAddTarget.wishlist:
        await mutations.addToWishlist(item.id);
        break;
    }
  }
}
