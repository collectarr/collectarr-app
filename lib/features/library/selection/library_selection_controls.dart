import 'package:flutter/material.dart';

enum _BulkAction {
  exportCsvTxt,
  exportXml,
  exportCovrPrice,
  duplicate,
  loan,
  transferFieldData,
  moveToOwned,
  moveToWishlist,
  updateValues,
  updateKeyInfo,
  updateFromCore,
}

typedef LibrarySelectionCallbacks = ({
  VoidCallback onClearSelection,
  VoidCallback onSelectAll,
  VoidCallback? onBulkEdit,
  VoidCallback? onPrintToPdf,
  VoidCallback? onExportCsvTxt,
  VoidCallback? onBulkDuplicate,
  VoidCallback? onBulkLoan,
  VoidCallback? onTransferFieldData,
  VoidCallback? onBulkUpdateValues,
  VoidCallback? onBulkUpdateKeyInfo,
  VoidCallback? onBulkMoveToOwned,
  VoidCallback? onBulkMoveToWishlist,
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
          onPressed: callbacks.onPrintToPdf,
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
          onPressed: callbacks.onBulkUpdateValues,
          icon: const Icon(Icons.price_change_outlined, size: 15),
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
              _BulkAction.exportCsvTxt => callbacks.onExportCsvTxt,
              _BulkAction.exportXml => null,
              _BulkAction.exportCovrPrice => null,
              _BulkAction.duplicate => callbacks.onBulkDuplicate,
              _BulkAction.loan => callbacks.onBulkLoan,
              _BulkAction.transferFieldData => callbacks.onTransferFieldData,
              _BulkAction.moveToOwned => callbacks.onBulkMoveToOwned,
              _BulkAction.moveToWishlist => callbacks.onBulkMoveToWishlist,
              _BulkAction.updateValues => callbacks.onBulkUpdateValues,
              _BulkAction.updateKeyInfo => callbacks.onBulkUpdateKeyInfo,
              _BulkAction.updateFromCore => callbacks.onBulkRefreshMetadata,
            };
            if (callback != null) {
              _dispatchAfterMenuClose(callback);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _BulkAction.exportCsvTxt,
              enabled: callbacks.onExportCsvTxt != null,
              child: ListTile(
                leading: const Icon(Icons.table_view_outlined),
                title: const Text('Export to CSV / TXT'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: _BulkAction.exportXml,
              enabled: false,
              child: ListTile(
                leading: Icon(Icons.data_object_outlined),
                title: Text('Export to XML'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: _BulkAction.exportCovrPrice,
              enabled: false,
              child: ListTile(
                leading: Icon(Icons.sell_outlined),
                title: Text('Export for CovrPrice'),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: _BulkAction.duplicate,
              enabled: callbacks.onBulkDuplicate != null,
              child: ListTile(
                leading: const Icon(Icons.copy_all_outlined),
                title: const Text('Duplicate'),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: _BulkAction.loan,
              enabled: callbacks.onBulkLoan != null,
              child: ListTile(
                leading: Icon(Icons.handshake_outlined),
                title: Text('Loan'),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: _BulkAction.transferFieldData,
              enabled: callbacks.onTransferFieldData != null,
              child: ListTile(
                leading: const Icon(Icons.swap_horiz),
                title: const Text('Transfer Field Data'),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: _BulkAction.moveToOwned,
              enabled: callbacks.onBulkMoveToOwned != null,
              child: ListTile(
                leading: Icon(Icons.inventory_2_outlined),
                title: Text('Move to owned'),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: _BulkAction.moveToWishlist,
              enabled: callbacks.onBulkMoveToWishlist != null,
              child: ListTile(
                leading: Icon(Icons.star_border),
                title: Text('Move to wishlist'),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: _BulkAction.updateValues,
              enabled: callbacks.onBulkUpdateValues != null,
              child: ListTile(
                leading: const Icon(Icons.price_change_outlined),
                title: Text('Update values'),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: _BulkAction.updateKeyInfo,
              enabled: callbacks.onBulkUpdateKeyInfo != null,
              child: ListTile(
                leading: Icon(Icons.key_outlined),
                title: Text('Update Key Info'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: _BulkAction.updateFromCore,
              child: ListTile(
                leading: Icon(Icons.sync),
                title: Text('Update from Core'),
                dense: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
