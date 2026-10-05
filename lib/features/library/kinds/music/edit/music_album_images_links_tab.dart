import 'package:collectarr_app/features/library/edit/fields/library_external_links_draft_editor.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_table.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_external_link.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:flutter/material.dart';

final class MusicAlbumLinksTab extends StatefulWidget {
  const MusicAlbumLinksTab({
    super.key,
    required this.draft,
    required this.accent,
  });

  final MusicAlbumEditDraft draft;
  final Color accent;

  @override
  State<MusicAlbumLinksTab> createState() => _MusicAlbumLinksTabState();
}

final class _MusicAlbumLinksTabState extends State<MusicAlbumLinksTab> {
  late final List<LibraryExternalLinkDraftRow> _rows;

  @override
  void initState() {
    super.initState();
    _rows = [
      for (final link in widget.draft.externalLinks)
        LibraryExternalLinkDraftRow(
          title: link.title ?? '',
          url: link.url,
          description: link.description ?? '',
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
    widget.draft.externalLinks = [
      for (final row in _rows)
        MusicExternalLink(
          url: row.urlController.text.trim(),
          title: _nullable(row.titleController.text),
          description: _nullable(row.descriptionController.text),
        ),
    ];
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

String? _nullable(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
