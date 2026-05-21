import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/ui/clz_style.dart';
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
  copyTitle,
  copyBarcode,
}

Future<LibraryItemContextMenuResult?> showLibraryItemContextMenu({
  required BuildContext context,
  required Offset position,
  required LibraryWorkspaceEntry entry,
  required Color accent,
}) {
  final overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox?;
  if (overlay == null) {
    return Future.value(null);
  }
  return showMenu<LibraryItemContextMenuResult>(
    context: context,
    position: RelativeRect.fromLTRB(
      position.dx,
      position.dy,
      overlay.size.width - position.dx,
      overlay.size.height - position.dy,
    ),
    color: const Color(0xFF262626),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
      side: BorderSide(color: accent.withValues(alpha: 0.3)),
    ),
    items: [
      _header('Editing'),
      _item(
        LibraryItemContextAction.edit,
        Icons.edit_outlined,
        'Edit item...',
      ),
      const PopupMenuDivider(),
      _header('Collection'),
      if (!entry.isOwned)
        _item(
          LibraryItemContextAction.addToOwned,
          Icons.add_circle_outline,
          'Add to owned',
        )
      else
        _item(
          LibraryItemContextAction.removeFromOwned,
          Icons.remove_circle_outline,
          'Remove from owned',
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
      const PopupMenuDivider(),
      _header('Copy'),
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

PopupMenuEntry<LibraryItemContextMenuResult> _header(String label) {
  return PopupMenuItem<LibraryItemContextMenuResult>(
    enabled: false,
    height: 28,
    child: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: kClzYellow,
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
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: destructive ? Colors.red[300] : Colors.white,
          ),
        ),
      ],
    ),
  );
}
