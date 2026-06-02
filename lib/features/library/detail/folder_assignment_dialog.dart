import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/user_folder.dart';
import 'package:collectarr_app/features/collection/repositories/user_folder_repository.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Shows a dialog to add/remove an owned item from user folders.
Future<void> showFolderAssignmentDialog({
  required BuildContext context,
  required LocalDatabase db,
  required String ownedItemId,
}) async {
  return showDialog<void>(
    context: context,
    builder: (_) => _FolderAssignmentDialog(db: db, ownedItemId: ownedItemId),
  );
}

class _FolderAssignmentDialog extends StatefulWidget {
  const _FolderAssignmentDialog({
    required this.db,
    required this.ownedItemId,
  });

  final LocalDatabase db;
  final String ownedItemId;

  @override
  State<_FolderAssignmentDialog> createState() =>
      _FolderAssignmentDialogState();
}

class _FolderAssignmentDialogState extends State<_FolderAssignmentDialog> {
  List<UserFolder> _folders = [];
  Set<String> _memberOf = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = UserFolderRepository(widget.db);
    final folders = await repo.getAll();
    final belonging = await repo.getFoldersForItem(widget.ownedItemId);
    if (mounted) {
      setState(() {
        _folders = folders;
        _memberOf = belonging.map((f) => f.id).toSet();
        _loading = false;
      });
    }
  }

  Future<void> _toggle(String folderId) async {
    final repo = UserFolderRepository(widget.db);
    if (_memberOf.contains(folderId)) {
      await repo.removeItemFromFolder(folderId, widget.ownedItemId);
      if (mounted) setState(() => _memberOf.remove(folderId));
    } else {
      await repo.addItemToFolder(folderId, widget.ownedItemId);
      if (mounted) setState(() => _memberOf.add(folderId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return AlertDialog(
      backgroundColor: palette.panel,
      titlePadding: EdgeInsets.zero,
      title: const AccentDialogHeader(
        title: 'Assign to Folders',
        icon: Icons.folder_outlined,
      ),
      content: SizedBox(
        width: 320,
        height: 280,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _folders.isEmpty
                ? Center(
                    child: Text(
                      'No folders yet.\n'
                      'Create folders from the toolbar menu\n'
                      'to organize items into shortlists.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: palette.textMuted),
                    ),
                  )
                : ListView.builder(
                    itemCount: _folders.length,
                    itemBuilder: (context, i) {
                      final folder = _folders[i];
                      final isMember = _memberOf.contains(folder.id);
                      return CheckboxListTile(
                        value: isMember,
                        title: Text(folder.name),
                        secondary: Icon(
                          isMember
                              ? Icons.folder
                              : Icons.folder_outlined,
                          size: 20,
                        ),
                        dense: true,
                        onChanged: (_) => _toggle(folder.id),
                      );
                    },
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
