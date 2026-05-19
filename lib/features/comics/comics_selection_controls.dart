import 'package:collectarr_app/features/comics/workspace/comics_workspace_control_models.dart';
import 'package:collectarr_app/features/library/workspace/library_toolbar_stat.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_chrome.dart';
import 'package:flutter/material.dart';

enum _ComicsBulkToolbarAction { edit, owned, wishlist, remove, clear }

class ComicsSelectionControls extends StatelessWidget {
  const ComicsSelectionControls({
    super.key,
    required this.state,
    required this.callbacks,
  });

  final ComicsSelectionControlState state;
  final ComicsSelectionControlCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: state.enabled ? 'Exit selection' : 'Select comics',
          child: LibraryWorkspaceIconButton(
            onPressed: () => callbacks.onSelectionModeChanged(!state.enabled),
            icon: state.enabled ? Icons.close : Icons.checklist,
          ),
        ),
        if (state.enabled) ...[
          const SizedBox(width: 6),
          LibraryToolbarStat(label: 'Selected', value: state.selectedCount),
          const SizedBox(width: 6),
          ComicsBulkActionsMenu(
            state: state,
            callbacks: callbacks,
          ),
        ],
      ],
    );
  }
}

class ComicsBulkActionsMenu extends StatelessWidget {
  const ComicsBulkActionsMenu({
    super.key,
    required this.state,
    required this.callbacks,
  });

  final ComicsSelectionControlState state;
  final ComicsSelectionControlCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ComicsBulkToolbarAction>(
      tooltip: 'Bulk actions',
      enabled: state.selectedCount > 0,
      icon: const Icon(Icons.more_vert),
      onSelected: (action) {
        switch (action) {
          case _ComicsBulkToolbarAction.edit:
            callbacks.onBulkEdit();
          case _ComicsBulkToolbarAction.owned:
            callbacks.onBulkMoveToOwned();
          case _ComicsBulkToolbarAction.wishlist:
            callbacks.onBulkMoveToWishlist();
          case _ComicsBulkToolbarAction.remove:
            callbacks.onBulkRemove();
          case _ComicsBulkToolbarAction.clear:
            callbacks.onClearSelection();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _ComicsBulkToolbarAction.edit,
          child: ListTile(
            leading: Icon(Icons.edit_note),
            title: Text('Bulk edit'),
            dense: true,
          ),
        ),
        PopupMenuItem(
          value: _ComicsBulkToolbarAction.owned,
          child: ListTile(
            leading: Icon(Icons.inventory_2_outlined),
            title: Text('Move to owned'),
            dense: true,
          ),
        ),
        PopupMenuItem(
          value: _ComicsBulkToolbarAction.wishlist,
          child: ListTile(
            leading: Icon(Icons.star_border),
            title: Text('Move to wishlist'),
            dense: true,
          ),
        ),
        PopupMenuItem(
          value: _ComicsBulkToolbarAction.remove,
          child: ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text('Remove selected'),
            dense: true,
          ),
        ),
        PopupMenuItem(
          value: _ComicsBulkToolbarAction.clear,
          child: ListTile(
            leading: Icon(Icons.deselect),
            title: Text('Clear selection'),
            dense: true,
          ),
        ),
      ],
    );
  }
}
