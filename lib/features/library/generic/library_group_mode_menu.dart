import 'package:collectarr_app/core/models/catalog_item.dart';
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

Future<List<LibraryFolderPreset>?> showLibraryFolderFavoritesDialog({
  required BuildContext context,
  required LibraryTypeConfig type,
  required List<LibraryGroupMode> availableModes,
  List<LibraryFolderPreset> initialFavorites = const [],
}) {
  return showDialog<List<LibraryFolderPreset>>(
    context: context,
    builder: (dialogContext) => _GroupModeFavoritesDialog(
      type: type,
      availableModes: availableModes,
      initialFavorites: initialFavorites,
    ),
  );
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
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            constraints: const BoxConstraints(minHeight: 30),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.folder_open_outlined, size: 16, color: accent),
                const SizedBox(width: 6),
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
                const SizedBox(width: 2),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: accent,
                ),
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
        final updated = await showLibraryFolderFavoritesDialog(
          context: context,
          type: type,
          availableModes: modes,
          initialFavorites: value.favoritePresets,
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
    _categories = _categorizeGroupModes(widget.type, widget.availableModes);
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

List<_GroupModeCategory> _categorizeGroupModes(
  LibraryTypeConfig type,
  List<LibraryGroupMode> modes,
) {
  if (type.workspace.kind == CatalogMediaKind.comic) {
    const mainModes = {
      LibraryGroupMode.series,
      LibraryGroupMode.ageRating,
      LibraryGroupMode.country,
      LibraryGroupMode.crossover,
      LibraryGroupMode.genre,
      LibraryGroupMode.imprint,
      LibraryGroupMode.language,
      LibraryGroupMode.publisher,
      LibraryGroupMode.releaseDate,
      LibraryGroupMode.releaseMonth,
      LibraryGroupMode.releaseYear,
      LibraryGroupMode.seriesGroup,
      LibraryGroupMode.storyArc,
    };
    const valueModes = {
      LibraryGroupMode.grade,
      LibraryGroupMode.condition,
      LibraryGroupMode.isKeyComic,
      LibraryGroupMode.rawOrSlabbed,
      LibraryGroupMode.myRating,
      LibraryGroupMode.purchaseDate,
      LibraryGroupMode.purchaseMonth,
      LibraryGroupMode.purchaseYear,
      LibraryGroupMode.purchaseStore,
      LibraryGroupMode.owner,
    };
    const editionModes = {
      LibraryGroupMode.coverDate,
      LibraryGroupMode.coverMonth,
      LibraryGroupMode.coverYear,
      LibraryGroupMode.format,
    };
    const creatorsAndCharactersModes = {
      LibraryGroupMode.creator,
      LibraryGroupMode.artist,
      LibraryGroupMode.character,
      LibraryGroupMode.colorist,
      LibraryGroupMode.coverArtist,
      LibraryGroupMode.coverColorist,
      LibraryGroupMode.coverInker,
      LibraryGroupMode.coverPainter,
      LibraryGroupMode.coverPenciller,
      LibraryGroupMode.coverSeparator,
      LibraryGroupMode.editor,
      LibraryGroupMode.editorInChief,
      LibraryGroupMode.inker,
      LibraryGroupMode.layouts,
      LibraryGroupMode.letterer,
      LibraryGroupMode.painter,
      LibraryGroupMode.penciller,
      LibraryGroupMode.plotter,
      LibraryGroupMode.scripter,
      LibraryGroupMode.separator,
      LibraryGroupMode.translator,
      LibraryGroupMode.writer,
    };
    final main = modes.where(mainModes.contains).toList();
    final value = modes.where(valueModes.contains).toList();
    final edition = modes.where(editionModes.contains).toList();
    final creatorsAndCharacters = modes
        .where(creatorsAndCharactersModes.contains)
        .toList();
    final personal = modes
        .where((mode) =>
            !mainModes.contains(mode) &&
            !valueModes.contains(mode) &&
            !editionModes.contains(mode) &&
            !creatorsAndCharactersModes.contains(mode))
        .toList();
    return [
      if (main.isNotEmpty) _GroupModeCategory('Main', main),
      if (value.isNotEmpty) _GroupModeCategory('Value', value),
      if (edition.isNotEmpty) _GroupModeCategory('Edition', edition),
      if (creatorsAndCharacters.isNotEmpty)
        _GroupModeCategory('Creators & Characters', creatorsAndCharacters),
      if (personal.isNotEmpty) _GroupModeCategory('Personal', personal),
    ];
  }
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
  var _isCreatingFavorite = false;
  late List<LibraryGroupMode> _draftModes;
  late final TextEditingController _fieldSearchController;
  late Map<String, bool> _expandedEditorSections;
  var _fieldSearch = '';

  @override
  void initState() {
    super.initState();
    _favoritePresets = [
      for (final preset in widget.initialFavorites)
        if (preset.modes.every(widget.availableModes.contains)) preset,
    ];
    _fieldSearchController = TextEditingController();
    _draftModes = const [];
    _expandedEditorSections = {
      for (final category in _categorizeGroupModes(widget.type, widget.availableModes))
        category.label: category.label == 'Main',
    };
  }

  @override
  void dispose() {
    _fieldSearchController.dispose();
    super.dispose();
  }

  bool get _isEditorVisible =>
      _isCreatingFavorite || _editingIndex != null || _draftModes.isNotEmpty;

  bool get _hasDraft => _draftModes.isNotEmpty;

  String get _draftTitle {
    if (_isCreatingFavorite) {
      return 'Select one or more fields';
    }
    return 'Edit folder favorite';
  }

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
      _isCreatingFavorite = true;
      _editingIndex = null;
      _draftModes = [];
      _fieldSearch = '';
      _fieldSearchController.clear();
    });
  }

  void _startEditFavorite(int index) {
    setState(() {
      _isCreatingFavorite = false;
      _editingIndex = index;
      _draftModes = List<LibraryGroupMode>.from(_favoritePresets[index].modes);
      _fieldSearch = '';
      _fieldSearchController.clear();
    });
  }

  void _cancelEditor() {
    setState(() {
      _isCreatingFavorite = false;
      _editingIndex = null;
      _draftModes = [];
      _fieldSearch = '';
      _fieldSearchController.clear();
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

  void _toggleEditorSection(String label) {
    setState(() {
      _expandedEditorSections[label] = !(_expandedEditorSections[label] ?? true);
    });
  }

  void _toggleCategoryModes(_GroupModeCategory category) {
    final visibleModes = [
      for (final mode in category.modes)
        if (_matchesFieldSearch(mode)) mode,
    ];
    if (visibleModes.isEmpty) {
      return;
    }
    final allSelected = visibleModes.every(_draftModes.contains);
    setState(() {
      if (allSelected) {
        _draftModes.removeWhere(visibleModes.contains);
        return;
      }
      for (final mode in visibleModes) {
        if (_draftModes.contains(mode)) {
          continue;
        }
        if (_draftModes.length >= 3) {
          break;
        }
        _draftModes = [..._draftModes, mode];
      }
    });
  }

  bool _matchesFieldSearch(LibraryGroupMode mode) {
    final query = _fieldSearch.trim().toLowerCase();
    if (query.isEmpty) {
      return true;
    }
    return genericGroupModeLabel(mode, widget.type).toLowerCase().contains(query) ||
        genericGroupModeSidebarTitle(mode, widget.type)
            .toLowerCase()
            .contains(query);
  }

  _FolderGroupSelectionState _selectionStateForCategory(
    _GroupModeCategory category,
  ) {
    final visibleModes = [
      for (final mode in category.modes)
        if (_matchesFieldSearch(mode)) mode,
    ];
    if (visibleModes.isEmpty) {
      return _FolderGroupSelectionState.none;
    }
    final selectedCount = visibleModes.where(_draftModes.contains).length;
    if (selectedCount == 0) {
      return _FolderGroupSelectionState.none;
    }
    if (selectedCount == visibleModes.length) {
      return _FolderGroupSelectionState.all;
    }
    return _FolderGroupSelectionState.partial;
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
      _isCreatingFavorite = false;
      _editingIndex = null;
      _draftModes = [];
      _fieldSearch = '';
      _fieldSearchController.clear();
    });
  }

  List<_GroupModeCategory> get _filteredCategories {
    final query = _fieldSearch.trim().toLowerCase();
    final categories = _categorizeGroupModes(widget.type, widget.availableModes);
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
    final panelColor = libraryToolbarMenuSurface(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      clipBehavior: Clip.antiAlias,
      shape: libraryToolbarDropdownMenuShape(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth.clamp(920.0, 1320.0);
          final maxHeight = constraints.maxHeight.clamp(620.0, 980.0);
          return SizedBox(
            width: maxWidth,
            height: maxHeight,
            child: ColoredBox(
              color: panelColor,
              child: Column(
                children: [
                  Container(
                    color: libraryToolbarControlSurface(context),
                    padding: const EdgeInsets.fromLTRB(18, 12, 10, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Manage Folder Favorites',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(
                              List<LibraryFolderPreset>.from(_favoritePresets),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: libraryToolbarMenuMutedText(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: libraryToolbarMenuBorder(context)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: 350,
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
                                    padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Folder Favorites',
                                            style: theme.textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 34,
                                          height: 34,
                                          child: FilledButton(
                                            key: const ValueKey('folderFavoritesAddButton'),
                                            onPressed: _startAddFavorite,
                                            style: FilledButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              shape: const RoundedRectangleBorder(),
                                              minimumSize: const Size.square(34),
                                            ),
                                            child: const Icon(Icons.add, size: 16),
                                          ),
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
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 36,
                                                      child: Center(
                                                        child: ReorderableDragStartListener(
                                                          index: index,
                                                          child: Icon(
                                                            Icons.drag_indicator,
                                                            size: 18,
                                                            color: libraryToolbarMenuMutedText(context),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 24,
                                                      child: Center(
                                                        child: Container(
                                                          width: 8,
                                                          height: 8,
                                                          decoration: BoxDecoration(
                                                            color: isEditing
                                                                ? theme.colorScheme.primary
                                                                : Colors.transparent,
                                                            shape: BoxShape.circle,
                                                            border: Border.all(
                                                              color: libraryToolbarMenuBorder(context),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                        child: Text(
                                                          genericFolderPresetLabel(preset, widget.type),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: theme.textTheme.bodyMedium?.copyWith(
                                                            fontWeight: FontWeight.w700,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          OutlinedButton.icon(
                                                            onPressed: () => _startEditFavorite(index),
                                                            icon: const Icon(Icons.edit_outlined, size: 14),
                                                            label: const Text('Edit'),
                                                            style: OutlinedButton.styleFrom(
                                                              visualDensity: VisualDensity.compact,
                                                              padding: const EdgeInsets.symmetric(
                                                                horizontal: 9,
                                                                vertical: 7,
                                                              ),
                                                              shape: const RoundedRectangleBorder(),
                                                              minimumSize: const Size(0, 30),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          FilledButton.tonal(
                                                            onPressed: () {
                                                              setState(() {
                                                                _favoritePresets.removeAt(index);
                                                                if (_editingIndex == index) {
                                                                  _isCreatingFavorite = false;
                                                                  _editingIndex = null;
                                                                  _draftModes = [];
                                                                  _fieldSearch = '';
                                                                  _fieldSearchController.clear();
                                                                } else if (_editingIndex != null &&
                                                                    index < _editingIndex!) {
                                                                  _editingIndex = _editingIndex! - 1;
                                                                }
                                                              });
                                                            },
                                                            style: FilledButton.styleFrom(
                                                              backgroundColor: theme.colorScheme.errorContainer,
                                                              foregroundColor: theme.colorScheme.onErrorContainer,
                                                              visualDensity: VisualDensity.compact,
                                                              padding: const EdgeInsets.symmetric(
                                                                horizontal: 9,
                                                                vertical: 7,
                                                              ),
                                                              shape: const RoundedRectangleBorder(),
                                                              minimumSize: const Size(30, 30),
                                                            ),
                                                            child: const Icon(Icons.delete_outline, size: 16),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: libraryToolbarMenuBorder(context),
                                ),
                              ),
                              child: _isEditorVisible
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _draftTitle,
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: libraryToolbarMenuMutedText(context),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Select one or more fields',
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                                          child: TextField(
                                            controller: _fieldSearchController,
                                            onChanged: (value) => setState(() => _fieldSearch = value),
                                            decoration: InputDecoration(
                                              isDense: true,
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 10,
                                              ),
                                              prefixIcon: const Icon(Icons.search, size: 18),
                                              suffixIcon: _fieldSearch.isEmpty
                                                  ? null
                                                  : IconButton(
                                                      tooltip: 'Clear search',
                                                      onPressed: () {
                                                        _fieldSearchController.clear();
                                                        setState(() => _fieldSearch = '');
                                                      },
                                                      icon: const Icon(Icons.cancel, size: 18),
                                                    ),
                                              hintText: 'Search fields',
                                              border: const OutlineInputBorder(),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child: DecoratedBox(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: libraryToolbarMenuBorder(context),
                                                      ),
                                                    ),
                                                    child: ListView(
                                                      padding: EdgeInsets.zero,
                                                      children: [
                                                        for (final category in _filteredCategories)
                                                          _buildEditorCategorySection(
                                                            context,
                                                            category,
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
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
                                                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                                                          child: Text(
                                                            'Selected Fields',
                                                            style: theme.textTheme.titleSmall?.copyWith(
                                                              fontWeight: FontWeight.w800,
                                                            ),
                                                          ),
                                                        ),
                                                        Divider(
                                                          height: 1,
                                                          color: libraryToolbarMenuBorder(context),
                                                        ),
                                                        Expanded(
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
                                                                      child: Row(
                                                                        children: [
                                                                          SizedBox(
                                                                            width: 34,
                                                                            child: Center(
                                                                              child: ReorderableDragStartListener(
                                                                                index: index,
                                                                                child: Icon(
                                                                                  Icons.drag_indicator,
                                                                                  size: 18,
                                                                                  color: libraryToolbarMenuMutedText(context),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                                                              child: Text(
                                                                                genericGroupModeLabel(mode, widget.type),
                                                                                maxLines: 2,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          IconButton(
                                                                            tooltip: 'Remove field',
                                                                            onPressed: () => _toggleDraftMode(mode),
                                                                            visualDensity: VisualDensity.compact,
                                                                            icon: const Icon(Icons.close, size: 16),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
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
                                        if (_hasDuplicateDraft)
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                                            child: Text(
                                              'This folder favorite already exists.',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.error,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                      ],
                                    )
                                  : Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(28),
                                        child: Text(
                                          'Select a favorite to edit it, or press + to create a new folder preset.',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: libraryToolbarMenuMutedText(context),
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 1, color: libraryToolbarMenuBorder(context)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          key: const ValueKey('folderFavoritesManagerSaveButton'),
                          onPressed: () => Navigator.of(context).pop(
                            List<LibraryFolderPreset>.from(_favoritePresets),
                          ),
                          child: const Text('Close'),
                        ),
                        if (_isEditorVisible) ...[
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: _cancelEditor,
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            key: const ValueKey('folderFavoritesDraftSaveButton'),
                            onPressed:
                                _hasDraft && !_hasDuplicateDraft ? _saveDraft : null,
                            style: FilledButton.styleFrom(
                              shape: const RoundedRectangleBorder(),
                            ),
                            child: const Text('Save'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditorCategorySection(
    BuildContext context,
    _GroupModeCategory category,
  ) {
    final expanded = _expandedEditorSections[category.label] ?? true;
    final selectionState = _selectionStateForCategory(category);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => _toggleEditorSection(category.label),
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: BoxDecoration(
              color: libraryToolbarControlSurface(context),
              border: Border(
                bottom: BorderSide(color: libraryToolbarMenuBorder(context)),
              ),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => _toggleCategoryModes(category),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      switch (selectionState) {
                        _FolderGroupSelectionState.all => Icons.check_box,
                        _FolderGroupSelectionState.partial => Icons.indeterminate_check_box,
                        _FolderGroupSelectionState.none => Icons.check_box_outline_blank,
                      },
                      size: 18,
                      color: selectionState == _FolderGroupSelectionState.none
                          ? libraryToolbarMenuMutedText(context)
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    category.label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: libraryToolbarMenuMutedText(context),
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          for (final mode in category.modes)
            if (_matchesFieldSearch(mode))
              InkWell(
                onTap: () => _toggleDraftMode(mode),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
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
                        child: Text(genericGroupModeLabel(mode, widget.type)),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }
}

enum _FolderGroupSelectionState { none, partial, all }