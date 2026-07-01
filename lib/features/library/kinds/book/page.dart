import 'package:collectarr_app/features/library/generic/page.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookLibraryPage extends GenericLibraryPage {
  const BookLibraryPage({
    super.key,
    required super.type,
    required super.topBar,
    required super.accent,
    required super.routeUri,
  }) : super();

  @override
  ConsumerState<GenericLibraryPage> createState() => BookLibraryPageState();
}

class BookLibraryPageState extends GenericLibraryPageState {
  @override
  bool canOpenItemDetailDrilldown(LibraryProjectionItem item) {
    return widget.type.kindHooks.page.canOpenItemDetailDrilldown?.call(item) ??
        false;
  }

  @override
  void openItemDetailDrilldown(LibraryProjectionItem item) {
    widget.type.kindHooks.page.openItemDetailDrilldown?.call(item);
  }

  @override
  Widget? buildWorkspaceOverride(
    LibraryProjection projection,
    LibraryWorkspaceViewState viewState, {
    required List<OwnedItem> allOwnedCopies,
    required List<WishlistItem> allWishlistItems,
  }) {
    return widget.type.kindHooks.page.buildWorkspaceOverride?.call(
          projection,
          viewState,
          allOwnedCopies: allOwnedCopies,
          allWishlistItems: allWishlistItems,
        ) ??
        super.buildWorkspaceOverride(
          projection,
          viewState,
          allOwnedCopies: allOwnedCopies,
          allWishlistItems: allWishlistItems,
        );
  }
}
