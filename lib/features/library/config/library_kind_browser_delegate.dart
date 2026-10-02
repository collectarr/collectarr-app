import 'package:collectarr_app/core/models/owned_copy_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/config/library_kind_drilldown.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

abstract class LibraryKindBrowserDelegate {
  LibraryDrilldownState? get itemDrilldownState;

  set itemDrilldownState(LibraryDrilldownState? value);

  String? get drilldownRootItemId => itemDrilldownState?.rootItemId;

  bool get hasItemDrilldown => itemDrilldownState != null;

  void openItemDrilldown(String rootItemId) {
    itemDrilldownState = LibraryDrilldownState(rootItemId: rootItemId);
  }

  void closeItemDrilldown() {
    itemDrilldownState = null;
  }

  bool canOpenItemDetailDrilldown(
    LibraryKindRegistration type,
    LibraryProjectionItem item,
  ) {
    return false;
  }

  void openItemDetailDrilldown(
    LibraryKindRegistration type,
    LibraryProjectionItem item,
  ) {}

  Widget? buildWorkspaceOverride({
    required BuildContext context,
    required LibraryKindRegistration type,
    required LibraryProjection projection,
    required LibraryProjectionItem selectedItem,
    required LibraryWorkspaceViewState viewState,
    required Color accent,
    required Future<void> Function() onRefreshFromCore,
    required VoidCallback onOpenTitleDetails,
    required List<OwnedCopySummary> allOwnedCopies,
    required List<WishlistItem> allWishlistItems,
  }) {
    return null;
  }

  Widget? buildDrilldown({
    required BuildContext context,
    required LibraryKindRegistration type,
    required LibraryProjectionItem selectedItem,
    required double coverSize,
    required Color accent,
    required VoidCallback onBack,
    required Future<void> Function() onRefreshFromCore,
    required VoidCallback onOpenTitleDetails,
    required List<OwnedCopySummary> ownedCopies,
    required List<WishlistItem> wishlistItems,
  }) {
    return buildLibraryKindDrilldown(
      context: context,
      type: type,
      selectedItem: selectedItem,
      coverSize: coverSize,
      accent: accent,
      onBack: onBack,
      onRefreshFromCore: onRefreshFromCore,
      onOpenTitleDetails: onOpenTitleDetails,
      ownedCopies: ownedCopies,
      wishlistItems: wishlistItems,
    );
  }
}

class LibraryDrilldownState {
  const LibraryDrilldownState({required this.rootItemId});

  final String rootItemId;
}

class LibraryNoopBrowserDelegate extends LibraryKindBrowserDelegate {
  LibraryDrilldownState? _itemDrilldownState;

  @override
  LibraryDrilldownState? get itemDrilldownState => _itemDrilldownState;

  @override
  set itemDrilldownState(LibraryDrilldownState? value) {
    _itemDrilldownState = value;
  }
}
