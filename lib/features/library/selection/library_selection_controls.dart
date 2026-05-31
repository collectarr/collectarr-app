import 'package:flutter/material.dart';

enum _BulkAction { edit, owned, wishlist, remove, refreshMetadata, clear }

typedef LibrarySelectionCallbacks = ({
  VoidCallback onClearSelection,
  VoidCallback onBulkEdit,
  VoidCallback onBulkMoveToOwned,
  VoidCallback onBulkMoveToWishlist,
  VoidCallback onBulkRemove,
  VoidCallback onBulkRefreshMetadata,
});

class LibrarySelectionControls extends StatelessWidget {
  const LibrarySelectionControls({
    super.key,
    required this.selectedCount,
    required this.callbacks,
  });

  final int selectedCount;
  final LibrarySelectionCallbacks callbacks;

  void _dispatchAfterMenuClose(VoidCallback action) {
    WidgetsBinding.instance.addPostFrameCallback((_) => action());
  }

  @override
  Widget build(BuildContext context) {
    if (selectedCount == 0) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FilledButton.tonalIcon(
          onPressed: callbacks.onBulkEdit,
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('Edit'),
          style: FilledButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
        const SizedBox(width: 6),
        FilledButton.tonalIcon(
          onPressed: callbacks.onBulkRemove,
          icon: const Icon(Icons.delete_outline, size: 16),
          label: const Text('Remove'),
          style: FilledButton.styleFrom(
            visualDensity: VisualDensity.compact,
            foregroundColor: Theme.of(context).colorScheme.error,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
        PopupMenuButton<_BulkAction>(
          tooltip: 'More bulk actions',
          enabled: selectedCount > 0,
          style: FilledButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
          icon: const Icon(Icons.more_horiz),
          onSelected: (action) {
            final callback = switch (action) {
              _BulkAction.edit => callbacks.onBulkEdit,
              _BulkAction.owned => callbacks.onBulkMoveToOwned,
              _BulkAction.wishlist => callbacks.onBulkMoveToWishlist,
              _BulkAction.remove => callbacks.onBulkRemove,
              _BulkAction.refreshMetadata => callbacks.onBulkRefreshMetadata,
              _BulkAction.clear => callbacks.onClearSelection,
            };
            _dispatchAfterMenuClose(callback);
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
              value: _BulkAction.refreshMetadata,
              child: ListTile(
                leading: Icon(Icons.sync),
                title: Text('Refresh metadata'),
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
      ],
    );
  }
}
