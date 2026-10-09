import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_transport.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_kind_data.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_transport_codec.dart';

Future<Map<LibraryEntryRef, LibraryWorkspaceKindData>>
    enrichedWorkspaceKindDataByEntry(
  LocalDatabase db,
  Map<LibraryEntryRef, Map<String, dynamic>> kindDataByEntry,
) async {
  if (kindDataByEntry.isEmpty) return const {};
  final result = <LibraryEntryRef, LibraryWorkspaceKindData>{};
  for (final codec in libraryCatalogTransportCodecs) {
    final entriesForKind = <LibraryEntryRef, LibraryWorkspaceKindData>{};
    for (final entry in kindDataByEntry.entries) {
      if (entry.key.kind == codec.kind) {
        entriesForKind[entry.key] =
            codec.workspaceDataFromKindData(entry.value);
      }
    }
    if (entriesForKind.isEmpty) continue;

    if (codec case final CatalogWorkspaceDataBatchEnricher enricher) {
      result.addAll(
        await enricher.enrichWorkspaceDataForEntries(db, entriesForKind),
      );
      continue;
    }
    if (codec case final CatalogWorkspaceDataEnricher enricher) {
      for (final entry in entriesForKind.entries) {
        result[entry.key] = await enricher.enrichWorkspaceData(
          db,
          entry.value,
          libraryEntryRef: entry.key,
        );
      }
      continue;
    }
    result.addAll(entriesForKind);
  }
  return result;
}

/// Composition-root dispatch from schema-v1 catalog transport into the
/// owning kind's concrete workspace graph.
///
/// The returned interface is intentionally structural for mixed hosts. A
/// kind workspace immediately narrows it to its own catalog data type.
LibraryWorkspaceKindData workspaceCatalogDataFromTransport(
  CatalogImportTransport item,
) {
  return _workspaceCatalogDataFromDecoded(item.decodeItem());
}

Future<LibraryWorkspaceKindData> enrichedWorkspaceCatalogDataFromTransport(
  LocalDatabase db,
  CatalogImportTransport item,
) async {
  return enrichedWorkspaceCatalogDataFromItem(db, item.decodeItem());
}

Future<LibraryWorkspaceKindData> enrichedWorkspaceCatalogDataFromItem(
  LocalDatabase db,
  CatalogItemDto item, {
  LibraryEntryRef? libraryEntryRef,
}) async {
  for (final codec in libraryCatalogTransportCodecs) {
    if (codec.kind != item.mediaKind) continue;
    final data = codec.workspaceData(item);
    if (codec case final CatalogWorkspaceDataEnricher enricher) {
      return enricher.enrichWorkspaceData(
        db,
        data,
        libraryEntryRef: libraryEntryRef,
      );
    }
    return data;
  }
  throw StateError(
    'No typed workspace catalog codec registered for ${item.mediaKind}',
  );
}

/// Decodes kind-owned metadata already stored on an independent local entry.
/// This path intentionally receives no catalog DTO or Core identity.
LibraryWorkspaceKindData workspaceKindDataFromKindData(
  CatalogMediaKind kind,
  Map<String, dynamic> kindData,
) {
  for (final codec in libraryCatalogTransportCodecs) {
    if (codec.kind == kind) return codec.workspaceDataFromKindData(kindData);
  }
  throw StateError('No typed workspace codec registered for $kind');
}

LibraryWorkspaceKindData _workspaceCatalogDataFromDecoded(
  CatalogItemDto item,
) {
  for (final codec in libraryCatalogTransportCodecs) {
    if (codec.kind == item.mediaKind) {
      return codec.workspaceData(item);
    }
  }
  throw StateError(
    'No typed workspace catalog codec registered for ${item.mediaKind}',
  );
}
