import 'package:collectarr_app/features/library/workspace/library_toolbar_stat.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_chrome.dart';
import 'package:flutter/material.dart';

enum _BulkAction { edit, owned, wishlist, remove, clear }

typedef LibrarySelectionCallbacks = ({
  VoidCallback onClearSelection,
  VoidCallback onBulkEdit,
  VoidCallback onBulkMoveToOwned,
  VoidCallback onBulkMoveToWishlist,
  VoidCallback onBulkRemove,
});

class LibrarySelectionControls extends StatelessWidget {
  const LibrarySelectionControls({
    super.key,
    required this.selectedCount,
    required this.callbacks,
  });

  final int selectedCount;
  final LibrarySelectionCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    if (selectedCount == 0) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LibraryToolbarStat(label: 'Selected', value: selectedCount),
        const SizedBox(width: 6),
        PopupMenuButton<_BulkAction>(
          tooltip: 'Bulk actions',
          enabled: selectedCount > 0,
          icon: const Icon(Icons.more_vert),
          onSelected: (action) {
            switch (action) {
              case _BulkAction.edit:
                callbacks.onBulkEdit();
              case _BulkAction.owned:
                callbacks.onBulkMoveToOwned();
              case _BulkAction.wishlist:
                callbacks.onBulkMoveToWishlist();
              case _BulkAction.remove:
                callbacks.onBulkRemove();
              case _BulkAction.clear:
                callbacks.onClearSelection();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: _BulkAction.edit,
              child: ListTile(
                leading: Icon(Icons.edit_note),
                title: Text('Bulk edit'),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: _BulkAction.owned,
              child: ListTile(
                leading: Icon(Icons.inventory_2_outlined),
                title: Text('Move to owned'),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: _BulkAction.wishlist,
              child: ListTile(
                leading: Icon(Icons.star_border),
                title: Text('Move to wishlist'),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: _BulkAction.remove,
              child: ListTile(
                leading: Icon(Icons.delete_outline),
                title: Text('Remove selected'),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: _BulkAction.clear,
              child: ListTile(
                leading: Icon(Icons.deselect),
                title: Text('Clear selection'),
                dense: true,
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
        Tooltip(
          message: 'Clear selection',
          child: LibraryWorkspaceIconButton(
            onPressed: callbacks.onClearSelection,
            icon: Icons.close,
          ),
        ),
      ],
    );
  }
}
