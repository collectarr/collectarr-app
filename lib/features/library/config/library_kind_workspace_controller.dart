import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/config/library_kind_drilldown.dart';
import 'package:collectarr_app/features/library/config/library_kind_browser_delegate.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

class LibraryKindWorkspaceController extends LibraryNoopBrowserDelegate {
  void closeAllKindDrilldowns() {
    closeItemDrilldown();
  }

  @override
  bool canOpenItemDetailDrilldown(
    LibraryKindRegistration type,
    LibraryProjectionView item,
  ) {
    return canOpenKindDrilldown(type, item);
  }

  @override
  void openItemDetailDrilldown(
    LibraryKindRegistration type,
    LibraryProjectionView item,
  ) {
    if (!canOpenItemDetailDrilldown(type, item)) {
      return;
    }
    openItemDrilldown(item.target.id);
  }

  @override
  Widget? buildWorkspaceOverride({
    required BuildContext context,
    required LibraryKindRegistration type,
    required LibraryProjection projection,
    required LibraryProjectionView selectedItem,
    required LibraryWorkspaceViewState viewState,
    required Color accent,
    required Future<void> Function() onRefreshFromCore,
    required VoidCallback onOpenTitleDetails,
    required List<LibraryEntrySummary> allLibraryEntries,
    required List<WishlistItem> allWishlistItems,
  }) {
    if (!canOpenKindDrilldown(type, selectedItem)) {
      return null;
    }
    final drilldownState = itemDrilldownState;
    if (drilldownState == null ||
        drilldownState.rootItemId != selectedItem.target.id) {
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
      libraryEntries: allLibraryEntries,
      wishlistItems: allWishlistItems,
    );
  }
}

LibraryKindBrowserDelegate buildMovieBrowserDelegate() {
  return LibraryKindWorkspaceController();
}
