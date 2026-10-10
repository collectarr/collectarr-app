import 'dart:async';
import 'package:collectarr_app/features/library/collections/library_collection_repository.dart';
import 'package:collectarr_app/features/library/collections/library_collections_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryCollectionTabBar extends ConsumerWidget {
  const LibraryCollectionTabBar(
      {super.key,
      required this.mediaKind,
      required this.accent,
      this.onCollectionSelected});
  final String mediaKind;
  final Color accent;
  final ValueChanged<LibraryCollectionSummary>? onCollectionSelected;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(libraryCollectionsProvider(mediaKind));
    final repo = LibraryCollectionRepository(ref.watch(localDatabaseProvider));
    final values =
        collections.asData?.value ?? const <LibraryCollectionSummary>[];
    final activeId = activeLibraryCollectionId(values);
    final palette = appPalette(context);
    Future<void> select(LibraryCollectionSummary collection) async {
      await repo.activate(collection.id);
      onCollectionSelected?.call(collection);
    }

    return Container(
        height: 36,
        color: palette.isDark ? const Color(0xff272323) : palette.toolbar,
        child: Column(children: [
          Container(height: 3, color: accent),
          Expanded(
            child: Row(
              children: [
                PopupMenuButton<String>(
                  key: const ValueKey('library-collection-menu'),
                  tooltip: 'Collections',
                  onSelected: (id) {
                    if (id == '__manage__') {
                      unawaited(showLibraryCollectionsDialog(context,
                          kind: mediaKind));
                    } else {
                      unawaited(select(values.firstWhere((c) => c.id == id)));
                    }
                  },
                  itemBuilder: (_) => [
                    for (final collection in values)
                      PopupMenuItem(
                        value: collection.id,
                        height: 30,
                        child: Row(
                          children: [
                            Icon(
                              collection.id == activeId
                                  ? Icons.check
                                  : Icons.folder_outlined,
                              size: 17,
                            ),
                            const SizedBox(width: 8),
                            Text(collection.name),
                          ],
                        ),
                      ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: '__manage__',
                      height: 30,
                      child: Text('Manage Collections'),
                    ),
                  ],
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: SizedBox(
                      width: 36,
                      child: Center(
                        child: _ClzCollectionMenuIcon(
                          color: palette.textPrimary.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ReorderableListView.builder(
                    scrollDirection: Axis.horizontal,
                    buildDefaultDragHandles: false,
                    itemCount: values.length,
                    onReorderItem: (oldIndex, newIndex) async {
                      final ids = values.map((c) => c.id).toList();
                      final id = ids.removeAt(oldIndex);
                      ids.insert(newIndex, id);
                      await repo.reorder(mediaKind, ids);
                    },
                    itemBuilder: (_, index) {
                      final collection = values[index];
                      return ReorderableDragStartListener(
                        key:
                            ValueKey('library-collection-tab-${collection.id}'),
                        index: index,
                        child: LibraryCollectionTab(
                          label: collection.name,
                          isActive: collection.id == activeId,
                          accent: accent,
                          onTap: () => select(collection),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ]));
  }
}

class _ClzCollectionMenuIcon extends StatelessWidget {
  const _ClzCollectionMenuIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 15,
      height: 12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 1.5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(0.5),
            ),
          ),
          Container(
            height: 1.5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(0.5),
            ),
          ),
          Container(
            height: 1.5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class LibraryCollectionTab extends StatelessWidget {
  const LibraryCollectionTab({
    super.key,
    required this.label,
    required this.isActive,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final background = isActive
        ? accent
        : palette.isDark
            ? const Color(0xFF131313)
            : palette.surfaceSubtle;
    final foreground = isActive
        ? appContrastingTextColor(accent)
        : palette.textPrimary.withValues(alpha: 0.78);
    return Padding(
      padding: const EdgeInsets.only(left: 1, top: 2, right: 1),
      child: Material(
        color: background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        child: InkWell(
          mouseCursor: WidgetStateMouseCursor.clickable,
          onTap: onTap,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          child: Container(
            constraints: const BoxConstraints(minWidth: 58),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 13),
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
              border: Border(
                bottom: BorderSide(
                  color: isActive ? accent : palette.divider,
                  width: isActive ? 2 : 1,
                ),
              ),
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: foreground,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
