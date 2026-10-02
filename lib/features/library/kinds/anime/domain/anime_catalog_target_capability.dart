import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/config/library_catalog_target_capability.dart';

/// Anime-owned interpretation of nested catalog target references.
final class AnimeCatalogTargetCapability
    implements LibraryCatalogTargetCapability {
  const AnimeCatalogTargetCapability();

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
