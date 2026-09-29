import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_item_projection.dart';
import 'package:collectarr_app/features/library/config/library_value_capability.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';

class ComicValueCapability implements LibraryValueCapability {
  const ComicValueCapability();

  @override
  LibraryCollectionValueSummary? resolveCollectionValueSummary(
    Iterable<LibraryWorkspaceSource> entries,
  ) {
    final valuedEntries = [
      for (final entry in entries)
        if (entry.isOwned)
          (
            entry: entry,
            owned: _comicOwnedItem(entry),
          ),
    ].where((candidate) {
      final ownedItem = candidate.owned;
      return ownedItem != null &&
          ownedItem.details.coverPriceCents != null &&
          ownedItem.currency != null;
    }).toList(growable: false);
    if (valuedEntries.isEmpty) {
      return null;
    }
    final currencies = {
      for (final candidate in valuedEntries) candidate.owned!.currency!,
    };
    return LibraryCollectionValueSummary(
      valuedCount: valuedEntries.length,
      totalValueCents: currencies.length > 1
          ? null
          : valuedEntries.fold<int>(
              0,
              (total, candidate) {
                return total + candidate.owned!.details.coverPriceCents!;
              },
            ),
      currency: currencies.length == 1 ? currencies.single : null,
      hasMixedCurrencies: currencies.length > 1,
    );
  }

  static ComicOwnedItem? _comicOwnedItem(LibraryWorkspaceSource entry) {
    return ComicOwnedItemProjection.fromDispatch(entry.ownedItemDispatch);
  }
}
