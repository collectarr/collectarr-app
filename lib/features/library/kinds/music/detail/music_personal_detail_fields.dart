import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:flutter/material.dart';

List<LibraryDetailField> buildMusicPersonalDetailFields({
  required BuildContext context,
  required LibraryProjectionView item,
  required OwnedItemSummary? ownedItem,
  required Object? typedOwnedItem,
  required String? currency,
}) {
  final typedOwned = typedOwnedItem;
  final details = typedOwned is MusicOwnedItem ? typedOwned.details : null;
  if (details == null) {
    return const [];
  }
  return [
    LibraryDetailField(
      label: 'Storage Device',
      value: genericLibraryDash(details.storageDevice),
    ),
    LibraryDetailField(
      label: 'Storage Slot',
      value: genericLibraryDash(details.storageSlot),
    ),
  ];
}
