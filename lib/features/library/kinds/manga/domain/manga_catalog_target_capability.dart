import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/config/library_catalog_target_capability.dart';

/// Manga-owned interpretation of nested catalog target references.
final class MangaCatalogTargetCapability
    implements LibraryCatalogTargetCapability {
  const MangaCatalogTargetCapability();

  @override
  CatalogEntityRef resolve(
    CatalogEntityRef root,
    LibraryCatalogTargetSelection _,
  ) {
    return root.rootScope;
  }

  @override
  LibraryCatalogTargetParts parts(CatalogEntityRef? _) {
    return const LibraryCatalogTargetParts();
  }
}
