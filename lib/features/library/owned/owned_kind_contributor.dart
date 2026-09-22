import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/features/library/config/owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/config/owned_item_mutation_result.dart';
import 'package:collectarr_app/features/library/config/owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';

typedef OwnedKindFind<TItem> = Future<TItem?> Function(
  LocalDatabase database,
  String id,
);

typedef OwnedKindUpsert<TItem> = Future<void> Function(
  LocalDatabase database,
  TItem item,
);

typedef OwnedKindList<TItem> = Future<List<TItem>> Function(
  LocalDatabase database,
);

typedef OwnedKindCreate<TItem> = TItem Function({
  required OwnedItemCreatePayload payload,
  required CatalogEntityRef resolvedCatalogRef,
  required String id,
  required DateTime createdAt,
  required bool? existingIsDigital,
  required String? ownerUserId,
  required String? ownerLabel,
});

typedef OwnedKindUpdate<TItem> = TItem Function({
  required TItem existing,
  required OwnedItemUpdatePayload payload,
  required DateTime updatedAt,
  required String? fallbackOwnerUserId,
  required String? fallbackOwnerLabel,
});

typedef OwnedKindToJson<TItem> = JsonMap Function(TItem item);
typedef OwnedKindFromJson<TItem> = TItem Function(JsonMap payload);
typedef OwnedKindSummary<TItem> = OwnedItemSummary Function(TItem item);
typedef OwnedKindCreatePayload<TItem> = OwnedItemCreatePayload Function(
  TItem item,
);
typedef OwnedKindItemId<TItem> = String Function(TItem item);
typedef OwnedKindMarkDeleted<TItem> = TItem Function(
  TItem item,
  DateTime deletedAt,
);
typedef OwnedKindUpdateLocation<TItem> = TItem Function(
  TItem item,
  String? locationId,
);

/// Structural Owned contributor implemented by one library kind.
abstract interface class OwnedKindContributor {
  CatalogMediaKind get kind;

  Future<OwnedItemMutationResult> createOwned({
    required LocalDatabase database,
    required OwnedItemCreatePayload payload,
    required CatalogEntityRef resolvedCatalogRef,
    required String id,
    required DateTime createdAt,
    required bool? existingIsDigital,
    required String? ownerUserId,
    required String? ownerLabel,
  });

  Future<OwnedItemMutationResult> updateOwned({
    required LocalDatabase database,
    required OwnedItemRef ref,
    required OwnedItemUpdatePayload payload,
    required DateTime updatedAt,
    required String? fallbackOwnerUserId,
    required String? fallbackOwnerLabel,
  });

  Future<OwnedItemCreatePayload?> createPayloadByRef(
    LocalDatabase database,
    OwnedItemRef ref,
  );

  Future<JsonMap?> payloadByRef(LocalDatabase database, OwnedItemRef ref);

  Future<({JsonMap payload, bool isDeleted})?> syncPayloadByRef(
    LocalDatabase database,
    OwnedItemRef ref,
  );

  Future<OwnedItemMutationResult> replaceFromPayload(
    LocalDatabase database,
    JsonMap payload,
  );

  Future<LibraryOwnedItemDispatch?> itemForLibraryByRef(
    LocalDatabase database,
    OwnedItemRef ref,
  );

  Future<OwnedItemMutationResult?> markDeletedByRef(
    LocalDatabase database,
    OwnedItemRef ref,
    DateTime deletedAt,
  );

  Future<void> updateLocation(
    LocalDatabase database,
    OwnedItemRef ref,
    String? locationId,
  );

  Future<List<OwnedItemSummary>> listActiveSummaries(LocalDatabase database);
}

/// Generic orchestration for a kind's typed repository.
///
/// The generic part only performs structural persistence mechanics. Every
/// semantic cast, payload validation, aggregate conversion and projection is
/// supplied by the owning kind in its contributor file.
final class TypedOwnedKindContributor<TItem> implements OwnedKindContributor {
  const TypedOwnedKindContributor({
    required this.kind,
    required this.findById,
    required this.upsert,
    required this.listActive,
    required this.createItem,
    required this.updateItem,
    required this.toJson,
    required this.fromJson,
    required this.summary,
    required this.createPayload,
    required this.itemId,
    required this.markDeleted,
    required this.updateItemLocation,
  });

  @override
  final CatalogMediaKind kind;
  final OwnedKindFind<TItem> findById;
  final OwnedKindUpsert<TItem> upsert;
  final OwnedKindList<TItem> listActive;
  final OwnedKindCreate<TItem> createItem;
  final OwnedKindUpdate<TItem> updateItem;
  final OwnedKindToJson<TItem> toJson;
  final OwnedKindFromJson<TItem> fromJson;
  final OwnedKindSummary<TItem> summary;
  final OwnedKindCreatePayload<TItem> createPayload;
  final OwnedKindItemId<TItem> itemId;
  final OwnedKindMarkDeleted<TItem> markDeleted;
  final OwnedKindUpdateLocation<TItem> updateItemLocation;

  OwnedItemRef _refFor(TItem item) => OwnedItemRef(
        kind: kind,
        id: OwnedItemId(itemId(item)),
      );

  ({JsonMap payload, bool isDeleted}) _syncPayload(TItem item) {
    final payload = JsonMap.from(toJson(item));
    final isDeleted = payload['deleted_at'] != null;
    payload.remove('id');
    payload.remove('updated_at');
    payload.remove('deleted_at');
    payload.remove('reading');
    return (payload: payload, isDeleted: isDeleted);
  }

  OwnedItemMutationResult _mutationResult(TItem item) {
    final serialized = _syncPayload(item);
    return OwnedItemMutationResult(
      ref: _refFor(item),
      syncPayload: serialized.payload,
      isDeleted: serialized.isDeleted,
    );
  }

  @override
  Future<OwnedItemMutationResult> createOwned({
    required LocalDatabase database,
    required OwnedItemCreatePayload payload,
    required CatalogEntityRef resolvedCatalogRef,
    required String id,
    required DateTime createdAt,
    required bool? existingIsDigital,
    required String? ownerUserId,
    required String? ownerLabel,
  }) async {
    final item = createItem(
      payload: payload,
      resolvedCatalogRef: resolvedCatalogRef,
      id: id,
      createdAt: createdAt,
      existingIsDigital: existingIsDigital,
      ownerUserId: ownerUserId,
      ownerLabel: ownerLabel,
    );
    await upsert(database, item);
    return _mutationResult(item);
  }

  @override
  Future<OwnedItemMutationResult> updateOwned({
    required LocalDatabase database,
    required OwnedItemRef ref,
    required OwnedItemUpdatePayload payload,
    required DateTime updatedAt,
    required String? fallbackOwnerUserId,
    required String? fallbackOwnerLabel,
  }) async {
    if (ref.kind != kind) {
      throw ArgumentError.value(
          ref, 'ref', 'Owned ref belongs to another kind');
    }
    final existing = await findById(database, ref.id.value);
    if (existing == null) throw StateError('Owned item not found');
    final updated = updateItem(
      existing: existing,
      payload: payload,
      updatedAt: updatedAt,
      fallbackOwnerUserId: fallbackOwnerUserId,
      fallbackOwnerLabel: fallbackOwnerLabel,
    );
    await upsert(database, updated);
    return _mutationResult(updated);
  }

  @override
  Future<OwnedItemCreatePayload?> createPayloadByRef(
    LocalDatabase database,
    OwnedItemRef ref,
  ) async {
    if (ref.kind != kind) return null;
    final item = await findById(database, ref.id.value);
    return item == null ? null : createPayload(item);
  }

  @override
  Future<JsonMap?> payloadByRef(
    LocalDatabase database,
    OwnedItemRef ref,
  ) async {
    if (ref.kind != kind) return null;
    final item = await findById(database, ref.id.value);
    return item == null ? null : JsonMap.from(toJson(item));
  }

  @override
  Future<({JsonMap payload, bool isDeleted})?> syncPayloadByRef(
    LocalDatabase database,
    OwnedItemRef ref,
  ) async {
    if (ref.kind != kind) return null;
    final item = await findById(database, ref.id.value);
    return item == null ? null : _syncPayload(item);
  }

  @override
  Future<OwnedItemMutationResult> replaceFromPayload(
    LocalDatabase database,
    JsonMap payload,
  ) async {
    final item = fromJson(payload);
    await upsert(database, item);
    return _mutationResult(item);
  }

  @override
  Future<LibraryOwnedItemDispatch?> itemForLibraryByRef(
    LocalDatabase database,
    OwnedItemRef ref,
  ) async {
    if (ref.kind != kind) return null;
    final item = await findById(database, ref.id.value);
    if (item == null) return null;
    return OpaqueLibraryOwnedItemDispatch(
      ref: ref,
      kind: kind,
      value: item,
    );
  }

  @override
  Future<OwnedItemMutationResult?> markDeletedByRef(
    LocalDatabase database,
    OwnedItemRef ref,
    DateTime deletedAt,
  ) async {
    if (ref.kind != kind) return null;
    final item = await findById(database, ref.id.value);
    if (item == null) return null;
    final deleted = markDeleted(item, deletedAt);
    await upsert(database, deleted);
    return _mutationResult(deleted);
  }

  @override
  Future<void> updateLocation(
    LocalDatabase database,
    OwnedItemRef ref,
    String? locationId,
  ) async {
    if (ref.kind != kind) return;
    final item = await findById(database, ref.id.value);
    if (item == null) return;
    await upsert(database, updateItemLocation(item, locationId));
  }

  @override
  Future<List<OwnedItemSummary>> listActiveSummaries(
    LocalDatabase database,
  ) async {
    final items = await listActive(database);
    return [for (final item in items) summary(item)];
  }
}
