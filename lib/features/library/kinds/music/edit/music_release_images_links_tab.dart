import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
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

  void _reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final row = _rows.removeAt(oldIndex);
    _rows.insert(newIndex, row);
    setState(() {});
    _syncDraft();
  }

  void _remove(int index) {
    final row = _rows.removeAt(index);
    row.dispose();
    setState(() {});
    _syncDraft();
  }

  @override
  Widget build(BuildContext context) => EditTabShell(
        children: [
          EditSection(
            title: 'Release links',
            accent: widget.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add store pages, artist pages, Discogs entries and other release references. Drag rows to change their order.',
                ),
                if (_rows.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Center(child: Text('No links added yet.')),
                  ),
                if (_rows.isNotEmpty)
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _rows.length,
                    onReorder: _reorder,
                    itemBuilder: (context, index) => Padding(
                      key: _rows[index].key,
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 18),
                            child: Icon(Icons.drag_indicator),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 30,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 18),
                              child: Text('${index + 1}'),
                            ),
                          ),
                          Expanded(
                            flex: 7,
                            child: TextFormField(
                              key: ValueKey('musicReleaseLinkUrl_$index'),
                              controller: _rows[index].url,
                              decoration: const InputDecoration(
                                labelText: 'URL',
                                hintText: 'https://…',
                              ),
                              keyboardType: TextInputType.url,
                              onChanged: (_) => _syncDraft(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 5,
                            child: TextFormField(
                              key: ValueKey(
                                  'musicReleaseLinkDescription_$index'),
                              controller: _rows[index].description,
                              decoration: const InputDecoration(
                                  labelText: 'Description'),
                              onChanged: (_) => _syncDraft(),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Remove link',
                            onPressed: () => _remove(index),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _rows.add(_ReleaseLinkRow.empty()));
                      _syncDraft();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('New Link'),
                  ),
                ),
              ],
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
