import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/user_folder.dart';
import 'package:collectarr_app/features/collection/repositories/user_folder_repository.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
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
    final palette = appPalette(context);
    final colorScheme = Theme.of(context).colorScheme;

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
          DecoratedBox(
            decoration: BoxDecoration(
              color: palette.surfaceSubtle.withValues(alpha: 0.74),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: palette.divider.withValues(alpha: 0.8)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: palette.textMuted.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Icon(
                      Icons.folder_off_outlined,
                      size: 16,
                      color: palette.textMuted,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Not in any folder',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: palette.textMuted,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Use the add action to place this item into a custom folder.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ..._folders.map(
          (folder) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: palette.surfaceSubtle.withValues(alpha: 0.74),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: palette.divider.withValues(alpha: 0.8)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: widget.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Icon(
                        Icons.folder_outlined,
                        size: 16,
                        color: widget.accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        folder.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removeFromFolder(folder.id),
                      tooltip: 'Remove from folder',
                      icon: Icon(Icons.close, size: 16, color: palette.textMuted),
                      visualDensity: VisualDensity.compact,
                      style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
        backgroundColor: appPalette(ctx).panel,
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
    final palette = appPalette(context);
    return AlertDialog(
      backgroundColor: palette.panel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            ? DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.surfaceSubtle.withValues(alpha: 0.82),
                  border: Border.all(color: palette.divider),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'No folders available.\nTap + to create one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: palette.textMuted),
                    ),
                  ),
                ),
              )
            : Material(
                color: palette.surfaceSubtle.withValues(alpha: 0.64),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: palette.divider),
                ),
                clipBehavior: Clip.antiAlias,
                child: ListView.builder(
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
