import 'package:flutter/material.dart';

class ComicLinksTab extends StatelessWidget {
  const ComicLinksTab({
    super.key,
    required this.links,
    required this.onReorderItem,
    required this.onRemoveLink,
    required this.onAddLink,
  });

  final List<Map<String, TextEditingController>> links;
  final void Function(int oldIndex, int newIndex) onReorderItem;
  final void Function(int index) onRemoveLink;
  final VoidCallback onAddLink;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                const SizedBox(width: 28),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Title',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: Text(
                    'URL',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 36),
              ],
            ),
          ),
          if (links.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No links added yet',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Theme.of(context).hintColor),
                ),
              ),
            ),
          if (links.isNotEmpty)
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorderItem: onReorderItem,
              itemCount: links.length,
              buildDefaultDragHandles: false,
              proxyDecorator: (child, _, __) => Material(
                elevation: 2,
                child: child,
              ),
              itemBuilder: (context, i) => Container(
                key: ValueKey(links[i]),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Theme.of(context).dividerColor),
                    right: BorderSide(color: Theme.of(context).dividerColor),
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    ReorderableDragStartListener(
                      index: i,
                      child: Icon(
                        Icons.drag_handle,
                        size: 20,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: links[i]['title'],
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Link title',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 5,
                      child: TextField(
                        controller: links[i]['url'],
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'https://',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => onRemoveLink(i),
                      tooltip: 'Remove',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: onAddLink,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Link'),
            ),
          ),
        ],
      ),
    );
  }
}
