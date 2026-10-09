import 'dart:async';

import 'package:collectarr_app/core/models/smart_list_criteria.dart';
import 'package:collectarr_app/features/collection/repositories/smart_list_repository.dart';
import 'package:collectarr_app/features/library/generic/smart_list.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final libraryCollectionTabsRevisionProvider =
    NotifierProvider<LibraryCollectionTabsRevision, int>(
  LibraryCollectionTabsRevision.new,
);

class LibraryCollectionTabsRevision extends Notifier<int> {
  @override
  int build() => 0;

  void refresh() => state++;
}

/// Excel-style tabs backed by saved collection views for the active kind.
class LibraryCollectionTabBar extends ConsumerStatefulWidget {
  const LibraryCollectionTabBar({
    super.key,
    required this.mediaKind,
    required this.target,
    required this.activeSmartListId,
    required this.onSmartListSelected,
    required this.onAllSelected,
    required this.accent,
    this.onManageCollections,
  });

  final String mediaKind;
  final SmartListCriteriaTarget target;
  final String? activeSmartListId;
  final ValueChanged<SmartList> onSmartListSelected;
  final VoidCallback onAllSelected;
  final Color accent;
  final Future<void> Function()? onManageCollections;

  @override
  ConsumerState<LibraryCollectionTabBar> createState() =>
      _LibraryCollectionTabBarState();
}

class _LibraryCollectionTabBarState
    extends ConsumerState<LibraryCollectionTabBar> {
  List<SmartList> _smartLists = const [];
  int _loadGeneration = 0;

  String get _orderKey =>
      'library.collection_tabs.${widget.mediaKind}.${widget.target.value}';

  @override
  void initState() {
    super.initState();
    _loadSmartLists();
  }

  @override
  void didUpdateWidget(LibraryCollectionTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaKind != widget.mediaKind ||
        oldWidget.target != widget.target) {
      _loadSmartLists();
    }
  }

  Future<void> _loadSmartLists() async {
    final generation = ++_loadGeneration;
    final mediaKind = widget.mediaKind;
    final target = widget.target;
    final orderKey = _orderKey;
    final lists = await SmartListRepository(ref.read(localDatabaseProvider))
        .getAll(mediaKind: mediaKind, target: target);
    final preferences = await SharedPreferences.getInstance();
    final savedOrder = preferences.getStringList(orderKey) ?? const [];
    final remaining = {for (final list in lists) list.id: list};
    final ordered = <SmartList>[
      for (final id in savedOrder)
        if (remaining.remove(id) case final list?) list,
      ...remaining.values,
    ];
    if (mounted && generation == _loadGeneration) {
      setState(() => _smartLists = ordered);
      if (widget.activeSmartListId != null &&
          !ordered.any((list) => list.id == widget.activeSmartListId)) {
        widget.onAllSelected();
      }
    }
  }

  Future<void> _persistOrder() async {
    final orderKey = _orderKey;
    final orderedIds =
        _smartLists.map((list) => list.id).toList(growable: false);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(orderKey, orderedIds);
  }

  void _reorder(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    setState(() {
      final list = _smartLists.removeAt(oldIndex);
      _smartLists.insert(newIndex, list);
    });
    unawaited(_persistOrder());
  }

  Future<void> _manageCollections() async {
    final onManage = widget.onManageCollections;
    if (onManage == null) return;
    await onManage();
    await _loadSmartLists();
  }

  void _selectMenuItem(String value) {
    if (value == _allCollectionsMenuValue) {
      widget.onAllSelected();
    } else if (value == _manageCollectionsMenuValue) {
      unawaited(_manageCollections());
    } else {
      final list = _smartLists.where((item) => item.id == value).firstOrNull;
      if (list != null) widget.onSmartListSelected(list);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(libraryCollectionTabsRevisionProvider, (previous, next) {
      if (previous != next) _loadSmartLists();
    });

    final palette = appPalette(context);
    final isAllActive = widget.activeSmartListId == null;
    return Container(
      height: 38,
      color: palette.isDark ? const Color(0xFF272323) : palette.surface,
      child: Column(
        children: [
          Container(height: 3, color: widget.accent),
          Expanded(
            child: Row(
              children: [
                PopupMenuButton<String>(
                  tooltip: 'Collections',
                  onSelected: _selectMenuItem,
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: _allCollectionsMenuValue,
                      child: Row(
                        children: [
                          Icon(
                            isAllActive ? Icons.check : Icons.grid_view,
                            size: 17,
                          ),
                          const SizedBox(width: 9),
                          const Flexible(
                            child: Text(
                              'All items',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_smartLists.isNotEmpty) const PopupMenuDivider(),
                    for (final list in _smartLists)
                      PopupMenuItem<String>(
                        value: list.id,
                        child: Row(
                          children: [
                            Icon(
                              list.id == widget.activeSmartListId
                                  ? Icons.check
                                  : Icons.folder_outlined,
                              size: 17,
                            ),
                            const SizedBox(width: 9),
                            Flexible(
                              child: Text(
                                list.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (widget.onManageCollections != null) ...[
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: _manageCollectionsMenuValue,
                        child: Row(
                          children: [
                            Icon(Icons.settings_outlined, size: 17),
                            SizedBox(width: 9),
                            Flexible(
                              child: Text(
                                'Manage Collections',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                  child: SizedBox(
                    width: 38,
                    height: 35,
                    child: Icon(
                      Icons.menu,
                      size: 17,
                      color: palette.textPrimary.withValues(alpha: 0.78),
                    ),
                  ),
                ),
                LibraryCollectionTab(
                  label: 'All',
                  isActive: isAllActive,
                  accent: widget.accent,
                  onTap: widget.onAllSelected,
                ),
                Expanded(
                  child: ReorderableListView.builder(
                    scrollDirection: Axis.horizontal,
                    buildDefaultDragHandles: false,
                    itemCount: _smartLists.length,
                    onReorderItem: _reorder,
                    itemBuilder: (context, index) {
                      final list = _smartLists[index];
                      return ReorderableDelayedDragStartListener(
                        key: ValueKey('library-collection-tab-${list.id}'),
                        index: index,
                        child: LibraryCollectionTab(
                          label: list.name,
                          isActive: widget.activeSmartListId == list.id,
                          accent: widget.accent,
                          onTap: () => widget.onSmartListSelected(list),
                        ),
                      );
                    },
                  ),
                ),
                if (widget.onManageCollections != null)
                  IconButton(
                    key: const ValueKey('library-collection-add'),
                    tooltip: 'Add collection',
                    visualDensity: VisualDensity.compact,
                    onPressed: _manageCollections,
                    icon: Icon(
                      Icons.add,
                      size: 18,
                      color: palette.textPrimary.withValues(alpha: 0.78),
                    ),
                  ),
              ],
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

const _allCollectionsMenuValue = '\u0000all';
const _manageCollectionsMenuValue = '\u0000manage';
