import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/config/owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/config/owned_item_mutation_result.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';
import 'package:collectarr_app/features/library/owned/owned_kind_contributor_registry.dart';
import 'package:collectarr_app/features/library/owned/owned_kind_contributor.dart';

/// Composition-root dispatch for the typed owned repositories.
///
/// The registry is generated from each kind's repository, projection and ID
/// files. Collection orchestration only owns the structural dispatch contract;
/// it does not import or enumerate concrete kinds manually.
final class CollectarrOwnedItemPersistence {
  CollectarrOwnedItemPersistence(this._database)
      : _contributors = collectarrOwnedKindContributors;

  final LocalDatabase _database;
  final Map<CatalogMediaKind, OwnedKindContributor> _contributors;

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
    return ownedContributorForKind(kind).createOwned(
      database: _database,
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
    required OwnedItemUpdatePayload payload,
    required DateTime updatedAt,
    required String? fallbackOwnerUserId,
    required String? fallbackOwnerLabel,
  }) {
    return ownedContributorForKind(ref.kind).updateOwned(
      database: _database,
      ref: ref,
      payload: payload,
      updatedAt: updatedAt,
      fallbackOwnerUserId: fallbackOwnerUserId,
      fallbackOwnerLabel: fallbackOwnerLabel,
    );
  }

  Future<OwnedItemCreatePayload?> createPayloadByRef(OwnedItemRef ref) {
    return ownedContributorForKind(ref.kind).createPayloadByRef(
      _database,
      ref,
    );
  }

  Future<JsonMap?> payloadByRef(OwnedItemRef ref) {
    return ownedContributorForKind(ref.kind).payloadByRef(_database, ref);
  }

  Future<({JsonMap payload, bool isDeleted})?> syncPayloadByRef(
    OwnedItemRef ref,
  ) {
    return ownedContributorForKind(ref.kind).syncPayloadByRef(_database, ref);
  }

  Future<OwnedItemMutationResult> replaceFromPayload(
    CatalogMediaKind kind,
    JsonMap payload,
  ) {
    return ownedContributorForKind(kind).replaceFromPayload(_database, payload);
  }

  Future<LibraryOwnedItemDispatch?> ownedItemForLibraryByRef(
    OwnedItemRef ref,
  ) async {
    return ownedContributorForKind(ref.kind).itemForLibraryByRef(
      _database,
      ref,
    );
  }

  Future<OwnedItemMutationResult?> markDeletedByRef(
    OwnedItemRef ref,
    DateTime deletedAt,
  ) async {
    return ownedContributorForKind(ref.kind).markDeletedByRef(
      _database,
      ref,
      deletedAt,
    );
  }

  Future<void> updateLocation(OwnedItemRef ref, String? locationId) async {
    await ownedContributorForKind(ref.kind).updateLocation(
      _database,
      ref,
      locationId,
    );
  }

  Future<List<OwnedItemSummary>> listActiveSummaries() async {
    final groups = await Future.wait(
      _contributors.values.map(
        (contributor) => contributor.listActiveSummaries(_database),
      ),
    );
    return groups.expand((group) => group).toList(growable: false);
  }
}
