import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resolves hierarchy behavior only for registered kinds.
///
/// Unknown/provider-only kinds must not silently acquire the generic hierarchy
/// behavior. They have no owning hierarchy semantics and therefore fail at
/// the dispatch boundary.
LibraryHierarchyCapability requireLibraryHierarchyForKind(
  CatalogMediaKind kind,
) {
  final registration = collectarrKindRegistrations[kind];
  if (registration == null) {
    throw UnsupportedError(
      'Hierarchy is not supported for unregistered kind: $kind',
    );
  }
  return libraryHierarchyForKind(registration.kind);
}

final libraryHierarchyProvider = FutureProvider.autoDispose.family<
    List<LibraryHierarchyNode>,
    ({
      CatalogMediaKind kind,
      String itemId,
    })>((ref, params) async {
  final hierarchy = requireLibraryHierarchyForKind(params.kind);
  try {
    final api = ref.watch(apiClientProvider);
    return await hierarchy.fetchChildren(
      api: api,
      itemId: params.itemId,
    );
  } catch (_) {
    return const <LibraryHierarchyNode>[];
  }
});
