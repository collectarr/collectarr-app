import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/user_folder.dart';
import 'package:collectarr_app/features/collection/repositories/user_folder_repository.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Shows the user folders (shortlists) management dialog.
Future<void> showUserFoldersDialog({
  required BuildContext context,
  required LocalDatabase db,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _UserFoldersDialog(db: db),
  );
}

class _UserFoldersDialog extends StatefulWidget {
  const _UserFoldersDialog({required this.db});

  final LocalDatabase db;

  @override
  State<_UserFoldersDialog> createState() => _UserFoldersDialogState();
}

class _UserFoldersDialogState extends State<_UserFoldersDialog> {
  List<UserFolder> _folders = [];
  Map<String, List<String>> _folderItemIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = UserFolderRepository(widget.db);
    final folders = await repo.getAll();
    final itemIds = <String, List<String>>{};
    for (final folder in folders) {
      itemIds[folder.id] = await repo.getItemIdsInFolder(folder.id);
    }
    if (mounted) {
      setState(() {
        _folders = folders;
        _folderItemIds = itemIds;
        _loading = false;
      });
    }
  }

  Future<void> _createFolder() async {
    final name = await _promptForName(
      title: 'New Folder',
      confirmLabel: 'Create',
      hintText: 'e.g. Favorites, To Watch, Top 10',
    );
    if (name == null || name.isEmpty) return;

    final repo = UserFolderRepository(widget.db);
    await repo.create(name: name);
    await _load();
  }

  Future<void> _renameFolder(UserFolder folder) async {
    final name = await _promptForName(
      title: 'Rename Folder',
      confirmLabel: 'Rename',
      hintText: 'New name',
      initialValue: folder.name,
    );
    if (name == null || name.isEmpty || name == folder.name) return;

    final repo = UserFolderRepository(widget.db);
    await repo.rename(folder.id, name);
    await _load();
  }

  Future<void> _deleteFolder(UserFolder folder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: appPalette(ctx).panel,
        title: const Text('Delete Folder'),
        content: Text(
          'Delete "${folder.name}" and remove all item assignments?\n'
          'Items themselves will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final repo = UserFolderRepository(widget.db);
    await repo.delete(folder.id);
    await _load();
  }

  Future<String?> _promptForName({
    required String title,
    required String confirmLabel,
    required String hintText,
    String? initialValue,
  }) async {
    final nameCtrl = TextEditingController(text: initialValue ?? '');
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: appPalette(ctx).panel,
        title: Text(title),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Name',
            hintText: hintText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, nameCtrl.text.trim()),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return AlertDialog(
      backgroundColor: palette.panel,
      title: Row(
        children: [
          const Icon(Icons.folder_outlined, size: 20),
          const SizedBox(width: 8),
          const Expanded(child: Text('Folders')),
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            tooltip: 'Create folder',
            onPressed: _createFolder,
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        height: 340,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _folders.isEmpty
                ? Center(
                    child: Text(
                      'No folders yet.\n'
                      'Create a folder to organize items\n'
                      'into custom shortlists.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: palette.textMuted),
                    ),
                  )
                : ListView.separated(
                    itemCount: _folders.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: palette.divider),
                    itemBuilder: (context, i) {
                      final folder = _folders[i];
                      final count = _folderItemIds[folder.id]?.length ?? 0;
                      return ListTile(
                        leading: Icon(
                          _iconForFolder(folder.iconName),
                          size: 20,
                        ),
                        title: Text(folder.name),
                        subtitle: Text(
                          '$count ${count == 1 ? 'item' : 'items'}',
                          style: TextStyle(
                            color: palette.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        dense: true,
                        trailing: PopupMenuButton<_FolderAction>(
                          icon: const Icon(Icons.more_horiz, size: 18),
                          tooltip: 'Folder actions',
                          onSelected: (action) async {
                            switch (action) {
                              case _FolderAction.rename:
                                await _renameFolder(folder);
                              case _FolderAction.delete:
                                await _deleteFolder(folder);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: _FolderAction.rename,
                              child: Text('Rename'),
                            ),
                            PopupMenuItem(
                              value: _FolderAction.delete,
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  static IconData _iconForFolder(String? iconName) {
    return switch (iconName) {
      'star' => Icons.star,
      'bookmark' => Icons.bookmark,
      'favorite' => Icons.favorite,
      'playlist' => Icons.playlist_add_check,
      _ => Icons.folder_outlined,
    };
  }
}

enum _FolderAction { rename, delete }
