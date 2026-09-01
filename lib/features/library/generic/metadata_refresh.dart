import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_refresh_dialog.dart';
import 'package:flutter/material.dart';

Future<LibraryMetadataRefreshResult?> showGenericLibraryMetadataRefreshDialog({
  required BuildContext context,
  required LibraryKindRuntime type,
  required Color accent,
  required LibraryProjection projection,
}) {
  return showLibraryMetadataRefreshDialog(
    context: context,
    type: type,
    accent: accent,
    allEntries: projection.allItems,
    shownEntries: projection.filteredItems,
    selectedEntry: projection.selectedItem,
  );
}
