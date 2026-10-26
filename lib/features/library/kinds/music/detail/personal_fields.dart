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
  final details = MusicLibraryEntryProjection.fromDispatch(
    libraryEntryDispatch,
  )?.personal.details;
  final entry = MusicLibraryEntryProjection.fromDispatch(libraryEntryDispatch);
  if (details == null || entry == null) {
    return const [];
  }
  final discNumbers = <String, int>{};
  for (final disc in entry.metadata.discs) {
    discNumbers[disc.id.value] = disc.discNumber;
  }
  final storage = [
    for (final disc in details.media) ...[
      if (disc.storageDevice?.trim().isNotEmpty == true)
        'Disc ${discNumbers[disc.discId] ?? '?'}: ${disc.storageDevice!.trim()}',
      if (disc.storageSlot?.trim().isNotEmpty == true)
        'Disc ${discNumbers[disc.discId] ?? '?'}: ${disc.storageSlot!.trim()}',
    ],
  ];
  return [
    LibraryDetailField(
      label: 'Storage',
      value: genericLibraryDash(storage.isEmpty ? null : storage.join(' / ')),
    ),
  ];
}
