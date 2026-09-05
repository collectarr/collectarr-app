import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/release/video_release_source.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_workspace_grid.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_workspace_card.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MovieShelfReleaseDrilldownItem {
  const MovieShelfReleaseDrilldownItem({
    required this.item,
    required this.sourceLabel,
    required this.ownedCount,
    required this.wishlistCount,
    required this.node,
  });

  final LibraryProjectionRuntime item;
  final String sourceLabel;
  final int ownedCount;
  final int wishlistCount;
  final LibraryReleaseNodeRef node;
}

bool canOpenMovieShelfDrilldown(
  LibraryKindRuntime? type,
  LibraryProjectionRuntime item,
) {
  if (item.node.scope != LibraryBrowserScope.title) {
    return false;
  }
  final kind = item.source.catalogItem?.kind.trim().toLowerCase();
  if (kind == null) return false;
  final runtime =
      type ?? libraryKindRuntimeForKind(catalogMediaKindFromApiValue(kind));
  return runtime.presentation.builder.canOpenKindDrilldown(item);
}

List<MovieShelfReleaseDrilldownItem> buildMovieShelfReleaseItems({
  required LibraryProjectionRuntime titleItem,
  required List<OwnedItem> ownedCopies,
  required List<WishlistItem> wishlistItems,
  required LibraryWorkspaceProjector<LibraryWorkspaceDto> projector,
}) {
  final catalogItem = titleItem.source.catalogItem;
  if (catalogItem == null) {
    return const [];
  }
  final editions = resolveVideoCatalogEditionsForCatalogItem(
    catalogItem,
    ownedItems: ownedCopies,
    wishlistItems: wishlistItems,
  );
  final releaseEditions = [
    for (final edition in editions)
      if (ownedCopies.any(
            (item) => matchesVideoReleaseAnchor(
              edition,
              editionId: item.editionId,
              variantId: item.variantId,
              bundleReleaseId: item.bundleReleaseId,
            ),
          ) ||
          wishlistItems.any(
            (item) => matchesVideoReleaseAnchor(
              edition,
              editionId: item.editionId,
              variantId: item.variantId,
              bundleReleaseId: item.bundleReleaseId,
            ),
          ))
        edition,
  ];
  return [
    for (final edition in releaseEditions)
      _buildDrilldownItem(
        titleItem,
        edition,
        editions: releaseEditions,
        ownedCopies: ownedCopies,
        wishlistItems: wishlistItems,
        projector: projector,
      ),
  ];
}

MovieShelfReleaseDrilldownItem _buildDrilldownItem(
  LibraryProjectionRuntime titleItem,
  CatalogEdition edition, {
  required List<CatalogEdition> editions,
  required List<OwnedItem> ownedCopies,
  required List<WishlistItem> wishlistItems,
  required LibraryWorkspaceProjector<LibraryWorkspaceDto> projector,
}) {
  final matchedOwnedCopies = ownedCopies
      .where(
        (item) => matchesVideoReleaseAnchor(
          edition,
          editionId: item.editionId,
          variantId: item.variantId,
          bundleReleaseId: item.bundleReleaseId,
        ),
      )
      .toList(growable: false);
  final matchedWishlistItems = wishlistItems
      .where(
        (item) => matchesVideoReleaseAnchor(
          edition,
          editionId: item.editionId,
          variantId: item.variantId,
          bundleReleaseId: item.bundleReleaseId,
        ),
      )
      .toList(growable: false);

  final releaseNode = LibraryReleaseNodeRef(
    titleItemId: titleItem.node.titleItemId,
    releaseId: edition.id,
    edition: edition,
  );

  final releaseState = LibraryReleaseState(
    isOwned: matchedOwnedCopies.isNotEmpty,
    isWishlisted: matchedWishlistItems.isNotEmpty,
    isTracked: false,
    referenceEditionId: edition.id,
  );

  final dto = projector.projectRelease(
    source: titleItem.source,
    node: releaseNode,
    releaseState: releaseState,
  );

  final projectionItem = LibraryProjectionItem(
    source: titleItem.source,
    node: releaseNode,
    dto: dto,
    customFieldBadges: titleItem.customFieldBadges,
  );

  return MovieShelfReleaseDrilldownItem(
    item: projectionItem,
    sourceLabel: videoReleaseSourceLabel(edition),
    ownedCount:
        matchedOwnedCopies.fold<int>(0, (sum, item) => sum + item.quantity),
    wishlistCount: matchedWishlistItems.length,
    node: releaseNode,
  );
}

class MovieShelfReleaseDrilldown extends StatelessWidget {
  const MovieShelfReleaseDrilldown({
    super.key,
    required this.titleItem,
    required this.items,
    required this.selectedReleaseId,
    required this.coverSize,
    required this.accent,
    required this.onBack,
    required this.onRefreshFromCore,
    required this.onSelectRelease,
    required this.onOpenTitleDetails,
  });

  final LibraryProjectionRuntime titleItem;
  final List<MovieShelfReleaseDrilldownItem> items;
  final String? selectedReleaseId;
  final double coverSize;
  final Color accent;
  final VoidCallback onBack;
  final Future<void> Function() onRefreshFromCore;
  final void Function(String releaseId) onSelectRelease;
  final VoidCallback onOpenTitleDetails;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Scaffold(
      backgroundColor: palette.surfaceSubtle,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: Text(titleItem.dto.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRefreshFromCore,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: onOpenTitleDetails,
          ),
        ],
      ),
      body: items.isEmpty
          ? const Center(child: Text('No release variants found'))
          : LibraryWorkspaceGrid<MovieShelfReleaseDrilldownItem>(
              items: items,
              maxCrossAxisExtent: coverSize,
              mainAxisExtent: coverSize / 0.68,
              emptyBuilder: (context) =>
                  const Center(child: Text('No release variants found')),
              itemBuilder: (context, drillItem) {
                final isSelected =
                    drillItem.node.releaseId == selectedReleaseId;
                return LibraryWorkspaceCard(
                  item: drillItem.item,
                  selected: isSelected,
                  onTap: () => onSelectRelease(drillItem.node.releaseId),
                  dateFormatter: (DateTime d) => '${d.year}',
                  moneyFormatter: (int? c, String? cur) => '\$$c',
                );
              },
            ),
    );
  }
}
