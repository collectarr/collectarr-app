import 'dart:collection';

import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

const libraryManageSortFavoritesMenuValue = 'manage_sort_favorites';

Future<Set<String>?> showSortFavoritesManagerDialog({
  required BuildContext context,
  required LibraryTypeConfig type,
  required List<LibrarySortFavorite> favorites,
  required Set<String> initialPinnedIds,
  String? activeSortFavoriteId,
}) {
  return showDialog<Set<String>>(
    context: context,
    builder: (context) => _SortFavoritesManagerDialog(
      type: type,
      favorites: favorites,
      initialPinnedIds: initialPinnedIds,
      activeSortFavoriteId: activeSortFavoriteId,
    ),
  );
}

class LibraryCollectionStatusScopeDropdown extends StatelessWidget {
  const LibraryCollectionStatusScopeDropdown({
    super.key,
    required this.collectionStatusScope,
    required this.onCollectionStatusScopeChanged,
  });

  final LibraryCollectionStatusScope collectionStatusScope;
  final ValueChanged<LibraryCollectionStatusScope>
      onCollectionStatusScopeChanged;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final accent = Theme.of(context).colorScheme.primary;
    final borderColor = libraryCollectionStatusScopeColor(
      collectionStatusScope,
      accent,
      palette.textMuted,
    );
    final menuText = libraryToolbarMenuText(context);
    final menuMuted = libraryToolbarMenuMutedText(context);
    final dropdownTextStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1,
          fontWeight: FontWeight.w700,
          color: palette.textPrimary,
        );
    final menuWidth = measureLibraryToolbarDropdownWidth(
      context,
      labels: LibraryCollectionStatusScope.values.map((scope) => scope.label),
      textStyle: dropdownTextStyle,
      leadingWidth: 20,
      leadingSpacing: 8,
      trailingWidth: 24,
      horizontalPadding: 24,
      minWidth: 132,
    );
    final triggerWidth = measureLibraryToolbarDropdownWidth(
      context,
      labels: [collectionStatusScope.label],
      textStyle: dropdownTextStyle,
      leadingWidth: 20,
      leadingSpacing: 8,
      trailingWidth: 24,
      horizontalPadding: 24,
      minWidth: 0,
    );
    return SizedBox(
      width: triggerWidth,
      child: PopupMenuButton<LibraryCollectionStatusScope>(
        key: const Key('collection-status-scope-dropdown'),
        tooltip: 'Collection status scope',
        initialValue: collectionStatusScope,
        onSelected: onCollectionStatusScopeChanged,
        padding: EdgeInsets.zero,
        menuPadding: const EdgeInsets.symmetric(vertical: 4),
        position: PopupMenuPosition.under,
        color: libraryToolbarMenuSurface(context),
        surfaceTintColor: Colors.transparent,
        constraints: const BoxConstraints(
          minWidth: 0,
          maxWidth: double.infinity,
        ).copyWith(minWidth: menuWidth, maxWidth: menuWidth),
        shape: libraryToolbarDropdownMenuShape(context),
        itemBuilder: (context) => [
          for (final scope in LibraryCollectionStatusScope.values)
            PopupMenuItem<LibraryCollectionStatusScope>(
              value: scope,
              height: kLibraryToolbarTextDropdownHeight,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: LibraryCollectionStatusScopeMenuItem(
                scope: scope,
                isSelected: scope == collectionStatusScope,
                accent: accent,
                muted: menuMuted,
                textColor: menuText,
              ),
            ),
        ],
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.panelRaised,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor),
          ),
          child: SizedBox(
            height: kLibraryToolbarTextDropdownHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  LibraryCollectionStatusScopeBadge(
                    scope: collectionStatusScope,
                    accent: accent,
                    muted: palette.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      collectionStatusScope.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: dropdownTextStyle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 18,
                    color: borderColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LibraryToolbarSortButton extends StatelessWidget {
  const LibraryToolbarSortButton({
    super.key,
    required this.onPressed,
    required this.sortFavorites,
    required this.activeSortFavoriteId,
    this.pinnedSortFavoriteIds = const {},
    this.onSortFavoriteSelected,
    this.onManageFavoritesPressed,
  });

  final VoidCallback onPressed;
  final List<LibrarySortFavorite> sortFavorites;
  final String? activeSortFavoriteId;
  final Set<String> pinnedSortFavoriteIds;
  final ValueChanged<LibrarySortFavorite>? onSortFavoriteSelected;
  final VoidCallback? onManageFavoritesPressed;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final pinnedFavorites = _orderedPinnedSortFavorites(
      sortFavorites,
      pinnedSortFavoriteIds,
    );
    final overflowFavorites = _overflowSortFavorites(
      sortFavorites,
      pinnedSortFavoriteIds,
    );
    LibrarySortFavorite? activeFavorite;
    for (final favorite in sortFavorites) {
      if (favorite.id == activeSortFavoriteId) {
        activeFavorite = favorite;
        break;
      }
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panelRaised,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: palette.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: activeFavorite == null
                ? 'Change sorting'
                : 'Sorting: ${activeFavorite.label}',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(4),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sort, size: 16),
                      const SizedBox(width: 7),
                      Text(
                        activeFavorite?.label ?? 'Sort By',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: palette.textPrimary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.1,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 18,
            color: palette.divider,
          ),
          PopupMenuButton<Object>(
            key: const ValueKey('library-sort-split-button-menu'),
            tooltip: activeFavorite == null
                ? 'Sort favorites'
                : 'Sort favorites: ${activeFavorite.label}',
            padding: EdgeInsets.zero,
            color: Color.alphaBlend(
              palette.accent.withValues(alpha: 0.025),
              palette.panelRaised,
            ),
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.black.withValues(alpha: 0.22),
            menuPadding: const EdgeInsets.symmetric(vertical: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(color: palette.divider.withValues(alpha: 0.9)),
            ),
            onSelected: (value) {
              if (value == libraryManageSortFavoritesMenuValue) {
                onManageFavoritesPressed?.call();
                return;
              }
              if (value is LibrarySortFavorite) {
                onSortFavoriteSelected?.call(value);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<Object>(
                value: libraryManageSortFavoritesMenuValue,
                height: 32,
                child: const _LibraryToolbarSortMenuRow(
                  label: 'Manage Favorites',
                  icon: Icons.settings_outlined,
                ),
              ),
              if (pinnedFavorites.isNotEmpty || overflowFavorites.isNotEmpty)
                const PopupMenuDivider(height: 1),
              for (final favorite in pinnedFavorites)
                PopupMenuItem<Object>(
                  value: favorite,
                  height: 32,
                  child: _LibraryToolbarSortMenuRow(
                    label: favorite.label,
                    icon: favorite.icon,
                    active: favorite.id == activeSortFavoriteId,
                    trailingLabel: 'Pinned',
                  ),
                ),
              if (pinnedFavorites.isNotEmpty && overflowFavorites.isNotEmpty)
                const PopupMenuDivider(height: 1),
              for (final favorite in overflowFavorites)
                PopupMenuItem<Object>(
                  value: favorite,
                  height: 32,
                  child: _LibraryToolbarSortMenuRow(
                    label: favorite.label,
                    icon: favorite.icon,
                    active: favorite.id == activeSortFavoriteId,
                  ),
                ),
            ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
              child: Icon(Icons.arrow_drop_down, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryToolbarSortMenuRow extends StatelessWidget {
  const _LibraryToolbarSortMenuRow({
    required this.label,
    required this.icon,
    this.active = false,
    this.trailingLabel,
  });

  final String label;
  final IconData icon;
  final bool active;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Row(
      children: [
        Icon(icon,
            size: 16, color: active ? palette.accent : palette.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
          ),
        ),
        if (trailingLabel != null) ...[
          Text(
            trailingLabel!,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: palette.textMuted,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(width: 8),
        ],
        if (active) Icon(Icons.check, size: 16, color: palette.textPrimary),
      ],
    );
  }
}

class _SortFavoritesManagerDialog extends StatefulWidget {
  const _SortFavoritesManagerDialog({
    required this.type,
    required this.favorites,
    required this.initialPinnedIds,
    this.activeSortFavoriteId,
  });

  final LibraryTypeConfig type;
  final List<LibrarySortFavorite> favorites;
  final Set<String> initialPinnedIds;
  final String? activeSortFavoriteId;

  @override
  State<_SortFavoritesManagerDialog> createState() =>
      _SortFavoritesManagerDialogState();
}

class _SortFavoritesManagerDialogState
    extends State<_SortFavoritesManagerDialog> {
  late final List<LibrarySortFavorite> _allFavorites;
  late List<LibrarySortFavorite> _pinnedFavorites;
  late List<LibrarySortFavorite> _availableFavorites;

  @override
  void initState() {
    super.initState();
    _allFavorites = List<LibrarySortFavorite>.from(widget.favorites);
    _pinnedFavorites = _orderedPinnedSortFavorites(
      widget.favorites,
      widget.initialPinnedIds,
    );
    _availableFavorites = _overflowSortFavorites(
      widget.favorites,
      widget.initialPinnedIds,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final theme = Theme.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: libraryToolbarDropdownMenuShape(context),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manage Sorting Favorites',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pinned favorites stay at the top of the sort menu. Drag to reorder them.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: libraryToolbarMenuMutedText(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: palette.badgeBackground,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${_allFavorites.length} total',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: libraryToolbarMenuBorder(context)),
            Flexible(
              child: _allFavorites.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No sort favorites are available for this library type.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: libraryToolbarMenuMutedText(context),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final panes = [
                            Expanded(
                              child: _SortFavoritesPaneFrame(
                                title: 'Pinned Favorites',
                                count: _pinnedFavorites.length,
                                child: _pinnedFavorites.isEmpty
                                    ? _SortFavoritesEmptyState(
                                        message:
                                            'No pinned favorites yet. Add favorites from the right pane to keep them at the top of the sort menu.',
                                      )
                                    : ReorderableListView.builder(
                                        padding: const EdgeInsets.all(8),
                                        buildDefaultDragHandles: false,
                                        itemCount: _pinnedFavorites.length,
                                        onReorderItem: (oldIndex, newIndex) {
                                          setState(() {
                                            final favorite = _pinnedFavorites
                                                .removeAt(oldIndex);
                                            _pinnedFavorites.insert(
                                              newIndex,
                                              favorite,
                                            );
                                          });
                                        },
                                        itemBuilder: (context, index) {
                                          final favorite =
                                              _pinnedFavorites[index];
                                          return _PinnedSortFavoriteTile(
                                            key: ValueKey(
                                              'sortFavorite_${favorite.id}',
                                            ),
                                            type: widget.type,
                                            favorite: favorite,
                                            active: favorite.id ==
                                                widget.activeSortFavoriteId,
                                            index: index,
                                            onRemove: () => setState(() {
                                              _pinnedFavorites.removeAt(index);
                                              _availableFavorites.add(favorite);
                                              _availableFavorites.sort(
                                                (left, right) =>
                                                    _allFavorites
                                                        .indexOf(left) -
                                                    _allFavorites
                                                        .indexOf(right),
                                              );
                                            }),
                                          );
                                        },
                                      ),
                              ),
                            ),
                            Expanded(
                              child: _SortFavoritesPaneFrame(
                                title: 'Available Favorites',
                                count: _availableFavorites.length,
                                child: _availableFavorites.isEmpty
                                    ? const _SortFavoritesEmptyState(
                                        message:
                                            'All available sort favorites are already pinned.',
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.all(8),
                                        itemCount: _availableFavorites.length,
                                        itemBuilder: (context, index) {
                                          final favorite =
                                              _availableFavorites[index];
                                          return _AvailableSortFavoriteTile(
                                            key: ValueKey(
                                              'availableSortFavorite_${favorite.id}',
                                            ),
                                            type: widget.type,
                                            favorite: favorite,
                                            active: favorite.id ==
                                                widget.activeSortFavoriteId,
                                            onAdd: () => setState(() {
                                              _availableFavorites
                                                  .removeAt(index);
                                              _pinnedFavorites.add(favorite);
                                            }),
                                          );
                                        },
                                      ),
                              ),
                            ),
                          ];

                          if (constraints.maxWidth <
                              kLibraryToolbarCompactBreakpoint) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                panes[0],
                                const SizedBox(height: 14),
                                panes[1],
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              panes[0],
                              const SizedBox(width: 14),
                              panes[1],
                            ],
                          );
                        },
                      ),
                    ),
            ),
            Divider(height: 1, color: libraryToolbarMenuBorder(context)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  Text(
                    '${_pinnedFavorites.length} pinned',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: libraryToolbarMenuMutedText(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(
                      LinkedHashSet<String>.from(
                        _pinnedFavorites.map((favorite) => favorite.id),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortFavoritesPaneFrame extends StatelessWidget {
  const _SortFavoritesPaneFrame({
    required this.title,
    required this.count,
    required this.child,
  });

  final String title;
  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border.all(color: palette.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                palette.accent.withValues(alpha: 0.06),
                palette.surface,
              ),
              border: Border(bottom: BorderSide(color: palette.divider)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: palette.accent,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: palette.badgeBackground,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SortFavoritesEmptyState extends StatelessWidget {
  const _SortFavoritesEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: libraryToolbarMenuMutedText(context),
              ),
        ),
      ),
    );
  }
}

class _PinnedSortFavoriteTile extends StatelessWidget {
  const _PinnedSortFavoriteTile({
    super.key,
    required this.type,
    required this.favorite,
    required this.active,
    required this.index,
    required this.onRemove,
  });

  final LibraryTypeConfig type;
  final LibrarySortFavorite favorite;
  final bool active;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? Color.alphaBlend(
                palette.accent.withValues(alpha: 0.08),
                palette.panelRaised,
              )
            : libraryToolbarMenuHover(context),
        border: Border.all(
          color: active
              ? palette.accent.withValues(alpha: 0.45)
              : libraryToolbarMenuBorder(context),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: Icon(
                Icons.drag_indicator,
                color: libraryToolbarMenuMutedText(context),
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              favorite.icon,
              size: 18,
              color: active ? palette.accent : palette.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    favorite.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _sortFavoriteSummary(type, favorite.rules),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: libraryToolbarMenuMutedText(context),
                    ),
                  ),
                ],
              ),
            ),
            if (active) ...[
              Text(
                'Active',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: palette.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
            ],
            IconButton(
              tooltip: 'Remove favorite',
              onPressed: onRemove,
              icon: const Icon(Icons.remove_circle_outline, size: 18),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailableSortFavoriteTile extends StatelessWidget {
  const _AvailableSortFavoriteTile({
    super.key,
    required this.type,
    required this.favorite,
    required this.active,
    required this.onAdd,
  });

  final LibraryTypeConfig type;
  final LibrarySortFavorite favorite;
  final bool active;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? Color.alphaBlend(
                palette.accent.withValues(alpha: 0.08),
                palette.panelRaised,
              )
            : libraryToolbarMenuHover(context),
        border: Border.all(color: libraryToolbarMenuBorder(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Icon(
              favorite.icon,
              size: 18,
              color: active ? palette.accent : palette.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    favorite.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _sortFavoriteSummary(type, favorite.rules),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: libraryToolbarMenuMutedText(context),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Pin favorite',
              onPressed: onAdd,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

String _sortFavoriteSummary(
    LibraryTypeConfig type, List<LibrarySortRule> rules) {
  return rules
      .map(
        (rule) =>
            '${type.presentation.sortColumnDefinitionFor(rule.column).label} ${rule.ascending ? 'ASC' : 'DESC'}',
      )
      .join('  |  ');
}

List<LibrarySortFavorite> _orderedPinnedSortFavorites(
  List<LibrarySortFavorite> favorites,
  Iterable<String> pinnedIds,
) {
  final byId = {for (final favorite in favorites) favorite.id: favorite};
  return [
    for (final id in pinnedIds)
      if (byId[id] case final favorite?) favorite,
  ];
}

List<LibrarySortFavorite> _overflowSortFavorites(
  List<LibrarySortFavorite> favorites,
  Iterable<String> pinnedIds,
) {
  final pinned = pinnedIds.toSet();
  return [
    for (final favorite in favorites)
      if (!pinned.contains(favorite.id)) favorite,
  ];
}

double measureLibraryToolbarDropdownWidth(
  BuildContext context, {
  required Iterable<String> labels,
  required TextStyle? textStyle,
  required double leadingWidth,
  required double leadingSpacing,
  required double trailingWidth,
  required double horizontalPadding,
  required double minWidth,
}) {
  final textDirection = Directionality.of(context);
  final textScaler = MediaQuery.textScalerOf(context);
  final painter = TextPainter(
    textDirection: textDirection,
    textScaler: textScaler,
    maxLines: 1,
  );
  var maxLabelWidth = 0.0;

  for (final label in labels) {
    painter.text = TextSpan(text: label, style: textStyle);
    painter.layout();
    if (painter.width > maxLabelWidth) {
      maxLabelWidth = painter.width;
    }
  }

  return (horizontalPadding +
          leadingWidth +
          leadingSpacing +
          maxLabelWidth +
          trailingWidth)
      .clamp(minWidth, double.infinity);
}

class LibraryCollectionStatusScopeMenuItem extends StatelessWidget {
  const LibraryCollectionStatusScopeMenuItem({
    super.key,
    required this.scope,
    required this.isSelected,
    required this.accent,
    required this.muted,
    required this.textColor,
  });

  final LibraryCollectionStatusScope scope;
  final bool isSelected;
  final Color accent;
  final Color muted;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: LibraryWorkspaceMenuRow(
        label: scope.label,
        leading: LibraryCollectionStatusScopeBadge(
          scope: scope,
          accent: accent,
          muted: muted,
        ),
        trailing:
            isSelected ? Icon(Icons.check, size: 16, color: textColor) : null,
        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: textColor,
            ),
      ),
    );
  }
}

class LibraryCollectionStatusScopeBadge extends StatelessWidget {
  const LibraryCollectionStatusScopeBadge({
    super.key,
    required this.scope,
    required this.accent,
    required this.muted,
  });

  final LibraryCollectionStatusScope scope;
  final Color accent;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final color = libraryCollectionStatusScopeColor(scope, accent, muted);
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Icon(scope.icon, size: 13, color: Colors.white),
    );
  }
}

Color libraryCollectionStatusScopeColor(
  LibraryCollectionStatusScope scope,
  Color accent,
  Color muted,
) {
  return switch (scope) {
    LibraryCollectionStatusScope.all => muted,
    LibraryCollectionStatusScope.inCollection => accent,
    LibraryCollectionStatusScope.forSale => const Color(0xFF2E7D32),
    LibraryCollectionStatusScope.wishList => const Color(0xFFFF9800),
    LibraryCollectionStatusScope.onOrder => const Color(0xFF0EA5E9),
    LibraryCollectionStatusScope.sold => const Color(0xFFC44B4F),
    LibraryCollectionStatusScope.notInCollection => const Color(0xFF9E9E9E),
  };
}

final RegExp _libraryToolbarLetterPattern = RegExp(r'[A-Z]');

class LibraryToolbarAlphabetRow extends StatelessWidget {
  const LibraryToolbarAlphabetRow({
    super.key,
    required this.letters,
    required this.selectedLetter,
    required this.onLetterSelected,
  });

  final Set<String> letters;
  final String? selectedLetter;
  final ValueChanged<String?> onLetterSelected;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final availableLetters = letters
        .map((letter) => letter.trim().toUpperCase())
        .where(
          (letter) =>
              letter == '#' ||
              letter == '0-9' ||
              (letter.length == 1 &&
                  _libraryToolbarLetterPattern.hasMatch(letter)),
        )
        .toSet();
    const alphabet = [
      '#',
      '0-9',
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'G',
      'H',
      'I',
      'J',
      'K',
      'L',
      'M',
      'N',
      'O',
      'P',
      'Q',
      'R',
      'S',
      'T',
      'U',
      'V',
      'W',
      'X',
      'Y',
      'Z',
    ];

    Widget buildLetterButton({
      required String label,
      required bool selected,
      required bool enabled,
      required VoidCallback? onTap,
    }) {
      final foreground = selected
          ? Colors.white
          : enabled
              ? palette.textPrimary
              : palette.textMuted.withValues(alpha: 0.38);
      final background = selected
          ? palette.selection
          : enabled
              ? palette.surfaceSubtle.withValues(alpha: 0.42)
              : Colors.transparent;
      final borderColor = selected
          ? palette.selection.withValues(alpha: 0.9)
          : enabled
              ? palette.divider.withValues(alpha: 0.7)
              : palette.divider.withValues(alpha: 0.24);

      return Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              constraints: BoxConstraints(
                minWidth: label == 'All' ? 34 : 22,
                minHeight: 24,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: label == 'All' ? 8 : 0,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderColor),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: foreground,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 28,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildLetterButton(
                      label: 'All',
                      selected: selectedLetter == null,
                      enabled: true,
                      onTap: () => onLetterSelected(null),
                    ),
                    for (final letter in alphabet)
                      buildLetterButton(
                        label: letter,
                        selected: selectedLetter == letter,
                        enabled: availableLetters.contains(letter),
                        onTap: availableLetters.contains(letter)
                            ? () => onLetterSelected(
                                  selectedLetter == letter ? null : letter,
                                )
                            : null,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class LibraryInlineIssueJumpField extends StatefulWidget {
  const LibraryInlineIssueJumpField({super.key, required this.onSubmitted});

  final ValueChanged<String> onSubmitted;

  @override
  State<LibraryInlineIssueJumpField> createState() =>
      _LibraryInlineIssueJumpFieldState();
}

class _LibraryInlineIssueJumpFieldState
    extends State<LibraryInlineIssueJumpField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void submit() {
      final value = _controller.text.trim();
      if (value.isEmpty) {
        return;
      }
      widget.onSubmitted(value);
      _controller.clear();
    }

    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Issue #',
        prefixIcon: const Icon(Icons.tag, size: 16),
        suffixIcon: IconButton(
          tooltip: 'Jump to issue',
          onPressed: submit,
          icon: const Icon(Icons.arrow_forward, size: 16),
        ),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      keyboardType: TextInputType.number,
      onSubmitted: (_) => submit(),
    );
  }
}

void showLibraryCompactCoverSizeSheet(
  BuildContext context,
  LibraryViewMode viewMode,
  ValueChanged<LibraryViewMode> onViewModeChanged,
  ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged,
  ValueChanged<double> onCoverSizeChanged,
) {
  final coverSizeEnabled = viewMode.supportsCoverSize;
  showModalBottomSheet<void>(
    context: context,
    builder: (context) => Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.grid_view),
              title: const Text('Grid view'),
              onTap: () {
                Navigator.of(context).pop();
                onViewModeChanged(LibraryViewMode.grid);
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_module),
              title: const Text('Cards view'),
              onTap: () {
                Navigator.of(context).pop();
                onViewModeChanged(LibraryViewMode.card);
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_agenda),
              title: const Text('Flow view'),
              onTap: () {
                Navigator.of(context).pop();
                onViewModeChanged(LibraryViewMode.cardFlow);
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_list),
              title: const Text('List view'),
              onTap: () {
                Navigator.of(context).pop();
                onViewModeChanged(LibraryViewMode.list);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.view_sidebar_outlined),
              title: const Text('Details on right'),
              onTap: () {
                Navigator.of(context).pop();
                onDetailsLayoutChanged(LibraryDetailsLayout.right);
              },
            ),
            ListTile(
              leading: const Icon(Icons.splitscreen_outlined),
              title: const Text('Details on bottom'),
              onTap: () {
                Navigator.of(context).pop();
                onDetailsLayoutChanged(LibraryDetailsLayout.bottom);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close_fullscreen_outlined),
              title: const Text('Hide details'),
              onTap: () {
                Navigator.of(context).pop();
                onDetailsLayoutChanged(LibraryDetailsLayout.hidden);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.photo_size_select_small),
              title: const Text('Small covers'),
              enabled: coverSizeEnabled,
              onTap: coverSizeEnabled
                  ? () {
                      Navigator.of(context).pop();
                      onCoverSizeChanged(96);
                    }
                  : null,
            ),
            ListTile(
              leading: const Icon(Icons.photo_size_select_large),
              title: const Text('Large covers'),
              enabled: coverSizeEnabled,
              onTap: coverSizeEnabled
                  ? () {
                      Navigator.of(context).pop();
                      onCoverSizeChanged(188);
                    }
                  : null,
            ),
          ],
        ),
      ),
    ),
  );
}

class LibraryFilterButton extends StatelessWidget {
  const LibraryFilterButton({
    super.key,
    required this.activeCount,
    required this.onPressed,
  });

  final int activeCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: activeCount > 0,
      largeSize: 14,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      label: Text(
        activeCount.toString(),
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
      ),
      child: DecoratedBox(
        decoration: libraryToolbarDropdownDecoration(context),
        child: SizedBox.square(
          dimension: 30,
          child: IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 30, height: 30),
            icon: Icon(
              activeCount > 0 ? Icons.filter_alt : Icons.filter_alt_outlined,
              size: 17,
            ),
            tooltip: 'Edit filters',
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}

class LibraryItemCountLabel extends StatelessWidget {
  const LibraryItemCountLabel({
    super.key,
    required this.shown,
    required this.total,
    required this.pluralLabel,
  });

  final int shown;
  final int total;
  final String pluralLabel;

  @override
  Widget build(BuildContext context) {
    final label = shown == total
        ? '$total ${pluralLabel.toLowerCase()}'
        : '$shown of $total ${pluralLabel.toLowerCase()}';
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: appPalette(context).textMuted,
      ),
    );
  }
}

class LibraryToolbarScopeChip extends StatelessWidget {
  const LibraryToolbarScopeChip({
    super.key,
    required this.label,
    required this.onClear,
  });

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: appPalette(context).selection,
      label: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 2),
      onDeleted: onClear,
    );
  }
}

class LibraryCollectionValueChip extends StatelessWidget {
  const LibraryCollectionValueChip({
    super.key,
    required this.totalPaidCents,
    required this.totalCoverCents,
    required this.totalSellCents,
    required this.currency,
  });

  final int totalPaidCents;
  final int totalCoverCents;
  final int totalSellCents;
  final String? currency;

  String _fmt(int cents) {
    final cur = currency ?? 'USD';
    return '${(cents / 100).toStringAsFixed(2)} $cur';
  }

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (totalPaidCents > 0) parts.add('Paid ${_fmt(totalPaidCents)}');
    if (totalCoverCents > 0) parts.add('Cover ${_fmt(totalCoverCents)}');
    if (totalSellCents > 0) parts.add('Sold ${_fmt(totalSellCents)}');
    if (parts.isEmpty) return const SizedBox.shrink();
    return Tooltip(
      message: parts.join('\n'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.attach_money,
              size: 12,
              color: Colors.greenAccent.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 2),
            Text(
              _fmt(
                totalPaidCents > 0
                    ? totalPaidCents
                    : (totalCoverCents > 0 ? totalCoverCents : totalSellCents),
              ),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.greenAccent.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
