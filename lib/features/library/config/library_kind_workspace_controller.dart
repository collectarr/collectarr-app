import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/config/library_kind_drilldown.dart';
import 'package:collectarr_app/features/library/config/library_kind_browser_delegate.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_shelf_drilldown.dart';
import 'package:collectarr_app/features/library/kinds/video/release/video_shelf_drilldown.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

class LibraryKindWorkspaceController extends LibraryReleaseFolderBrowserDelegate {
  LibraryKindWorkspaceController({super.initialReleaseFolderTitleItemId});

  void closeAllKindDrilldowns() {
    closeReleaseFolder();
    closeItemDrilldown();
  }

  @override
  bool canOpenItemDetailDrilldown(
    LibraryTypeConfig type,
    LibraryProjectionRuntime item,
  ) {
    return canOpenKindDrilldown(type, item);
  }

  @override
  void openItemDetailDrilldown(
    LibraryTypeConfig type,
    LibraryProjectionRuntime item,
  ) {
    if (!canOpenItemDetailDrilldown(type, item)) {
      return;
    }
    openItemDrilldown(item.node.titleItemId);
  }

  @override
  Widget? buildWorkspaceOverride({
    required BuildContext context,
    required LibraryTypeConfig type,
    required LibraryProjection projection,
    required LibraryProjectionRuntime selectedItem,
    required LibraryWorkspaceViewState viewState,
    required Color accent,
    required Future<void> Function() onRefreshFromCore,
    required VoidCallback onOpenTitleDetails,
    required List<OwnedItem> allOwnedCopies,
    required List<WishlistItem> allWishlistItems,
  }) {
    if (!canOpenKindDrilldown(type, selectedItem)) {
      return null;
    }
    final drilldownState = itemDrilldownState;
    if (drilldownState == null || drilldownState.rootItemId != selectedItem.node.titleItemId) {
      return null;
    }
    if (selectedItem.source.catalogItem?.kind.toLowerCase() == 'tv') {
      return TvShelfSeasonDrilldown(
        titleItem: selectedItem,
        coverSize: viewState.coverSize,
        accent: accent,
        onBack: closeItemDrilldown,
        onRefreshFromCore: onRefreshFromCore,
        onOpenTitleDetails: onOpenTitleDetails,
      );
    }

    final drilldownItems = buildVideoShelfReleaseItems(
      titleItem: selectedItem,
      ownedCopies: allOwnedCopies,
      wishlistItems: allWishlistItems,
      projector: type.presentation.projector,
    );
    return VideoShelfReleaseDrilldown(
      titleItem: selectedItem,
      items: drilldownItems,
      selectedReleaseId: drilldownState.selectedReleaseId,
      coverSize: viewState.coverSize,
      accent: accent,
      onBack: closeItemDrilldown,
      onRefreshFromCore: onRefreshFromCore,
      onSelectRelease: (releaseId) => openItemDrilldown(
        drilldownState.rootItemId,
        selectedReleaseId: releaseId,
      ),
      onOpenTitleDetails: onOpenTitleDetails,
    );
  }
}

LibraryKindBrowserDelegate buildMovieBrowserDelegate() {
  return LibraryKindWorkspaceController();
}
