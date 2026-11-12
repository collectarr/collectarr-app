import 'dart:math' as math;
import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/ui/app_bottom_sheet.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/adaptive/mobile_page.dart';
import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:collectarr_app/features/library/generic/sort_preset_store.dart';
import 'package:collectarr_app/features/library/generic/sort_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/ui/primitives/collection_status_icon.dart';
import 'dart:collection';

import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/chrome/chrome.dart';
import 'package:collectarr_app/features/library/workspace/config/config.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/generic/folder_reorder_list.dart';
import 'package:collectarr_app/features/library/generic/folder_reorder_row.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_chrome.dart';
import 'package:flutter/material.dart';

const libraryManageSortFavoritesMenuValue = 'manage_sort_favorites';

Future<Set<String>?> showSortFavoritesManagerDialog({
  required BuildContext context,
  required LibraryKindRegistration type,
  required List<LibrarySortFavorite> favorites,
  required Set<String> initialPinnedIds,
  String? activeFavoriteId,
}) async {
  if (favorites.isEmpty) {
    favorites = [
      for (final preset in await LibrarySortPresetStore(type).read())
        LibrarySortFavorite(
            id: preset.id!,
            label: preset.label,
            icon: AppIcons.sortAlpha,
            rules: preset.rules),
    ];
  }
  if (!context.mounted) return null;
  return showAppPageOrDialog<Set<String>>(
    context: context,
    builder: (context) => _SortFavoritesManagerDialog(
      type: type,
      favorites: favorites,
      initialPinnedIds: initialPinnedIds,
      activeFavoriteId: activeFavoriteId,
    ),
  );
}

class LibraryCollectionStatusScopeDropdown extends StatefulWidget {
  const LibraryCollectionStatusScopeDropdown({
    super.key,
    required this.collectionStatusScope,
    required this.onCollectionStatusScopeChanged,
  });

  final LibraryCollectionStatusScope collectionStatusScope;
  final ValueChanged<LibraryCollectionStatusScope>
      onCollectionStatusScopeChanged;

  @override
  State<LibraryCollectionStatusScopeDropdown> createState() =>
      _LibraryCollectionStatusScopeDropdownState();
}

class _LibraryCollectionStatusScopeDropdownState
    extends State<LibraryCollectionStatusScopeDropdown> {
  bool _hovered = false;
  bool _open = false;

  void _setOpen(bool value) {
    if (mounted && _open != value) setState(() => _open = value);
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final accent = Theme.of(context).colorScheme.primary;
    final filtered =
        widget.collectionStatusScope != LibraryCollectionStatusScope.all;
    final menuText = libraryToolbarMenuText(context);
    final menuMuted = libraryToolbarMenuMutedText(context);
    final dropdownTextStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: palette.textPrimary,
        );
    final menuWidth = measureLibraryToolbarDropdownWidth(
      context,
      labels: LibraryCollectionStatusScope.values.map((scope) => scope.label),
      textStyle: dropdownTextStyle?.copyWith(
          fontSize: 14, fontWeight: FontWeight.w500),
      leadingWidth: 20,
      leadingSpacing: 6,
      trailingWidth: 0,
      horizontalPadding: 16,
      minWidth: 160,
    );
    final triggerWidth = measureLibraryToolbarDropdownWidth(
      context,
      labels: [widget.collectionStatusScope.label],
      textStyle: dropdownTextStyle,
      leadingWidth: 20,
      leadingSpacing: 4,
      trailingWidth: 14,
      horizontalPadding: 10,
      minWidth: 0,
    );
    return SizedBox(
      width: triggerWidth,
      child: PopupMenuButton<LibraryCollectionStatusScope>(
        popUpAnimationStyle: AnimationStyle.noAnimation,
        key: const Key('collection-status-scope-dropdown'),
        tooltip: 'Collection status scope',
        onOpened: () => _setOpen(true),
        onCanceled: () => _setOpen(false),
        onSelected: (scope) {
          _setOpen(false);
          widget.onCollectionStatusScopeChanged(scope);
        },
        padding: EdgeInsets.zero,
        menuPadding: EdgeInsets.zero,
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
            LibraryToolbarMenuItem<LibraryCollectionStatusScope>(
              value: scope,
              height: 26,
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: LibraryCollectionStatusScopeMenuItem(
                  scope: scope,
                  accent: accent,
                  textColor: menuText,
                  muted: menuMuted,
                  isSelected: widget.collectionStatusScope == scope),
            ),
        ],
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: DecoratedBox(
            // An active status filter is outlined in the shared blue, as in
            // the reference, so a narrowed list is visible at a glance; the
            // trigger stays lit while its menu is open.
            decoration: BoxDecoration(
                color: _open || _hovered
                    ? libraryToolbarControlHover(context)
                    : filtered
                        ? const Color(0xFF464950)
                        : Colors.transparent,
                borderRadius: filtered || _open
                    ? BorderRadius.circular(5)
                    : kLibraryToolbarHoverRadius,
                border: filtered
                    ? Border.all(color: palette.utilityAction, width: 2)
                    : null),
            child: SizedBox(
              height: kLibraryToolbarTextDropdownHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  children: [
                    LibraryCollectionStatusScopeBadge(
                      scope: widget.collectionStatusScope,
                      accent: accent,
                      muted: palette.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.collectionStatusScope.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: dropdownTextStyle,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      AppIcons.chevronDown,
                      size: 12,
                      color: palette.textPrimary,
                    ),
                  ],
                ),
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
    this.iconOnly = false,
    this.fieldLabel,
  });

  final VoidCallback onPressed;
  final List<LibrarySortFavorite> sortFavorites;
  final String? activeSortFavoriteId;
  final Set<String> pinnedSortFavoriteIds;
  final ValueChanged<LibrarySortFavorite>? onSortFavoriteSelected;
  final VoidCallback? onManageFavoritesPressed;
  final bool iconOnly;
  final String Function(String id)? fieldLabel;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final pinnedFavorites = _orderedPinnedSortFavorites(
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
    final menuTextStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        );
    double labelWidth(String label) => measureLibraryToolbarDropdownWidth(
          context,
          labels: [label],
          textStyle: menuTextStyle,
          leadingWidth: 0,
          leadingSpacing: 0,
          trailingWidth: 0,
          horizontalPadding: 0,
          minWidth: 0,
        );
    var measuredMenuWidth = labelWidth('Manage Favorites') +
        kLibraryToolbarMenuActionExtent +
        kLibraryToolbarMenuMarkSpacing * 2;
    for (final favorite in pinnedFavorites) {
      final contentWidth = fieldLabel == null
          ? labelWidth(favorite.label)
          : favorite.rules.fold<double>(
                0,
                (width, rule) =>
                    width + labelWidth(fieldLabel!(rule.column)) + 19,
              ) +
              (favorite.rules.length - 1).clamp(0, double.infinity) *
                  (labelWidth('|') + 12);
      final width = 14 +
          kLibraryToolbarMenuMarkWidth +
          kLibraryToolbarMenuMarkSpacing +
          contentWidth;
      if (width > measuredMenuWidth) measuredMenuWidth = width;
    }
    final menuWidth = measuredMenuWidth.ceilToDouble().clamp(
        180.0, (MediaQuery.sizeOf(context).width - 16).clamp(180.0, 900.0));
    final changeSortingButton = Tooltip(
      message: 'Change Sorting',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          mouseCursor: WidgetStateMouseCursor.clickable,
          onTap: onPressed,
          hoverColor: libraryToolbarControlHover(context),
          borderRadius: kLibraryToolbarHoverRadius,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: iconOnly ? 7 : 10, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(AppIcons.sortAlpha, size: 16),
                if (!iconOnly) ...[
                  const SizedBox(width: 7),
                  Text(
                    activeFavorite?.label ?? 'Sort By',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(color: libraryToolbarControlSurface(context)),
      child: PopupMenuButton<Object>(
        key: const ValueKey('library-sort-split-button-menu'),
        popUpAnimationStyle: AnimationStyle.noAnimation,
        tooltip: 'Sorting Favorites',
        padding: EdgeInsets.zero,
        color: libraryToolbarMenuSurface(context),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.22),
        menuPadding: EdgeInsets.zero,
        constraints: BoxConstraints(minWidth: menuWidth, maxWidth: menuWidth),
        position: PopupMenuPosition.under,
        offset: const Offset(-4, 4),
        elevation: 6,
        shape: libraryToolbarDropdownMenuShape(context),
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
          LibraryToolbarMenuItem<Object>(
            value: libraryManageSortFavoritesMenuValue,
            height: kLibraryToolbarPopupItemHeight,
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: _LibraryToolbarSortMenuRow(
              onTrailingPressed: () => Navigator.of(context)
                  .pop(libraryManageSortFavoritesMenuValue),
              label: 'Manage Favorites',
              icon: null,
              trailingIcon: AppIcons.settings,
            ),
          ),
          if (pinnedFavorites.isNotEmpty)
            LibraryToolbarMenuItem<Object>(
              enabled: false,
              height: 22,
              padding: EdgeInsets.zero,
              child: const LibraryToolbarMenuSection('Favorites'),
            ),
          for (final favorite in pinnedFavorites)
            LibraryToolbarMenuItem<Object>(
              value: favorite,
              height: kLibraryToolbarPopupItemHeight,
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: _LibraryToolbarSortMenuRow(
                label: favorite.label,
                fontWeight: kLibraryToolbarMenuFavoriteFontWeight,
                icon: null,
                rules: favorite.rules,
                fieldLabel: fieldLabel,
                active: favorite.id == activeSortFavoriteId,
              ),
            ),
        ],
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          changeSortingButton,
          const LibraryToolbarHoverSurface(
            child: SizedBox(
                width: 18,
                height: 30,
                child: Center(child: Icon(AppIcons.chevronDown, size: 12))),
          ),
        ]),
      ),
    );
  }
}

class _LibraryToolbarSortMenuRow extends StatelessWidget {
  const _LibraryToolbarSortMenuRow({
    required this.label,
    required this.icon,
    this.active = false,
    this.rules = const [],
    this.fieldLabel,
    this.trailingIcon,
    this.onTrailingPressed,
    this.fontWeight = kLibraryToolbarMenuActionFontWeight,
  });

  final String label;
  final IconData? icon;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingPressed;
  final FontWeight fontWeight;
  final bool active;
  final List<LibrarySortRule> rules;
  final String Function(String id)? fieldLabel;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: kLibraryToolbarMenuFontSize,
          color: libraryToolbarMenuText(context),
          fontWeight: fontWeight,
        );
    return Row(children: [
      if (rules.isNotEmpty || active || icon != null)
        SizedBox(
            width: kLibraryToolbarMenuMarkWidth,
            child: active
                ? Icon(AppIcons.check,
                    size: 14,
                    color: palette.isDark
                        ? Colors.white
                        : libraryToolbarMenuText(context))
                : icon == null
                    ? null
                    : Icon(icon, size: 14, color: palette.textMuted)),
      if (rules.isNotEmpty || active || icon != null)
        const SizedBox(width: kLibraryToolbarMenuMarkSpacing),
      Expanded(
          child: fieldLabel == null || rules.isEmpty
              ? Text(label, style: textStyle)
              : Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                      for (var index = 0; index < rules.length; index++)
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          if (index > 0) ...[
                            Text('|', style: textStyle),
                            const SizedBox(width: 6),
                          ],
                          Text(fieldLabel!(rules[index].column),
                              style: textStyle),
                          const SizedBox(width: 3),
                          Tooltip(
                            message: rules[index].ascending
                                ? 'Ascending'
                                : 'Descending',
                            child: Icon(
                                rules[index].ascending
                                    ? AppIcons.sortAscending
                                    : AppIcons.sortDescending,
                                semanticLabel: rules[index].ascending
                                    ? 'Ascending'
                                    : 'Descending',
                                size: 16),
                          ),
                        ]),
                    ])),
      if (trailingIcon != null && onTrailingPressed != null)
        LibraryToolbarMenuIconAction(
            icon: trailingIcon!, label: label, onPressed: onTrailingPressed!),
    ]);
  }
}

class _SortFavoritesManagerDialog extends StatefulWidget {
  const _SortFavoritesManagerDialog({
    required this.type,
    required this.favorites,
    required this.initialPinnedIds,
    this.activeFavoriteId,
  });

  final LibraryKindRegistration type;
  final List<LibrarySortFavorite> favorites;
  final Set<String> initialPinnedIds;
  final String? activeFavoriteId;

  @override
  State<_SortFavoritesManagerDialog> createState() =>
      _SortFavoritesManagerDialogState();
}

class _SortFavoritesManagerDialogState
    extends State<_SortFavoritesManagerDialog> {
  late final List<LibrarySortFavorite> _favorites;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _favorites = _orderedPinnedSortFavorites(widget.favorites, {
      ...widget.initialPinnedIds,
      ...widget.favorites.map((favorite) => favorite.id)
    });
  }

  Future<void> _close() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await LibrarySortPresetStore(widget.type).saveFavorites([
        for (final favorite in _favorites)
          LibrarySortPreset(
              id: favorite.id, label: favorite.label, rules: favorite.rules),
      ]);
      if (!mounted) return;
      Navigator.of(context).pop(LinkedHashSet<String>.from(
          _favorites.map((favorite) => favorite.id)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save sorting favorites.')));
    }
  }

  Future<void> _edit([LibrarySortFavorite? favorite]) async {
    final rules = await showLibrarySortDialog(
        context: context,
        type: widget.type,
        currentRules: favorite?.rules ?? [],
        showFavorites: false);
    if (rules == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final fields =
          libraryKindWorkspaceForKind(widget.type.kind).workspaceFields;
      final label = rules
          .map((rule) =>
              fields.sortDefinitionFor(fields.decodeSortId(rule.column)).label)
          .join(' | ');
      final presets = await LibrarySortPresetStore(widget.type)
          .savePreset(id: favorite?.id, label: label, rules: rules);
      final preset = favorite == null
          ? presets.last
          : presets.firstWhere((p) => p.id == favorite.id);
      if (!mounted) return;
      final updated = LibrarySortFavorite(
          id: preset.id!,
          label: preset.label,
          icon: AppIcons.sortAlpha,
          rules: preset.rules);
      setState(() {
        final pinnedIndex = _favorites.indexWhere((f) => f.id == updated.id);
        if (pinnedIndex < 0) {
          _favorites.add(updated);
        } else {
          _favorites[pinnedIndex] = updated;
        }
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not save sorting favorite.')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _fieldLabel(String id) {
    final fields =
        libraryKindWorkspaceForKind(widget.type.kind).workspaceFields;
    return fields.sortDefinitionFor(fields.decodeSortId(id)).label;
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final isDark = palette.isDark;
    if (appPresentationPlatform.isNativeMobile) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && !_busy) _close();
        },
        child: MobilePage(
          title: 'Manage Sorting Favorites',
          onBack: _busy ? () {} : _close,
          headerColor: widget.type.identity.accent,
          backgroundColor: palette.panel,
          actions: [
            IconButton(
              tooltip: 'New sorting favorite',
              onPressed: _busy ? null : _edit,
              icon: const Icon(Icons.add),
            ),
          ],
          body: ReorderableListView.builder(
            itemCount: _favorites.length,
            onReorderItem: (oldIndex, newIndex) => setState(() {
              _favorites.insert(newIndex, _favorites.removeAt(oldIndex));
            }),
            itemBuilder: (context, index) {
              final favorite = _favorites[index];
              return ListTile(
                key: ValueKey('sortFavorite_${favorite.id}'),
                leading: ReorderableDragStartListener(
                    index: index, child: const Icon(Icons.drag_handle)),
                title: Text(favorite.label),
                subtitle: _SortFavoriteRules(
                    rules: favorite.rules, fieldLabel: _fieldLabel),
                trailing: PopupMenuButton<String>(
                  tooltip: 'Favorite actions',
                  onSelected: (action) {
                    if (action == 'edit') {
                      _edit(favorite);
                    } else if (_favorites.length > 1) {
                      setState(() => _favorites.removeAt(index));
                    }
                  },
                  itemBuilder: (_) => [
                    const LibraryToolbarMenuItem(
                        value: 'edit', child: Text('Edit')),
                    if (_favorites.length > 1)
                      const LibraryToolbarMenuItem(
                          value: 'remove', child: Text('Remove')),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }
    // The reference Sorting Favorites manager, laid out like Manage Folder
    // Favorites: a heading with the blue add button over bordered rows.
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      backgroundColor: pickListSurface(context),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: SizedBox(
        width: 600,
        // Sized to its rows: 217 px for one favorite, as in the reference.
        height: math.min(168.0 + 49 * math.max(_favorites.length, 1),
            math.max(0.0, MediaQuery.sizeOf(context).height - 60)),
        child: DefaultTextStyle.merge(
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: palette.textPrimary),
          child: Column(children: [
            PickListHeader(
                icon: AppIcons.sortAlpha,
                title: 'Manage Sorting Favorites',
                onClose: _busy ? null : _close),
            Expanded(
              child: ColoredBox(
                color: isDark ? const Color(0xff1d1d1d) : palette.panel,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Row(children: [
                            const Expanded(
                              child: Text('Sorting Favorites',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      height: 26 / 18)),
                            ),
                            Tooltip(
                              message: 'New sorting favorite',
                              child: FilledButton(
                                key: const ValueKey('sortFavoritesAddButton'),
                                onPressed: _busy ? null : _edit,
                                style: pickListButtonStyle(context),
                                child: const Icon(Icons.add, size: 16),
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 15),
                        Expanded(
                          child: LibraryFolderReorderList(
                            padding: EdgeInsets.zero,
                            placeholderColor: const Color(0xff808080),
                            rowSpacing: 5,
                            itemCount: _favorites.length,
                            onReorder: (oldIndex, newIndex) => setState(() {
                              _favorites.insert(
                                  newIndex, _favorites.removeAt(oldIndex));
                            }),
                            itemBuilder: (context, index) =>
                                _buildFavorite(context, index),
                          ),
                        ),
                      ]),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xff383838)
                    : libraryToolbarControlSurface(context),
                border:
                    Border(top: BorderSide(color: pickListDivider(context))),
              ),
              child: Row(children: [
                const Spacer(),
                FilledButton(
                  key: const ValueKey('sortFavoritesCloseButton'),
                  onPressed: _busy ? null : _close,
                  style: pickListButtonStyle(context,
                      primary: false, footer: true),
                  child: const Text('Close'),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildFavorite(BuildContext context, int index) {
    final favorite = _favorites[index];
    final isDark = appPalette(context).isDark;
    final rowColor = isDark
        ? const Color(0xff444444)
        : libraryToolbarControlSurface(context);
    return LibraryFolderReorderRow(
      key: ValueKey('sortFavorite_${favorite.id}'),
      color: rowColor,
      hoverColor: rowColor,
      borderColor:
          isDark ? const Color(0xff666666) : libraryToolbarMenuBorder(context),
      minHeight: 44,
      padding: const EdgeInsets.all(5),
      bottomSpacing: 5,
      child: Row(children: [
        Padding(
          padding: const EdgeInsets.only(right: 5),
          child: Icon(AppIcons.menu,
              size: 16, color: libraryToolbarMenuMutedText(context)),
        ),
        // The reference marks the favorite the list is sorted by.
        SizedBox(
          width: 28,
          child: favorite.id == widget.activeFavoriteId
              ? const Icon(Icons.radio_button_checked,
                  key: ValueKey('sortFavoriteActive'), size: 16)
              : null,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: _SortFavoriteRules(
                rules: favorite.rules, fieldLabel: _fieldLabel),
          ),
        ),
        FilledButton.icon(
          onPressed: _busy ? null : () => _edit(favorite),
          style: pickListButtonStyle(context, primary: false).copyWith(
            textStyle: const WidgetStatePropertyAll(
                TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
          ),
          icon: const Icon(AppIcons.inlineEdit, size: 14),
          label: const Text('Edit'),
        ),
        const SizedBox(width: 5),
        if (_favorites.length > 1)
          Tooltip(
            message: 'Remove favorite',
            child: FilledButton(
              onPressed: _busy
                  ? null
                  : () => setState(() => _favorites.removeAt(index)),
              style: pickListButtonStyle(context).copyWith(
                backgroundColor:
                    const WidgetStatePropertyAll(Color(0xffd9534f)),
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
}

/// "Platform ASC | Title ASC": bold field names with the reference's white
/// direction badges.
class _SortFavoriteRules extends StatelessWidget {
  const _SortFavoriteRules({required this.rules, required this.fieldLabel});

  final List<LibrarySortRule> rules;
  final String Function(String id) fieldLabel;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 14, fontWeight: FontWeight.w700);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final (index, rule) in rules.indexed) ...[
          if (index > 0)
            const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Text('|', style: style)),
          Text(fieldLabel(rule.column), style: style),
          Container(
            margin: const EdgeInsets.only(left: 4, right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(4)),
            child: Text(rule.ascending ? 'ASC' : 'DESC',
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    height: 13 / 10,
                    color: Color(0xff1d1d1d))),
          ),
        ],
      ],
    );
  }
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
  Widget build(BuildContext context) => Row(children: [
        LibraryCollectionStatusIcon(collectionStatus: scope),
        const SizedBox(width: 6),
        Expanded(
            child: Text(scope.label,
                style: TextStyle(
                  fontSize: 14,
                  height: 1,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ))),
      ]);
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
  Widget build(BuildContext context) =>
      LibraryCollectionStatusIcon(collectionStatus: scope);
}

Color libraryCollectionStatusScopeColor(
  LibraryCollectionStatusScope scope,
  Color accent,
  Color muted,
) {
  return switch (scope) {
    LibraryCollectionStatusScope.all => muted,
    LibraryCollectionStatusScope.inCollection => const Color(0xFF2AA4CC),
    LibraryCollectionStatusScope.forSale => const Color(0xFF2D7427),
    LibraryCollectionStatusScope.wishList => const Color(0xFFFF9B00),
    LibraryCollectionStatusScope.onOrder => const Color(0xFF13627F),
    LibraryCollectionStatusScope.sold => const Color(0xFFA63131),
    LibraryCollectionStatusScope.notInCollection => const Color(0xFF605C5C),
  };
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
  showAppBottomSheet<void>(
    context: context,
    builder: (context) => Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AccentDialogHeader(
                title: 'View & Layout',
                onClose: () => Navigator.of(context).pop()),
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
              title: const Text('Horizontal cards'),
              onTap: () {
                Navigator.of(context).pop();
                onViewModeChanged(LibraryViewMode.horizontalCards);
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_carousel),
              title: const Text('Flow carousel'),
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

class LibraryItemCountLabel extends StatelessWidget {
  const LibraryItemCountLabel({
    super.key,
    required this.shown,
    required this.total,
    required this.singularLabel,
    required this.pluralLabel,
  });

  final int shown;
  final int total;
  final String singularLabel;
  final String pluralLabel;

  @override
  Widget build(BuildContext context) {
    final noun = (total == 1 ? singularLabel : pluralLabel).toLowerCase();
    final label = shown == total ? '$total $noun' : '$shown of $total $noun';
    final palette = appPalette(context);
    return _ToolbarPill(
      color: palette.isDark ? const Color(0xFF4A4A4A) : palette.panelRaised,
      child: Text(label,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: palette.isDark ? Colors.white : palette.textPrimary)),
    );
  }
}

/// The rounded count and scope pills of the browsing toolbar.
class _ToolbarPill extends StatelessWidget {
  const _ToolbarPill({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        // Hugs its content wherever it sits, also in a row with a width limit.
        child: Center(widthFactor: 1, child: child),
      );
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
    const style = TextStyle(
        fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white);
    return _ToolbarPill(
      color: appPalette(context).utilityAction,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Text(label,
              style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 5),
        Tooltip(
          message: 'Clear',
          child: InkWell(
            onTap: onClear,
            customBorder: const CircleBorder(),
            mouseCursor: SystemMouseCursors.click,
            child: const Padding(
              padding: EdgeInsets.all(3),
              child: Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ]),
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
    final cur = currency ?? AppFormats.current.currency;
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
                fontSize: 12,
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
