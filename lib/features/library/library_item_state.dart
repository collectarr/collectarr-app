import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';

class LibraryItemState {
  const LibraryItemState({this.ownedItem, this.isWishlisted = false});

  final OwnedItem? ownedItem;
  final bool isWishlisted;

  bool get isOwned => ownedItem != null;

  String get statusLabel {
    if (isOwned && isWishlisted) {
      return 'Owned + Wishlist';
    }
    if (isOwned) {
      return 'Owned';
    }
    if (isWishlisted) {
      return 'Wishlist';
    }
    return 'Not in library';
  }
}

LibraryItemState libraryItemStateFor({
  required CatalogItem? item,
  required Map<String, OwnedItem> ownedByItemId,
  required Set<String> wishlistIds,
}) {
  if (item == null) {
    return const LibraryItemState();
  }
  return LibraryItemState(
    ownedItem: ownedByItemId[item.id],
    isWishlisted: wishlistIds.contains(item.id),
  );
}
