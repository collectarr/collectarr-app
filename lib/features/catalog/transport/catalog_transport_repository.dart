import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_snapshot.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_transport_codec.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_contributor.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';

/// Reads and writes the kind-owned catalog graphs.
///
/// Generic catalog orchestration over the typed kind repositories. No catalog
/// payload is stored by this class; typed kind repositories own the durable
/// representation.
final class CatalogTransportRepository {
  CatalogTransportRepository(
    this._db, {
    Iterable<CatalogKindTransportCodec> codecs =
        collectarrKindCatalogTransportCodecs,
  }) : _codecs = {
          for (final codec in codecs) codec.kind: codec,
        };

  final LocalDatabase _db;
  final Map<CatalogMediaKind, CatalogKindTransportCodec> _codecs;

  Future<void> upsertImportSnapshots(
    Iterable<CatalogImportSnapshot> snapshots,
  ) {
    return upsertAll(
      snapshots.map((snapshot) => snapshot.toTransportItem()),
    );
  }

  Future<void> upsertSearchCandidates(
    Iterable<CatalogSearchCandidate> candidates,
  ) {
    return upsertAll(
      candidates.map(
        (candidate) => candidate.toImportSnapshot().toTransportItem(),
      ),
    );
  }

  CatalogImportSnapshot snapshotFromSyncPayload({
    required String id,
    required Map<String, dynamic> payload,
  }) {
    return CatalogImportSnapshot.fromItem(
      CatalogItemDto.fromJson({...payload, 'id': id}),
    );
  }

  Future<void> upsertAll(
    Iterable<CatalogItemDto> items, {
    bool captureDerivedData = true,
  }) async {
    final catalogItems = items.toList(growable: false);
    if (catalogItems.isEmpty) return;

    for (final item in catalogItems) {
      await _upsertItem(item);
    }
    if (captureDerivedData) {
      await _captureDerivedData(catalogItems);
    }
  }

  /// Captures only derived infrastructure values from already typed catalog
  /// projections. The owning kind contributors interpret metadata; this
  /// repository only coordinates the persistence transaction.
  Future<void> _captureDerivedData(Iterable<CatalogItemDto> items) async {
    final list = items.toList(growable: false);
    if (list.isEmpty) return;

    final pickLists = PickListRepository(_db);
    final serialAuthority = SerialAuthorityRepository(_db);
    final serialCandidates = <SerialAuthorityCandidate>[];
    await _db.transaction(() async {
      for (final item in list) {
        final codec = _codecs[item.mediaKind];
        final derived = codec?.derivedDataFromDto(item);
        if (derived == null) continue;

        for (final projected in derived.pickListValues) {
          await pickLists.captureValuesWithoutTransaction(
            projected.listName,
            projected.values,
            mediaKind: item.mediaKind.apiValue,
          );
        }
        serialCandidates.addAll(derived.serialCandidates);
      }
      await serialAuthority
          .captureCandidatesWithoutTransaction(serialCandidates);
    });
  }

  Future<void> _upsertItem(CatalogItemDto item) async {
    final codec = _codecs[item.mediaKind];
    if (codec == null) {
      throw StateError(
        'Cannot persist catalog item without a supported kind: ${item.kind}',
      );
    }
    await codec.upsertTransport(_db, item);
  }
}
