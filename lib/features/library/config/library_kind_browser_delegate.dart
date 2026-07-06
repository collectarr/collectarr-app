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

  String? get videoShelfDrilldownTitleItemId;

  set videoShelfDrilldownTitleItemId(String? value);

  String? get videoShelfDrilldownReleaseId;

  set videoShelfDrilldownReleaseId(String? value);

  bool get hasVideoShelfDrilldown => videoShelfDrilldownTitleItemId != null;

  void openVideoShelfDrilldown(
    String titleItemId, {
    String? releaseId,
  }) {
    videoShelfDrilldownTitleItemId = titleItemId;
    videoShelfDrilldownReleaseId = releaseId;
  }

  void closeVideoShelfDrilldown() {
    videoShelfDrilldownTitleItemId = null;
    videoShelfDrilldownReleaseId = null;
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
      selectedReleaseId: videoShelfDrilldownReleaseId,
      onSelectRelease: (releaseId) => openVideoShelfDrilldown(
        selectedItem.entry.id,
        releaseId: releaseId,
      ),
    );
  }
}

class LibraryNoopBrowserDelegate extends LibraryKindBrowserDelegate {
  LibraryNoopBrowserDelegate({String? initialReleaseFolderTitleItemId})
      : _releaseFolderTitleItemId = initialReleaseFolderTitleItemId;

  String? _releaseFolderTitleItemId;
  String? _videoShelfDrilldownTitleItemId;
  String? _videoShelfDrilldownReleaseId;

  @override
  String? get releaseFolderTitleItemId => _releaseFolderTitleItemId;

  @override
  set releaseFolderTitleItemId(String? value) {
    _releaseFolderTitleItemId = value;
  }

  @override
  String? get videoShelfDrilldownTitleItemId => _videoShelfDrilldownTitleItemId;

  @override
  set videoShelfDrilldownTitleItemId(String? value) {
    _videoShelfDrilldownTitleItemId = value;
  }

  @override
  String? get videoShelfDrilldownReleaseId => _videoShelfDrilldownReleaseId;

  @override
  set videoShelfDrilldownReleaseId(String? value) {
    _videoShelfDrilldownReleaseId = value;
  }
}

class LibraryReleaseFolderBrowserDelegate extends LibraryKindBrowserDelegate {
  LibraryReleaseFolderBrowserDelegate({
    String? initialReleaseFolderTitleItemId,
  }) : _releaseFolderTitleItemId = initialReleaseFolderTitleItemId;

  String? _releaseFolderTitleItemId;
  String? _videoShelfDrilldownTitleItemId;
  String? _videoShelfDrilldownReleaseId;

  @override
  String? get releaseFolderTitleItemId => _releaseFolderTitleItemId;

  @override
  set releaseFolderTitleItemId(String? value) {
    _releaseFolderTitleItemId = value;
  }

  @override
  String? get videoShelfDrilldownTitleItemId => _videoShelfDrilldownTitleItemId;

  @override
  set videoShelfDrilldownTitleItemId(String? value) {
    _videoShelfDrilldownTitleItemId = value;
  }

  @override
  String? get videoShelfDrilldownReleaseId => _videoShelfDrilldownReleaseId;

  @override
  set videoShelfDrilldownReleaseId(String? value) {
    _videoShelfDrilldownReleaseId = value;
  }
}

LibraryKindBrowserDelegate buildReleaseFolderBrowserDelegate() {
  return LibraryReleaseFolderBrowserDelegate();
}
