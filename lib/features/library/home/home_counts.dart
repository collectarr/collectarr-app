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

  LibraryKindCount add({required bool owned, required bool wishlist}) {
    return LibraryKindCount(
      owned: this.owned + (owned ? 1 : 0),
      wishlist: this.wishlist + (wishlist ? 1 : 0),
    );
  }
}

final overdueLoanOwnedItemIdsProvider = FutureProvider<Set<String>>((ref) async {
  final repo = LoanRepository(ref.watch(localDatabaseProvider));
  final loans = await repo.getActiveLoans();
  final now = DateTime.now();
  return {
    for (final loan in loans)
      if (loan.isOverdueAt(now)) loan.ownedItemId,
  };
});

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

Map<String, int> overdueLoanCountsByKind(
  ShelfState state,
  Set<String> overdueOwnedItemIds,
) {
  if (overdueOwnedItemIds.isEmpty) {
    return const <String, int>{};
  }

  final counts = <String, int>{};
  for (final entry in state.entries) {
    final kind = entry.catalogItem?.kind;
    final ownedItemId = entry.ownedItem?.id;
    if (kind == null || kind.isEmpty || ownedItemId == null) {
      continue;
    }
    if (!overdueOwnedItemIds.contains(ownedItemId)) {
      continue;
    }
    counts.update(kind, (value) => value + 1, ifAbsent: () => 1);
  }
  return counts;
}
