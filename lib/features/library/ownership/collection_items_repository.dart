import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/features/collection/commands/collection_item_commands.dart';
import 'package:collectarr_app/features/library/config/collection_item_mutation_result.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_collection_item_persistence.dart';
import 'package:collectarr_app/features/library/ownership/owned_import_transport.dart';

/// Cross-kind read/write host backed by each kind's complete owned table.
///
/// Typed aggregates are the canonical persistence path. Mixed/global views
/// consume structural summaries and references rather than a common Owned
/// aggregate.
final class CollectionItemsRepository {
  CollectionItemsRepository(LocalDatabase database)
      : _persistence = CollectarrCollectionItemPersistence(database);

  final CollectarrCollectionItemPersistence _persistence;

  Future<CollectionItemMutationResult> createCollectionItem({
    required CatalogMediaKind kind,
    required CollectionItemCreatePayload payload,
    required CatalogEntityRef resolvedCatalogRef,
    required String id,
    required DateTime createdAt,
    required bool? existingIsDigital,
    required String? ownerUserId,
    required String? ownerLabel,
  }) {
    return _persistence.createCollectionItem(
      kind: kind,
      payload: payload,
      resolvedCatalogRef: resolvedCatalogRef,
      id: id,
      createdAt: createdAt,
      existingIsDigital: existingIsDigital,
      ownerUserId: ownerUserId,
      ownerLabel: ownerLabel,
    );
  }

  Future<CollectionItemMutationResult> updateCollectionItem({
    required CollectionItemRef ref,
    required CollectionItemUpdatePayload payload,
    required DateTime updatedAt,
    required String? fallbackOwnerUserId,
    required String? fallbackOwnerLabel,
  }) {
    return _persistence.updateCollectionItem(
      ref: ref,
      payload: payload,
      updatedAt: updatedAt,
      fallbackOwnerUserId: fallbackOwnerUserId,
      fallbackOwnerLabel: fallbackOwnerLabel,
    );
  }

  Future<CollectionItemCreatePayload?> createPayloadByRef(CollectionItemRef ref) {
    return _persistence.createPayloadByRef(ref);
  }

  Future<JsonMap?> payloadByRef(CollectionItemRef ref) {
    return _persistence.payloadByRef(ref);
  }

  Future<CollectionItemMutationResult> replaceFromTransport(
    OwnedImportTransport transport,
  ) {
    return _persistence.replaceFromPayload(
      transport.ref.kind,
      {
        ...transport.payload,
        'id': transport.ref.id.value,
        'catalog_ref': transport.catalogRef.toJson(),
      },
    );
  }

  SyncChange syncChangeForMutation(
    CollectionItemMutationResult result, {
    required String action,
    required DateTime changedAt,
  }) {
    return SyncChange(
      id: 'collection_item:${result.ref.id.value}:$action:'
          '${changedAt.millisecondsSinceEpoch}',
      entityType: 'collection_item',
      entityId: result.ref.id.value,
      action: action,
      payload: result.syncPayload,
      clientChangedAt: changedAt,
    );
  }

  Future<List<CollectionItemSummary>> listActiveSummaries() async {
    return _persistence.listActiveSummaries();
  }

  Future<CollectionItemSummary?> findSummaryByRef(CollectionItemRef ref) async {
    for (final item in await listActiveSummaries()) {
      if (item.ref == ref) return item;
    }
    return null;
  }

  Future<CollectionItemMutationResult?> markDeletedByRef(
    CollectionItemRef ref,
    DateTime deletedAt,
  ) {
    return _persistence.markDeletedByRef(ref, deletedAt);
  }

  Future<void> updateLocation(CollectionItemRef ref, String? locationId) {
    return _persistence.updateLocation(ref, locationId);
  }
}
