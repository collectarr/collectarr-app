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
  late final List<_ReleaseLinkRow> _rows;

  @override
  void initState() {
    super.initState();
    _rows = [
      for (final link in widget.draft.externalLinks)
        _ReleaseLinkRow.fromLink(link),
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
          url: row.url.text.trim(),
          title: _nullable(row.title.text),
          description: _nullable(row.description.text),
        ),
    ];
  }

  void _add() {
    setState(() => _rows.add(_ReleaseLinkRow.empty()));
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
    List<LibraryExternalLinkEditRow<_ReleaseLinkRow>> selectedRows,
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
  Widget build(BuildContext context) => EditTabShell(
        scrollable: false,
        children: [
          EditSection(
            title: 'Release links',
            accent: widget.accent,
            child: LibraryExternalLinksTable<_ReleaseLinkRow>(
              rows: [
                for (final row in _rows)
                  LibraryExternalLinkEditRow<_ReleaseLinkRow>(
                    identity: row,
                    titleController: row.title,
                    urlController: row.url,
                    descriptionController: row.description,
                    titleFieldKey: ValueKey('musicAlbumLinkTitle_${row.key}'),
                    urlFieldKey: ValueKey('musicAlbumLinkUrl_${row.key}'),
                    descriptionFieldKey:
                        ValueKey('musicAlbumLinkDescription_${row.key}'),
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
          ),
        ],
      );
}

final class _ReleaseLinkRow {
  _ReleaseLinkRow({
    required this.title,
    required this.url,
    required this.description,
  }) : key = UniqueKey();

  factory _ReleaseLinkRow.empty() => _ReleaseLinkRow(
        title: TextEditingController(),
        url: TextEditingController(),
        description: TextEditingController(),
      );

  factory _ReleaseLinkRow.fromLink(MusicExternalLink link) => _ReleaseLinkRow(
        title: TextEditingController(text: link.title ?? ''),
        url: TextEditingController(text: link.url),
        description: TextEditingController(text: link.description ?? ''),
      );

  final Key key;
  final TextEditingController title;
  final TextEditingController url;
  final TextEditingController description;
  void dispose() {
    title.dispose();
    url.dispose();
    description.dispose();
  }
}

String? _nullable(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
