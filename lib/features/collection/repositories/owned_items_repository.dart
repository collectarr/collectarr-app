import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_owned_item_persistence.dart';

/// Cross-kind read/write host backed by each kind's complete owned table.
///
/// Collection orchestration keeps common writes for now, while read summaries
/// are projected directly from the owning kind tables. No universal owned
/// table or serialized details payload exists here.
final class OwnedItemsRepository {
  OwnedItemsRepository(LocalDatabase database)
      : _persistence = CollectarrOwnedItemPersistence(database);

  final CollectarrOwnedItemPersistence _persistence;

  Future<List<OwnedItem>> listActive() => _persistence.listActive();

  Future<List<OwnedItemSummary>> listActiveSummaries() async {
    return _persistence.listActiveSummaries();
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
}
