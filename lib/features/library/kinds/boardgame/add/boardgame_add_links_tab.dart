import 'package:collectarr_app/features/library/edit/fields/library_external_links_table.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_external_link_draft.dart';
import 'package:flutter/material.dart';

final class BoardgameAddLinksTab extends StatefulWidget {
  const BoardgameAddLinksTab({
    super.key,
    required this.draft,
    required this.accent,
    this.onChanged,
  });

  final BoardgameAddManualDraft draft;
  final Color accent;
  final VoidCallback? onChanged;

  @override
  State<BoardgameAddLinksTab> createState() => _BoardgameAddLinksTabState();
}

final class _BoardgameAddLinksTabState extends State<BoardgameAddLinksTab> {
  @override
  Widget build(BuildContext context) {
    final links = widget.draft.externalLinks;
    return LibraryExternalLinksTable<BoardGameExternalLinkDraft>(
      rows: [
        for (final link in links)
          LibraryExternalLinkEditRow<BoardGameExternalLinkDraft>(
            identity: link,
            urlController: link.urlController,
            descriptionController: link.descriptionController,
          ),
      ],
      accent: widget.accent,
      addLabel: 'New Link',
      onAdd: () => setState(() {
        links.add(BoardGameExternalLinkDraft());
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
