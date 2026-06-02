import 'package:flutter/material.dart';

enum _BulkAction { owned, wishlist, refreshMetadata }

typedef LibrarySelectionCallbacks = ({
  VoidCallback onClearSelection,
  VoidCallback onSelectAll,
  VoidCallback onBulkEdit,
  VoidCallback onBulkMoveToOwned,
  VoidCallback onBulkMoveToWishlist,
  VoidCallback onBulkRemove,
  VoidCallback onBulkRefreshMetadata,
});

class LibrarySelectionControls extends StatelessWidget {
  const LibrarySelectionControls({
    super.key,
    required this.callbacks,
  });

  final LibrarySelectionCallbacks callbacks;

  void _dispatchAfterMenuClose(VoidCallback action) {
    WidgetsBinding.instance.addPostFrameCallback((_) => action());
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TextButton.icon(
          onPressed: callbacks.onBulkEdit,
          icon: const Icon(Icons.edit_outlined, size: 15),
          label: const Text('Edit'),
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: callbacks.onBulkRemove,
          icon: Icon(
            Icons.delete_outline,
            size: 15,
            color: Theme.of(context).colorScheme.error,
          ),
          label: const Text('Remove'),
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            foregroundColor: Theme.of(context).colorScheme.error,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: callbacks.onBulkRefreshMetadata,
          icon: const Icon(Icons.picture_as_pdf_outlined, size: 15),
          label: const Text('Print to PDF'),
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: callbacks.onBulkMoveToOwned,
          icon: const Icon(Icons.tune, size: 15),
          label: const Text('Update values'),
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        PopupMenuButton<_BulkAction>(
          tooltip: 'More selection actions',
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          icon: const Icon(Icons.more_horiz, size: 18),
          onSelected: (action) {
            final callback = switch (action) {
              _BulkAction.owned => callbacks.onBulkMoveToOwned,
              _BulkAction.wishlist => callbacks.onBulkMoveToWishlist,
              _BulkAction.refreshMetadata => callbacks.onBulkRefreshMetadata,
            };
            _dispatchAfterMenuClose(callback);
          },
          itemBuilder: (context) => const [
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
              value: _BulkAction.refreshMetadata,
              child: ListTile(
                leading: Icon(Icons.sync),
                title: Text('Refresh metadata'),
                dense: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
