import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_collection_item_projection.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_collection_item_dispatch.dart';
import 'package:flutter/material.dart';

List<LibraryDetailField> buildMusicPersonalDetailFields({
  required BuildContext context,
  required LibraryProjectionView item,
  required CollectionItemSummary? collectionItem,
  required LibraryCollectionItemDispatch? collectionItemDispatch,
  required String? currency,
}) {
  final details =
      MusicCollectionItemProjection.fromDispatch(collectionItemDispatch)?.details;
  if (details == null) {
    return const [];
  }
  final storage = [
    for (final medium in details.media) ...[
      if (medium.storageDevice?.trim().isNotEmpty == true)
        'Disc ${medium.mediumIndex}: ${medium.storageDevice!.trim()}',
      if (medium.storageSlot?.trim().isNotEmpty == true)
        'Disc ${medium.mediumIndex}: ${medium.storageSlot!.trim()}',
    ],
  ];
  return [
    LibraryDetailField(
      label: 'Storage',
      value: genericLibraryDash(storage.isEmpty ? null : storage.join(' / ')),
    ),
  ];
}
