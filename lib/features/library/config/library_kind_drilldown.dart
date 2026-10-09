import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter/material.dart';

bool canOpenKindDrilldown(
  LibraryKindRegistration type,
  LibraryProjectionView item,
) {
  return libraryPresentationForKind(type.kind)
      .builder
      .canOpenKindDrilldown(item);
}

Widget? buildLibraryKindDrilldown({
  required BuildContext context,
  required LibraryKindRegistration type,
  required LibraryProjectionView selectedItem,
  required Color accent,
  required double coverSize,
  required VoidCallback onBack,
  required Future<void> Function() onRefreshFromCore,
  required VoidCallback onOpenTitleDetails,
  required List<LibraryEntrySummary> libraryEntries,
  required List<WishlistItem> wishlistItems,
}) {
  return libraryPresentationForKind(type.kind).builder.buildKindDrilldown(
        context: context,
        selectedItem: selectedItem,
        accent: accent,
        coverSize: coverSize,
        onBack: onBack,
        onRefreshFromCore: onRefreshFromCore,
        onOpenTitleDetails: onOpenTitleDetails,
        libraryEntries: libraryEntries,
        wishlistItems: wishlistItems,
        projector: libraryKindWorkspaceForKind(type.kind)
            .projectorForTarget(selectedItem.target),
      );
}
