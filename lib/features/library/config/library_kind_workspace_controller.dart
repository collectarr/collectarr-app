import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/config/library_kind_drilldown.dart';
import 'package:collectarr_app/features/library/config/library_kind_browser_delegate.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

class LibraryKindWorkspaceController
    extends LibraryReleaseFolderBrowserDelegate {
  LibraryKindWorkspaceController({super.initialReleaseFolderTitleItemId});

  void closeAllKindDrilldowns() {
    closeReleaseFolder();
    closeItemDrilldown();
  }

  @override
  bool canOpenItemDetailDrilldown(
    LibraryKindRuntime type,
    LibraryProjectionRuntime item,
  ) {
    return canOpenKindDrilldown(type, item);
  }

  @override
  void openItemDetailDrilldown(
    LibraryKindRuntime type,
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
    required LibraryKindRuntime type,
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
    if (drilldownState == null ||
        drilldownState.rootItemId != selectedItem.node.titleItemId) {
      return null;
    }
    return buildLibraryKindDrilldown(
      context: context,
      type: type,
      selectedItem: selectedItem,
      accent: accent,
      coverSize: viewState.coverSize,
      onBack: closeItemDrilldown,
      onRefreshFromCore: onRefreshFromCore,
      onOpenTitleDetails: onOpenTitleDetails,
      ownedCopies: allOwnedCopies,
      wishlistItems: allWishlistItems,
      selectedReleaseId: drilldownState.selectedReleaseId,
      onSelectRelease: (releaseId) => openItemDrilldown(
        drilldownState.rootItemId,
        selectedReleaseId: releaseId,
      ),
    );
  }
}

LibraryKindBrowserDelegate buildMovieBrowserDelegate() {
  return LibraryKindWorkspaceController();
}
