import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/library/selection/library_bulk_actions.dart';
import 'package:collectarr_app/features/library/selection/library_bulk_edit_dialog.dart';
import 'package:flutter/material.dart';

List<ShelfEntry> selectedComicsShelfEntries(
  List<ShelfEntry> visibleEntries,
  Set<String> selectedItemIds,
) {
  return [
    for (final entry in visibleEntries)
      if (selectedItemIds.contains(entry.itemId)) entry,
  ];
}

Future<bool> showComicsBulkEditDialog({
  required BuildContext context,
  required LibraryBulkActions actions,
  required List<ShelfEntry> visibleEntries,
  required Set<String> selectedItemIds,
}) async {
  final entries = selectedComicsShelfEntries(visibleEntries, selectedItemIds);
  final selection = await showDialog<LibraryBulkEditSelection>(
    context: context,
    builder: (context) => LibraryBulkEditDialog(
      type: comicsLibraryConfig,
      selectedCount: entries.length,
    ),
  );
  if (selection == null) {
    return false;
  }
  await actions.editSelected(
    entries: entries,
    selection: selection,
  );
  return true;
}

Future<bool> moveSelectedComicsToOwned({
  required LibraryBulkActions actions,
  required List<ShelfEntry> visibleEntries,
  required Set<String> selectedItemIds,
}) async {
  await actions.moveSelectedToOwned(
    selectedComicsShelfEntries(visibleEntries, selectedItemIds),
    defaultCondition: comicsLibraryConfig.defaultCondition,
    defaultGrade: comicsLibraryConfig.defaultGrade,
  );
  return true;
}

Future<bool> moveSelectedComicsToWishlist({
  required LibraryBulkActions actions,
  required List<ShelfEntry> visibleEntries,
  required Set<String> selectedItemIds,
}) async {
  await actions.moveSelectedToWishlist(
    selectedComicsShelfEntries(visibleEntries, selectedItemIds),
  );
  return true;
}

Future<bool> confirmAndRemoveSelectedComics({
  required BuildContext context,
  required LibraryBulkActions actions,
  required List<ShelfEntry> visibleEntries,
  required Set<String> selectedItemIds,
}) async {
  final entries = selectedComicsShelfEntries(visibleEntries, selectedItemIds);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Remove selected comics?'),
      content: Text(
        'This removes ${entries.length} selected item${entries.length == 1 ? '' : 's'} from the local shelf and queues the change for sync.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
  if (confirmed != true) {
    return false;
  }
  await actions.removeSelected(entries);
  return true;
}
