import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:flutter/material.dart';

bool canOpenKindDrilldown(
  LibraryKindModule type,
  LibraryProjectionRuntime item,
) {
  return type.presentation.builder.canOpenKindDrilldown(item);
}

Widget? buildLibraryKindDrilldown({
  required BuildContext context,
  required LibraryKindModule type,
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
  return type.presentation.builder.buildKindDrilldown(
    context: context,
    selectedItem: selectedItem,
    accent: accent,
    coverSize: coverSize,
    onBack: onBack,
    onRefreshFromCore: onRefreshFromCore,
    onOpenTitleDetails: onOpenTitleDetails,
    ownedCopies: ownedCopies,
    wishlistItems: wishlistItems,
    selectedReleaseId: selectedReleaseId,
    onSelectRelease: onSelectRelease,
    projector: type.projector,
  );
}
