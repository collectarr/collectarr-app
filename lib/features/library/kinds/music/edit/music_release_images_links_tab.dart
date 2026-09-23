import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_table.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_external_link.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_draft.dart';
import 'package:flutter/material.dart';

final class MusicReleaseLinksTab extends StatefulWidget {
  const MusicReleaseLinksTab({
    super.key,
    required this.draft,
    required this.accent,
  });

  final MusicReleaseEditDraft draft;
  final Color accent;

  @override
  State<MusicReleaseLinksTab> createState() => _MusicReleaseLinksTabState();
}

final class _MusicReleaseLinksTabState extends State<MusicReleaseLinksTab> {
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
          title: row.original?.title,
          description: _nullable(row.description.text),
          source: row.original?.source ?? 'manual',
          isAutomatic: row.original?.isAutomatic ?? false,
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

  void _removeSelected(List<LibraryExternalLinkEditRow> selectedRows) {
    final selected = {
      for (final row in selectedRows) row.identity as _ReleaseLinkRow,
    };
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
        children: [
          EditSection(
            title: 'Release links',
            accent: widget.accent,
            child: LibraryExternalLinksTable(
              rows: [
                for (final row in _rows)
                  LibraryExternalLinkEditRow(
                    identity: row,
                    urlController: row.url,
                    descriptionController: row.description,
                    urlFieldKey: ValueKey('musicReleaseLinkUrl_${row.key}'),
                    descriptionFieldKey:
                        ValueKey('musicReleaseLinkDescription_${row.key}'),
                  ),
              ],
              accent: widget.accent,
              addLabel: 'New Link',
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
    required this.url,
    required this.description,
    this.original,
  }) : key = UniqueKey();

  factory _ReleaseLinkRow.empty() => _ReleaseLinkRow(
        url: TextEditingController(),
        description: TextEditingController(),
      );

  factory _ReleaseLinkRow.fromLink(MusicExternalLink link) => _ReleaseLinkRow(
        url: TextEditingController(text: link.url),
        description: TextEditingController(
          text: link.description ?? link.title ?? '',
        ),
        original: link,
      );

  final Key key;
  final TextEditingController url;
  final TextEditingController description;
  final MusicExternalLink? original;

  void dispose() {
    url.dispose();
    description.dispose();
  }
}

String? _nullable(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
