import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/library/entries/library_entry_store.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/config/library_entry_create_payload.dart';
import 'package:collectarr_app/features/library/config/library_entry_mutation_result.dart';
import 'package:collectarr_app/features/library/config/library_entry_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';

typedef EntryKindFind<TItem> = Future<TItem?> Function(
  LocalDatabase database,
  String id,
);

typedef EntryKindUpsert<TItem> = Future<void> Function(
  LocalDatabase database,
  TItem item,
);

typedef EntryKindList<TItem> = Future<List<TItem>> Function(
  LocalDatabase database,
);

typedef EntryKindCreate<TItem> = TItem Function({
  required LibraryEntryCreatePayload payload,
  required String id,
  required DateTime createdAt,
  required bool? existingIsDigital,
  required String? ownerUserId,
  required String? ownerLabel,
});

typedef EntryKindCreateWithCatalog<TItem> = TItem Function({
  required LibraryEntryCreatePayload payload,
  required CatalogItemDto sourceCatalogItem,
  required String id,
  required DateTime createdAt,
  required bool? existingIsDigital,
  required String? ownerUserId,
  required String? ownerLabel,
});

typedef EntryKindUpdate<TItem> = TItem Function({
  required TItem existing,
  required LibraryEntryUpdatePayload payload,
  required DateTime updatedAt,
  required String? fallbackOwnerUserId,
  required String? fallbackOwnerLabel,
});

typedef EntryKindToJson<TItem> = JsonMap Function(TItem item);
typedef EntryKindFromJson<TItem> = TItem Function(JsonMap payload);
typedef EntryKindSummary<TItem> = LibraryEntrySummary Function(TItem item);
typedef EntryKindCreatePayload<TItem> = LibraryEntryCreatePayload Function(
  TItem item,
);
typedef EntryKindItemId<TItem> = String Function(TItem item);
typedef EntryKindMarkDeleted<TItem> = TItem Function(
  TItem item,
  DateTime deletedAt,
);
typedef EntryKindUpdateLocation<TItem> = TItem Function(
  TItem item,
  String? locationId,
);

/// Structural Entry contributor implemented by one library kind.
abstract interface class EntryKindContributor {
  CatalogMediaKind get kind;

  Future<LibraryEntryMutationResult> createLibraryEntry({
    required LocalDatabase database,
    required LibraryEntryCreatePayload payload,
    required CatalogEntityRef resolvedCatalogRef,
    required String id,
    required DateTime createdAt,
    required bool? existingIsDigital,
    required String? ownerUserId,
    required String? ownerLabel,
  });

  Future<LibraryEntryMutationResult> updateLibraryEntry({
    required LocalDatabase database,
    required LibraryEntryRef ref,
    required LibraryEntryUpdatePayload payload,
    required DateTime updatedAt,
    required String? fallbackOwnerUserId,
    required String? fallbackOwnerLabel,
  });

  Future<LibraryEntryCreatePayload?> createPayloadByRef(
    LocalDatabase database,
    LibraryEntryRef ref,
  );

  Future<JsonMap?> payloadByRef(LocalDatabase database, LibraryEntryRef ref);

  Future<({JsonMap payload, bool isDeleted})?> syncPayloadByRef(
    LocalDatabase database,
    LibraryEntryRef ref,
  );

  Future<LibraryEntryMutationResult> replaceFromPayload(
    LocalDatabase database,
    JsonMap payload,
  );

  Future<LibraryEntryDispatch?> itemForLibraryByRef(
    LocalDatabase database,
    LibraryEntryRef ref,
  );

  Future<List<LibraryEntryDispatch>> listActiveDispatches(
    LocalDatabase database,
  );

  Future<LibraryEntryMutationResult?> markDeletedByRef(
    LocalDatabase database,
    LibraryEntryRef ref,
    DateTime deletedAt,
  );

  Future<void> updateLocation(
    LocalDatabase database,
    LibraryEntryRef ref,
    String? locationId,
  );

  Future<List<LibraryEntrySummary>> listActiveSummaries(LocalDatabase database);
}

/// Generic orchestration for a kind's typed repository.
///
/// The generic part only performs structural persistence mechanics. Every
/// semantic cast, payload validation, aggregate conversion and projection is
/// supplied by the owning kind in its contributor file.
final class TypedEntryKindContributor<TItem> implements EntryKindContributor {
  const TypedEntryKindContributor({
    required this.kind,
    required this.findById,
    required this.upsert,
    required this.listActive,
    this.createItem,
    this.createItemWithCatalog,
    required this.updateItem,
    required this.toJson,
    required this.fromJson,
    required this.summary,
    required this.createPayload,
    required this.itemId,
    required this.markDeleted,
    required this.updateItemLocation,
  }) : assert((createItem == null) != (createItemWithCatalog == null));

  @override
  final CatalogMediaKind kind;
  final EntryKindFind<TItem> findById;
  final EntryKindUpsert<TItem> upsert;
  final EntryKindList<TItem> listActive;
  final EntryKindCreate<TItem>? createItem;
  final EntryKindCreateWithCatalog<TItem>? createItemWithCatalog;
  final EntryKindUpdate<TItem> updateItem;
  final EntryKindToJson<TItem> toJson;
  final EntryKindFromJson<TItem> fromJson;
  final EntryKindSummary<TItem> summary;
  final EntryKindCreatePayload<TItem> createPayload;
  final EntryKindItemId<TItem> itemId;
  final EntryKindMarkDeleted<TItem> markDeleted;
  final EntryKindUpdateLocation<TItem> updateItemLocation;

  LibraryEntryRef _refFor(TItem item) {
    final ref = summary(item).ref;
    if (ref.kind != kind) {
      throw StateError(
        'The $kind entry projection returned a ${ref.kind} entry ref.',
      );
    }
    if (ref.id.value != itemId(item)) {
      throw StateError('Entry projection ID does not match its stored item.');
    }
    return LibraryEntryRef(
      kind: kind,
      id: LibraryEntryId(itemId(item)),
    );
  }

  Future<({JsonMap payload, bool isDeleted})> _syncPayload(
      LocalDatabase database, TItem item) async {
    final record = await LibraryEntryStore(database).find(kind, itemId(item));
    if (record == null) throw StateError('Library entry was not persisted.');
    return (payload: record.toJson(), isDeleted: record.deletedAt != null);
  }

  Future<LibraryEntryMutationResult> _mutationResult(
      LocalDatabase database, TItem item) async {
    final serialized = await _syncPayload(database, item);
    return LibraryEntryMutationResult(
      ref: _refFor(item),
      syncPayload: serialized.payload,
      isDeleted: serialized.isDeleted,
    );
  }

  @override
  Future<LibraryEntryMutationResult> createLibraryEntry({
    required LocalDatabase database,
    required LibraryEntryCreatePayload payload,
    required CatalogEntityRef resolvedCatalogRef,
    required String id,
    required DateTime createdAt,
    required bool? existingIsDigital,
    required String? ownerUserId,
    required String? ownerLabel,
  }) async {
    final source = await CatalogItemCacheRepository(database)
        .find(resolvedCatalogRef.toCatalogItemRef());
    if (source == null) {
      throw StateError('The source catalog item is unavailable locally.');
    }
    final sourceEntry = await LibraryEntryStore(database).find(kind, source.id);
    final createWithCatalog = createItemWithCatalog;
    final personal = createWithCatalog == null
        ? createItem!(
            payload: payload,
            id: id,
            createdAt: createdAt,
            existingIsDigital: existingIsDigital,
            ownerUserId: ownerUserId,
            ownerLabel: ownerLabel,
          )
        : createWithCatalog(
            payload: payload,
            sourceCatalogItem: source,
            id: id,
            createdAt: createdAt,
            existingIsDigital: existingIsDigital,
            ownerUserId: ownerUserId,
            ownerLabel: ownerLabel,
          );
    final item = fromJson({
      ...toJson(personal),
      'catalog_data': source.kindData,
      'source_catalog_ref': (sourceEntry?.sourceCatalogRef ??
              (source.origin == CatalogItemOrigin.core
                  ? source.catalogItemRef
                  : null))
          ?.toJson(),
    });
    await upsert(database, item);
    return _mutationResult(database, item);
  }

  @override
  Future<LibraryEntryMutationResult> updateLibraryEntry({
    required LocalDatabase database,
    required LibraryEntryRef ref,
    required LibraryEntryUpdatePayload payload,
    required DateTime updatedAt,
    required String? fallbackOwnerUserId,
    required String? fallbackOwnerLabel,
  }) async {
    if (ref.kind != kind) {
      throw ArgumentError.value(
          ref, 'ref', 'Entry ref belongs to another kind');
    }
    final existing = await findById(database, ref.id.value);
    if (existing == null) throw StateError('Library entry not found');
    final updated = updateItem(
      existing: existing,
      payload: payload,
      updatedAt: updatedAt,
      fallbackOwnerUserId: fallbackOwnerUserId,
      fallbackOwnerLabel: fallbackOwnerLabel,
    );
    await upsert(database, updated);
    return _mutationResult(database, updated);
  }

  @override
  Future<LibraryEntryCreatePayload?> createPayloadByRef(
    LocalDatabase database,
    LibraryEntryRef ref,
  ) async {
    if (ref.kind != kind) return null;
    final item = await findById(database, ref.id.value);
    return item == null ? null : createPayload(item);
  }

  @override
  Future<JsonMap?> payloadByRef(
    LocalDatabase database,
    LibraryEntryRef ref,
  ) async {
    if (ref.kind != kind) return null;
    final item = await findById(database, ref.id.value);
    return item == null ? null : JsonMap.from(toJson(item));
  }

  @override
  Future<({JsonMap payload, bool isDeleted})?> syncPayloadByRef(
    LocalDatabase database,
    LibraryEntryRef ref,
  ) async {
    if (ref.kind != kind) return null;
    final item = await findById(database, ref.id.value);
    return item == null ? null : await _syncPayload(database, item);
  }

  @override
  Future<LibraryEntryMutationResult> replaceFromPayload(
    LocalDatabase database,
    JsonMap payload,
  ) async {
    final record = LibraryEntryRecord.fromJson(payload);
    if (record.kind != kind) {
      throw const FormatException('Library entry kind mismatch.');
    }
    await LibraryEntryStore(database).put(record);
    final item = fromJson(record.toKindJson());
    return _mutationResult(database, item);
  }

  @override
  Future<LibraryEntryDispatch?> itemForLibraryByRef(
    LocalDatabase database,
    LibraryEntryRef ref,
  ) async {
    if (ref.kind != kind) return null;
    final item = await findById(database, ref.id.value);
    if (item == null) return null;
    return OpaqueLibraryEntryDispatch(
      ref: ref,
      kind: kind,
      value: item,
    );
  }

  @override
  Future<List<LibraryEntryDispatch>> listActiveDispatches(
    LocalDatabase database,
  ) async {
    final items = await listActive(database);
    return [
      for (final item in items)
        OpaqueLibraryEntryDispatch(
          ref: _refFor(item),
          kind: kind,
          value: item as Object,
        ),
    ];
  }

  @override
  Future<LibraryEntryMutationResult?> markDeletedByRef(
    LocalDatabase database,
    LibraryEntryRef ref,
    DateTime deletedAt,
  ) async {
    if (ref.kind != kind) return null;
    final item = await findById(database, ref.id.value);
    if (item == null) return null;
    final deleted = markDeleted(item, deletedAt);
    await upsert(database, deleted);
    return _mutationResult(database, deleted);
  }

  @override
  Future<void> updateLocation(
    LocalDatabase database,
    LibraryEntryRef ref,
    String? locationId,
  ) async {
    if (ref.kind != kind) return;
    final item = await findById(database, ref.id.value);
    if (item == null) return;
    await upsert(database, updateItemLocation(item, locationId));
  }

  @override
  Future<List<LibraryEntrySummary>> listActiveSummaries(
    LocalDatabase database,
  ) async {
    final items = await listActive(database);
    return [for (final item in items) summary(item)];
  }
}
