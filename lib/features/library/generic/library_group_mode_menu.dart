import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_controls.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_menus.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:flutter/material.dart';

enum LibraryGroupModeMenuAction { disableFolders }

class _ManageFavoritesRequest {
  const _ManageFavoritesRequest(this.favoritePresets);

  final List<LibraryFolderPreset> favoritePresets;
}

class LibraryGroupModeMenuButton extends StatelessWidget {
  const LibraryGroupModeMenuButton({
    super.key,
    required this.type,
    required this.folderPreset,
    required this.accent,
    required this.icon,
    required this.onChanged,
    this.sidebarVisible = true,
    this.onSidebarVisibilityChanged,
    this.pinnedFolderPresets = const [],
    this.onPinnedPresetsChanged,
    this.iconOnly = false,
  });

  final LibraryTypeConfig type;
  final LibraryFolderPreset? folderPreset;
  final Color accent;
  final IconData icon;
  final ValueChanged<LibraryFolderPreset> onChanged;
  final bool sidebarVisible;
  final ValueChanged<bool>? onSidebarVisibilityChanged;
  final List<LibraryFolderPreset> pinnedFolderPresets;
  final ValueChanged<List<LibraryFolderPreset>>? onPinnedPresetsChanged;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    final label = folderPreset == null
        ? 'Group by'
      : genericFolderPresetLabel(folderPreset!, type);
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
                selectedPreset: folderPreset,
                availableModes: modes,
                initialPinnedPresets: pinnedFolderPresets,
                onPinnedPresetsChanged: onPinnedPresetsChanged,
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
      if (value is LibraryFolderPreset) {
        onChanged(value);
        if (!sidebarVisible && onSidebarVisibilityChanged != null) {
          onSidebarVisibilityChanged!(true);
        }
      } else if (value is _ManageFavoritesRequest) {
        if (!context.mounted) {
          return;
        }
        final updated = await showDialog<List<LibraryFolderPreset>>(
          context: context,
          builder: (dialogContext) => _GroupModeFavoritesDialog(
            type: type,
            availableModes: modes,
            initialFavorites: value.favoritePresets,
          ),
        );
        if (updated != null && context.mounted) {
          onPinnedPresetsChanged?.call(updated);
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
    required this.selectedPreset,
    required this.availableModes,
    required this.initialPinnedPresets,
    this.sidebarVisible = true,
    this.hasSidebarVisibilityToggle = false,
    this.onPinnedPresetsChanged,
  });

  final LibraryTypeConfig type;
  final LibraryFolderPreset? selectedPreset;
  final List<LibraryGroupMode> availableModes;
  final List<LibraryFolderPreset> initialPinnedPresets;
  final bool sidebarVisible;
  final bool hasSidebarVisibilityToggle;
  final ValueChanged<List<LibraryFolderPreset>>? onPinnedPresetsChanged;

  @override
  State<LibraryGroupModeDropdownMenu> createState() =>
      _LibraryGroupModeDropdownMenuState();
}

class _LibraryGroupModeDropdownMenuState
    extends State<LibraryGroupModeDropdownMenu> {
  late List<LibraryFolderPreset> _pinnedPresets;
  late Map<String, bool> _expandedSections;
  late List<_GroupModeCategory> _categories;

  @override
  void initState() {
    super.initState();
    _pinnedPresets = List<LibraryFolderPreset>.from(widget.initialPinnedPresets);
    _categories = _categorizeGroupModes(widget.availableModes);
    _expandedSections = {
      if (_pinnedPresets.isNotEmpty) 'Favorites': true,
      for (final category in _categories)
        category.label: category.modes.any(
          (mode) =>
              widget.selectedPreset == LibraryFolderPreset.single(mode) ||
              _pinnedPresets.contains(LibraryFolderPreset.single(mode)),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final favoritePresets = [
      for (final preset in _pinnedPresets)
        if (preset.modes.every(widget.availableModes.contains)) preset,
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
                        onPressed: widget.onPinnedPresetsChanged == null
                            ? null
                            : () => Navigator.of(context).pop(
                                  _ManageFavoritesRequest(
                                    List<LibraryFolderPreset>.from(
                                      _pinnedPresets,
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
                if (favoritePresets.isEmpty)
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
                        presets: favoritePresets,
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
    List<LibraryGroupMode> modes = const [],
    List<LibraryFolderPreset> presets = const [],
  }) {
    final expanded = _expandedSections[label] ?? false;
    final selectedSingleMode = widget.selectedPreset != null &&
            widget.selectedPreset!.modes.length == 1
        ? widget.selectedPreset!.primaryMode
        : null;
    final hasSelectedMode = modes.contains(selectedSingleMode) ||
        presets.contains(widget.selectedPreset);
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
                        for (final preset in presets)
                          _buildPresetItem(
                            context,
                            preset,
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
    final isSelected = widget.selectedPreset == LibraryFolderPreset.single(mode);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Padding(
        padding: EdgeInsets.only(left: isSelected && !sectionHighlighted ? 10 : 0),
        child: LibraryWorkspaceMenuRow(
          key: ValueKey('groupModeItemRow_${mode.name}'),
          label: genericGroupModeFolderSetLabel(mode, widget.type),
          leadingWidth: 16,
          leading: isSelected
              ? Icon(
                  Icons.check,
                  size: 16,
                  color: libraryToolbarMenuText(context),
                )
              : null,
          onTap: () => Navigator.of(context).pop(LibraryFolderPreset.single(mode)),
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

  Widget _buildPresetItem(
    BuildContext context,
    LibraryFolderPreset preset, {
    required bool sectionHighlighted,
  }) {
    final isSelected = preset == widget.selectedPreset;
    final keySuffix = preset.storageValue.replaceAll('>', '_');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Padding(
        padding: EdgeInsets.only(left: isSelected && !sectionHighlighted ? 10 : 0),
        child: LibraryWorkspaceMenuRow(
          key: ValueKey('groupPresetItemRow_$keySuffix'),
          label: genericFolderPresetLabel(preset, widget.type),
          leadingWidth: 16,
          leading: isSelected
              ? Icon(
                  Icons.check,
                  size: 16,
                  color: libraryToolbarMenuText(context),
                )
              : null,
          onTap: () => Navigator.of(context).pop(preset),
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
  final List<LibraryFolderPreset> initialFavorites;

  @override
  State<_GroupModeFavoritesDialog> createState() =>
      _GroupModeFavoritesDialogState();
}

class _GroupModeFavoritesDialogState extends State<_GroupModeFavoritesDialog> {
  late final List<LibraryFolderPreset> _favoritePresets;
  int? _editingIndex;
  late List<LibraryGroupMode> _draftModes;
  var _fieldSearch = '';

  @override
  void initState() {
    super.initState();
    _favoritePresets = [
      for (final preset in widget.initialFavorites)
        if (preset.modes.every(widget.availableModes.contains)) preset,
    ];
    _draftModes = const [];
  }

  bool get _hasDraft => _draftModes.isNotEmpty;

  bool get _hasDuplicateDraft {
    if (_draftModes.isEmpty) {
      return false;
    }
    final draft = LibraryFolderPreset(modes: _draftModes);
    for (var index = 0; index < _favoritePresets.length; index += 1) {
      if (index == _editingIndex) {
        continue;
      }
      if (_favoritePresets[index] == draft) {
        return true;
      }
    }
    return false;
  }

  void _startAddFavorite() {
    setState(() {
      _editingIndex = null;
      _draftModes = [];
      _fieldSearch = '';
    });
  }

  void _startEditFavorite(int index) {
    setState(() {
      _editingIndex = index;
      _draftModes = List<LibraryGroupMode>.from(_favoritePresets[index].modes);
      _fieldSearch = '';
    });
  }

  void _toggleDraftMode(LibraryGroupMode mode) {
    setState(() {
      if (_draftModes.contains(mode)) {
        _draftModes.remove(mode);
        return;
      }
      if (_draftModes.length >= 3) {
        return;
      }
      _draftModes = [..._draftModes, mode];
    });
  }

  void _saveDraft() {
    if (_draftModes.isEmpty || _hasDuplicateDraft) {
      return;
    }
    final preset = LibraryFolderPreset(modes: _draftModes);
    setState(() {
      if (_editingIndex == null) {
        _favoritePresets.add(preset);
      } else {
        _favoritePresets[_editingIndex!] = preset;
      }
      _editingIndex = null;
      _draftModes = [];
      _fieldSearch = '';
    });
  }

  List<_GroupModeCategory> get _filteredCategories {
    final query = _fieldSearch.trim().toLowerCase();
    final categories = _categorizeGroupModes(widget.availableModes);
    if (query.isEmpty) {
      return categories;
    }
    return [
      for (final category in categories)
        _GroupModeCategory(
          category.label,
          [
            for (final mode in category.modes)
              if (genericGroupModeLabel(mode, widget.type)
                      .toLowerCase()
                      .contains(query) ||
                  genericGroupModeSidebarTitle(mode, widget.type)
                      .toLowerCase()
                      .contains(query))
                mode,
          ],
        ),
    ].where((category) => category.modes.isNotEmpty).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: libraryToolbarDropdownMenuShape(context),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Manage Folder Favorites',
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: libraryToolbarMenuBorder(context),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Folder Favorites',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  FilledButton.tonal(
                                    key: const ValueKey('folderFavoritesAddButton'),
                                    onPressed: _startAddFavorite,
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    child: const Icon(Icons.add, size: 16),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              height: 1,
                              color: libraryToolbarMenuBorder(context),
                            ),
                            Expanded(
                              child: _favoritePresets.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Text(
                                          'No folder favorites yet.',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: libraryToolbarMenuMutedText(context),
                                          ),
                                        ),
                                      ),
                                    )
                                  : ReorderableListView.builder(
                                      padding: const EdgeInsets.all(8),
                                      buildDefaultDragHandles: false,
                                      itemCount: _favoritePresets.length,
                                      onReorderItem: (oldIndex, newIndex) {
                                        setState(() {
                                          final item = _favoritePresets.removeAt(oldIndex);
                                          _favoritePresets.insert(newIndex, item);
                                        });
                                      },
                                      itemBuilder: (context, index) {
                                        final preset = _favoritePresets[index];
                                        final isEditing = _editingIndex == index;
                                        return Container(
                                          key: ValueKey(
                                            'groupFavorite_${preset.storageValue.replaceAll('>', '_')}',
                                          ),
                                          margin: const EdgeInsets.symmetric(vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isEditing
                                                ? libraryToolbarMenuHover(context)
                                                : Colors.transparent,
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
                                                    color: libraryToolbarMenuMutedText(context),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    genericFolderPresetLabel(preset, widget.type),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  tooltip: 'Edit favorite',
                                                  onPressed: () => _startEditFavorite(index),
                                                  icon: const Icon(
                                                    Icons.edit_outlined,
                                                    size: 16,
                                                  ),
                                                ),
                                                IconButton(
                                                  tooltip: 'Remove favorite',
                                                  onPressed: () => setState(() {
                                                    _favoritePresets.removeAt(index);
                                                    if (_editingIndex == index) {
                                                      _editingIndex = null;
                                                      _draftModes = [];
                                                    }
                                                  }),
                                                  icon: const Icon(Icons.delete_outline),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: libraryToolbarMenuBorder(context),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Select one or more fields',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Choose up to three folder fields in drilldown order.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: libraryToolbarMenuMutedText(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: TextField(
                                onChanged: (value) => setState(() => _fieldSearch = value),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  prefixIcon: Icon(Icons.search, size: 18),
                                  hintText: 'Search fields',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: libraryToolbarMenuBorder(context),
                                          ),
                                        ),
                                        child: ListView(
                                          padding: const EdgeInsets.all(10),
                                          children: [
                                            for (final category in _filteredCategories) ...[
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 8),
                                                child: Text(
                                                  category.label,
                                                  style: theme.textTheme.titleSmall?.copyWith(
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                              for (final mode in category.modes)
                                                InkWell(
                                                  onTap: () => _toggleDraftMode(mode),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 8,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          _draftModes.contains(mode)
                                                              ? Icons.check_box
                                                              : Icons.check_box_outline_blank,
                                                          size: 18,
                                                          color: _draftModes.contains(mode)
                                                              ? Theme.of(context).colorScheme.primary
                                                              : libraryToolbarMenuMutedText(context),
                                                        ),
                                                        const SizedBox(width: 10),
                                                        Expanded(
                                                          child: Text(
                                                            genericGroupModeLabel(mode, widget.type),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              const SizedBox(height: 12),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: libraryToolbarMenuBorder(context),
                                          ),
                                        ),
                                        child: _draftModes.isEmpty
                                            ? Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(16),
                                                  child: Text(
                                                    'Selected fields will appear here.',
                                                    textAlign: TextAlign.center,
                                                    style: theme.textTheme.bodySmall?.copyWith(
                                                      color: libraryToolbarMenuMutedText(context),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : ReorderableListView.builder(
                                                padding: const EdgeInsets.all(8),
                                                buildDefaultDragHandles: false,
                                                itemCount: _draftModes.length,
                                                onReorderItem: (oldIndex, newIndex) {
                                                  setState(() {
                                                    final mode = _draftModes.removeAt(oldIndex);
                                                    _draftModes.insert(newIndex, mode);
                                                  });
                                                },
                                                itemBuilder: (context, index) {
                                                  final mode = _draftModes[index];
                                                  return Container(
                                                    key: ValueKey('draftFolderMode_${mode.name}'),
                                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: libraryToolbarMenuHover(context),
                                                      border: Border.all(
                                                        color: libraryToolbarMenuBorder(context),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 8,
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          ReorderableDragStartListener(
                                                            index: index,
                                                            child: Icon(
                                                              Icons.drag_indicator,
                                                              color: libraryToolbarMenuMutedText(context),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Expanded(
                                                            child: Text(
                                                              genericGroupModeLabel(mode, widget.type),
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                          IconButton(
                                                            tooltip: 'Remove field',
                                                            onPressed: () => _toggleDraftMode(mode),
                                                            icon: const Icon(Icons.close, size: 16),
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
                            if (_hasDuplicateDraft)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                child: Text(
                                  'This folder favorite already exists.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
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
                    key: const ValueKey('folderFavoritesDraftSaveButton'),
                    onPressed: _hasDraft && !_hasDuplicateDraft ? _saveDraft : null,
                    child: const Text('Save Favorite'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    key: const ValueKey('folderFavoritesManagerSaveButton'),
                    onPressed: () => Navigator.of(context).pop(
                      List<LibraryFolderPreset>.from(_favoritePresets),
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