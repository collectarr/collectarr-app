import 'package:collectarr_app/features/library/generic_library_projection.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_refresh_dialog.dart';
import 'package:flutter/material.dart';

Future<LibraryMetadataRefreshResult?> showGenericLibraryMetadataRefreshDialog({
  required BuildContext context,
  required LibraryTypeConfig type,
  required Color accent,
  required GenericLibraryProjection projection,
}) {
  return showLibraryMetadataRefreshDialog(
    context: context,
    type: type,
    accent: accent,
    allEntries: [for (final item in projection.allItems) item.entry],
    shownEntries: [for (final item in projection.filteredItems) item.entry],
    selectedEntry: projection.selectedItem?.entry,
  );
}
