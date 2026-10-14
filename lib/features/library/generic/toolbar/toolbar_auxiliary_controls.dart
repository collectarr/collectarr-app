import 'package:collectarr_app/features/library/generic/library_sort_preset_store.dart';
import 'package:collectarr_app/features/library/generic/sort_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_icon.dart';
import 'dart:collection';

import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

const libraryManageSortFavoritesMenuValue = 'manage_sort_favorites';

Future<Set<String>?> showSortFavoritesManagerDialog({
  required BuildContext context,
  required LibraryKindRegistration type,
  required List<LibrarySortFavorite> favorites,
  required Set<String> initialPinnedIds,
}) {
  return showDialog<Set<String>>(
    context: context,
    builder: (context) => _SortFavoritesManagerDialog(
      type: type,
      favorites: favorites,
      initialPinnedIds: initialPinnedIds,
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

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final accent = Theme.of(context).colorScheme.primary;
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
        onSelected: widget.onCollectionStatusScopeChanged,
        padding: EdgeInsets.zero,
        menuPadding: EdgeInsets.zero,
        position: PopupMenuPosition.under,
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF444444)
            : libraryToolbarMenuSurface(context),
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
            decoration: BoxDecoration(
                color: _hovered
                    ? libraryToolbarControlHover(context)
                    : Colors.transparent),
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
          fontWeight: FontWeight.w400,
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
    var measuredMenuWidth = labelWidth('Manage Favorites') + 14 + 14;
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
      final width = 14 + 18 + 4 + contentWidth;
      if (width > measuredMenuWidth) measuredMenuWidth = width;
    }
    final menuWidth = measuredMenuWidth.ceilToDouble().clamp(
        180.0, (MediaQuery.sizeOf(context).width - 16).clamp(180.0, 900.0));
    return DecoratedBox(
      decoration: BoxDecoration(
        color: libraryToolbarControlSurface(context),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: 'Change Sorting',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                mouseCursor: WidgetStateMouseCursor.clickable,
                onTap: onPressed,
                hoverColor: libraryToolbarControlHover(context),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(4),
                ),
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
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
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
          ),
          PopupMenuButton<Object>(
            key: const ValueKey('library-sort-split-button-menu'),
            popUpAnimationStyle: AnimationStyle.noAnimation,
            tooltip: 'Sorting Favorites',
            padding: EdgeInsets.zero,
            color: libraryToolbarMenuSurface(context),
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.black.withValues(alpha: 0.22),
            menuPadding: EdgeInsets.zero,
            constraints:
                BoxConstraints(minWidth: menuWidth, maxWidth: menuWidth),
            position: PopupMenuPosition.under,
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
              PopupMenuItem<Object>(
                value: libraryManageSortFavoritesMenuValue,
                height: kLibraryToolbarPopupItemHeight,
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: const _LibraryToolbarSortMenuRow(
                  label: 'Manage Favorites',
                  icon: null,
                  trailingIcon: AppIcons.settings,
                ),
              ),
              if (pinnedFavorites.isNotEmpty)
                PopupMenuItem<Object>(
                  enabled: false,
                  height: 22,
                  child: Text('Favorites',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: palette.isDark
                              ? const Color(0xff666666)
                              : palette.textMuted)),
                ),
              for (final favorite in pinnedFavorites)
                PopupMenuItem<Object>(
                  value: favorite,
                  height: kLibraryToolbarPopupItemHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: _LibraryToolbarSortMenuRow(
                    label: favorite.label,
                    icon: null,
                    rules: favorite.rules,
                    fieldLabel: fieldLabel,
                    active: favorite.id == activeSortFavoriteId,
                  ),
                ),
            ],
            child: const LibraryToolbarHoverSurface(
              child: SizedBox(
                  width: 18,
                  height: 30,
                  child: Center(child: Icon(AppIcons.chevronDown, size: 12))),
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
    this.rules = const [],
    this.fieldLabel,
    this.trailingIcon,
  });

  final String label;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool active;
  final List<LibrarySortRule> rules;
  final String Function(String id)? fieldLabel;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        );
    return Row(children: [
      if (rules.isNotEmpty || active || icon != null)
        SizedBox(
            width: 18,
            child: active
                ? Icon(AppIcons.check, size: 14, color: palette.accent)
                : icon == null
                    ? null
                    : Icon(icon, size: 14, color: palette.textMuted)),
      if (rules.isNotEmpty || active || icon != null) const SizedBox(width: 4),
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
      if (trailingIcon != null) Icon(trailingIcon, size: 14),
    ]);
  }
}

class _SortFavoritesManagerDialog extends StatefulWidget {
  const _SortFavoritesManagerDialog({
    required this.type,
    required this.favorites,
    required this.initialPinnedIds,
  });

  final LibraryKindRegistration type;
  final List<LibrarySortFavorite> favorites;
  final Set<String> initialPinnedIds;

  @override
  State<_SortFavoritesManagerDialog> createState() =>
      _SortFavoritesManagerDialogState();
}

class _SortFavoritesManagerDialogState
    extends State<_SortFavoritesManagerDialog> {
  late final List<LibrarySortFavorite> _allFavorites;
  late final List<LibrarySortFavorite> _pinnedFavorites;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _allFavorites = List.of(widget.favorites);
    _pinnedFavorites =
        _orderedPinnedSortFavorites(widget.favorites, widget.initialPinnedIds);
  }

  void _close() => Navigator.of(context).pop(LinkedHashSet<String>.from(
      _pinnedFavorites.map((favorite) => favorite.id)));

  Future<void> _edit([LibrarySortFavorite? favorite]) async {
    final rules = await showLibrarySortDialog(
        context: context,
        type: widget.type,
        currentRules: favorite?.rules ?? []);
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
        final allIndex = _allFavorites.indexWhere((f) => f.id == updated.id);
        if (allIndex < 0) {
          _allFavorites.add(updated);
        } else {
          _allFavorites[allIndex] = updated;
        }
        final pinnedIndex =
            _pinnedFavorites.indexWhere((f) => f.id == updated.id);
        if (pinnedIndex < 0) {
          _pinnedFavorites.add(updated);
        } else {
          _pinnedFavorites[pinnedIndex] = updated;
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

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final available = _allFavorites
        .where((f) => !_pinnedFavorites.any((p) => p.id == f.id))
        .toList();
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 640),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AccentDialogHeader(
              title: 'Manage Sorting Favorites',
              icon: AppIcons.sortAlpha,
              onClose: _busy ? null : _close),
          Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Sorting Favorites',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: palette.textPrimary)))),
          Flexible(
              child: ReorderableListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            buildDefaultDragHandles: false,
            itemCount: _pinnedFavorites.length,
            onReorderItem: (oldIndex, newIndex) => setState(() {
              _pinnedFavorites.insert(
                  newIndex, _pinnedFavorites.removeAt(oldIndex));
            }),
            itemBuilder: (context, index) {
              final favorite = _pinnedFavorites[index];
              return SizedBox(
                  key: ValueKey('sortFavorite_${favorite.id}'),
                  height: 38,
                  child: Row(children: [
                    ReorderableDragStartListener(
                        index: index,
                        enabled: !_busy,
                        child: const MouseRegion(
                            cursor: SystemMouseCursors.grab,
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(Icons.drag_indicator, size: 16)))),
                    Expanded(
                        child: _LibraryToolbarSortMenuRow(
                            label: favorite.label,
                            icon: null,
                            rules: favorite.rules,
                            fieldLabel: (id) =>
                                libraryKindWorkspaceForKind(widget.type.kind)
                                    .workspaceFields
                                    .sortDefinitionFor(
                                        libraryKindWorkspaceForKind(
                                                widget.type.kind)
                                            .workspaceFields
                                            .decodeSortId(id))
                                    .label)),
                    TextButton.icon(
                        style: TextButton.styleFrom(
                            foregroundColor: palette.textPrimary),
                        onPressed: _busy ? null : () => _edit(favorite),
                        icon: const Icon(AppIcons.inlineEdit, size: 14),
                        label: const Text('Edit')),
                    IconButton(
                        tooltip: 'Remove favorite',
                        icon: const Icon(AppIcons.delete, size: 16),
                        onPressed: _busy
                            ? null
                            : () => setState(
                                () => _pinnedFavorites.removeAt(index))),
                  ]));
            },
          )),
          if (_pinnedFavorites.isEmpty)
            const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No sorting favorites.')),
          Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: Row(children: [
                PopupMenuButton<LibrarySortFavorite>(
                  tooltip: 'Add Favorite',
                  onSelected: (favorite) =>
                      setState(() => _pinnedFavorites.add(favorite)),
                  itemBuilder: (context) => [
                    for (final favorite in available)
                      PopupMenuItem(
                          value: favorite, child: Text(favorite.label))
                  ],
                  child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Row(children: [
                        Icon(AppIcons.add, size: 14),
                        SizedBox(width: 6),
                        Text('Add Favorite'),
                        Icon(AppIcons.chevronDown, size: 12)
                      ])),
                ),
                TextButton(
                    onPressed: _busy ? null : _edit,
                    child: const Text('New Favorite')),
                const Spacer(),
                DialogActionButtons.cancel(
                    label: 'Close', onPressed: _busy ? null : _close),
              ])),
        ]),
      ),
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

class LibraryToolbarAlphabetRow extends StatelessWidget {
  const LibraryToolbarAlphabetRow(
      {super.key,
      required this.letters,
      required this.selectedLetter,
      required this.accent,
      required this.onLetterSelected});
  final Set<String> letters;
  final String? selectedLetter;
  final Color accent;
  final ValueChanged<String?> onLetterSelected;
  @override
  Widget build(BuildContext context) {
    final available =
        letters.map((letter) => letter.trim().toUpperCase()).toSet();
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
      'Z'
    ];
    void select(String value) => onLetterSelected(
        value == 'All' || value == selectedLetter ? null : value);
    final palette = appPalette(context);
    return SizedBox(
        height: 28,
        child: LayoutBuilder(builder: (context, constraints) {
          final scale = MediaQuery.textScalerOf(context).scale(12) / 12;
          if (constraints.maxWidth < 480 * scale) {
            return Align(
                alignment: Alignment.centerLeft,
                child: PopupMenuButton<String>(
                  tooltip: 'Filter A–Z',
                  onSelected: select,
                  itemBuilder: (_) => [
                    for (final label in ['All', ...alphabet])
                      PopupMenuItem(
                          value: label,
                          height: 30,
                          enabled: label == 'All' || available.contains(label),
                          child: Text(label,
                              style: TextStyle(
                                  fontWeight: label == (selectedLetter ?? 'All')
                                      ? FontWeight.w700
                                      : FontWeight.w500)))
                  ],
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.filter_alt, size: 17),
                        const SizedBox(width: 4),
                        Text(selectedLetter ?? 'A–Z',
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        const Icon(Icons.expand_more, size: 16)
                      ])),
                ));
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final label in ['All', ...alphabet])
                _AlphabetLetterButton(
                  label: label,
                  width: (label == 'All' ? 44 : 28) *
                      scale *
                      (constraints.maxWidth / (828 * scale)).clamp(0.0, 1.0),
                  isSelected: label == (selectedLetter ?? 'All'),
                  isAvailable: label == 'All' || available.contains(label),
                  accent: accent,
                  palette: palette,
                  onTap: label == 'All' || available.contains(label)
                      ? () => select(label)
                      : null,
                ),
            ],
          );
        }));
  }
}

class _AlphabetLetterButton extends StatefulWidget {
  const _AlphabetLetterButton({
    required this.label,
    required this.isSelected,
    required this.isAvailable,
    required this.accent,
    required this.palette,
    required this.onTap,
    required this.width,
  });

  final String label;
  final bool isSelected;
  final bool isAvailable;
  final Color accent;
  final AppThemePalette palette;
  final VoidCallback? onTap;
  final double width;

  @override
  State<_AlphabetLetterButton> createState() => _AlphabetLetterButtonState();
}

class _AlphabetLetterButtonState extends State<_AlphabetLetterButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final isAvailable = widget.isAvailable;
    final canTap = widget.onTap != null;

    final textColor = isSelected
        ? Colors.white
        : _hovered && isAvailable
            ? Colors.white
            : isAvailable
                ? widget.palette.textPrimary
                : widget.palette.textMuted.withValues(alpha: 0.25);

    final bgColor = isSelected
        ? (_hovered && canTap
            ? Color.lerp(widget.accent, Colors.white, 0.12)!
            : widget.accent)
        : _hovered && isAvailable
            ? (widget.palette.isDark
                ? const Color(0xFF464950)
                : widget.palette.panelRaised)
            : Colors.transparent;

    return SizedBox(
      width: widget.width,
      height: 26,
      child: MouseRegion(
        cursor: canTap ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InkWell(
          mouseCursor:
              canTap ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected || _hovered
                      ? FontWeight.w700
                      : FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
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
            AccentDialogHeader(
                title: 'View & Layout',
                icon: AppIcons.toolbarTools,
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
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
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
