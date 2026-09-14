import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';

/// Kind-owned release semantics consumed by the generic detail host.
///
/// The host may render an edition and coordinate actions, but it never decides
/// what an edition, variant, or bundle means. Each owning kind turns its
/// concrete release model into this small structural UI boundary.
abstract interface class LibraryReleaseDetailSource {
  const LibraryReleaseDetailSource();

  List<CatalogEditionDto> resolveCatalogData(
    LibraryWorkspaceCatalogData catalogData, {
    Iterable<OwnedItemSummary> ownedItems,
    Iterable<WishlistItem> wishlistItems,
  });

  CatalogSearchCandidate candidateForCatalogData(
    LibraryWorkspaceCatalogData catalogData,
  );

  CatalogEntityRef targetRefForEdition(
    CatalogEntityRef rootRef,
    CatalogEditionDto edition,
  );

  bool matchesTarget(CatalogEntityRef targetRef, CatalogEditionDto edition);

  String sourceLabel(CatalogEditionDto edition);

  bool isCatalogRelease(CatalogEditionDto edition);

  bool isTitleSnapshotRelease(CatalogEditionDto edition);

  String? preferredVariantId(CatalogEditionDto edition);
}
