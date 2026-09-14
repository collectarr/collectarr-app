import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';

/// Composition-root dispatch from schema-v1 catalog transport into the
/// owning kind's concrete workspace graph.
///
/// The returned interface is intentionally structural for mixed hosts. A
/// kind workspace immediately narrows it to its own catalog data type.
LibraryWorkspaceCatalogData workspaceCatalogDataFromTransport(
  CatalogSearchCandidate item,
) {
  for (final codec in collectarrKindCatalogTransportCodecs) {
    if (codec.kind == item.mediaKind) {
      return codec.workspaceData(item.toTransport());
    }
  }
  throw StateError(
    'No typed workspace catalog codec registered for ${item.mediaKind}',
  );
}
