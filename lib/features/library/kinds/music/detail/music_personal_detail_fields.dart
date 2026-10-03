import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';
import 'package:flutter/material.dart';

List<LibraryDetailField> buildMusicPersonalDetailFields({
  required BuildContext context,
  required LibraryProjectionView item,
  required LibraryEntrySummary? libraryEntry,
  required LibraryEntryDispatch? libraryEntryDispatch,
  required String? currency,
}) {
  final details =
      MusicLibraryEntryProjection.fromDispatch(libraryEntryDispatch)?.details;
  final entry = MusicLibraryEntryProjection.fromDispatch(libraryEntryDispatch);
  if (details == null || entry == null) {
    return const [];
  }
  final discNumbers = <String, int>{};
  for (final medium in entry.metadata.mediums) {
    discNumbers[medium.id.value] = medium.mediumNumber;
  }
  final storage = [
    for (final medium in details.media) ...[
      if (medium.storageDevice?.trim().isNotEmpty == true)
        'Disc ${discNumbers[medium.mediumId] ?? '?'}: ${medium.storageDevice!.trim()}',
      if (medium.storageSlot?.trim().isNotEmpty == true)
        'Disc ${discNumbers[medium.mediumId] ?? '?'}: ${medium.storageSlot!.trim()}',
    ],
  ];
  return [
    LibraryDetailField(
      label: 'Storage',
      value: genericLibraryDash(storage.isEmpty ? null : storage.join(' / ')),
    ),
  ];
}
