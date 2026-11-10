import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/adaptive/mobile_page.dart';
import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/user_folder.dart';
import 'package:collectarr_app/features/collection/repositories/user_folder_repository.dart';
import 'package:collectarr_app/features/library/entries/repository.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';

/// Shows the user folders (shortlists) management dialog.
Future<void> showUserFoldersDialog({
  required BuildContext context,
  required LocalDatabase db,
  required Color accent,
}) {
  return showAppPageOrDialog<void>(
    context: context,
    builder: (_) => _UserFoldersDialog(db: db, accent: accent),
  );
}

class _UserFoldersDialog extends StatefulWidget {
  const _UserFoldersDialog({required this.db, required this.accent});

  final LocalDatabase db;
  final Color accent;

  @override
  State<_UserFoldersDialog> createState() => _UserFoldersDialogState();
}

class _UserFoldersDialogState extends State<_UserFoldersDialog> {
  List<UserFolder> _folders = [];
  Map<String, List<LibraryEntryRef>> _folderLibraryEntryRefs = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = UserFolderRepository(widget.db);
    final folders = await repo.getAll();
    final libraryEntryRefs = <String, List<LibraryEntryRef>>{};
    for (final folder in folders) {
      libraryEntryRefs[folder.id] =
          await repo.getLibraryEntryRefsInFolder(folder.id);
    }
    if (mounted) {
      setState(() {
        _folders = folders;
        _folderLibraryEntryRefs = libraryEntryRefs;
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
    final confirmed = await showAppDialog<bool>(
      context: context,
      builder: (ctx) => AccentAlertDialog(
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
    final refs = await repo.getLibraryEntryRefsInFolder(folder.id);
    await repo.delete(folder.id);
    for (final ref in refs) {
      await enqueueLibraryEntrySnapshot(widget.db, ref);
    }
    await _load();
  }

  Future<String?> _promptForName({
    required String title,
    required String confirmLabel,
    required String hintText,
    String? initialValue,
  }) async {
    var name = initialValue ?? '';
    return showAppDialog<String>(
      context: context,
      builder: (ctx) => AccentAlertDialog(
        backgroundColor: appPalette(ctx).panel,
        title: Text(title),
        content: TextFormField(
          initialValue: name,
          onChanged: (value) => name = value,
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
            onPressed: () => Navigator.pop(ctx, name.trim()),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final content = _loading
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
                  final count = _folderLibraryEntryRefs[folder.id]?.length ?? 0;
                  return ListTile(
                    leading: Icon(_iconForFolder(folder.iconName), size: 20),
                    title: Text(folder.name),
                    subtitle: Text('$count ${count == 1 ? 'item' : 'items'}',
                        style:
                            TextStyle(color: palette.textMuted, fontSize: 12)),
                    trailing: PopupMenuButton<_FolderAction>(
                      popUpAnimationStyle: AnimationStyle.noAnimation,
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
                            value: _FolderAction.rename, child: Text('Rename')),
                        PopupMenuItem(
                            value: _FolderAction.delete, child: Text('Delete')),
                      ],
                    ),
                  );
                },
              );
    if (appPresentationPlatform.isNativeMobile) {
      return MobilePage(
        title: 'Folders',
        onBack: () => Navigator.of(context).pop(),
        headerColor: widget.accent,
        backgroundColor: palette.panel,
        actions: [
          IconButton(
            tooltip: 'Create folder',
            icon: const Icon(Icons.add),
            onPressed: _createFolder,
          ),
        ],
        body: content,
      );
    }
    return AccentAlertDialog(
      backgroundColor: palette.panel,
      title: Row(
        children: [
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
        child: content,
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
