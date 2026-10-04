import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
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

  void _add() {
    setState(() => _rows.add(LibraryExternalLinkDraftRow()));
    _syncDraft();
  }

  void _reorder(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    final row = _rows.removeAt(oldIndex);
    _rows.insert(newIndex, row);
    setState(() {});
    _syncDraft();
  }

  void _removeSelected(
    List<LibraryExternalLinkEditRow<LibraryExternalLinkDraftRow>> selectedRows,
  ) {
    final selected = {for (final row in selectedRows) row.identity};
    final removed = _rows.where(selected.contains).toList();
    _rows.removeWhere(selected.contains);
    for (final row in removed) {
      row.dispose();
    }
    setState(() {});
    _syncDraft();
  }

  @override
  Widget build(BuildContext context) => EditSection(
        title: 'Release links',
        accent: widget.accent,
        child: LibraryExternalLinksTable<LibraryExternalLinkDraftRow>(
          rows: [
            for (final row in _rows)
              LibraryExternalLinkEditRow<LibraryExternalLinkDraftRow>(
                identity: row,
                titleController: row.titleController,
                urlController: row.urlController,
                descriptionController: row.descriptionController,
                titleFieldKey: ValueKey('musicAlbumLinkTitle_${row.id}'),
                urlFieldKey: ValueKey('musicAlbumLinkUrl_${row.id}'),
                descriptionFieldKey:
                    ValueKey('musicAlbumLinkDescription_${row.id}'),
              ),
          ],
          accent: widget.accent,
          addLabel: 'New Link',
          showTitleColumn: true,
          onAdd: _add,
          onReorder: _reorder,
          onRemoveSelected: _removeSelected,
          onChanged: _syncDraft,
        ),
      );
}

String? _nullable(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
