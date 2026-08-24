import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_edit_draft.dart';
import 'package:flutter/material.dart';

class MusicLinksTab extends StatefulWidget {
  const MusicLinksTab({
    super.key,
    required this.draft,
    required this.accent,
    required this.markDirty,
  });

  final MusicEditDraft draft;
  final Color accent;
  final VoidCallback markDirty;

  @override
  State<MusicLinksTab> createState() => _MusicLinksTabState();
}

class _MusicLinksTabState extends State<MusicLinksTab> {
  void _addExternalLink() {
    setState(() {
      widget.draft.addExternalLink();
    });
    widget.markDirty();
  }

  void _removeExternalLink(int index) {
    setState(() {
      widget.draft.removeExternalLinkAt(index);
    });
    widget.markDirty();
  }

  void _moveExternalLink(int fromIndex, int toIndex) {
    setState(() {
      widget.draft.moveExternalLink(fromIndex, toIndex);
    });
    widget.markDirty();
  }

  Widget _buildExternalLinkRow(int index) {
    final link = widget.draft.externalLinks[index];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: kEditPanelRaised,
        border: Border.all(color: kEditDivider),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Column(
          children: [
            LibraryEditResponsiveRow(
              children: [
                TextFormField(
                  key: ValueKey('musicExternalLinkUrlField_$index'),
                  controller: link.urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL',
                    hintText: 'https://example.com',
                  ),
                  onChanged: (_) => widget.markDirty(),
                ),
                TextFormField(
                  key: ValueKey('musicExternalLinkDescriptionField_$index'),
                  controller: link.descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Spotify, Discogs, etc.',
                  ),
                  onChanged: (_) => widget.markDirty(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  tooltip: 'Move up',
                  icon: const Icon(Icons.arrow_upward, size: 18),
                  onPressed: index > 0
                      ? () => _moveExternalLink(index, index - 1)
                      : null,
                ),
                IconButton(
                  tooltip: 'Move down',
                  icon: const Icon(Icons.arrow_downward, size: 18),
                  onPressed: index < widget.draft.externalLinks.length - 1
                      ? () => _moveExternalLink(index, index + 1)
                      : null,
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Remove',
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () => _removeExternalLink(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final links = widget.draft.externalLinks;
    return EditTabShell(
      children: [
        EditSection(
          title: 'External links',
          accent: widget.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (links.isEmpty)
                const Text(
                  'Add web links for stores, discography pages or other references.',
                  style: TextStyle(color: kEditTextMuted),
                )
              else
                Column(
                  children: [
                    for (var index = 0; index < links.length; index++) ...[
                      _buildExternalLinkRow(index),
                      if (index < links.length - 1) const SizedBox(height: 10),
                    ],
                  ],
                ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _addExternalLink,
                icon: const Icon(Icons.add),
                label: const Text('Add link'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
