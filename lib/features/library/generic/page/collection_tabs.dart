import 'dart:async';
import 'package:collectarr_app/features/library/collections/library_collection_repository.dart';
import 'package:collectarr_app/features/library/collections/library_collections_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'library_collection_menu.dart';

class LibraryCollectionTabBar extends ConsumerStatefulWidget {
  const LibraryCollectionTabBar(
      {super.key,
      required this.mediaKind,
      required this.accent,
      this.onCollectionSelected});
  final String mediaKind;
  final Color accent;
  final ValueChanged<LibraryCollectionSummary>? onCollectionSelected;

  @override
  ConsumerState<LibraryCollectionTabBar> createState() =>
      _LibraryCollectionTabBarState();
}

class _LibraryCollectionTabBarState
    extends ConsumerState<LibraryCollectionTabBar> {
  /// The order just dropped, shown until the saved order arrives, so the tabs
  /// never flash back to their old positions while the save is in flight.
  List<String>? _pendingOrder;

  Future<void> _reorder(LibraryCollectionRepository repo,
      List<LibraryCollectionSummary> values, int oldIndex, int newIndex) async {
    final ids = values.map((c) => c.id).toList();
    final id = ids.removeAt(oldIndex);
    ids.insert(newIndex, id);
    setState(() => _pendingOrder = ids);
    try {
      await repo.reorder(widget.mediaKind, ids);
    } catch (_) {
      if (mounted) setState(() => _pendingOrder = null);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(libraryCollectionsProvider(widget.mediaKind));
    final repo = LibraryCollectionRepository(ref.watch(localDatabaseProvider));
    final saved =
        collections.asData?.value ?? const <LibraryCollectionSummary>[];
    final pending = _pendingOrder;
    final values = pending == null
        ? saved
        : [
            for (final id in pending)
              ...saved.where((collection) => collection.id == id),
          ];
    if (pending != null && values.length != saved.length) {
      // A collection was added or removed meanwhile: the saved order wins.
      WidgetsBinding.instance.addPostFrameCallback((_) => _clearPending());
    } else if (pending != null &&
        saved.map((c) => c.id).join(',') == pending.join(',')) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _clearPending());
    }
    final accent = widget.accent;
    final activeId = activeLibraryCollectionId(saved);
    final palette = appPalette(context);
    Future<void> select(LibraryCollectionSummary collection) async {
      await repo.activate(collection.id);
      widget.onCollectionSelected?.call(collection);
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
                  collections: saved,
                  activeId: activeId,
                  accent: accent,
                  onSelected: (collection) => unawaited(select(collection)),
                  onManage: () => unawaited(showLibraryCollectionsDialog(
                      context,
                      kind: widget.mediaKind)),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: ReorderableListView.builder(
                    scrollDirection: Axis.horizontal,
                    buildDefaultDragHandles: false,
                    // The default proxy adds an elevation shadow that shows as
                    // a lighter rim on the dragged tab's edges.
                    proxyDecorator: (child, _, __) =>
                        Material(type: MaterialType.transparency, child: child),
                    itemCount: values.length,
                    onReorderItem: (oldIndex, newIndex) =>
                        _reorder(repo, values, oldIndex, newIndex),
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

  void _clearPending() {
    if (mounted && _pendingOrder != null) {
      setState(() => _pendingOrder = null);
    }
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
          // Plain box, no ink: the active colour switches instantly and
          // pressing or hovering draws no splash or highlight.
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    color: background,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(4))),
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
