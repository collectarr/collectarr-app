import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_table.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_external_link.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_group_cover_editor.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_group_edit_draft.dart';
import 'package:flutter/material.dart';

enum MusicReleaseGroupAssetSection { covers, links }

/// Release-group-owned artwork and external links, shown on separate tabs.
final class MusicReleaseGroupImagesLinksTab extends StatefulWidget {
  const MusicReleaseGroupImagesLinksTab({
    super.key,
    required this.draft,
    required this.accent,
    required this.section,
  });

  final MusicReleaseGroupEditDraft draft;
  final Color accent;
  final MusicReleaseGroupAssetSection section;

  @override
  State<MusicReleaseGroupImagesLinksTab> createState() =>
      _MusicReleaseGroupImagesLinksTabState();
}

final class _MusicReleaseGroupImagesLinksTabState
    extends State<MusicReleaseGroupImagesLinksTab> {
  late final List<_GroupLinkRow> _rows;

  @override
  void initState() {
    super.initState();
    _rows = [
      for (final link in widget.draft.externalLinks)
        _GroupLinkRow.fromLink(link),
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
        if (_nullable(row.url.text) case final url?)
          MusicExternalLink(
            url: url,
            title: row.original?.title,
            description: _nullable(row.description.text),
            source: row.original?.source ?? 'manual',
            isAutomatic: row.original?.isAutomatic ?? false,
          ),
    ];
  }

  void _add() {
    setState(() => _rows.add(_GroupLinkRow.empty()));
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
    List<LibraryExternalLinkEditRow<_GroupLinkRow>> selectedRows,
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
  Widget build(BuildContext context) {
    final covers = [
      MusicReleaseGroupCoverEditor(
        releaseGroupId: widget.draft.original.id.value,
        coreCoverUrl: widget.draft.values.coverImageUrl,
        originalCoreCoverUrl: widget.draft.original.coverImageUrl,
        localCoverPath: widget.draft.localCoverImagePath,
        onCoreCoverChanged: (value) => setState(() {
          widget.draft.values.coverImageUrl = value;
        }),
        onLocalCoverPathChanged: (value) => setState(() {
          widget.draft.localCoverImagePath = value;
        }),
      ),
    ];
    final links = [
      EditSection(
        title: 'External links',
        accent: widget.accent,
        child: LibraryExternalLinksTable<_GroupLinkRow>(
          rows: [
            for (final row in _rows)
              LibraryExternalLinkEditRow<_GroupLinkRow>(
                identity: row,
                urlController: row.url,
                descriptionController: row.description,
              ),
          ],
          accent: widget.accent,
          addLabel: 'Add group link',
          emptyMessage:
              'Add web links for stores, discography pages or other references.',
          onAdd: _add,
          onReorder: _reorder,
          onRemoveSelected: _removeSelected,
          onChanged: _syncDraft,
        ),
      ),
    ];
    return EditTabShell(
      children: switch (widget.section) {
        MusicReleaseGroupAssetSection.covers => covers,
        MusicReleaseGroupAssetSection.links => links,
      },
    );
  }
}

final class _GroupLinkRow {
  _GroupLinkRow({
    required this.url,
    required this.description,
    this.original,
  });

  factory _GroupLinkRow.empty() => _GroupLinkRow(
        url: TextEditingController(),
        description: TextEditingController(),
      );

  factory _GroupLinkRow.fromLink(MusicExternalLink link) => _GroupLinkRow(
        url: TextEditingController(text: link.url),
        description: TextEditingController(
          text: link.description ?? link.title ?? '',
        ),
        original: link,
      );

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
