import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/config/owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/config/owned_item_mutation_result.dart';
import 'package:collectarr_app/features/library/config/owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';

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
    return collectarrCreateOwnedItem(
      _database,
      kind,
      payload,
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
    required OwnedItemUpdatePayload payload,
    required DateTime updatedAt,
    required String? fallbackOwnerUserId,
    required String? fallbackOwnerLabel,
  }) {
    return collectarrUpdateOwnedItem(
      _database,
      ref,
      payload,
      updatedAt: updatedAt,
      fallbackOwnerUserId: fallbackOwnerUserId,
      fallbackOwnerLabel: fallbackOwnerLabel,
    );
  }

  Future<OwnedItemCreatePayload?> createPayloadByRef(OwnedItemRef ref) {
    return collectarrOwnedCreatePayloadByRef(_database, ref);
  }

  Future<JsonMap?> payloadByRef(OwnedItemRef ref) {
    return collectarrOwnedItemJsonByRef(_database, ref);
  }

  Future<({JsonMap payload, bool isDeleted})?> syncPayloadByRef(
    OwnedItemRef ref,
  ) {
    return collectarrOwnedItemSyncPayloadByRef(_database, ref);
  }

  Future<OwnedItemMutationResult> replaceFromPayload(
    CatalogMediaKind kind,
    JsonMap payload,
  ) {
    return collectarrReplaceOwnedFromJson(_database, kind, payload);
  }

  Future<LibraryOwnedItemDispatch?> ownedItemForLibraryByRef(
    OwnedItemRef ref,
  ) async {
    return collectarrOwnedItemForLibraryByRef(_database, ref);
  }

  Future<OwnedItemMutationResult?> markDeletedByRef(
    OwnedItemRef ref,
    DateTime deletedAt,
  ) async {
    return collectarrMarkOwnedItemDeletedByRef(_database, ref, deletedAt);
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
