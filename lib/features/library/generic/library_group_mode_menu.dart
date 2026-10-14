import 'package:collectarr_app/ui/app_icons.dart';
import 'dart:async';

import 'package:collectarr_app/features/library/ui/primitives/library_field_selection.dart';

import 'package:collectarr_app/features/library/config/library_group_mode_category.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/library_folder_reorder_row.dart';
import 'package:collectarr_app/features/library/generic/library_folder_reorder_list.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_controls.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_menus.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_chrome.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum LibraryGroupModeMenuAction { disableFolders }

class _ManageFavoritesRequest {
  const _ManageFavoritesRequest(this.favoritePresets);

  final List<LibraryFolderPreset> favoritePresets;
}

Future<List<LibraryFolderPreset>?> showLibraryFolderFavoritesDialog({
  required BuildContext context,
  required LibraryKindRegistration type,
  required List<String> availableModes,
  List<LibraryFolderPreset> initialFavorites = const [],
}) {
  return showDialog<List<LibraryFolderPreset>>(
    context: context,
    builder: (dialogContext) => Theme(
      data: libraryAccentTheme(context, type.identity.accent),
      child: _GroupModeFavoritesDialog(
        type: type,
        availableModes: availableModes,
        initialFavorites: initialFavorites,
      ),
    ),
  );
}

class LibraryGroupModeMenuButton extends StatefulWidget {
  const LibraryGroupModeMenuButton({
    super.key,
    required this.type,
    required this.folderPreset,
    required this.accent,
    required this.icon,
    required this.onChanged,
    this.sidebarVisible = true,
    this.onSidebarVisibilityChanged,
    this.onClearBucket,
    this.pinnedFolderPresets = const [],
    this.onPinnedPresetsChanged,
    this.iconOnly = false,
    this.availableModes,
  });

  final LibraryKindRegistration type;
  final LibraryFolderPreset? folderPreset;
  final Color accent;
  final IconData icon;
  final ValueChanged<LibraryFolderPreset> onChanged;
  final bool sidebarVisible;
  final ValueChanged<bool>? onSidebarVisibilityChanged;
  final VoidCallback? onClearBucket;
  final List<LibraryFolderPreset> pinnedFolderPresets;
  final ValueChanged<List<LibraryFolderPreset>>? onPinnedPresetsChanged;
  final bool iconOnly;
  final List<String>? availableModes;

  @override
  State<LibraryGroupModeMenuButton> createState() =>
      _LibraryGroupModeMenuButtonState();
}

class _LibraryGroupModeMenuButtonState
    extends State<LibraryGroupModeMenuButton> {
  final _menuController = OverlayPortalController();
  bool get _menuOpen => _menuController.isShowing;

  void _closeGroupModeMenu() => _menuController.hide();

  void _handleMenuSelection(Object? value, List<String> modes) async {
    _closeGroupModeMenu();
    if (value is LibraryFolderPreset) {
      widget.onChanged(value);
      if (!widget.sidebarVisible && widget.onSidebarVisibilityChanged != null) {
        widget.onSidebarVisibilityChanged!(true);
      }
    } else if (value is _ManageFavoritesRequest) {
      if (!mounted) {
        return;
      }
      final updated = await showLibraryFolderFavoritesDialog(
        context: context,
        type: widget.type,
        availableModes: modes,
        initialFavorites: value.favoritePresets,
      );
      if (updated != null && mounted) {
        widget.onPinnedPresetsChanged?.call(updated);
      }
    } else if (value == LibraryGroupModeMenuAction.disableFolders &&
        widget.onSidebarVisibilityChanged != null) {
      widget.onClearBucket?.call();
      widget.onSidebarVisibilityChanged!(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The sidebar header can temporarily allocate only a few pixels to
        // the flexible group control while its fixed action buttons are
        // being laid out. The trigger is not usable at that size, and its
        // fixed icons must not participate in layout until space is restored.
        if (!widget.iconOnly && constraints.maxWidth < 64) {
          return const SizedBox.shrink();
        }

        final label = widget.folderPreset == null
            ? 'Group By'
            : genericFolderPresetLabel(widget.folderPreset!, widget.type);
        final triggerColor = libraryToolbarMenuText(context);
        final child = widget.iconOnly
            ? LibraryToolbarCompactDropdownTrigger(icon: widget.icon)
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                constraints: const BoxConstraints(minHeight: 30),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppIcons.folderOpen,
                      size: 14,
                      color: triggerColor,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: triggerColor,
                            ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      AppIcons.chevronDown,
                      size: 14,
                      color: triggerColor,
                    ),
                  ],
                ),
              );

        return Tooltip(
          message: 'Group By',
          child: OverlayPortal.overlayChildLayoutBuilder(
            controller: _menuController,
            overlayLocation: OverlayChildLocation.rootOverlay,
            overlayChildBuilder: _buildGroupModeMenu,
            child: InkWell(
              mouseCursor: WidgetStateMouseCursor.clickable,
              onTap: () {
                if (_menuOpen) {
                  _closeGroupModeMenu();
                } else {
                  _menuController.show();
                }
              },
              borderRadius: BorderRadius.circular(5),
              hoverColor: libraryToolbarControlHover(context),
              child: LibraryToolbarHoverSurface(child: child),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupModeMenu(
      BuildContext context, OverlayChildLayoutInfo info) {
    final label = widget.folderPreset == null
        ? 'Group By'
        : genericFolderPresetLabel(widget.folderPreset!, widget.type);
    final modes =
        widget.availableModes ?? libraryGroupModesForType(widget.type);
    final menuWidth = _resolveMenuWidth(context);
    final target = MatrixUtils.transformRect(
        info.childPaintTransform, Offset.zero & info.childSize);
    final left = target.left.clamp(0.0,
        (info.overlaySize.width - menuWidth - 8).clamp(0.0, double.infinity));
    return Stack(children: [
      Positioned.fill(
          child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeGroupModeMenu)),
      Positioned(
          left: left,
          top: target.bottom,
          width: menuWidth,
          child: LibraryGroupModeDropdownMenu(
            type: widget.type,
            selectedPreset: widget.folderPreset,
            availableModes: modes,
            initialPinnedPresets: widget.pinnedFolderPresets,
            onPinnedPresetsChanged: widget.onPinnedPresetsChanged,
            sidebarVisible: widget.sidebarVisible,
            hasSidebarVisibilityToggle:
                widget.onSidebarVisibilityChanged != null,
            triggerLabel: label,
            triggerIcon: widget.icon,
            onSelected: (value) => _handleMenuSelection(value, modes),
          )),
    ]);
  }

  double _resolveMenuWidth(BuildContext context) =>
      350.0.clamp(0.0, MediaQuery.sizeOf(context).width - 16);
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
    this.triggerLabel,
    this.triggerIcon,
    this.onSelected,
  });

  final LibraryKindRegistration type;
  final LibraryFolderPreset? selectedPreset;
  final List<String> availableModes;
  final List<LibraryFolderPreset> initialPinnedPresets;
  final bool sidebarVisible;
  final bool hasSidebarVisibilityToggle;
  final ValueChanged<List<LibraryFolderPreset>>? onPinnedPresetsChanged;
  final String? triggerLabel;
  final IconData? triggerIcon;
  final ValueChanged<Object?>? onSelected;

  @override
  State<LibraryGroupModeDropdownMenu> createState() =>
      _LibraryGroupModeDropdownMenuState();
}

class _LibraryGroupModeDropdownMenuState
    extends State<LibraryGroupModeDropdownMenu> {
  late List<LibraryFolderPreset> _pinnedPresets;
  late Map<String, bool> _expandedSections;
  late List<LibraryGroupModeCategory> _categories;

  void _emitSelection(Object? value) {
    final onSelected = widget.onSelected;
    if (onSelected != null) {
      onSelected(value);
      return;
    }
    Navigator.of(context).pop(value);
  }

  bool _isModeMatching(String m1, String m2) {
    final fields = libraryKindWorkspaceForKind(widget.type.kind).fields;
    return fields.decodeGroupId(m1).sameIdentityAs(fields.decodeGroupId(m2));
  }

  bool _isPresetMatching(LibraryFolderPreset p1, LibraryFolderPreset p2) {
    if (p1.modes.length != p2.modes.length) return false;
    for (var i = 0; i < p1.modes.length; i++) {
      if (!_isModeMatching(p1.modes[i], p2.modes[i])) return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _pinnedPresets =
        List<LibraryFolderPreset>.from(widget.initialPinnedPresets);
    _categories = libraryGroupModeCategories(
      widget.type,
      widget.availableModes,
    );
    _expandedSections = {
      for (final category in _categories)
        category.label: category.modes.any(
          (mode) =>
              (widget.selectedPreset != null &&
                  widget.selectedPreset!.modes.length == 1 &&
                  _isModeMatching(
                      widget.selectedPreset!.primaryMode, mode.toString())) ||
              _pinnedPresets.any((p) =>
                  p.modes.length == 1 &&
                  _isModeMatching(p.primaryMode, mode.toString())),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final favoritePresets = [
      for (final preset in _pinnedPresets)
        if (preset.modes.every((m) =>
            widget.availableModes.contains(m) ||
            libraryKindWorkspaceForKind(widget.type.kind)
                    .fields
                    .findGroupDefinition(
                      libraryKindWorkspaceForKind(widget.type.kind)
                          .fields
                          .decodeGroupId(m),
                    ) !=
                null))
          preset,
    ];
    return LibraryWorkspaceMenuPanel(
      child: Material(
        color: libraryToolbarMenuSurface(context),
        surfaceTintColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 470),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.hasSidebarVisibilityToggle && widget.sidebarVisible)
                  _buildActionItem(
                    context,
                    label: 'No folders',
                    onTap: () => _emitSelection(
                      LibraryGroupModeMenuAction.disableFolders,
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
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        key: const ValueKey('manageGroupFavoritesButton'),
                        tooltip: 'Manage folder favorites',
                        onPressed: widget.onPinnedPresetsChanged == null
                            ? null
                            : () => _emitSelection(
                                  _ManageFavoritesRequest(
                                    List<LibraryFolderPreset>.from(
                                      _pinnedPresets,
                                    ),
                                  ),
                                ),
                        icon: const Icon(AppIcons.settings, size: 18),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        alignment: Alignment.centerRight,
                      ),
                    ],
                  ),
                ),
                const LibraryWorkspaceMenuSectionDivider(
                  label: 'Favorites',
                  leadingInset: 0,
                  leadingLineWidth: 24,
                ),
                if (favoritePresets.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(26, 2, 12, 10),
                    child: Text(
                      'No favorites',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: libraryToolbarMenuMutedText(context),
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(26, 0, 6, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final preset in favoritePresets)
                          _buildPresetItem(
                            context,
                            preset,
                          ),
                      ],
                    ),
                  ),
                const LibraryWorkspaceMenuSectionDivider(
                  label: 'Folders',
                  leadingInset: 0,
                  leadingLineWidth: 24,
                ),
                for (final category in _categories)
                  _buildSection(
                    context,
                    label: category.label,
                    modes: category.modes.cast<String>(),
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
    List<String> modes = const [],
    List<LibraryFolderPreset> presets = const [],
  }) {
    final expanded = _expandedSections[label] ?? false;
    final selectedSingleMode = widget.selectedPreset != null &&
            widget.selectedPreset!.modes.length == 1
        ? widget.selectedPreset!.primaryMode
        : null;
    final hasSelectedMode = modes.any((m) =>
            selectedSingleMode != null &&
            _isModeMatching(m, selectedSingleMode)) ||
        presets.any((p) =>
            widget.selectedPreset != null &&
            _isPresetMatching(p, widget.selectedPreset!));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LibraryWorkspaceMenuTreeHeader(
            label: label,
            expanded: expanded,
            highlighted: hasSelectedMode,
            leading: SizedBox(
                width: 12,
                child: hasSelectedMode
                    ? const Icon(AppIcons.check, size: 13, color: Colors.white)
                    : null),
            onTap: () {
              setState(() {
                _expandedSections[label] = !expanded;
              });
            },
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      key: ValueKey('groupModeSectionLevelBar_$label'),
                      width: 20,
                      margin: EdgeInsets.zero,
                      color: libraryToolbarMenuBorder(context)
                          .withValues(alpha: hasSelectedMode ? 0.85 : 0.65),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 6, 6, 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final mode in modes)
                              _buildModeItem(context, mode),
                            for (final preset in presets)
                              _buildPresetItem(context, preset),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    IconData? icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: LibraryWorkspaceMenuRow(
        label: label,
        leading: icon == null
            ? null
            : Icon(
                icon,
                size: 16,
                color: libraryToolbarMenuMutedText(context),
              ),
        onTap: onTap,
        textStyle: TextStyle(
          color: libraryToolbarMenuText(context),
          fontWeight: FontWeight.w700,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      ),
    );
  }

  Widget _buildModeItem(BuildContext context, String mode) {
    final isSelected = widget.selectedPreset != null &&
        widget.selectedPreset!.modes.length == 1 &&
        _isModeMatching(widget.selectedPreset!.primaryMode, mode);
    final selectedBackground = _selectedRowBackground(context, isSelected);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: LibraryWorkspaceMenuRow(
        key: ValueKey('groupModeItemRow_$mode'),
        label: genericGroupModeFolderSetLabel(mode, widget.type),
        leadingWidth: 16,
        leadingSpacing: 6,
        leading: isSelected
            ? const Icon(AppIcons.check, size: 13, color: Colors.white)
            : null,
        onTap: () => _emitSelection(LibraryFolderPreset.single(mode)),
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
        backgroundColor: selectedBackground,
        textStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: libraryToolbarMenuText(context),
        ),
      ),
    );
  }

  Widget _buildPresetItem(BuildContext context, LibraryFolderPreset preset) {
    final isSelected = preset == widget.selectedPreset;
    final keySuffix = preset.storageValue.replaceAll('>', '_');
    final selectedBackground = _selectedRowBackground(context, isSelected);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: LibraryWorkspaceMenuRow(
        key: ValueKey('groupPresetItemRow_$keySuffix'),
        label: genericFolderPresetLabel(preset, widget.type),
        leadingWidth: 16,
        leadingSpacing: 6,
        leading: isSelected
            ? const Icon(AppIcons.check, size: 13, color: Colors.white)
            : null,
        onTap: () => _emitSelection(preset),
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
        backgroundColor: selectedBackground,
        textStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: libraryToolbarMenuText(context),
        ),
      ),
    );
  }

  Color _selectedRowBackground(BuildContext context, bool selected) {
    if (!selected) {
      return Colors.transparent;
    }
    final palette = appPalette(context);
    return Color.alphaBlend(
      palette.textPrimary.withValues(alpha: palette.isDark ? 0.27 : 0.10),
      libraryToolbarMenuSurface(context),
    );
  }
}

class _GroupModeFavoritesDialog extends StatefulWidget {
  const _GroupModeFavoritesDialog({
    required this.type,
    required this.availableModes,
    required this.initialFavorites,
  });

  final LibraryKindRegistration type;
  final List<String> availableModes;
  final List<LibraryFolderPreset> initialFavorites;

  @override
  State<_GroupModeFavoritesDialog> createState() =>
      _GroupModeFavoritesDialogState();
}

class _GroupModeFavoritesDialogState extends State<_GroupModeFavoritesDialog> {
  late final List<LibraryFolderPreset> _favoritePresets;
  int? _editingIndex;
  var _isCreatingFavorite = false;
  late List<String> _draftModes;
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
      for (final category in libraryGroupModeCategories(
        widget.type,
        widget.availableModes,
      ))
        category.label: true,
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

  String get _draftTitle => _draftModes.isEmpty
      ? 'Select fields'
      : genericFolderPresetLabel(
          LibraryFolderPreset(modes: _draftModes), widget.type);

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
      _draftModes = List<String>.from(_favoritePresets[index].modes);
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

  void _toggleDraftMode(String mode) {
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
      _expandedEditorSections[label] =
          !(_expandedEditorSections[label] ?? true);
    });
  }

  bool _matchesFieldSearch(String mode) {
    final query = _fieldSearch.trim().toLowerCase();
    if (query.isEmpty) {
      return true;
    }
    return genericGroupModeLabel(mode, widget.type)
            .toLowerCase()
            .contains(query) ||
        genericGroupModeSidebarTitle(mode, widget.type)
            .toLowerCase()
            .contains(query);
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

  List<LibraryGroupModeCategory> get _filteredCategories {
    final query = _fieldSearch.trim().toLowerCase();
    final categories = libraryGroupModeCategories(
      widget.type,
      widget.availableModes,
    );
    if (query.isEmpty) {
      return categories;
    }
    return [
      for (final category in categories)
        LibraryGroupModeCategory(
          category.label,
          [
            for (final mode in category.modes.cast<String>())
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

  void _close() => Navigator.of(context).pop(
        List<LibraryFolderPreset>.from(_favoritePresets),
      );

  Color _insetColor(BuildContext context) => appPalette(context).isDark
      ? const Color(0xff1d1d1d)
      : appPalette(context).panel;

  Color _fieldColor(BuildContext context) => appPalette(context).isDark
      ? const Color(0xff444444)
      : libraryToolbarControlSurface(context);

  Color _fieldBorder(BuildContext context) => appPalette(context).isDark
      ? const Color(0xff666666)
      : libraryToolbarMenuBorder(context);

  static TextStyle get _headingStyle => TextStyle(
        fontFamily: appFontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 26 / 18,
      );
  static TextStyle get _fieldStyle => TextStyle(
        fontFamily: appFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1,
      );

  @override
  Widget build(BuildContext context) {
    final availableHeight = MediaQuery.sizeOf(context).height - 60;
    final listHeight =
        (167.0 + _favoritePresets.length * 49).clamp(200.0, double.infinity);
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      backgroundColor: pickListSurface(context),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: SizedBox(
        width: 600,
        height: (_isEditorVisible ? availableHeight : listHeight)
            .clamp(0.0, availableHeight.clamp(0.0, double.infinity)),
        child: DefaultTextStyle.merge(
          style: _fieldStyle.copyWith(color: appPalette(context).textPrimary),
          child: Column(children: [
            PickListHeader(
              icon: AppIcons.folderOpen,
              title: 'Manage Folder Favorites',
              onClose: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: _isEditorVisible
                  ? _buildEditor(context)
                  : _buildFavorites(context),
            ),
            _buildFooter(context),
          ]),
        ),
      ),
    );
  }

  Widget _buildFavorites(BuildContext context) => ColoredBox(
        color: _insetColor(context),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(children: [
                Expanded(
                  child: Text('Folder Favorites', style: _headingStyle),
                ),
                Tooltip(
                  message: 'Add folder favorite',
                  child: FilledButton(
                    key: const ValueKey('folderFavoritesAddButton'),
                    onPressed: _startAddFavorite,
                    style: pickListButtonStyle(context),
                    child: const Icon(Icons.add, size: 16),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: _favoritePresets.isEmpty
                  ? Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        child: Text('No folder favorites yet.',
                            style: _fieldStyle.copyWith(
                                color: libraryToolbarMenuMutedText(context))),
                      ),
                    )
                  : LibraryFolderReorderList(
                      padding: EdgeInsets.zero,
                      placeholderColor: const Color(0xff808080),
                      rowSpacing: 5,
                      itemCount: _favoritePresets.length,
                      onReorder: (oldIndex, newIndex) => setState(() {
                        final preset = _favoritePresets.removeAt(oldIndex);
                        _favoritePresets.insert(newIndex, preset);
                      }),
                      itemBuilder: (context, index) =>
                          _buildFavorite(context, index),
                    ),
            ),
          ]),
        ),
      );

  Widget _buildFavorite(BuildContext context, int index) {
    final preset = _favoritePresets[index];
    return LibraryFolderReorderRow(
      color: _fieldColor(context),
      hoverColor: _fieldColor(context),
      borderColor: _fieldBorder(context),
      minHeight: 44,
      padding: const EdgeInsets.all(5),
      bottomSpacing: 5,
      child: Row(children: [
        Padding(
          padding: const EdgeInsets.only(right: 5),
          child: Icon(AppIcons.menu,
              size: 16, color: libraryToolbarMenuMutedText(context)),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(genericFolderPresetLabel(preset, widget.type)),
          ),
        ),
        FilledButton.icon(
          onPressed: () => _startEditFavorite(index),
          style: pickListButtonStyle(context, primary: false).copyWith(
            textStyle: const WidgetStatePropertyAll(
                TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
          ),
          icon: const Icon(AppIcons.inlineEdit, size: 14),
          label: const Text('Edit'),
        ),
        const SizedBox(width: 5),
        Tooltip(
          message: 'Delete favorite',
          child: FilledButton(
            onPressed: () => setState(() => _favoritePresets.removeAt(index)),
            style: pickListButtonStyle(context).copyWith(
              backgroundColor: const WidgetStatePropertyAll(Color(0xffd9534f)),
              foregroundColor: const WidgetStatePropertyAll(Colors.white),
              minimumSize: const WidgetStatePropertyAll(Size(28, 32)),
              fixedSize: const WidgetStatePropertyAll(Size(28, 32)),
              padding: const WidgetStatePropertyAll(EdgeInsets.zero),
            ),
            child: const Icon(AppIcons.removeAction, size: 14),
          ),
        ),
      ]),
    );
  }

  Widget _buildEditor(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(_draftTitle, style: _headingStyle),
          const SizedBox(height: 15),
          Expanded(child: LayoutBuilder(builder: (context, constraints) {
            // Keep both lists usable on narrow windows.
            if (constraints.maxWidth < 380) {
              return Column(children: [
                Expanded(child: _buildAvailableFields(context)),
                const SizedBox(height: 10),
                SizedBox(height: 120, child: _buildSelectedFields(context)),
              ]);
            }
            return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: _buildAvailableFields(context),
                  )),
                  Expanded(child: _buildSelectedFields(context)),
                ]);
          })),
          if (_hasDuplicateDraft) ...[
            const SizedBox(height: 10),
            Text('This folder favorite already exists.',
                style: _fieldStyle.copyWith(
                    color: Theme.of(context).colorScheme.error)),
          ],
        ]),
      );

  Widget _buildAvailableFields(BuildContext context) => Column(children: [
        LibraryFieldSelectionSearch(
            key: const ValueKey('folderFavoritesFieldSearch'),
            controller: _fieldSearchController,
            onChanged: (value) => setState(() => _fieldSearch = value)),
        const SizedBox(height: 10),
        Expanded(
            child: ListView(children: [
          for (final category in _filteredCategories)
            _buildEditorCategorySection(context, category),
        ])),
      ]);

  Widget _buildSelectedFields(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: _insetColor(context),
          borderRadius: BorderRadius.circular(4),
        ),
        child: _draftModes.isEmpty
            ? Center(
                child: Text(
                  'Select one or more fields',
                  style: _fieldStyle.copyWith(
                      color: libraryToolbarMenuMutedText(context)),
                ),
              )
            : LibraryFolderReorderList(
                padding: const EdgeInsets.all(10),
                placeholderColor: const Color(0xff808080),
                itemCount: _draftModes.length,
                onReorder: (oldIndex, newIndex) => setState(() {
                  final mode = _draftModes.removeAt(oldIndex);
                  _draftModes.insert(newIndex, mode);
                }),
                itemBuilder: (context, index) {
                  final mode = _draftModes[index];
                  return LibraryFolderReorderRow(
                    selectedField: true,
                    height: 28,
                    color: _fieldColor(context),
                    hoverColor: _fieldColor(context),
                    borderColor: _fieldBorder(context),
                    child: Row(children: [
                      const SizedBox(
                          width: 26, child: Icon(Icons.menu, size: 16)),
                      Expanded(
                          child: Text(genericGroupModeLabel(mode, widget.type),
                              maxLines: 1, overflow: TextOverflow.ellipsis)),
                      IconButton(
                        tooltip: 'Remove field',
                        onPressed: () => _toggleDraftMode(mode),
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          overlayColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          surfaceTintColor: Colors.transparent,
                          side: BorderSide.none,
                          elevation: 0,
                          minimumSize: const Size(28, 26),
                          maximumSize: const Size(28, 26),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ).copyWith(
                          foregroundColor: WidgetStateProperty.resolveWith(
                              (states) => states.contains(WidgetState.hovered)
                                  ? Theme.of(context).colorScheme.error
                                  : appPalette(context).textPrimary),
                        ),
                        icon: const Icon(Icons.close, size: 16),
                      ),
                    ]),
                  );
                },
              ),
      );

  Widget _buildEditorCategorySection(
          BuildContext context, LibraryGroupModeCategory category) =>
      LibraryFieldSelectionCategory(
          title: category.label,
          expanded: _fieldSearch.isNotEmpty ||
              (_expandedEditorSections[category.label] ?? true),
          onToggle: () => _toggleEditorSection(category.label),
          children: [
            for (final mode in category.modes.cast<String>())
              if (_matchesFieldSearch(mode))
                LibraryFieldSelectionCheckbox(
                    label: genericGroupModeLabel(mode, widget.type),
                    selected: _draftModes.contains(mode),
                    onTap: _draftModes.contains(mode) || _draftModes.length < 3
                        ? () => _toggleDraftMode(mode)
                        : null),
          ]);

  Widget _buildFooter(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: appPalette(context).isDark
              ? const Color(0xff383838)
              : libraryToolbarControlSurface(context),
          border: Border(top: BorderSide(color: pickListDivider(context))),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          FilledButton(
            onPressed: _isEditorVisible
                ? _cancelEditor
                : () => Navigator.of(context).pop(),
            style: pickListButtonStyle(context, primary: false, footer: true),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 5),
          FilledButton(
            key: ValueKey(_isEditorVisible
                ? 'folderFavoritesDraftSaveButton'
                : 'folderFavoritesManagerSaveButton'),
            onPressed: _isEditorVisible
                ? (_hasDraft && !_hasDuplicateDraft ? _saveDraft : null)
                : _close,
            style: pickListButtonStyle(context, footer: true),
            child: const Text('Save'),
          ),
        ]),
      );
}
