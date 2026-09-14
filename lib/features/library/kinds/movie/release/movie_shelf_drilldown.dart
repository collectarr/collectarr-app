import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/movie/release/movie_release_detail_source.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_catalog_data.dart';
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

  final LibraryProjectionView item;
  final String sourceLabel;
  final int ownedCount;
  final int wishlistCount;
  final LibraryReleaseNodeRef node;
}

bool canOpenMovieShelfDrilldown(
  LibraryKindRegistration? type,
  LibraryProjectionView item,
) {
  if (item.node.scope != LibraryBrowserScope.title) {
    return false;
  }
  final kind = item.source.catalogData?.kind;
  if (kind == null) return false;
  final kindModule = type ?? libraryKindRegistrationForKind(kind);
  return kindModule.presentation.builder.canOpenKindDrilldown(item);
}

List<MovieShelfReleaseDrilldownItem> buildMovieShelfReleaseItems({
  required LibraryProjectionView titleItem,
  required List<OwnedItemSummary> ownedCopies,
  required List<WishlistItem> wishlistItems,
  required LibraryWorkspaceProjector<LibraryWorkspaceDto> projector,
}) {
  const releaseSource = MovieReleaseDetailSource();
  final catalog = titleItem.source.catalogData;
  if (catalog is! MovieWorkspaceCatalogData) {
    return const [];
  }
  final editions = catalog.metadata?.editions ?? const <CatalogEditionDto>[];
  final releaseEditions = [
    for (final edition in editions)
      if (ownedCopies.any(
            (item) {
              final targetRef = item.targetRef;
              return targetRef != null &&
                  releaseSource.matchesTarget(targetRef, edition);
            },
          ) ||
          wishlistItems.any(
            (item) => releaseSource.matchesTarget(item.catalogRef, edition),
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
  LibraryProjectionView titleItem,
  CatalogEditionDto edition, {
  required List<CatalogEditionDto> editions,
  required List<OwnedItemSummary> ownedCopies,
  required List<WishlistItem> wishlistItems,
  required LibraryWorkspaceProjector<LibraryWorkspaceDto> projector,
}) {
  const releaseSource = MovieReleaseDetailSource();
  final matchedOwnedCopies = ownedCopies.where(
    (item) {
      final targetRef = item.targetRef;
      return targetRef != null &&
          releaseSource.matchesTarget(targetRef, edition);
    },
  ).toList(growable: false);
  final matchedWishlistItems = wishlistItems
      .where(
        (item) => releaseSource.matchesTarget(item.catalogRef, edition),
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
    sourceLabel: releaseSource.sourceLabel(edition),
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

  final LibraryProjectionView titleItem;
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
