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
  late final List<_MusicAddLinkRow> _rows;

  @override
  void initState() {
    super.initState();
    _rows = [
      for (final link in widget.draft.externalLinks)
        _MusicAddLinkRow.fromLink(link),
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
            title: row.title.text,
            url: row.url.text,
            description: row.description.text,
          ),
      ]);
  }

  void _add() {
    setState(() => _rows.add(_MusicAddLinkRow.empty()));
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
    List<LibraryExternalLinkEditRow<_MusicAddLinkRow>> selectedRows,
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
        child: LibraryExternalLinksTable<_MusicAddLinkRow>(
          rows: [
            for (final row in _rows)
              LibraryExternalLinkEditRow<_MusicAddLinkRow>(
                identity: row,
                titleController: row.title,
                urlController: row.url,
                descriptionController: row.description,
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

final class _MusicAddLinkRow {
  _MusicAddLinkRow({
    required this.id,
    required this.title,
    required this.url,
    required this.description,
  });

  factory _MusicAddLinkRow.empty() => _MusicAddLinkRow(
        id: MusicAddManualExternalLink().id,
        title: TextEditingController(),
        url: TextEditingController(),
        description: TextEditingController(),
      );

  factory _MusicAddLinkRow.fromLink(MusicAddManualExternalLink link) =>
      _MusicAddLinkRow(
        id: link.id,
        title: TextEditingController(text: link.title),
        url: TextEditingController(text: link.url),
        description: TextEditingController(text: link.description),
      );

  final String id;
  final TextEditingController title;
  final TextEditingController url;
  final TextEditingController description;

  void dispose() {
    title.dispose();
    url.dispose();
    description.dispose();
  }
}
