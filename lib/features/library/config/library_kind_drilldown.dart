import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_shelf_drilldown.dart';
import 'package:collectarr_app/features/library/kinds/video/release/video_shelf_drilldown.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/kinds/video/release/video_shelf_drilldown.dart'
    show
        VideoShelfReleaseDrilldownItem,
        buildVideoShelfReleaseItems,
        canOpenVideoShelfDrilldown;

bool canOpenKindDrilldown(
  LibraryTypeConfig type,
  LibraryProjectionRuntime item,
) {
  return canOpenVideoShelfDrilldown(type, item);
}

Widget? buildLibraryKindDrilldown({
  required BuildContext context,
  required LibraryTypeConfig type,
  required LibraryProjectionRuntime selectedItem,
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
  if (selectedItem.source.catalogItem?.kind.toLowerCase() == 'tv') {
    return TvShelfSeasonDrilldown(
      titleItem: selectedItem,
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
    projector: type.presentation.projector,
  );
  return VideoShelfReleaseDrilldown(
    titleItem: selectedItem,
    items: drilldownItems,
    selectedReleaseId: selectedReleaseId,
    coverSize: coverSize,
    accent: accent,
    onBack: onBack,
    onRefreshFromCore: onRefreshFromCore,
    onOpenTitleDetails: onOpenTitleDetails,
    onSelectRelease: onSelectRelease,
  );
}
