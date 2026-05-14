import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_bulk_actions.dart';
import 'package:collectarr_app/features/comics/comics_bulk_edit.dart';
import 'package:collectarr_app/features/comics/comics_inspector.dart';
import 'package:flutter/material.dart';

Future<bool> showComicsBulkEditDialog({
  required BuildContext context,
  required ComicsBulkActions actions,
  required List<ShelfEntry> visibleEntries,
  required Set<String> selectedItemIds,
}) async {
  final selection = await showDialog<ComicsBulkEditSelection>(
    context: context,
    builder: (context) => ComicsBulkEditDialog(
      conditions: ComicInspector.conditions,
      grades: ComicInspector.grades,
    ),
  );
  if (selection == null) {
    return false;
  }
  await actions.editSelected(
    entries: selectedComicsShelfEntries(visibleEntries, selectedItemIds),
    selection: selection,
  );
  return true;
}

Future<bool> moveSelectedComicsToOwned({
  required ComicsBulkActions actions,
  required List<ShelfEntry> visibleEntries,
  required Set<String> selectedItemIds,
}) async {
  await actions.moveSelectedToOwned(
    selectedComicsShelfEntries(visibleEntries, selectedItemIds),
  );
  return true;
}

Future<bool> moveSelectedComicsToWishlist({
  required ComicsBulkActions actions,
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
  required ComicsBulkActions actions,
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
