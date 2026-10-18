import 'dart:async';
import 'package:collectarr_app/features/library/collections/library_collection_repository.dart';
import 'package:collectarr_app/features/library/collections/library_collections_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/app_sortable_row.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'library_collection_menu.dart';

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
        height: 33,
        color: palette.isDark ? const Color(0xff272323) : palette.toolbar,
        child: Column(children: [
          Container(height: 3, color: accent),
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 3),
                LibraryCollectionMenu(
                  collections: values,
                  activeId: activeId,
                  accent: accent,
                  onSelected: (collection) => unawaited(select(collection)),
                  onManage: () => unawaited(
                      showLibraryCollectionsDialog(context, kind: mediaKind)),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: AppSortableRow(
                    onReorder: (oldIndex, newIndex) {
                      final ids = values.map((c) => c.id).toList();
                      final id = ids.removeAt(oldIndex);
                      ids.insert(newIndex, id);
                      unawaited(repo.reorder(mediaKind, ids));
                    },
                    children: [
                      for (final collection in values)
                        KeyedSubtree(
                          key: ValueKey(
                              'library-collection-tab-${collection.id}'),
                          child: LibraryCollectionTab(
                            label: collection.name,
                            isActive: collection.id == activeId,
                            accent: accent,
                            onTap: () => select(collection),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]));
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
        ? Colors.white
        : palette.isDark
            ? const Color(0xBFFFFFFF)
            : palette.textPrimary;
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(right: 3),
        child: SizedBox(
          height: 27,
          child: Material(
            color: background,
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(4)),
            child: InkWell(
              mouseCursor: WidgetStateMouseCursor.clickable,
              onTap: onTap,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(4)),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: foreground)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
