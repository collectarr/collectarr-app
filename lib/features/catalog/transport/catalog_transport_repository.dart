import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_transport.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_transport_codec.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';

/// Reads and writes local projections of Core Catalog Items.
///
/// Every item is stored in the shared cache. Unconverted kind codecs may also
/// dual-write a typed local projection; flat kinds opt out and use the shared
/// cache as their sole local catalog store.
final class CatalogTransportRepository {
  CatalogTransportRepository(
    this._db, {
    Iterable<CatalogKindTransportBoundary> codecs =
        libraryCatalogTransportCodecs,
  }) : _codecs = {
          for (final codec in codecs) codec.kind: codec,
        };

  final LocalDatabase _db;
  final Map<CatalogMediaKind, CatalogKindTransportBoundary> _codecs;

  /// Persists kind-entry import snapshots at the catalog transport boundary.
  Future<void> upsertTransports(
    Iterable<CatalogImportTransport> transports,
  ) {
    return upsertTransportItems([
      for (final transport in transports) transport.decodeItem(),
    ]);
  }

  CatalogItemDto itemFromSyncPayload({
    required String id,
    required Map<String, dynamic> payload,
  }) {
    return CatalogItemDto.fromJson({...payload, 'id': id});
  }

  Future<CatalogItemDto?> findCatalogItem(CatalogItemRef ref) {
    return CatalogItemCacheRepository(_db).find(ref);
  }

  /// Cleans up a transient private Add candidate once its full catalog data is
  /// owned by a local Library Entry.
  Future<void> removePrivateCandidate(CatalogItemRef ref) =>
      CatalogItemCacheRepository(_db).removePrivateCandidate(ref);

  CatalogImportTransport transportFromSyncPayload({
    required String id,
    required Map<String, dynamic> payload,
  }) {
    return CatalogImportTransport.fromItem(
      itemFromSyncPayload(id: id, payload: payload),
    );
  }

  Future<void> upsertTransportItems(
    Iterable<CatalogItemDto> items, {
    bool captureDerivedData = true,
    bool forceCacheUpdate = false,
  }) async {
    final catalogItems = items.toList(growable: false);
    if (catalogItems.isEmpty) return;

    for (final item in catalogItems) {
      await _upsertItem(item, forceCacheUpdate: forceCacheUpdate);
    }
    if (captureDerivedData) {
      await _captureDerivedData(catalogItems);
    }
  }

  /// Refreshes kind-owned derived vocabulary from local-entry metadata. The
  /// local record is persisted by LibraryEntriesRepository; this method only
  /// updates indexes derived from the kind document and never creates a
  /// Catalog Item DTO from the local entry ID.
  Future<void> captureEntryDerivedData({
    required CatalogMediaKind kind,
    required Map<String, dynamic> kindData,
  }) async {
    final codec = _codecs[kind];
    if (codec is! CatalogKindTransportCodec<dynamic>) {
      throw StateError('No typed metadata codec is registered for $kind.');
    }
    final pickLists = PickListRepository(_db);
    final serialAuthority = SerialAuthorityRepository(_db);
    await _db.transaction(() => codec.captureDerivedDataTyped(
          pickLists,
          serialAuthority,
          codec.decodeKindData(kindData),
        ));
  }

  /// Captures only derived infrastructure values from already typed catalog
  /// projections. The owning kind contributors interpret metadata; this
  /// repository only coordinates the persistence transaction.
  Future<void> _captureDerivedData(Iterable<CatalogItemDto> items) async {
    final list = items.toList(growable: false);
    if (list.isEmpty) return;

    final pickLists = PickListRepository(_db);
    final serialAuthority = SerialAuthorityRepository(_db);
    await _db.transaction(() async {
      for (final item in list) {
        final codec = _codecs[item.mediaKind];
        if (codec == null) continue;
        await codec.captureDerivedData(
          pickLists,
          serialAuthority,
          item,
        );
      }
    });
  }

  Future<void> _upsertItem(
    CatalogItemDto item, {
    required bool forceCacheUpdate,
  }) async {
    final codec = _codecs[item.mediaKind];
    if (codec == null) {
      throw StateError(
        'Cannot persist catalog item without a supported kind: ${item.kind}',
      );
    }
    await _db.transaction(() => CatalogItemCacheRepository(_db).upsert(
          item,
          force: forceCacheUpdate,
        ));
  }
}
