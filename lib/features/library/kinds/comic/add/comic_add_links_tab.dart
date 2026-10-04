import 'package:collectarr_app/features/library/edit/fields/library_external_links_table.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_external_link_draft.dart';
import 'package:flutter/material.dart';

final class ComicAddLinksTab extends StatefulWidget {
  const ComicAddLinksTab({
    super.key,
    required this.draft,
    required this.accent,
    this.onChanged,
  });

  final ComicAddManualDraft draft;
  final Color accent;
  final VoidCallback? onChanged;

  @override
  State<ComicAddLinksTab> createState() => _ComicAddLinksTabState();
}

final class _ComicAddLinksTabState extends State<ComicAddLinksTab> {
  @override
  Widget build(BuildContext context) {
    final links = widget.draft.externalLinks;
    return LibraryExternalLinksTable<ComicExternalLinkDraft>(
      rows: [
        for (final link in links)
          LibraryExternalLinkEditRow<ComicExternalLinkDraft>(
            identity: link,
            urlController: link.urlController,
            descriptionController: link.titleController,
          ),
      ],
      accent: widget.accent,
      addLabel: 'New Link',
      onAdd: () => setState(() {
        links.add(ComicExternalLinkDraft());
        widget.onChanged?.call();
      }),
      onReorder: (oldIndex, newIndex) => setState(() {
        final link = links.removeAt(oldIndex);
        links.insert(newIndex, link);
        widget.onChanged?.call();
      }),
      onRemoveSelected: (rows) => setState(() {
        for (final row in rows) {
          final link = row.identity;
          if (links.remove(link)) link.dispose();
        }
        widget.onChanged?.call();
      }),
      onChanged: widget.onChanged,
    );
  }
}
