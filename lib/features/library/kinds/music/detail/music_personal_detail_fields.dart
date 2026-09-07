import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:flutter/material.dart';

List<LibraryDetailField> buildMusicPersonalDetailFields({
  required BuildContext context,
  required LibraryProjectionRuntime item,
  required OwnedItem? ownedItem,
  required String? currency,
}) {
  final details = ownedItem?.details;
  if (details is! MusicOwnedDetails) {
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
