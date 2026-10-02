import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_collection_item_projection.dart';
import 'package:collectarr_app/features/library/config/library_value_capability.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_collection_item.dart';

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
            owned: _comicCollectionItem(entry),
          ),
    ].where((candidate) {
      final collectionItem = candidate.owned;
      return collectionItem != null &&
          collectionItem.details.coverPriceCents != null &&
          collectionItem.currency != null;
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

  static ComicCollectionItem? _comicCollectionItem(LibraryWorkspaceSource entry) {
    return ComicCollectionItemProjection.fromDispatch(entry.collectionItemDispatch);
  }
}
