import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';

typedef _TypedOwnedItemPersister = Future<void> Function(
  LocalDatabase database,
  Object item,
);
typedef _TypedOwnedItemFinder = Future<Object?> Function(
  LocalDatabase database,
  String id,
);
typedef _TypedOwnedLocationUpdater = Future<void> Function(
  LocalDatabase database,
  String id,
  String? locationId,
);
typedef _TypedOwnedItemDeleter = Future<void> Function(
  LocalDatabase database,
  Object item,
  DateTime deletedAt,
);
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
      : _typedPersisters = collectarrTypedOwnedItemPersisters,
        _typedLocationUpdaters = collectarrTypedOwnedLocationUpdaters,
        _typedFinders = collectarrTypedOwnedItemFinders,
        _typedDeleters = collectarrTypedOwnedItemDeleters,
        _summaryReaders = collectarrOwnedItemSummaryReaders;

  final LocalDatabase _database;
  final Map<CatalogMediaKind, _TypedOwnedItemPersister> _typedPersisters;
  final Map<CatalogMediaKind, _TypedOwnedLocationUpdater>
      _typedLocationUpdaters;
  final Map<CatalogMediaKind, _TypedOwnedItemFinder> _typedFinders;
  final Map<CatalogMediaKind, _TypedOwnedItemDeleter> _typedDeleters;
  final Map<CatalogMediaKind, _OwnedItemSummaryReader> _summaryReaders;

  Future<void> upsertTyped(CatalogMediaKind kind, Object item) async {
    final persister = _typedPersisters[kind];
    if (persister == null) {
      throw StateError(
        'Cannot persist typed owned item without a supported kind: '
        '${kind.apiValue}',
      );
    }
    await persister(_database, item);
  }

  Future<(CatalogMediaKind kind, Object item)?> findTypedById(String id) {
    return collectarrFindTypedOwnedItem(_database, id);
  }

  ({Map<String, dynamic> payload, bool isDeleted}) syncPayloadForTyped(
    CatalogMediaKind kind,
    Object item,
  ) {
    final serializer = collectarrTypedOwnedItemSyncSerializers[kind];
    if (serializer == null) {
      throw StateError(
        'Cannot serialize typed owned item without a supported kind: '
        '${kind.apiValue}',
      );
    }
    return serializer(item);
  }

  Future<void> markDeletedByRef(
    OwnedItemRef ref,
    DateTime deletedAt,
  ) async {
    final finder = _typedFinders[ref.kind];
    final deleter = _typedDeleters[ref.kind];
    if (finder == null || deleter == null) {
      throw StateError(
        'Cannot delete typed owned item without a supported kind: '
        '${ref.kind.apiValue}',
      );
    }
    final item = await finder(_database, ref.id.value);
    if (item != null) {
      await deleter(_database, item, deletedAt);
    }
  }

  Future<void> updateLocation(OwnedItemRef ref, String? locationId) async {
    final updater = _typedLocationUpdaters[ref.kind];
    if (updater == null) {
      throw StateError(
        'Cannot update typed owned location without a supported kind: '
        '${ref.kind.apiValue}',
      );
    }
    await updater(_database, ref.id.value, locationId);
  }

  Future<List<OwnedItemSummary>> listActiveSummaries() async {
    final groups = await Future.wait(
      _summaryReaders.values.map((reader) => reader(_database)),
    );
    return groups.expand((group) => group).toList(growable: false);
  }
}
