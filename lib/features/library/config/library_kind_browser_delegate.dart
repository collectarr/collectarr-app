import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/config/library_kind_drilldown.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

abstract class LibraryKindBrowserDelegate {
  String? get releaseFolderTitleItemId;

  set releaseFolderTitleItemId(String? value);

  bool get hasReleaseFolderTitleItemId => releaseFolderTitleItemId != null;

  void openReleaseFolder(String? titleItemId) {
    releaseFolderTitleItemId = titleItemId;
  }

  void closeReleaseFolder() {
    releaseFolderTitleItemId = null;
  }

  LibraryDrilldownState? get itemDrilldownState;

  set itemDrilldownState(LibraryDrilldownState? value);

  String? get drilldownRootItemId => itemDrilldownState?.rootItemId;

  String? get drilldownSelectedChildId => itemDrilldownState?.selectedChildId;

  String? get drilldownSelectedReleaseId =>
      itemDrilldownState?.selectedReleaseId;

  bool get hasItemDrilldown => itemDrilldownState != null;

  void openItemDrilldown(
    String rootItemId, {
    String? selectedChildId,
    String? selectedReleaseId,
  }) {
    itemDrilldownState = LibraryDrilldownState(
      rootItemId: rootItemId,
      selectedChildId: selectedChildId,
      selectedReleaseId: selectedReleaseId,
    );
  }

  void closeItemDrilldown() {
    itemDrilldownState = null;
  }

  bool canOpenItemDetailDrilldown(
    LibraryTypeConfig type,
    LibraryProjectionItem item,
  ) {
    return false;
  }

  void openItemDetailDrilldown(
    LibraryTypeConfig type,
    LibraryProjectionItem item,
  ) {}

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
    return null;
  }

  Widget? buildDrilldown({
    required BuildContext context,
    required LibraryTypeConfig type,
    required LibraryProjectionItem selectedItem,
    required double coverSize,
    required Color accent,
    required VoidCallback onBack,
    required Future<void> Function() onRefreshFromCore,
    required VoidCallback onOpenTitleDetails,
    required List<OwnedItem> ownedCopies,
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
      selectedReleaseId: drilldownSelectedReleaseId,
      onSelectRelease: (releaseId) => openItemDrilldown(
        selectedItem.entry.id,
        selectedReleaseId: releaseId,
      ),
    );
  }
}

class LibraryDrilldownState {
  const LibraryDrilldownState({
    required this.rootItemId,
    this.selectedChildId,
    this.selectedReleaseId,
  });

  final String rootItemId;
  final String? selectedChildId;
  final String? selectedReleaseId;
}

class LibraryNoopBrowserDelegate extends LibraryKindBrowserDelegate {
  LibraryNoopBrowserDelegate({String? initialReleaseFolderTitleItemId})
      : _releaseFolderTitleItemId = initialReleaseFolderTitleItemId;

  String? _releaseFolderTitleItemId;
  LibraryDrilldownState? _itemDrilldownState;

  @override
  String? get releaseFolderTitleItemId => _releaseFolderTitleItemId;

  @override
  set releaseFolderTitleItemId(String? value) {
    _releaseFolderTitleItemId = value;
  }

  @override
  LibraryDrilldownState? get itemDrilldownState => _itemDrilldownState;

  @override
  set itemDrilldownState(LibraryDrilldownState? value) {
    _itemDrilldownState = value;
  }
}

class LibraryReleaseFolderBrowserDelegate extends LibraryKindBrowserDelegate {
  LibraryReleaseFolderBrowserDelegate({
    String? initialReleaseFolderTitleItemId,
  }) : _releaseFolderTitleItemId = initialReleaseFolderTitleItemId;

  String? _releaseFolderTitleItemId;
  LibraryDrilldownState? _itemDrilldownState;

  @override
  String? get releaseFolderTitleItemId => _releaseFolderTitleItemId;

  @override
  set releaseFolderTitleItemId(String? value) {
    _releaseFolderTitleItemId = value;
  }

  @override
  LibraryDrilldownState? get itemDrilldownState => _itemDrilldownState;

  @override
  set itemDrilldownState(LibraryDrilldownState? value) {
    _itemDrilldownState = value;
  }
}

LibraryKindBrowserDelegate buildReleaseFolderBrowserDelegate() {
  return LibraryReleaseFolderBrowserDelegate();
}
