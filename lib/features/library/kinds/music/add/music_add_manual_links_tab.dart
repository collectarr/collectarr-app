import 'package:collectarr_app/features/library/edit/fields/library_external_links_draft_editor.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_table.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_contents.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:flutter/material.dart';

/// Manual Add editor for the ordered external links attached to an album.
final class MusicAddManualLinksTab extends StatefulWidget {
  const MusicAddManualLinksTab({
    super.key,
    required this.draft,
    required this.accent,
  });

  final MusicAddManualDraft draft;
  final Color accent;

  @override
  State<MusicAddManualLinksTab> createState() => _MusicAddManualLinksTabState();
}

final class _MusicAddManualLinksTabState extends State<MusicAddManualLinksTab> {
  late final List<LibraryExternalLinkDraftRow> _rows;

  @override
  void initState() {
    super.initState();
    _rows = [
      for (final link in widget.draft.externalLinks)
        LibraryExternalLinkDraftRow(
          id: link.id,
          title: link.title,
          url: link.url,
          description: link.description,
        ),
    ];
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _syncDraft() {
    widget.draft.externalLinks
      ..clear()
      ..addAll([
        for (final row in _rows)
          MusicAddManualExternalLink(
            id: row.id,
            title: row.titleController.text,
            url: row.urlController.text,
            description: row.descriptionController.text,
          ),
      ]);
  }

  @override
  Widget build(BuildContext context) => LibraryExternalLinksDraftEditor(
        links: _rows,
        accent: widget.accent,
        addLabel: 'New Link',
        showTitleColumn: false,
        onChanged: _syncDraft,
      );
}
