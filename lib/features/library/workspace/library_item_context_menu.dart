import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryItemContextMenuResult {
  const LibraryItemContextMenuResult(this.action);
  final LibraryItemContextAction action;
}

enum LibraryItemContextAction {
  edit,
  addToOwned,
  removeFromOwned,
  addToWishlist,
  removeFromWishlist,
  removeTracking,
  copyTitle,
  copyBarcode,
}

Future<LibraryItemContextMenuResult?> showLibraryItemContextMenu({
  required BuildContext context,
  required Offset position,
  required LibraryWorkspaceEntry entry,
  required Color accent,
  int selectedCount = 1,
}) {
  final overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox?;
  if (overlay == null) {
    return Future.value(null);
  }
  final isBatchSelection = selectedCount > 1;
  return showMenu<LibraryItemContextMenuResult>(
    context: context,
    position: RelativeRect.fromLTRB(
      position.dx,
      position.dy,
      overlay.size.width - position.dx,
      overlay.size.height - position.dy,
    ),
    color: kAppSurfaceSubtle,
    shape: RoundedRectangleBorder(
      borderRadius: kAppMenuBorderRadius,
      side: BorderSide(color: accent.withValues(alpha: 0.3)),
    ),
    items: isBatchSelection
        ? [
            _header('Selection', accent),
            _item(
              LibraryItemContextAction.edit,
              Icons.edit_note,
              'Bulk edit selected',
            ),
            const PopupMenuDivider(),
            _header('Collection', accent),
            _item(
              LibraryItemContextAction.addToOwned,
              Icons.inventory_2_outlined,
              'Move selected to owned',
            ),
            _item(
              LibraryItemContextAction.addToWishlist,
              Icons.star_border,
              'Move selected to wishlist',
            ),
            _item(
              LibraryItemContextAction.removeFromOwned,
              Icons.delete_outline,
              'Remove selected',
              destructive: true,
            ),
          ]
        : [
            _header('Editing', accent),
            _item(
              LibraryItemContextAction.edit,
              Icons.edit_outlined,
              'Edit item...',
            ),
            const PopupMenuDivider(),
            _header('Collection', accent),
            if (!entry.isOwned)
              _item(
                LibraryItemContextAction.addToOwned,
                Icons.add_circle_outline,
                entry.isWishlisted
                    ? 'Convert wishlist to collection'
                    : 'Add to collection',
              )
            else
              _item(
                LibraryItemContextAction.removeFromOwned,
                Icons.remove_circle_outline,
                'Remove from collection',
                destructive: true,
              ),
            if (!entry.isWishlisted)
              _item(
                LibraryItemContextAction.addToWishlist,
                Icons.star_border,
                'Add to wishlist',
              )
            else
              _item(
                LibraryItemContextAction.removeFromWishlist,
                Icons.star_outline,
                'Remove from wishlist',
              ),
            if (entry.isTracked && !entry.isOwned)
              _item(
                LibraryItemContextAction.removeTracking,
                Icons.playlist_remove,
                'Stop tracking',
                destructive: true,
              ),
            const PopupMenuDivider(),
            _header('Copy', accent),
            _item(
              LibraryItemContextAction.copyTitle,
              Icons.content_copy,
              'Copy title',
            ),
            if (entry.barcode != null && entry.barcode!.isNotEmpty)
              _item(
                LibraryItemContextAction.copyBarcode,
                Icons.qr_code,
                'Copy barcode',
              ),
          ],
  );
}

PopupMenuEntry<LibraryItemContextMenuResult> _header(String label, Color accent) {
  return PopupMenuItem<LibraryItemContextMenuResult>(
    enabled: false,
    height: 28,
    child: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: accent,
        letterSpacing: 0.5,
      ),
    ),
  );
}

PopupMenuItem<LibraryItemContextMenuResult> _item(
  LibraryItemContextAction action,
  IconData icon,
  String label, {
  bool destructive = false,
}) {
  return PopupMenuItem<LibraryItemContextMenuResult>(
    value: LibraryItemContextMenuResult(action),
    height: 36,
    child: Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: destructive ? Colors.red[300] : Colors.white70,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: destructive ? Colors.red[300] : Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}
