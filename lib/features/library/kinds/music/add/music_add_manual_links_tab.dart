import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
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
    final removed = _rows.where(selected.contains).toList(growable: false);
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
                titleFieldKey: ValueKey('music-add-link-title-${row.id}'),
                urlFieldKey: ValueKey('music-add-link-url-${row.id}'),
                descriptionFieldKey:
                    ValueKey('music-add-link-description-${row.id}'),
              ),
          ],
          accent: widget.accent,
          addLabel: 'New Link',
          emptyMessage: 'No links added yet.',
          showTitleColumn: true,
          onAdd: _add,
          onReorder: _reorder,
          onRemoveSelected: _removeSelected,
          onChanged: _syncDraft,
        ),
      );
}
