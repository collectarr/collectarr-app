import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_item_projection.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';
import 'package:flutter/material.dart';

List<LibraryDetailField> buildMusicPersonalDetailFields({
  required BuildContext context,
  required LibraryProjectionView item,
  required OwnedItemSummary? ownedItem,
  required LibraryOwnedItemDispatch? ownedItemDispatch,
  required String? currency,
}) {
  final details =
      MusicOwnedItemProjection.fromDispatch(ownedItemDispatch)?.details;
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
