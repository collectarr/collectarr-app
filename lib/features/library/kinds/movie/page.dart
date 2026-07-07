import 'package:collectarr_app/features/library/generic/page.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MovieLibraryPage extends GenericLibraryPage {
  const MovieLibraryPage({
    super.key,
    required super.type,
    required super.topBar,
    required super.accent,
    required super.routeUri,
    super.switchLayoutSnapshot,
  });

  @override
  ConsumerState<GenericLibraryPage> createState() => MovieLibraryPageState();
}

class VideoDrilldownLibraryPageState extends GenericLibraryPageState {
  @override
  bool canOpenItemDetailDrilldown(LibraryProjectionItem item) {
    return canOpenDefaultVideoShelfDrilldown(item);
  }

  @override
  void openItemDetailDrilldown(LibraryProjectionItem item) {
    openDefaultVideoShelfDrilldown(item);
  }

  @override
  Widget? buildWorkspaceOverride(
    LibraryProjection projection,
    LibraryWorkspaceViewState viewState, {
    required List<OwnedItem> allOwnedCopies,
    required List<WishlistItem> allWishlistItems,
  }) {
    return buildDefaultVideoShelfWorkspaceOverride(
      projection,
      viewState,
      allOwnedCopies: allOwnedCopies,
      allWishlistItems: allWishlistItems,
    );
  }
}

class MovieLibraryPageState extends VideoDrilldownLibraryPageState {}
