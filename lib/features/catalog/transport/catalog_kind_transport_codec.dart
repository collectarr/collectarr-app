import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_summary_reader.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_repository.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_kind_data.dart';
import 'package:collectarr_app/features/library/entries/library_entry_store.dart';

/// Non-generic transport operations that the mixed catalog composition root
/// may invoke after dispatching by [kind].
///
/// This interface deliberately contains behavior, not a type-erased catalog
/// value. The generic codec below remains the concrete kind implementation;
/// registries store only this boundary interface.
abstract interface class CatalogKindTransportBoundary
    implements CatalogKindSummaryReader {
  Future<Map<String, int>> countCatalogValues(
    LocalDatabase db,
    String listName,
    Iterable<String> normalizedValues,
  );

  Future<Map<String, int>> replacementValuesByIds(
    LocalDatabase db,
    Iterable<String> ids,
  );

  Future<void> captureDerivedData(
    PickListRepository pickLists,
    SerialAuthorityRepository serialAuthority,
    CatalogItemDto item,
  );

  Future<List<CatalogItemDto>> listTransport(LocalDatabase db);

  /// Decodes transport into the owning kind's typed workspace projection.
  LibraryWorkspaceKindData workspaceData(CatalogItemDto item);

  /// Projects an already-local kind document without manufacturing a Core
  /// Catalog Item identity for its owning Library Entry.
  LibraryWorkspaceKindData workspaceDataFromKindData(
    Map<String, dynamic> kindData,
  );
}

/// Explicit schema-v1 transport adapter for one catalog kind.
///
/// This is not a Library domain repository or a generic catalog model. It is
/// the serialization boundary used by sync, admin/transport workflows, and
/// mixed infrastructure that must persist a complete catalog snapshot. Kind
/// code owns the mapping to and from its typed catalog item; converted kinds
/// may declare the shared item cache as their primary local store.
abstract interface class CatalogKindTransportCodec<
    TCatalog extends JsonEncodable> implements CatalogKindTransportBoundary {
  /// Decodes the transport boundary into the owning kind's concrete domain.
  ///
  /// Generic catalog orchestration must not inspect the returned value. The
  /// generated registry may invoke this method at the dispatch boundary, but
  /// the concrete codec owns all interpretation of the DTO.
  TCatalog decode(CatalogItemDto item);

  /// Encodes one typed kind value into its canonical flattened catalog item.
  /// The caller supplies the catalog identity; kind field mapping remains here.
  CatalogItemDto encode(String id, TCatalog item);

  /// Decodes kind-owned metadata from an independent local Library Entry.
  TCatalog decodeKindData(Map<String, dynamic> kindData);

  /// Captures derived values from the already decoded kind aggregate.
  ///
  /// Implementations may keep the transport adapter below as a very small
  /// boundary method, but all semantic extraction happens through this typed
  /// operation.
  Future<void> captureDerivedDataTyped(
    PickListRepository pickLists,
    SerialAuthorityRepository serialAuthority,
    TCatalog item,
  );

  /// Projects a concrete kind value for mixed/global read models.
  CatalogDisplaySummary summarize(String catalogItemId, TCatalog item);

  /// Decodes the transport payload into the owning kind's workspace data.
  ///
  /// The returned interface exposes only structural display values to mixed
  /// infrastructure. Kind workspace code downcasts/dispatches to its own
  /// concrete implementation immediately.
}

/// Optional kind-entry enrichment for the synchronous workspace projection.
///
/// Mixed infrastructure may ask a codec to attach a derived, read-only
/// projection after transport decoding. The semantic query and returned
/// typed value remain entry by the concrete kind.
abstract interface class CatalogWorkspaceDataEnricher {
  Future<LibraryWorkspaceKindData> enrichWorkspaceData(
    LocalDatabase db,
    LibraryWorkspaceKindData data, {
    LibraryEntryRef? libraryEntryRef,
  });
}

/// Optional batched enrichment for entry rows projected together in a shelf.
///
/// Kind implementations can load related personal activity in one bounded
/// query instead of issuing one query per visible entry.
abstract interface class CatalogWorkspaceDataBatchEnricher {
  Future<Map<LibraryEntryRef, LibraryWorkspaceKindData>>
      enrichWorkspaceDataForEntries(
    LocalDatabase db,
    Map<LibraryEntryRef, LibraryWorkspaceKindData> dataByEntry,
  );
}

/// Runs the kind-entry summary projection at the transport boundary.
extension CatalogKindTransportSummary on CatalogKindTransportBoundary {
  CatalogDisplaySummary summarizeTransport(CatalogItemDto item) {
    final codec = this as CatalogKindTransportCodec<dynamic>;
    return codec.summarize(item.id, codec.decode(item));
  }
}

/// Encodes typed kind values through the codec selected by the kind registry.
extension CatalogKindTransportEncoding on CatalogKindTransportBoundary {
  CatalogItemDto encodeTransport(String id, JsonEncodable item) {
    final codec = this as CatalogKindTransportCodec<dynamic>;
    return codec.encode(id, item);
  }
}

/// Reads typed metadata from Core snapshots and locally owned entries.
/// Local entry identities remain in their own namespace.
extension CatalogKindMetadataReads<TCatalog extends JsonEncodable>
    on CatalogKindTransportCodec<TCatalog> {
  Future<List<TCatalog>> listCatalogAndEntryMetadata(LocalDatabase db) async {
    final catalogItems = await listTransport(db);
    final localEntries = await LibraryEntryStore(db).list(kind: kind);
    return [
      for (final item in catalogItems) decode(item),
      for (final entry in localEntries) decodeKindData(entry.catalogData),
    ];
  }
}
