import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/features/library/config/collection_item_create_payload.dart';
import 'package:collectarr_app/features/library/config/collection_item_mutation_result.dart';
import 'package:collectarr_app/features/library/config/collection_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_collection_item_dispatch.dart';

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
  required CollectionItemCreatePayload payload,
  required CatalogEntityRef resolvedCatalogRef,
  required String id,
  required DateTime createdAt,
  required bool? existingIsDigital,
  required String? ownerUserId,
  required String? ownerLabel,
});

typedef OwnedKindUpdate<TItem> = TItem Function({
  required TItem existing,
  required CollectionItemUpdatePayload payload,
  required DateTime updatedAt,
  required String? fallbackOwnerUserId,
  required String? fallbackOwnerLabel,
});

typedef OwnedKindToJson<TItem> = JsonMap Function(TItem item);
typedef OwnedKindFromJson<TItem> = TItem Function(JsonMap payload);
typedef OwnedKindSummary<TItem> = CollectionItemSummary Function(TItem item);
typedef OwnedKindCreatePayload<TItem> = CollectionItemCreatePayload Function(
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

  Future<CollectionItemMutationResult> createCollectionItem({
    required LocalDatabase database,
    required CollectionItemCreatePayload payload,
    required CatalogEntityRef resolvedCatalogRef,
    required String id,
    required DateTime createdAt,
    required bool? existingIsDigital,
    required String? ownerUserId,
    required String? ownerLabel,
  });

  Future<CollectionItemMutationResult> updateCollectionItem({
    required LocalDatabase database,
    required CollectionItemRef ref,
    required CollectionItemUpdatePayload payload,
    required DateTime updatedAt,
    required String? fallbackOwnerUserId,
    required String? fallbackOwnerLabel,
  });

  Future<CollectionItemCreatePayload?> createPayloadByRef(
    LocalDatabase database,
    CollectionItemRef ref,
  );

  Future<JsonMap?> payloadByRef(LocalDatabase database, CollectionItemRef ref);

  Future<({JsonMap payload, bool isDeleted})?> syncPayloadByRef(
    LocalDatabase database,
    CollectionItemRef ref,
  );

  Future<CollectionItemMutationResult> replaceFromPayload(
    LocalDatabase database,
    JsonMap payload,
  );

  Future<LibraryCollectionItemDispatch?> itemForLibraryByRef(
    LocalDatabase database,
    CollectionItemRef ref,
  );

  Future<CollectionItemMutationResult?> markDeletedByRef(
    LocalDatabase database,
    CollectionItemRef ref,
    DateTime deletedAt,
  );

  Future<void> updateLocation(
    LocalDatabase database,
    CollectionItemRef ref,
    String? locationId,
  );

  Future<List<CollectionItemSummary>> listActiveSummaries(LocalDatabase database);
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

  CollectionItemRef _refFor(TItem item) {
    final catalogRef = summary(item).catalogRef;
    if (catalogRef == null) {
      throw StateError(
        'The ${kind.apiValue} owned projection is missing catalogRef.',
      );
    }
    if (catalogRef.mediaKind != kind) {
      throw StateError(
        'The $kind owned projection returned a ${catalogRef.mediaKind} catalogRef.',
      );
    }
    return CollectionItemRef(
      kind: kind,
      id: CollectionItemId(itemId(item)),
    );
  }

  ({JsonMap payload, bool isDeleted}) _syncPayload(TItem item) {
    final payload = JsonMap.from(toJson(item));
    final isDeleted = payload['deleted_at'] != null;
    payload.remove('id');
    payload.remove('updated_at');
    payload.remove('deleted_at');
    payload.remove('reading');
    return (payload: payload, isDeleted: isDeleted);
  }

  CollectionItemMutationResult _mutationResult(TItem item) {
    final serialized = _syncPayload(item);
    return CollectionItemMutationResult(
      ref: _refFor(item),
      syncPayload: serialized.payload,
      isDeleted: serialized.isDeleted,
    );
  }

  @override
  Future<CollectionItemMutationResult> createCollectionItem({
    required LocalDatabase database,
    required CollectionItemCreatePayload payload,
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
  Future<CollectionItemMutationResult> updateCollectionItem({
    required LocalDatabase database,
    required CollectionItemRef ref,
    required CollectionItemUpdatePayload payload,
    required DateTime updatedAt,
    required String? fallbackOwnerUserId,
    required String? fallbackOwnerLabel,
  }) async {
    if (ref.kind != kind) {
      throw ArgumentError.value(
          ref, 'ref', 'Owned ref belongs to another kind');
    }
    final existing = await findById(database, ref.id.value);
    if (existing == null) throw StateError('Collection item not found');
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
  Future<CollectionItemCreatePayload?> createPayloadByRef(
    LocalDatabase database,
    CollectionItemRef ref,
  ) async {
    if (ref.kind != kind) return null;
    final item = await findById(database, ref.id.value);
    return item == null ? null : createPayload(item);
  }

  @override
  Future<JsonMap?> payloadByRef(
    LocalDatabase database,
    CollectionItemRef ref,
  ) async {
    if (ref.kind != kind) return null;
    final item = await findById(database, ref.id.value);
    return item == null ? null : JsonMap.from(toJson(item));
  }

  @override
  Future<({JsonMap payload, bool isDeleted})?> syncPayloadByRef(
    LocalDatabase database,
    CollectionItemRef ref,
  ) async {
    if (ref.kind != kind) return null;
    final item = await findById(database, ref.id.value);
    return item == null ? null : _syncPayload(item);
  }

  @override
  Future<CollectionItemMutationResult> replaceFromPayload(
    LocalDatabase database,
    JsonMap payload,
  ) async {
    final item = fromJson(payload);
    await upsert(database, item);
    return _mutationResult(item);
  }

  @override
  Future<LibraryCollectionItemDispatch?> itemForLibraryByRef(
    LocalDatabase database,
    CollectionItemRef ref,
  ) async {
    if (ref.kind != kind) return null;
    final item = await findById(database, ref.id.value);
    if (item == null) return null;
    return OpaqueLibraryCollectionItemDispatch(
      ref: ref,
      kind: kind,
      value: item,
    );
  }

  @override
  Future<CollectionItemMutationResult?> markDeletedByRef(
    LocalDatabase database,
    CollectionItemRef ref,
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
    CollectionItemRef ref,
    String? locationId,
  ) async {
    if (ref.kind != kind) return;
    final item = await findById(database, ref.id.value);
    if (item == null) return;
    await upsert(database, updateItemLocation(item, locationId));
  }

  @override
  Future<List<CollectionItemSummary>> listActiveSummaries(
    LocalDatabase database,
  ) async {
    final items = await listActive(database);
    return [for (final item in items) summary(item)];
  }
}
