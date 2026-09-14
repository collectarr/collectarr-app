import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/release/library_release_detail_option.dart';

/// Kind-owned release semantics consumed by the generic detail host.
///
/// The host may render an edition and coordinate actions, but it never decides
/// what an edition, variant, or bundle means. Each owning kind turns its
/// concrete release model into this small structural UI boundary.
abstract interface class LibraryReleaseDetailSource {
  const LibraryReleaseDetailSource();

  CatalogSearchCandidate candidateForCatalogData(
    LibraryWorkspaceCatalogData catalogData,
  );

  /// Resolves kind-owned release semantics before entering the generic detail
  /// host. Matching and target construction stay inside the owning kind.
  List<LibraryReleaseDetailOption> detailOptionsForCatalogData(
    LibraryWorkspaceCatalogData catalogData,
    CatalogEntityRef rootRef, {
    Iterable<OwnedItemSummary> ownedItems = const <OwnedItemSummary>[],
    Iterable<WishlistItem> wishlistItems = const <WishlistItem>[],
  });
}
