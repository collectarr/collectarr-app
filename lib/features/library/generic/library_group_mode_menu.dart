import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_controls.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_menus.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_tokens.dart';
import 'package:flutter/material.dart';

enum LibraryGroupModeMenuAction { toggleSidebar }

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
    this.onTogglePin,
    this.iconOnly = false,
  });

  final LibraryTypeConfig type;
  final LibraryGroupMode groupMode;
  final Color accent;
  final IconData icon;
  final ValueChanged<LibraryGroupMode> onChanged;
  final bool sidebarVisible;
  final ValueChanged<bool>? onSidebarVisibilityChanged;
  final Set<LibraryGroupMode> pinnedGroupModes;
  final ValueChanged<LibraryGroupMode>? onTogglePin;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    final label = genericGroupModeSidebarTitle(groupMode, type);
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
                onTogglePin: onTogglePin,
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
    selection.then((value) {
      if (value is LibraryGroupMode) {
        onChanged(value);
      } else if (value == LibraryGroupModeMenuAction.toggleSidebar &&
          onSidebarVisibilityChanged != null) {
        onSidebarVisibilityChanged!(!sidebarVisible);
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
    this.onTogglePin,
  });

  final LibraryTypeConfig type;
  final LibraryGroupMode selectedMode;
  final List<LibraryGroupMode> availableModes;
  final Set<LibraryGroupMode> initialPinnedModes;
  final bool sidebarVisible;
  final bool hasSidebarVisibilityToggle;
  final ValueChanged<LibraryGroupMode>? onTogglePin;

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
    final favoriteModes = widget.availableModes
        .where(_pinnedModes.contains)
        .toList(growable: false);
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
                if (widget.hasSidebarVisibilityToggle)
                  _buildActionItem(
                    context,
                    icon: widget.sidebarVisible
                        ? Icons.folder_off_outlined
                        : Icons.folder_open_outlined,
                    label:
                        widget.sidebarVisible ? 'No folders' : 'Show folders',
                    onTap: () => Navigator.of(context).pop(
                      LibraryGroupModeMenuAction.toggleSidebar,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Manage Favorites',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      Icon(
                        Icons.settings_outlined,
                        size: 16,
                        color: libraryToolbarMenuMutedText(context),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
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
        if (expanded)
          for (final mode in modes) _buildModeItem(context, mode),
      ],
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

  Widget _buildModeItem(BuildContext context, LibraryGroupMode mode) {
    final isPinned = _pinnedModes.contains(mode);
    final isSelected = mode == widget.selectedMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      child: LibraryWorkspaceMenuRow(
        label: genericGroupModeLabel(mode, widget.type),
        leadingWidth: 16,
        leading: isSelected
            ? Icon(
                Icons.check,
                size: 16,
                color: libraryToolbarMenuText(context),
              )
            : null,
        trailing: widget.onTogglePin == null
            ? null
            : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    if (!isPinned) {
                      _pinnedModes.add(mode);
                      _expandedSections['Favorites'] = true;
                    } else {
                      _pinnedModes.remove(mode);
                      if (_pinnedModes.isEmpty) {
                        _expandedSections.remove('Favorites');
                      }
                    }
                  });
                  widget.onTogglePin!(mode);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    size: 15,
                    color: isPinned
                        ? libraryToolbarMenuText(context)
                        : libraryToolbarMenuMutedText(context),
                  ),
                ),
              ),
        onTap: () => Navigator.of(context).pop(mode),
        padding: const EdgeInsets.fromLTRB(24, 8, 8, 8),
        textStyle: TextStyle(
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          color: libraryToolbarMenuText(context),
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