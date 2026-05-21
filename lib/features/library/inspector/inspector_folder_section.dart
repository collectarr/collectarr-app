import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/user_folder.dart';
import 'package:collectarr_app/features/collection/repositories/user_folder_repository.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/ui/clz_style.dart';
import 'package:flutter/material.dart';

class InspectorFolderSection extends StatefulWidget {
  const InspectorFolderSection({
    super.key,
    required this.ownedItemId,
    required this.db,
    required this.accent,
  });

  final String ownedItemId;
  final LocalDatabase db;
  final Color accent;

  @override
  State<InspectorFolderSection> createState() => _InspectorFolderSectionState();
}

class _InspectorFolderSectionState extends State<InspectorFolderSection> {
  List<UserFolder> _folders = [];
  List<UserFolder> _allFolders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = UserFolderRepository(widget.db);
    final itemFolders = await repo.getFoldersForItem(widget.ownedItemId);
    final all = await repo.getAll();
    if (mounted) {
      setState(() {
        _folders = itemFolders;
        _allFolders = all;
        _loading = false;
      });
    }
  }

  Future<void> _addToFolder() async {
    final repo = UserFolderRepository(widget.db);
    final currentIds = _folders.map((f) => f.id).toSet();
    final available =
        _allFolders.where((f) => !currentIds.contains(f.id)).toList();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => _FolderPickerDialog(
        available: available,
        db: widget.db,
      ),
    );
    if (result != null && result.isNotEmpty) {
      await repo.addItemToFolder(result, widget.ownedItemId);
      _load();
    }
  }

  Future<void> _removeFromFolder(String folderId) async {
    final repo = UserFolderRepository(widget.db);
    await repo.removeItemFromFolder(folderId, widget.ownedItemId);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();

    return LibraryInspectorSection(
      title: 'Folders',
      accentColor: widget.accent,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.add, size: 18),
            tooltip: 'Add to folder',
            onPressed: _addToFolder,
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              foregroundColor: widget.accent,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        if (_folders.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Not in any folder',
              style: TextStyle(color: kClzTextMuted, fontSize: 12),
            ),
          ),
        ..._folders.map((folder) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  Icon(Icons.folder_outlined, size: 14, color: widget.accent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      folder.name,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  InkWell(
                    onTap: () => _removeFromFolder(folder.id),
                    child: Icon(Icons.close, size: 14, color: kClzTextMuted),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class _FolderPickerDialog extends StatefulWidget {
  const _FolderPickerDialog({
    required this.available,
    required this.db,
  });

  final List<UserFolder> available;
  final LocalDatabase db;

  @override
  State<_FolderPickerDialog> createState() => _FolderPickerDialogState();
}

class _FolderPickerDialogState extends State<_FolderPickerDialog> {
  late List<UserFolder> _available;

  @override
  void initState() {
    super.initState();
    _available = List.of(widget.available);
  }

  Future<void> _createNew() async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kClzPanel,
        title: const Text('New Folder'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Folder name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Create')),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      final repo = UserFolderRepository(widget.db);
      final folder = await repo.create(name: name);
      if (mounted) Navigator.pop(context, folder.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kClzPanel,
      title: Row(
        children: [
          const Expanded(child: Text('Add to Folder')),
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            tooltip: 'Create new folder',
            onPressed: _createNew,
          ),
        ],
      ),
      content: SizedBox(
        width: 280,
        height: 240,
        child: _available.isEmpty
            ? Center(
                child: Text(
                  'No folders available.\nTap + to create one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kClzTextMuted),
                ),
              )
            : ListView.builder(
                itemCount: _available.length,
                itemBuilder: (context, i) {
                  final folder = _available[i];
                  return ListTile(
                    leading: const Icon(Icons.folder_outlined, size: 20),
                    title: Text(folder.name),
                    dense: true,
                    onTap: () => Navigator.pop(context, folder.id),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
