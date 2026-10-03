import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_transport.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_transport_codec.dart';

/// Composition-root dispatch from schema-v1 catalog transport into the
/// owning kind's concrete workspace graph.
///
/// The returned interface is intentionally structural for mixed hosts. A
/// kind workspace immediately narrows it to its own catalog data type.
LibraryWorkspaceCatalogData workspaceCatalogDataFromTransport(
  CatalogImportTransport item,
) {
  return _workspaceCatalogDataFromDecoded(item.decodeItem());
}

Future<LibraryWorkspaceCatalogData> enrichedWorkspaceCatalogDataFromTransport(
  LocalDatabase db,
  CatalogImportTransport item,
) async {
  return enrichedWorkspaceCatalogDataFromItem(db, item.decodeItem());
}

Future<LibraryWorkspaceCatalogData> enrichedWorkspaceCatalogDataFromItem(
  LocalDatabase db,
  CatalogItemDto item, {
  LibraryEntryRef? libraryEntryRef,
}
) async {
  for (final codec in libraryCatalogTransportCodecs) {
    if (codec.kind != item.mediaKind) continue;
    final data = codec.workspaceData(item);
    if (codec case final CatalogWorkspaceDataEnricher enricher) {
      return enricher.enrichWorkspaceData(
        db,
        item,
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

LibraryWorkspaceCatalogData _workspaceCatalogDataFromDecoded(
  CatalogItemDto item,
) {
  for (final codec in libraryCatalogTransportCodecs) {
    if (codec.kind == item.catalogRef.kind) {
      return codec.workspaceData(item);
    }
  }
  throw StateError(
    'No typed workspace catalog codec registered for ${item.catalogRef.kind}',
  );
}
