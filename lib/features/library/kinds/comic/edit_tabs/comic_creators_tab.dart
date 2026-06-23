import 'package:flutter/material.dart';

class ComicCreatorsTab extends StatelessWidget {
  const ComicCreatorsTab({
    super.key,
    required this.creators,
    required this.commonCreatorRoles,
    required this.serverSnapshotDiffSection,
    required this.onAddCreator,
    required this.onAddCatalogCreator,
    required this.onAddCreatorWithRole,
    required this.onReorderItem,
    required this.onLookupCreatorForRow,
    required this.onRemoveCreator,
    required this.nameControllerOf,
    required this.roleOf,
    required this.setRole,
  });

  final List<dynamic> creators;
  final List<String> commonCreatorRoles;
  final Widget serverSnapshotDiffSection;
  final VoidCallback onAddCreator;
  final VoidCallback onAddCatalogCreator;
  final ValueChanged<String> onAddCreatorWithRole;
  final void Function(int oldIndex, int newIndex) onReorderItem;
  final void Function(int index) onLookupCreatorForRow;
  final void Function(int index) onRemoveCreator;
  final TextEditingController Function(dynamic creator) nameControllerOf;
  final String Function(dynamic creator) roleOf;
  final void Function(dynamic creator, String role) setRole;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FilledButton.icon(
                onPressed: onAddCreator,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
              ),
              const SizedBox(width: 6),
              OutlinedButton.icon(
                onPressed: onAddCatalogCreator,
                icon: const Icon(Icons.person_search_outlined, size: 16),
                label: const Text('Find in Catalog'),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                tooltip: 'Add by role',
                itemBuilder: (_) => [
                  for (final role in commonCreatorRoles)
                    PopupMenuItem(
                      value: role,
                      child: Text(role),
                    ),
                ],
                onSelected: onAddCreatorWithRole,
              ),
            ],
          ),
          const SizedBox(height: 8),
          serverSnapshotDiffSection,
          if (creators.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Creators is empty',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Theme.of(context).hintColor),
                ),
              ),
            ),
          if (creators.isNotEmpty)
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorderItem: onReorderItem,
              itemCount: creators.length,
              buildDefaultDragHandles: false,
              proxyDecorator: (child, _, __) => Material(
                elevation: 2,
                child: child,
              ),
              itemBuilder: (context, i) {
                final creator = creators[i];
                return Container(
                  key: ValueKey(creator),
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
                      SizedBox(
                        width: 140,
                        child: Builder(
                          builder: (context) {
                            final currentRole = roleOf(creator).trim();
                            final roles = <String>[
                              if (currentRole.isNotEmpty &&
                                  !commonCreatorRoles.contains(currentRole))
                                currentRole,
                              ...commonCreatorRoles,
                            ];
                            return DropdownButtonFormField<String>(
                              initialValue:
                                  currentRole.isEmpty ? null : currentRole,
                              isDense: true,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                hintText: 'Job',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 12),
                              items: [
                                for (final role in roles)
                                  DropdownMenuItem(
                                      value: role, child: Text(role)),
                              ],
                              onChanged: (v) {
                                if (v != null) {
                                  setRole(creator, v);
                                }
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: nameControllerOf(creator),
                          style: const TextStyle(fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'Name',
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
                        icon: const Icon(Icons.person_search, size: 18),
                        onPressed: () => onLookupCreatorForRow(i),
                        tooltip: 'Lookup',
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => onRemoveCreator(i),
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
