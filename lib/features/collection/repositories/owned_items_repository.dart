import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/config/owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/config/owned_item_mutation_result.dart';
import 'package:collectarr_app/features/library/config/owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_owned_item_persistence.dart';

/// Cross-kind read/write host backed by each kind's complete owned table.
///
/// Typed aggregates are the canonical persistence path. Mixed/global views
/// consume structural summaries and references rather than a common Owned
/// aggregate.
final class OwnedItemsRepository {
  OwnedItemsRepository(LocalDatabase database)
      : _persistence = CollectarrOwnedItemPersistence(database);

  final CollectarrOwnedItemPersistence _persistence;

  Future<OwnedItemMutationResult> createOwned({
    required CatalogMediaKind kind,
    required OwnedItemCreatePayload payload,
    required CatalogEntityRef resolvedCatalogRef,
    required String id,
    required DateTime createdAt,
    required bool? existingIsDigital,
    required String? ownerUserId,
    required String? ownerLabel,
  }) {
    return _persistence.createOwned(
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

  Future<OwnedItemMutationResult> updateOwned({
    required OwnedItemRef ref,
    required OwnedItemUpdatePayload<Object?> payload,
    required DateTime updatedAt,
    required String? fallbackOwnerUserId,
    required String? fallbackOwnerLabel,
  }) {
    return _persistence.updateOwned(
      ref: ref,
      payload: payload,
      updatedAt: updatedAt,
      fallbackOwnerUserId: fallbackOwnerUserId,
      fallbackOwnerLabel: fallbackOwnerLabel,
    );
  }

  SyncChange syncChangeForMutation(
    OwnedItemMutationResult result, {
    required String action,
    required DateTime changedAt,
  }) {
    return SyncChange(
      id: 'owned_item:${result.ref.id.value}:$action:'
          '${changedAt.millisecondsSinceEpoch}',
      entityType: 'owned_item',
      entityId: result.ref.id.value,
      action: action,
      payload: result.syncPayload,
      clientChangedAt: changedAt,
    );
  }

  Future<List<OwnedItemSummary>> listActiveSummaries() async {
    return _persistence.listActiveSummaries();
  }

  Future<OwnedItemSummary?> findSummaryByRef(OwnedItemRef ref) async {
    for (final item in await listActiveSummaries()) {
      if (item.ref == ref) return item;
    }
    return null;
  }

  Future<(CatalogMediaKind kind, Object item)?> findTypedByRef(
    OwnedItemRef ref,
  ) {
    return _persistence.findTypedByRef(ref);
  }

  SyncChange syncChangeForTyped(
    CatalogMediaKind kind,
    Object item, {
    required String id,
    required String action,
    required DateTime changedAt,
  }) {
    final serialized = _persistence.syncPayloadForTyped(kind, item);
    return SyncChange(
      id: 'owned_item:$id:$action:${changedAt.millisecondsSinceEpoch}',
      entityType: 'owned_item',
      entityId: id,
      action: action,
      payload: serialized.payload,
      clientChangedAt: changedAt,
    );
  }

  Future<void> upsertTyped(CatalogMediaKind kind, Object item) =>
      _persistence.upsertTyped(kind, item);

  Future<OwnedItemMutationResult?> markDeletedByRef(
    OwnedItemRef ref,
    DateTime deletedAt,
  ) {
    return _persistence.markDeletedByRef(ref, deletedAt);
  }

  Future<void> updateLocation(OwnedItemRef ref, String? locationId) {
    return _persistence.updateLocation(ref, locationId);
  }
}
