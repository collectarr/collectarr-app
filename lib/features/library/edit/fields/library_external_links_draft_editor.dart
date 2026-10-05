import 'package:collectarr_app/features/library/edit/fields/library_external_links_table.dart';
import 'package:flutter/material.dart';

/// Owns the common row interactions for a list of editable external links.
///
/// Kinds keep ownership of the rows and map them to their own metadata models.
final class LibraryExternalLinksDraftEditor extends StatefulWidget {
  const LibraryExternalLinksDraftEditor({
    super.key,
    required this.links,
    required this.accent,
    this.onChanged,
    this.addLabel = 'Add Link',
    this.showTitleColumn = true,
    this.emptyMessage = 'No external links added.',
  });

  final List<LibraryExternalLinkDraftRow> links;
  final Color accent;
  final VoidCallback? onChanged;
  final bool showTitleColumn;
  final String addLabel;
  final String emptyMessage;

  @override
  State<LibraryExternalLinksDraftEditor> createState() =>
      _LibraryExternalLinksDraftEditorState();
}

final class _LibraryExternalLinksDraftEditorState
    extends State<LibraryExternalLinksDraftEditor> {
  @override
  Widget build(BuildContext context) =>
      LibraryExternalLinksTable<LibraryExternalLinkDraftRow>(
        rows: [
          for (final link in widget.links)
            LibraryExternalLinkEditRow<LibraryExternalLinkDraftRow>(
              identity: link,
              titleController:
                  widget.showTitleColumn ? link.titleController : null,
              urlController: link.urlController,
              descriptionController: link.descriptionController,
            ),
        ],
        accent: widget.accent,
        addLabel: widget.addLabel,
        emptyMessage: widget.emptyMessage,
        showTitleColumn: widget.showTitleColumn,
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
