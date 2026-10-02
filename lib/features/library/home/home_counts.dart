import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryKindCount {
  const LibraryKindCount({
    this.owned = 0,
    this.wishlist = 0,
  });

  final int owned;
  final int wishlist;

  int get total => owned + wishlist;
}

final overdueLoanCollectionItemIdsProvider =
    FutureProvider.autoDispose<Set<CollectionItemRef>>((ref) async {
  final repo = LoanRepository(ref.watch(localDatabaseProvider));
  final loans = await repo.getActiveLoans();
  final now = DateTime.now();
  return {
    for (final loan in loans)
      if (loan.isOverdueAt(now)) loan.collectionItemRef,
  };
});

Map<String, LibraryKindCount> libraryCountsByKind(ShelfState state) {
  final kinds = <String>{
    ...state.collectionItemCountByKind.keys,
    ...state.wishlistItemCountByKind.keys,
  };
  return {
    for (final kind in kinds)
      kind: LibraryKindCount(
        owned: state.collectionItemCountByKind[kind] ?? 0,
        wishlist: state.wishlistItemCountByKind[kind] ?? 0,
      ),
  };
}

Map<String, int> overdueLoanCountsByKind(
  ShelfState state,
  Set<CollectionItemRef> overdueCollectionItemRefs,
) {
  if (overdueCollectionItemRefs.isEmpty) {
    return const <String, int>{};
  }

  final counts = <String, int>{};
  for (final entry in state.entries) {
    final kind = entry.catalogRef?.mediaKind.apiValue ??
        entry.catalogSummary?.kind.apiValue;
    final collectionItemRef = entry.collectionItemSummary?.ref;
    if (kind == null || kind.isEmpty || collectionItemRef == null) {
      continue;
    }
    if (!overdueCollectionItemRefs.contains(collectionItemRef)) {
      continue;
    }
    counts.update(kind, (value) => value + 1, ifAbsent: () => 1);
  }
  return counts;
}
