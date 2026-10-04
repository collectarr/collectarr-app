import 'package:collectarr_app/features/library/edit/fields/library_external_links_table.dart';
import 'package:flutter/material.dart';

/// Shared Add/Edit editor for Board Game catalog links.
final class BoardGameExternalLinksEditor extends StatefulWidget {
  const BoardGameExternalLinksEditor({
    super.key,
    required this.links,
    required this.accent,
    this.onChanged,
  });

  final List<LibraryExternalLinkDraftRow> links;
  final Color accent;
  final VoidCallback? onChanged;

  @override
  State<BoardGameExternalLinksEditor> createState() =>
      _BoardGameExternalLinksEditorState();
}

final class _BoardGameExternalLinksEditorState
    extends State<BoardGameExternalLinksEditor> {
  @override
  Widget build(BuildContext context) =>
      LibraryExternalLinksTable<LibraryExternalLinkDraftRow>(
        rows: [
          for (final link in widget.links)
            LibraryExternalLinkEditRow<LibraryExternalLinkDraftRow>(
              identity: link,
              titleController: link.titleController,
              urlController: link.urlController,
              descriptionController: link.descriptionController,
            ),
        ],
        accent: widget.accent,
        addLabel: 'Add Link',
        emptyMessage: 'No external links added.',
        showTitleColumn: true,
        onAdd: () => setState(() {
          widget.links.add(LibraryExternalLinkDraftRow());
          widget.onChanged?.call();
        }),
        onReorder: (oldIndex, newIndex) => setState(() {
          final link = widget.links.removeAt(oldIndex);
          widget.links.insert(newIndex, link);
          widget.onChanged?.call();
        }),
        onRemoveSelected: (rows) => setState(() {
          for (final row in rows) {
            if (widget.links.remove(row.identity)) row.identity.dispose();
          }
          widget.onChanged?.call();
        }),
        onChanged: widget.onChanged,
      );
}
