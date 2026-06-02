import 'dart:collection';

import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_controls.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_menus.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:flutter/material.dart';

enum LibraryGroupModeMenuAction { disableFolders }

class _ManageFavoritesRequest {
  const _ManageFavoritesRequest(this.favoriteModes);

  final Set<LibraryGroupMode> favoriteModes;
}

class LibraryGroupModeMenuButton extends StatelessWidget {
  const LibraryGroupModeMenuButton({
    super.key,
    required this.type,
    required this.groupMode,
    required this.accent,
    required this.icon,
    required this.onChanged,
    this.sidebarVisible = true,
    this.onSidebarVisibilityChanged,
    this.pinnedGroupModes = const {},
    this.onPinnedModesChanged,
    this.iconOnly = false,
  });

  final LibraryTypeConfig type;
  final LibraryGroupMode? groupMode;
  final Color accent;
  final IconData icon;
  final ValueChanged<LibraryGroupMode> onChanged;
  final bool sidebarVisible;
  final ValueChanged<bool>? onSidebarVisibilityChanged;
  final Set<LibraryGroupMode> pinnedGroupModes;
  final ValueChanged<Set<LibraryGroupMode>>? onPinnedModesChanged;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    final label = groupMode == null
        ? 'Group by'
        : genericGroupModeSidebarTitle(groupMode!, type);
    final child = iconOnly
        ? LibraryToolbarCompactDropdownTrigger(icon: icon)
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: accent),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, size: 18, color: accent),
              ],
            ),
          );

    return Tooltip(
      message: 'Group by',
      child: InkWell(
        onTap: () => _showGroupModeMenu(context),
        borderRadius: BorderRadius.zero,
        child: child,
      ),
    );
  }

  void _showGroupModeMenu(BuildContext context) {
    final modes = libraryGroupModesForType(type);
    final overlay = Overlay.of(context, rootOverlay: true)
        .context
        .findRenderObject() as RenderBox;
    final box = context.findRenderObject() as RenderBox;
    final target = box.localToGlobal(Offset.zero, ancestor: overlay) & box.size;
    final selection = showGeneralDialog<Object?>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss group mode menu',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 140),
      pageBuilder: (dialogContext, _, __) {
        const menuWidth = 280.0;
        final screenSize = overlay.size;
        final left = target.left.clamp(8.0, screenSize.width - menuWidth - 8.0);
        final top = (target.bottom + 4).clamp(8.0, screenSize.height - 420.0);
        return Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              width: menuWidth,
              child: LibraryGroupModeDropdownMenu(
                type: type,
                selectedMode: groupMode,
                availableModes: modes,
                initialPinnedModes: pinnedGroupModes,
                onPinnedModesChanged: onPinnedModesChanged,
                sidebarVisible: sidebarVisible,
                hasSidebarVisibilityToggle: onSidebarVisibilityChanged != null,
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1).animate(curved),
            alignment: Alignment.topLeft,
            child: child,
          ),
        );
      },
    );
    selection.then((value) async {
      if (value is LibraryGroupMode) {
        onChanged(value);
        if (!sidebarVisible && onSidebarVisibilityChanged != null) {
          onSidebarVisibilityChanged!(true);
        }
      } else if (value is _ManageFavoritesRequest) {
        if (!context.mounted) {
          return;
        }
        final updated = await showDialog<Set<LibraryGroupMode>>(
          context: context,
          builder: (dialogContext) => _GroupModeFavoritesDialog(
            type: type,
            availableModes: modes,
            initialFavorites: value.favoriteModes,
          ),
        );
        if (updated != null && context.mounted) {
          onPinnedModesChanged?.call(updated);
        }
      } else if (value == LibraryGroupModeMenuAction.disableFolders &&
          onSidebarVisibilityChanged != null) {
        onSidebarVisibilityChanged!(false);
      }
    });
  }
}

class LibraryGroupModeDropdownMenu extends StatefulWidget {
  const LibraryGroupModeDropdownMenu({
    super.key,
    required this.type,
    required this.selectedMode,
    required this.availableModes,
    required this.initialPinnedModes,
    this.sidebarVisible = true,
    this.hasSidebarVisibilityToggle = false,
    this.onPinnedModesChanged,
  });

  final LibraryTypeConfig type;
  final LibraryGroupMode? selectedMode;
  final List<LibraryGroupMode> availableModes;
  final Set<LibraryGroupMode> initialPinnedModes;
  final bool sidebarVisible;
  final bool hasSidebarVisibilityToggle;
  final ValueChanged<Set<LibraryGroupMode>>? onPinnedModesChanged;

  @override
  State<LibraryGroupModeDropdownMenu> createState() =>
      _LibraryGroupModeDropdownMenuState();
}

class _LibraryGroupModeDropdownMenuState
    extends State<LibraryGroupModeDropdownMenu> {
  late Set<LibraryGroupMode> _pinnedModes;
  late Map<String, bool> _expandedSections;
  late List<_GroupModeCategory> _categories;

  @override
  void initState() {
    super.initState();
    _pinnedModes = Set<LibraryGroupMode>.from(widget.initialPinnedModes);
    _categories = _categorizeGroupModes(widget.availableModes);
    _expandedSections = {
      if (_pinnedModes.isNotEmpty) 'Favorites': true,
      for (final category in _categories)
        category.label: category.modes.any(
          (mode) => mode == widget.selectedMode || _pinnedModes.contains(mode),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final favoriteModes = [
      for (final mode in _pinnedModes)
        if (widget.availableModes.contains(mode)) mode,
    ];
    return Material(
      color: Colors.transparent,
      child: LibraryWorkspaceMenuPanel(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.hasSidebarVisibilityToggle && widget.sidebarVisible)
                  _buildActionItem(
                    context,
                    icon: Icons.folder_off_outlined,
                    label: 'No folders',
                    onTap: () => Navigator.of(context).pop(
                      LibraryGroupModeMenuAction.disableFolders,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Favorites',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      FilledButton.tonalIcon(
                        key: const ValueKey('manageGroupFavoritesButton'),
                        onPressed: widget.onPinnedModesChanged == null
                            ? null
                            : () => Navigator.of(context).pop(
                                  _ManageFavoritesRequest(
                                    LinkedHashSet<LibraryGroupMode>.from(
                                      _pinnedModes,
                                    ),
                                  ),
                                ),
                        icon: const Icon(Icons.tune, size: 16),
                        label: const Text('Manage Favorites'),
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (favoriteModes.isEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const LibraryWorkspaceMenuSectionDivider(
                        label: 'Favorites',
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                        child: Text(
                          'No favorites',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: libraryToolbarMenuMutedText(context),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const LibraryWorkspaceMenuSectionDivider(
                        label: 'Favorites',
                      ),
                      _buildSection(
                        context,
                        label: 'Favorites',
                        modes: favoriteModes,
                      ),
                    ],
                  ),
                const LibraryWorkspaceMenuSectionDivider(label: 'Folders'),
                for (final category in _categories)
                  _buildSection(
                    context,
                    label: category.label,
                    modes: category.modes,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String label,
    required List<LibraryGroupMode> modes,
  }) {
    final expanded = _expandedSections[label] ?? false;
    final hasSelectedMode = modes.contains(widget.selectedMode);
    final highlightColor =
        libraryToolbarMenuText(context).withValues(alpha: 0.95);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              if (!expanded && hasSelectedMode)
                Positioned(
                  left: 0,
                  top: 4,
                  bottom: 4,
                  child: Container(
                    key: ValueKey('groupModeSectionBar_$label'),
                    width: 4,
                    color: highlightColor,
                  ),
                ),
              Padding(
                padding:
                    EdgeInsets.only(left: !expanded && hasSelectedMode ? 10 : 0),
                child: LibraryWorkspaceMenuTreeHeader(
                  label: label,
                  expanded: expanded,
                  highlighted: hasSelectedMode,
                  onTap: () {
                    setState(() {
                      _expandedSections[label] = !expanded;
                    });
                  },
                ),
              ),
            ],
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Stack(
                children: [
                  if (hasSelectedMode)
                    Positioned(
                      left: 0,
                      top: 4,
                      bottom: 4,
                      child: Container(
                        key: ValueKey('groupModeSectionLevelBar_$label'),
                        width: 4,
                        color: highlightColor,
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(left: hasSelectedMode ? 10 : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final mode in modes)
                          _buildModeItem(
                            context,
                            mode,
                            sectionHighlighted: hasSelectedMode,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: LibraryWorkspaceMenuRow(
        label: label,
        leading: Icon(
          icon,
          size: 16,
          color: libraryToolbarMenuMutedText(context),
        ),
        onTap: onTap,
        textStyle: TextStyle(
          color: libraryToolbarMenuText(context),
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      ),
    );
  }

  Widget _buildModeItem(
    BuildContext context,
    LibraryGroupMode mode, {
    required bool sectionHighlighted,
  }) {
    final isSelected = mode == widget.selectedMode;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Padding(
        padding: EdgeInsets.only(left: isSelected && !sectionHighlighted ? 10 : 0),
        child: LibraryWorkspaceMenuRow(
          key: ValueKey('groupModeItemRow_${mode.name}'),
          label: genericGroupModeLabel(mode, widget.type),
          leadingWidth: 16,
          leading: isSelected
              ? Icon(
                  Icons.check,
                  size: 16,
                  color: libraryToolbarMenuText(context),
                )
              : null,
          onTap: () => Navigator.of(context).pop(mode),
          padding: const EdgeInsets.fromLTRB(6, 8, 8, 8),
          backgroundColor: Colors.transparent,
          textStyle: TextStyle(
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: libraryToolbarMenuText(context),
          ),
        ),
      ),
    );
  }
}

class _GroupModeCategory {
  const _GroupModeCategory(this.label, this.modes);

  final String label;
  final List<LibraryGroupMode> modes;
}

List<_GroupModeCategory> _categorizeGroupModes(List<LibraryGroupMode> modes) {
  const mainModes = {
    LibraryGroupMode.series,
    LibraryGroupMode.storyArc,
    LibraryGroupMode.character,
    LibraryGroupMode.title,
    LibraryGroupMode.publisher,
    LibraryGroupMode.year,
    LibraryGroupMode.audienceRating,
    LibraryGroupMode.color,
    LibraryGroupMode.genre,
    LibraryGroupMode.country,
    LibraryGroupMode.language,
    LibraryGroupMode.ageRating,
    LibraryGroupMode.movieOrTvSeries,
    LibraryGroupMode.releaseDate,
    LibraryGroupMode.releaseMonth,
    LibraryGroupMode.releaseYear,
  };
  const editionModes = {
    LibraryGroupMode.audioTracks,
    LibraryGroupMode.boxSet,
    LibraryGroupMode.distributor,
    LibraryGroupMode.editionReleaseDate,
    LibraryGroupMode.editionReleaseMonth,
    LibraryGroupMode.editionReleaseYear,
    LibraryGroupMode.extras,
    LibraryGroupMode.format,
    LibraryGroupMode.hdr,
    LibraryGroupMode.layers,
    LibraryGroupMode.packaging,
    LibraryGroupMode.regions,
    LibraryGroupMode.screenRatios,
    LibraryGroupMode.subtitles,
  };
  const crewModes = {
    LibraryGroupMode.actor,
    LibraryGroupMode.director,
    LibraryGroupMode.musician,
    LibraryGroupMode.photography,
    LibraryGroupMode.producer,
    LibraryGroupMode.writer,
    LibraryGroupMode.creator,
    LibraryGroupMode.artist,
    LibraryGroupMode.penciller,
    LibraryGroupMode.colorist,
    LibraryGroupMode.letterer,
    LibraryGroupMode.coverArtist,
    LibraryGroupMode.editor,
  };
  final main = modes.where(mainModes.contains).toList();
  final edition = modes.where(editionModes.contains).toList();
  final crew = modes.where(crewModes.contains).toList();
  final personal = modes
      .where((mode) =>
          !mainModes.contains(mode) &&
          !editionModes.contains(mode) &&
          !crewModes.contains(mode))
      .toList();
  return [
    if (main.isNotEmpty) _GroupModeCategory('Main', main),
    if (edition.isNotEmpty) _GroupModeCategory('Edition', edition),
    if (crew.isNotEmpty) _GroupModeCategory('Cast & Crew', crew),
    if (personal.isNotEmpty) _GroupModeCategory('Personal', personal),
  ];
}

class _GroupModeFavoritesDialog extends StatefulWidget {
  const _GroupModeFavoritesDialog({
    required this.type,
    required this.availableModes,
    required this.initialFavorites,
  });

  final LibraryTypeConfig type;
  final List<LibraryGroupMode> availableModes;
  final Set<LibraryGroupMode> initialFavorites;

  @override
  State<_GroupModeFavoritesDialog> createState() =>
      _GroupModeFavoritesDialogState();
}

class _GroupModeFavoritesDialogState extends State<_GroupModeFavoritesDialog> {
  late final List<LibraryGroupMode> _favoriteModes;

  @override
  void initState() {
    super.initState();
    _favoriteModes = [
      for (final mode in widget.initialFavorites)
        if (widget.availableModes.contains(mode)) mode,
    ];
  }

  Set<LibraryGroupMode> _favoriteSet() =>
      LinkedHashSet<LibraryGroupMode>.from(_favoriteModes);

  Future<void> _addFavorite() async {
    final picked = await _pickMode(
      title: 'Add favorite',
      excludedModes: _favoriteSet(),
    );
    if (picked == null) {
      return;
    }
    setState(() => _favoriteModes.add(picked));
  }

  Future<void> _replaceFavorite(int index) async {
    final current = _favoriteModes[index];
    final excludedModes = _favoriteSet()..remove(current);
    final picked = await _pickMode(
      title: 'Edit favorite',
      excludedModes: excludedModes,
    );
    if (picked == null) {
      return;
    }
    setState(() => _favoriteModes[index] = picked);
  }

  Future<LibraryGroupMode?> _pickMode({
    required String title,
    required Set<LibraryGroupMode> excludedModes,
  }) {
    final candidates = [
      for (final mode in widget.availableModes)
        if (!excludedModes.contains(mode)) mode,
    ];
    return showDialog<LibraryGroupMode>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: [
          if (candidates.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Text('All available group modes are already favorited.'),
            )
          else
            for (final mode in candidates)
              SimpleDialogOption(
                onPressed: () => Navigator.of(context).pop(mode),
                child: Row(
                  children: [
                    Icon(genericGroupModeIcon(mode), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        genericGroupModeLabel(mode, widget.type),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: libraryToolbarDropdownMenuShape(context),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Manage Group Favorites',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Favorites',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: _addFavorite,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: _favoriteModes.isEmpty
                          ? DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: libraryToolbarMenuBorder(context),
                                ),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    'No favorites yet. Add group modes here to keep them at the top of the menu.',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: libraryToolbarMenuMutedText(
                                        context,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: libraryToolbarMenuBorder(context),
                                ),
                              ),
                              child: ReorderableListView.builder(
                                padding: const EdgeInsets.all(8),
                                buildDefaultDragHandles: false,
                                itemCount: _favoriteModes.length,
                                onReorderItem: (oldIndex, newIndex) {
                                  setState(() {
                                    final item = _favoriteModes.removeAt(
                                      oldIndex,
                                    );
                                    _favoriteModes.insert(newIndex, item);
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final mode = _favoriteModes[index];
                                  return Container(
                                    key: ValueKey(
                                      'groupFavorite_${mode.name}',
                                    ),
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      color: libraryToolbarMenuHover(context),
                                      border: Border.all(
                                        color: libraryToolbarMenuBorder(context),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10,
                                      ),
                                      child: Row(
                                        children: [
                                          ReorderableDragStartListener(
                                            index: index,
                                            child: Icon(
                                              Icons.drag_indicator,
                                              color: libraryToolbarMenuMutedText(
                                                context,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Icon(
                                            genericGroupModeIcon(mode),
                                            size: 18,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              genericGroupModeLabel(
                                                mode,
                                                widget.type,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            tooltip: 'Edit favorite',
                                            onPressed: () =>
                                                _replaceFavorite(index),
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              size: 16,
                                            ),
                                          ),
                                          IconButton(
                                            tooltip: 'Remove favorite',
                                            onPressed: () => setState(
                                              () => _favoriteModes.removeAt(
                                                index,
                                              ),
                                            ),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: libraryToolbarMenuBorder(context)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(_favoriteSet()),
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