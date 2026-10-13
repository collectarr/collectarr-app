import 'package:collectarr_app/features/library/edit/fields/library_external_links_table.dart';
import 'package:flutter/material.dart';

/// An external link value shared by kind-owned catalog models.
final class LibraryExternalLinkValue {
  const LibraryExternalLinkValue({
    required this.url,
    this.title = '',
    this.description = '',
  });

  final String url;
  final String title;
  final String description;
}

/// Shared link-tab lifecycle for kinds whose editable external links use the
/// common URL, title, and description fields.
final class LibraryExternalLinksEditSection extends StatefulWidget {
  const LibraryExternalLinksEditSection({
    super.key,
    required this.links,
    required this.accent,
    required this.onChanged,
    this.addLabel = 'Add Link',
    this.showTitleColumn = true,
    this.emptyMessage = 'No external links added.',
  });

  final List<LibraryExternalLinkValue> links;
  final Color accent;
  final ValueChanged<List<LibraryExternalLinkValue>> onChanged;
  final bool showTitleColumn;
  final String addLabel;
  final String emptyMessage;

  @override
  State<LibraryExternalLinksEditSection> createState() =>
      _LibraryExternalLinksEditSectionState();
}

final class _LibraryExternalLinksEditSectionState
    extends State<LibraryExternalLinksEditSection> {
  late final List<LibraryExternalLinkDraftRow> _rows = [
    for (final link in widget.links)
      LibraryExternalLinkDraftRow(
        title: link.title,
        url: link.url,
        description: link.description,
      ),
  ];

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _emitChanges() => widget.onChanged([
        for (final row in _rows)
          LibraryExternalLinkValue(
            title: row.titleController.text,
            url: row.urlController.text,
            description: row.descriptionController.text,
          ),
      ]);

  @override
  Widget build(BuildContext context) => LibraryExternalLinksDraftEditor(
        links: _rows,
        accent: widget.accent,
        onChanged: _emitChanges,
        addLabel: widget.addLabel,
        showTitleColumn: widget.showTitleColumn,
        emptyMessage: widget.emptyMessage,
      );
}

/// Renders common row interactions for externally managed link drafts.
///
/// Kind-specific editors may own and map rows themselves. The shared schema
/// editor uses [LibraryExternalLinksEditSection] to own row-controller
/// lifecycle for the common URL/title/description shape.
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
