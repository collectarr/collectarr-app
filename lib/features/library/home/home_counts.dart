import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryKindCount {
  const LibraryKindCount({
    this.entry = 0,
    this.wishlist = 0,
  });

  final int entry;
  final int wishlist;

  int get total => entry + wishlist;
}

final overdueLoanLibraryEntryIdsProvider =
    FutureProvider.autoDispose<Set<LibraryEntryRef>>((ref) async {
  final repo = LoanRepository(ref.watch(localDatabaseProvider));
  final loans = await repo.getActiveLoans();
  final now = DateTime.now();
  return {
    for (final loan in loans)
      if (loan.isOverdueAt(now)) loan.libraryEntryRef,
  };
});

Map<String, LibraryKindCount> libraryCountsByKind(ShelfState state) {
  final kinds = <String>{
    ...state.libraryEntryCountByKind.keys,
    ...state.wishlistItemCountByKind.keys,
  };
  return {
    for (final kind in kinds)
      kind: LibraryKindCount(
        entry: state.libraryEntryCountByKind[kind] ?? 0,
        wishlist: state.wishlistItemCountByKind[kind] ?? 0,
      ),
  };
}

Map<String, int> overdueLoanCountsByKind(
  ShelfState state,
  Set<LibraryEntryRef> overdueLibraryEntryRefs,
) {
  if (overdueLibraryEntryRefs.isEmpty) {
    return const <String, int>{};
  }

  final counts = <String, int>{};
  for (final entry in state.entries) {
    final kind = entry.mediaKind.apiValue;
    final libraryEntryRef = entry.libraryEntrySummary?.ref;
    if (kind.isEmpty || libraryEntryRef == null) {
      continue;
    }
    if (!overdueLibraryEntryRefs.contains(libraryEntryRef)) {
      continue;
    }
    counts.update(kind, (value) => value + 1, ifAbsent: () => 1);
  }
  return counts;
}
