import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_contents.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Manual Add editor for the ordered external links owned by a Music item.
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
  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final links = widget.draft.externalLinks;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child:
                  Text('Links', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            OutlinedButton.icon(
              onPressed: () => setState(
                () => links.add(MusicAddManualExternalLink()),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('New Link'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (links.isEmpty)
          Text('No links added', style: TextStyle(color: palette.textMuted))
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: links.length,
            onReorderItem: (oldIndex, newIndex) => setState(() {
              final link = links.removeAt(oldIndex);
              links.insert(newIndex, link);
            }),
            itemBuilder: (context, index) {
              final link = links[index];
              return Container(
                key: ValueKey(link.id),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: palette.surface,
                  border: Border.all(color: palette.divider),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final titleField = TextFormField(
                      key: ValueKey('${link.id}-title'),
                      initialValue: link.title,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        isDense: true,
                      ),
                      onChanged: (value) => link.title = value,
                    );
                    final urlField = TextFormField(
                      key: ValueKey('${link.id}-url'),
                      initialValue: link.url,
                      decoration: const InputDecoration(
                        labelText: 'URL',
                        isDense: true,
                      ),
                      keyboardType: TextInputType.url,
                      onChanged: (value) => link.url = value,
                    );
                    final descriptionField = TextFormField(
                      key: ValueKey('${link.id}-description'),
                      initialValue: link.description,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        isDense: true,
                      ),
                      onChanged: (value) => link.description = value,
                    );
                    final removeButton = IconButton(
                      tooltip: 'Remove link',
                      onPressed: () => setState(() => links.removeAt(index)),
                      icon: const Icon(Icons.close, size: 18),
                    );
                    if (constraints.maxWidth < 680) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              ReorderableDragStartListener(
                                index: index,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(Icons.drag_handle, size: 18),
                                ),
                              ),
                              const Spacer(),
                              removeButton,
                            ],
                          ),
                          titleField,
                          const SizedBox(height: 8),
                          urlField,
                          const SizedBox(height: 8),
                          descriptionField,
                        ],
                      );
                    }
                    return Row(
                      children: [
                        ReorderableDragStartListener(
                          index: index,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(Icons.drag_handle, size: 18),
                          ),
                        ),
                        Expanded(flex: 2, child: titleField),
                        const SizedBox(width: 8),
                        Expanded(flex: 4, child: urlField),
                        const SizedBox(width: 8),
                        Expanded(flex: 3, child: descriptionField),
                        removeButton,
                      ],
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}
