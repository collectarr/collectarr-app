import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/config/library_kind_drilldown.dart';
import 'package:collectarr_app/features/library/generic/page.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

class KindDrilldownLibraryPageState extends GenericLibraryPageState {
  @override
  bool canOpenItemDetailDrilldown(LibraryProjectionItem item) {
    return canOpenKindDrilldown(widget.type, item);
  }

  @override
  void openItemDetailDrilldown(LibraryProjectionItem item) {
    openKindDrilldown(item);
  }

  @override
  Widget? buildWorkspaceOverride(
    LibraryProjection projection,
    LibraryWorkspaceViewState viewState, {
    required List<OwnedItem> allOwnedCopies,
    required List<WishlistItem> allWishlistItems,
  }) {
    return buildKindWorkspaceOverride(
      projection,
      viewState,
      allOwnedCopies: allOwnedCopies,
      allWishlistItems: allWishlistItems,
    );
  }
}
