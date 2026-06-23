import 'package:flutter/material.dart';

class ComicCharactersTab extends StatelessWidget {
  const ComicCharactersTab({
    super.key,
    required this.characterDraftController,
    required this.characters,
    required this.serverSnapshotDiffSection,
    required this.onAddCharacter,
    required this.onAddCatalogCharacter,
    required this.onReorderItem,
    required this.onRemoveCharacter,
    required this.nameControllerOf,
    required this.realNameControllerOf,
  });

  final TextEditingController characterDraftController;
  final List<dynamic> characters;
  final Widget serverSnapshotDiffSection;
  final VoidCallback onAddCharacter;
  final VoidCallback onAddCatalogCharacter;
  final void Function(int oldIndex, int newIndex) onReorderItem;
  final void Function(int index) onRemoveCharacter;
  final TextEditingController Function(dynamic character) nameControllerOf;
  final TextEditingController Function(dynamic character) realNameControllerOf;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: characterDraftController,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Character name',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => onAddCharacter(),
                ),
              ),
              const SizedBox(width: 6),
              FilledButton.icon(
                onPressed: onAddCharacter,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
              ),
              const SizedBox(width: 6),
              OutlinedButton.icon(
                onPressed: onAddCatalogCharacter,
                icon: const Icon(Icons.person_search_outlined, size: 16),
                label: const Text('Find in Catalog'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          serverSnapshotDiffSection,
          if (characters.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Characters is empty',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Theme.of(context).hintColor),
                ),
              ),
            ),
          if (characters.isNotEmpty)
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorderItem: onReorderItem,
              itemCount: characters.length,
              buildDefaultDragHandles: false,
              proxyDecorator: (child, _, __) => Material(
                elevation: 2,
                child: child,
              ),
              itemBuilder: (context, i) {
                final character = characters[i];
                return Container(
                  key: ValueKey(character),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      ReorderableDragStartListener(
                        index: i,
                        child: Icon(Icons.drag_handle,
                            size: 20, color: Theme.of(context).hintColor),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 4,
                        child: TextField(
                          controller: nameControllerOf(character),
                          style: const TextStyle(fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'Character name',
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
                        flex: 3,
                        child: TextField(
                          controller: realNameControllerOf(character),
                          style: const TextStyle(fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'Real name',
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
                        onPressed: () => onRemoveCharacter(i),
                        tooltip: 'Remove',
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
