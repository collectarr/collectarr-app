import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/media/video/tv_shelf_drilldown.dart';
import 'package:collectarr_app/features/library/media/video/video_shelf_drilldown.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/media/video/video_shelf_drilldown.dart'
    show
        VideoShelfReleaseDrilldownItem,
        buildVideoShelfReleaseItems,
        canOpenVideoShelfDrilldown;

bool canOpenKindDrilldown(
  LibraryTypeConfig type,
  LibraryWorkspaceEntry entry,
) {
  return canOpenVideoShelfDrilldown(type, entry);
}

Widget? buildLibraryKindDrilldown({
  required BuildContext context,
  required LibraryTypeConfig type,
  required LibraryProjectionItem selectedItem,
  required Color accent,
  required double coverSize,
  required VoidCallback onBack,
  required Future<void> Function() onRefreshFromCore,
  required VoidCallback onOpenTitleDetails,
  required List<OwnedItem> ownedCopies,
  required List<WishlistItem> wishlistItems,
  required String? selectedReleaseId,
  required void Function(String releaseId) onSelectRelease,
}) {
  if (selectedItem.entry.mediaType == 'tv') {
    return TvShelfSeasonDrilldown(
      titleEntry: selectedItem.entry,
      coverSize: coverSize,
      accent: accent,
      onBack: onBack,
      onRefreshFromCore: onRefreshFromCore,
      onOpenTitleDetails: onOpenTitleDetails,
    );
  }

  final drilldownItems = buildVideoShelfReleaseItems(
    titleItem: selectedItem,
    ownedCopies: ownedCopies,
    wishlistItems: wishlistItems,
    releaseEntryBuilder: type.presentation.releaseEntryBuilder,
  );
  return VideoShelfReleaseDrilldown(
    titleItem: selectedItem,
    items: drilldownItems,
    selectedReleaseId: selectedReleaseId,
    coverSize: coverSize,
    accent: accent,
    onBack: onBack,
    onRefreshFromCore: onRefreshFromCore,
    onSelectRelease: onSelectRelease,
    onOpenTitleDetails: onOpenTitleDetails,
  );
}
