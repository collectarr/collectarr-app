import 'package:collectarr_app/features/library/edit/fields/library_external_links_table.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_external_link_draft.dart';
import 'package:flutter/material.dart';

/// Reorderable Book catalog links editor shared by Add and Edit.
final class BookExternalLinksEditor extends StatefulWidget {
  const BookExternalLinksEditor({
    super.key,
    required this.links,
    required this.accent,
    this.onChanged,
  });

  final List<BookCatalogExternalLinkDraft> links;
  final Color accent;
  final VoidCallback? onChanged;

  @override
  State<BookExternalLinksEditor> createState() =>
      _BookExternalLinksEditorState();
}

final class _BookExternalLinksEditorState
    extends State<BookExternalLinksEditor> {
  @override
  Widget build(BuildContext context) =>
      LibraryExternalLinksTable<BookCatalogExternalLinkDraft>(
        rows: [
          for (final link in widget.links)
            LibraryExternalLinkEditRow<BookCatalogExternalLinkDraft>(
              identity: link,
              titleController: link.row.titleController,
              urlController: link.row.urlController,
              descriptionController: link.row.descriptionController,
            ),
        ],
        accent: widget.accent,
        addLabel: 'Add Link',
        emptyMessage: 'No external links added.',
        showTitleColumn: true,
        onAdd: () => setState(() {
          widget.links.add(BookCatalogExternalLinkDraft());
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
