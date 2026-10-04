import 'package:collectarr_app/features/library/edit/draft/editable_user_external_link.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_table.dart';
import 'package:flutter/material.dart';

/// Editable external links owned by a local library entry.
final class LibraryExternalLinksEditor extends StatefulWidget {
  const LibraryExternalLinksEditor({
    super.key,
    required this.title,
    required this.items,
    required this.onAdd,
    this.onChanged,
    this.emptyMessage = 'No entries yet.',
    this.accent,
  });

  final String title;
  final List<EditableUserExternalLink> items;
  final VoidCallback onAdd;
  final VoidCallback? onChanged;
  final String emptyMessage;
  final Color? accent;

  @override
  State<LibraryExternalLinksEditor> createState() =>
      _LibraryExternalLinksEditorState();
}

final class _LibraryExternalLinksEditorState
    extends State<LibraryExternalLinksEditor> {
  void _add() {
    widget.onAdd();
    widget.onChanged?.call();
    setState(() {});
  }

  void _reorder(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    final item = widget.items.removeAt(oldIndex);
    widget.items.insert(newIndex, item);
    widget.onChanged?.call();
    setState(() {});
  }

  void _removeSelected(
    List<LibraryExternalLinkEditRow<EditableUserExternalLink>> selectedRows,
  ) {
    final selected = {for (final row in selectedRows) row.identity};
    widget.items.removeWhere((item) {
      if (!selected.contains(item)) return false;
      item.dispose();
      return true;
    });
    widget.onChanged?.call();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LibraryExternalLinksTable<EditableUserExternalLink>(
      rows: [
        for (final item in widget.items)
          LibraryExternalLinkEditRow<EditableUserExternalLink>(
            identity: item,
            urlController: item.urlController,
            descriptionController: item.labelController,
          ),
      ],
      accent: widget.accent ?? Theme.of(context).colorScheme.primary,
      addLabel: 'Add ${widget.title}',
      emptyMessage: widget.emptyMessage,
      onAdd: _add,
      onReorder: _reorder,
      onRemoveSelected: _removeSelected,
      onChanged: widget.onChanged,
    );
  }
}
