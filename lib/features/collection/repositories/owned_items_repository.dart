import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_owned_item_persistence.dart';

/// Cross-kind read/write host backed by each kind's complete owned table.
///
/// The collection feature only sees the temporary common read model while its
/// UI is being converted to typed kind contexts. Persistence itself is
/// dispatched immediately to the owning kind; no universal owned table or
/// serialized details payload exists here.
final class OwnedItemsRepository {
  OwnedItemsRepository(LocalDatabase database)
      : _persistence = CollectarrOwnedItemPersistence(database);

  final CollectarrOwnedItemPersistence _persistence;

  Future<List<OwnedItem>> listActive() => _persistence.listActive();

  Future<List<OwnedItemSummary>> listActiveSummaries() async {
    final items = await listActive();
    return items.map(_summary).toList(growable: false);
  }

  Future<OwnedItem?> findById(String id) => _persistence.findById(id);

  Future<List<OwnedItem>> findActiveByItemIds(Iterable<String> itemIds) {
    return _persistence.findActiveByItemIds(itemIds);
  }

  Future<void> upsert(OwnedItem item) => _persistence.upsert(item);

  Future<void> upsertAll(List<OwnedItem> items) =>
      _persistence.upsertAll(items);

  Future<void> markDeleted(OwnedItem item, DateTime deletedAt) {
    return _persistence.markDeleted(item, deletedAt);
  }

  OwnedItemSummary _summary(OwnedItem item) {
    return OwnedItemSummary(
      ref: OwnedItemRef(
        kind: item.catalogRef.mediaKind,
        id: item.typedId,
      ),
      catalogRef: item.catalogRef,
      title: item.itemId,
      ownerLabel: item.ownerLabel,
      locationLabel: item.locationId,
      notes: item.personalNotes,
      hasNotes: item.personalNotes?.trim().isNotEmpty == true,
    );
  }
}
