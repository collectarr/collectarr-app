import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_library_entry_projection.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';
import 'package:flutter/material.dart';

List<LibraryDetailField> buildComicPersonalDetailFields({
  required BuildContext context,
  required LibraryProjectionView item,
  required LibraryEntrySummary? libraryEntry,
  required LibraryEntryDispatch? libraryEntryDispatch,
  required String? currency,
}) {
  final details =
      ComicLibraryEntryProjection.fromDispatch(libraryEntryDispatch)?.details;
  if (details == null || details.coverPriceCents == null) {
    return const [];
  }
  return [
    LibraryDetailField(
      label: 'Cover price',
      value: formatMoney(details.coverPriceCents, currency),
    ),
  ];
}
