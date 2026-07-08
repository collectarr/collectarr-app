import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/config/library_kind_browser_delegate.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_shelf_drilldown.dart';
import 'package:collectarr_app/features/library/kinds/video/video_shelf_drilldown.dart';
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
    LibraryProjectionItem item,
  ) {
    return canOpenVideoShelfDrilldown(type, item.entry);
  }

  @override
  void openItemDetailDrilldown(
    LibraryTypeConfig type,
    LibraryProjectionItem item,
  ) {
    if (!canOpenItemDetailDrilldown(type, item)) {
      return;
    }
    openItemDrilldown(item.entry.id);
  }

  @override
  Widget? buildWorkspaceOverride({
    required BuildContext context,
    required LibraryTypeConfig type,
    required LibraryProjection projection,
    required LibraryProjectionItem selectedItem,
    required LibraryWorkspaceViewState viewState,
    required Color accent,
    required Future<void> Function() onRefreshFromCore,
    required VoidCallback onOpenTitleDetails,
    required List<OwnedItem> allOwnedCopies,
    required List<WishlistItem> allWishlistItems,
  }) {
    if (!canOpenVideoShelfDrilldown(type, selectedItem.entry)) {
      return null;
    }
    final drilldownState = itemDrilldownState;
    if (drilldownState == null || drilldownState.rootItemId != selectedItem.entry.id) {
      return null;
    }
    if (selectedItem.entry.mediaType == 'tv') {
      return TvShelfSeasonDrilldown(
        titleEntry: selectedItem.entry,
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
      releaseEntryBuilder: type.presentation.releaseEntryBuilder,
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
