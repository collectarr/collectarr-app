import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';

class LibraryKindCount {
  const LibraryKindCount({
    this.owned = 0,
    this.wishlist = 0,
  });

  final int owned;
  final int wishlist;

  int get total => owned + wishlist;

  LibraryKindCount add({required bool owned, required bool wishlist}) {
    return LibraryKindCount(
      owned: this.owned + (owned ? 1 : 0),
      wishlist: this.wishlist + (wishlist ? 1 : 0),
    );
  }
}

Map<String, LibraryKindCount> libraryCountsByKind(ShelfState state) {
  final counts = <String, LibraryKindCount>{};
  for (final entry in state.entries) {
    final kind = entry.catalogItem?.kind;
    if (kind == null || kind.isEmpty) {
      continue;
    }
    counts[kind] = (counts[kind] ?? const LibraryKindCount()).add(
      owned: entry.isOwned,
      wishlist: entry.isWishlisted,
    );
  }
  return counts;
}
