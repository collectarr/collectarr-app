import 'package:flutter/material.dart';

enum _BulkAction {
  exportCsvTxt,
  exportXml,
  exportCovrPrice,
  transferFieldData,
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
  VoidCallback? onBulkRemove,
  VoidCallback? onBulkRefreshMetadata,
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
    TextButton actionButton({
      required VoidCallback? onPressed,
      required IconData icon,
      required String label,
      Color? foregroundColor,
    }) {
      return TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 15),
        label: Text(label),
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          foregroundColor:
              foregroundColor ?? Theme.of(context).colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        actionButton(
          onPressed: callbacks.onBulkEdit,
          icon: Icons.edit_outlined,
          label: 'Edit',
        ),
        actionButton(
          onPressed: callbacks.onBulkRemove,
          icon: Icons.delete_outline,
          label: 'Remove',
          foregroundColor: Theme.of(context).colorScheme.error,
        ),
        actionButton(
          onPressed: callbacks.onBulkDuplicate,
          icon: Icons.copy_all_outlined,
          label: 'Duplicate',
        ),
        actionButton(
          onPressed: callbacks.onBulkLoan,
          icon: Icons.handshake_outlined,
          label: 'Loan',
        ),
        actionButton(
          onPressed: callbacks.onBulkMoveToOwned,
          icon: Icons.inventory_2_outlined,
          label: 'Move to owned',
        ),
        actionButton(
          onPressed: callbacks.onBulkMoveToWishlist,
          icon: Icons.star_border,
          label: 'Move to wishlist',
        ),
        actionButton(
          onPressed: callbacks.onPrintToPdf,
          icon: Icons.picture_as_pdf_outlined,
          label: 'Print to PDF',
        ),
        actionButton(
          onPressed: callbacks.onBulkUpdateValues,
          icon: Icons.price_change_outlined,
          label: 'Update values',
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
              _BulkAction.transferFieldData => callbacks.onTransferFieldData,
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
              value: _BulkAction.transferFieldData,
              enabled: callbacks.onTransferFieldData != null,
              child: ListTile(
                leading: const Icon(Icons.swap_horiz),
                title: const Text('Transfer Field Data'),
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
            PopupMenuItem(
              value: _BulkAction.updateFromCore,
              enabled: callbacks.onBulkRefreshMetadata != null,
              child: ListTile(
                leading: const Icon(Icons.sync),
                title: const Text('Update from Core'),
                dense: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
