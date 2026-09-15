import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_external_link.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_group_edit_draft.dart';
import 'package:flutter/material.dart';

/// Release-group-owned artwork and external links.
final class MusicReleaseGroupImagesLinksTab extends StatefulWidget {
  const MusicReleaseGroupImagesLinksTab({
    super.key,
    required this.draft,
    required this.accent,
  });

  final MusicReleaseGroupEditDraft draft;
  final Color accent;

  @override
  State<MusicReleaseGroupImagesLinksTab> createState() =>
      _MusicReleaseGroupImagesLinksTabState();
}

final class _MusicReleaseGroupImagesLinksTabState
    extends State<MusicReleaseGroupImagesLinksTab> {
  late final TextEditingController _coverImageUrl;
  late final List<_GroupLinkRow> _rows;

  @override
  void initState() {
    super.initState();
    _coverImageUrl = TextEditingController(
      text: widget.draft.coverImageUrl ?? '',
    );
    _rows = [
      for (final link in widget.draft.externalLinks)
        _GroupLinkRow.fromLink(link),
    ];
  }

  @override
  void dispose() {
    _coverImageUrl.dispose();
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _syncDraft() {
    widget.draft.coverImageUrl = _nullable(_coverImageUrl.text);
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

  void _remove(int index) {
    final row = _rows.removeAt(index);
    row.dispose();
    setState(() {});
    _syncDraft();
  }

  @override
  Widget build(BuildContext context) {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Release group artwork',
          accent: widget.accent,
          child: TextFormField(
            key: const ValueKey('musicReleaseGroupCoverImageUrlField'),
            controller: _coverImageUrl,
            decoration: const InputDecoration(
              labelText: 'Cover image URL',
              hintText: 'https://…',
            ),
            keyboardType: TextInputType.url,
            onChanged: (_) => _syncDraft(),
          ),
        ),
        EditSection(
          title: 'External links',
          accent: widget.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_rows.isEmpty)
                const Text(
                  'Add web links for stores, discography pages or other references.',
                ),
              for (var index = 0; index < _rows.length; index++) ...[
                if (index > 0) const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        key: ValueKey('musicReleaseGroupLinkUrlField_$index'),
                        controller: _rows[index].url,
                        decoration: const InputDecoration(labelText: 'URL'),
                        keyboardType: TextInputType.url,
                        onChanged: (_) => _syncDraft(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        key: ValueKey(
                          'musicReleaseGroupLinkDescriptionField_$index',
                        ),
                        controller: _rows[index].description,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        onChanged: (_) => _syncDraft(),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove',
                      onPressed: () => _remove(index),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _add,
                icon: const Icon(Icons.add),
                label: const Text('Add group link'),
              ),
            ],
          ),
        ),
      ],
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
