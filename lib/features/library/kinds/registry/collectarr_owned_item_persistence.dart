import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';

typedef _OwnedItemSummaryReader = Future<List<OwnedItemSummary>> Function(
  LocalDatabase database,
);

/// Composition-root dispatch for the typed owned repositories.
///
/// The registry is generated from each kind's repository, projection and ID
/// files. Collection orchestration only owns the structural dispatch contract;
/// it does not import or enumerate concrete kinds manually.
final class CollectarrOwnedItemPersistence {
  CollectarrOwnedItemPersistence(this._database)
      : _summaryReaders = collectarrOwnedItemSummaryReaders;

  final LocalDatabase _database;
  final Map<CatalogMediaKind, _OwnedItemSummaryReader> _summaryReaders;

  Future<void> upsertTyped(CatalogMediaKind kind, Object item) =>
      collectarrUpsertTypedOwnedItem(_database, kind, item);

  Future<(CatalogMediaKind kind, Object item)?> findTypedByRef(
    OwnedItemRef ref,
  ) async {
    return collectarrFindTypedOwnedItemByRef(_database, ref);
  }

  ({Map<String, dynamic> payload, bool isDeleted}) syncPayloadForTyped(
    CatalogMediaKind kind,
    Object item,
  ) {
    return collectarrTypedOwnedItemSyncPayload(kind, item);
  }

  Future<void> markDeletedByRef(
    OwnedItemRef ref,
    DateTime deletedAt,
  ) async {
    final item = await findTypedByRef(ref);
    if (item != null) {
      await collectarrMarkTypedOwnedItemDeleted(
        _database,
        item.$1,
        item.$2,
        deletedAt,
      );
    }
  }

  Future<void> updateLocation(OwnedItemRef ref, String? locationId) async {
    await collectarrUpdateTypedOwnedLocation(
      _database,
      ref.kind,
      ref.id.value,
      locationId,
    );
  }

  Future<List<OwnedItemSummary>> listActiveSummaries() async {
    final groups = await Future.wait(
      _summaryReaders.values.map((reader) => reader(_database)),
    );
    return groups.expand((group) => group).toList(growable: false);
  }
}
