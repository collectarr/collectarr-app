import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibrarySeriesBucket {
  const LibrarySeriesBucket({
    required this.title,
    required this.count,
    this.coverUrl,
    this.startYear,
    this.ownedCount,
    this.missingNumbers = const <int>[],
  });

  final String title;
  final int count;
  final String? coverUrl;
  final int? startYear;
  final int? ownedCount;
  final List<int> missingNumbers;

  int? get completionPercent {
    final owned = ownedCount;
    if (owned == null || count <= 0) {
      return null;
    }
    final percent = ((owned / count) * 100).round();
    if (percent < 0) {
      return 0;
    }
    if (percent > 100) {
      return 100;
    }
    return percent;
  }
}

class LibrarySeriesSidebar extends ConsumerStatefulWidget {
  const LibrarySeriesSidebar({
    super.key,
    required this.series,
    required this.selectedSeries,
    required this.onSelectSeries,
    this.title = 'Series',
    this.icon = Icons.folder,
    this.trailing,
    this.headerOverride,
    this.backgroundColor = kAppPanel,
    this.headerColor = kAppSurface,
    this.dividerColor = kAppDivider,
    this.accentColor = kAppAccent,
    this.selectionColor = kAppSelection,
    this.badgeColor = kAppBadgeBackground,
    this.selectedBadgeColor = kAppHighlight,
    this.mutedTextColor = kAppTextMuted,
    this.searchPlaceholder = 'Find folders',
    this.collectionStatusScope = LibraryCollectionStatusScope.all,
    this.onCollectionStatusScopeChanged,
  });

  final List<LibrarySeriesBucket> series;
  final String? selectedSeries;
  final ValueChanged<String> onSelectSeries;
  final String title;
  final IconData icon;
  final Widget? trailing;
  final Widget? headerOverride;
  final Color backgroundColor;
  final Color headerColor;
  final Color dividerColor;
  final Color accentColor;
  final Color selectionColor;
  final Color badgeColor;
  final Color selectedBadgeColor;
  final Color mutedTextColor;
  final String searchPlaceholder;
  final LibraryCollectionStatusScope collectionStatusScope;
  final ValueChanged<LibraryCollectionStatusScope>? onCollectionStatusScopeChanged;

  @override
  ConsumerState<LibrarySeriesSidebar> createState() => _LibrarySeriesSidebarState();
}

enum _SidebarSortMode { alphabetical, byCount }

class _LibrarySeriesSidebarState extends ConsumerState<LibrarySeriesSidebar> {
  final _searchController = TextEditingController();
  var _sortMode = _SidebarSortMode.alphabetical;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LibrarySeriesBucket> get _filteredSorted {
    final query = _searchController.text.trim().toLowerCase();
    var items = widget.series.where((b) {
      if (query.isEmpty) return true;
      return b.title.toLowerCase().contains(query);
    }).toList();
    switch (_sortMode) {
      case _SidebarSortMode.alphabetical:
        // Keep original order (already alphabetical from projection).
        break;
      case _SidebarSortMode.byCount:
        items.sort((a, b) => b.count.compareTo(a.count));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final filtered = _filteredSorted;
    final resolvedBackgroundColor = widget.backgroundColor == kAppPanel
      ? palette.panel
      : widget.backgroundColor;
    final resolvedHeaderColor = widget.headerColor == kAppSurface
      ? palette.surface
      : widget.headerColor;
    final resolvedDividerColor = widget.dividerColor == kAppDivider
      ? palette.divider
      : widget.dividerColor;
    final resolvedSelectionColor = widget.selectionColor == kAppSelection
      ? palette.selection
      : widget.selectionColor;
    final resolvedBadgeColor = widget.badgeColor == kAppBadgeBackground
      ? palette.badgeBackground
      : widget.badgeColor;
    final resolvedMutedTextColor = widget.mutedTextColor == kAppTextMuted
      ? palette.textMuted
      : widget.mutedTextColor;
    return DecoratedBox(
      decoration: BoxDecoration(color: resolvedBackgroundColor),
      child: Column(
        children: [
          widget.headerOverride ??
              Container(
                height: 34,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: resolvedHeaderColor,
                  border:
                      Border(bottom: BorderSide(color: resolvedDividerColor)),
                ),
                child: Row(
                  children: [
                    Icon(widget.icon, size: 18, color: widget.accentColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    if (widget.trailing != null) widget.trailing!,
                  ],
                ),
              ),
          _SidebarSearchAndSort(
            controller: _searchController,
            sortMode: _sortMode,
            searchPlaceholder: widget.searchPlaceholder,
            accentColor: widget.accentColor,
            dividerColor: resolvedDividerColor,
            mutedTextColor: resolvedMutedTextColor,
            collectionStatusScope: widget.collectionStatusScope,
            onCollectionStatusScopeChanged: widget.onCollectionStatusScopeChanged,
            onChanged: () => setState(() {}),
            onToggleSort: () => setState(() {
              _sortMode = _sortMode == _SidebarSortMode.alphabetical
                  ? _SidebarSortMode.byCount
                  : _SidebarSortMode.alphabetical;
            }),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final bucket = filtered[index];
                final selected = bucket.title == widget.selectedSeries;
                final rowPadding = ref.watch(
                  uiPreferencesProvider.select((p) => p.sidebarRowPadding),
                );
                return _LibrarySeriesRow(
                  bucket: bucket,
                  selected: selected,
                  onTap: () => widget.onSelectSeries(bucket.title),
                  dividerColor: resolvedDividerColor,
                  selectionColor: resolvedSelectionColor,
                  selectedBadgeColor: widget.selectedBadgeColor,
                  badgeColor: resolvedBadgeColor,
                  mutedTextColor: resolvedMutedTextColor,
                  extraVerticalPadding: rowPadding.clamp(1.0, 3.0),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarSearchAndSort extends StatelessWidget {
  const _SidebarSearchAndSort({
    required this.controller,
    required this.sortMode,
    required this.searchPlaceholder,
    required this.accentColor,
    required this.dividerColor,
    required this.mutedTextColor,
    required this.collectionStatusScope,
    required this.onCollectionStatusScopeChanged,
    required this.onChanged,
    required this.onToggleSort,
  });

  final TextEditingController controller;
  final _SidebarSortMode sortMode;
  final String searchPlaceholder;
  final Color accentColor;
  final Color dividerColor;
  final Color mutedTextColor;
  final LibraryCollectionStatusScope collectionStatusScope;
  final ValueChanged<LibraryCollectionStatusScope>? onCollectionStatusScopeChanged;
  final VoidCallback onChanged;
  final VoidCallback onToggleSort;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 28,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: dividerColor),
              ),
              child: TextField(
                controller: controller,
                onChanged: (_) => onChanged(),
                style: const TextStyle(fontSize: 11),
                decoration: InputDecoration(
                  hintText: searchPlaceholder,
                  hintStyle: TextStyle(fontSize: 11, color: mutedTextColor),
                  prefixIcon: Icon(Icons.search, size: 14, color: mutedTextColor),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 24, maxHeight: 22),
                  suffixIcon: controller.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            controller.clear();
                            onChanged();
                          },
                          child:
                              Icon(Icons.close, size: 14, color: mutedTextColor),
                        )
                      : null,
                  suffixIconConstraints:
                      const BoxConstraints(minWidth: 20, maxHeight: 22),
                  contentPadding: const EdgeInsets.only(bottom: 12),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ),
          if (onCollectionStatusScopeChanged != null) ...[
            const SizedBox(width: 6),
            _SidebarStatusScopeButton(
              accentColor: accentColor,
              mutedTextColor: mutedTextColor,
              scope: collectionStatusScope,
              onSelected: onCollectionStatusScopeChanged!,
            ),
          ],
          const SizedBox(width: 6),
          _SidebarSortSwitch(
            sortMode: sortMode,
            accentColor: accentColor,
            dividerColor: dividerColor,
            mutedTextColor: mutedTextColor,
            onTap: onToggleSort,
          ),
        ],
      ),
    );
  }
}

class _SidebarStatusScopeButton extends StatelessWidget {
  const _SidebarStatusScopeButton({
    required this.scope,
    required this.accentColor,
    required this.mutedTextColor,
    required this.onSelected,
  });

  final LibraryCollectionStatusScope scope;
  final Color accentColor;
  final Color mutedTextColor;
  final ValueChanged<LibraryCollectionStatusScope> onSelected;

  @override
  Widget build(BuildContext context) {
    final borderColor = scope == LibraryCollectionStatusScope.all
        ? mutedTextColor.withValues(alpha: 0.5)
        : accentColor.withValues(alpha: 0.9);
    final iconColor = scope == LibraryCollectionStatusScope.all
        ? mutedTextColor
        : accentColor;
    return PopupMenuButton<LibraryCollectionStatusScope>(
      tooltip: 'Filter completed series',
      initialValue: scope,
      onSelected: onSelected,
      position: PopupMenuPosition.under,
      padding: EdgeInsets.zero,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.checklist_outlined, size: 16, color: iconColor),
      ),
      itemBuilder: (context) => [
        for (final value in LibraryCollectionStatusScope.values)
          PopupMenuItem<LibraryCollectionStatusScope>(
            value: value,
            child: Row(
              children: [
                Icon(
                  value == scope ? Icons.check : Icons.remove,
                  size: 16,
                  color: value == scope ? accentColor : Colors.transparent,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(value.label)),
              ],
            ),
          ),
      ],
    );
  }
}

class _SidebarSortSwitch extends StatelessWidget {
  const _SidebarSortSwitch({
    required this.sortMode,
    required this.accentColor,
    required this.dividerColor,
    required this.mutedTextColor,
    required this.onTap,
  });

  final _SidebarSortMode sortMode;
  final Color accentColor;
  final Color dividerColor;
  final Color mutedTextColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final alphabeticalSelected = sortMode == _SidebarSortMode.alphabetical;
    return Tooltip(
      message: alphabeticalSelected ? 'Sort by count' : 'Sort alphabetically',
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
        child: Container(
          width: 54,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: dividerColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: _SidebarSortModeIcon(
                  icon: Icons.sort_by_alpha,
                  selected: alphabeticalSelected,
                  accentColor: accentColor,
                  mutedTextColor: mutedTextColor,
                ),
              ),
              Container(width: 1, color: dividerColor),
              Expanded(
                child: _SidebarSortModeIcon(
                  icon: Icons.format_list_numbered,
                  selected: !alphabeticalSelected,
                  accentColor: accentColor,
                  mutedTextColor: mutedTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarSortModeIcon extends StatelessWidget {
  const _SidebarSortModeIcon({
    required this.icon,
    required this.selected,
    required this.accentColor,
    required this.mutedTextColor,
  });

  final IconData icon;
  final bool selected;
  final Color accentColor;
  final Color mutedTextColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? accentColor.withValues(alpha: 0.18) : Colors.transparent,
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 15,
        color: selected ? accentColor : mutedTextColor,
      ),
    );
  }
}

class _LibrarySeriesRow extends StatefulWidget {
  const _LibrarySeriesRow({
    required this.bucket,
    required this.selected,
    required this.onTap,
    required this.dividerColor,
    required this.selectionColor,
    required this.selectedBadgeColor,
    required this.badgeColor,
    required this.mutedTextColor,
    this.extraVerticalPadding = 4.0,
  });

  final LibrarySeriesBucket bucket;
  final bool selected;
  final VoidCallback onTap;
  final Color dividerColor;
  final Color selectionColor;
  final Color selectedBadgeColor;
  final Color badgeColor;
  final Color mutedTextColor;
  final double extraVerticalPadding;

  @override
  State<_LibrarySeriesRow> createState() => _LibrarySeriesRowState();
}

class _LibrarySeriesRowState extends State<_LibrarySeriesRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final selectedTextColor = ThemeData.estimateBrightnessForColor(
              widget.selectionColor,
            ) ==
            Brightness.dark
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    final selectedBadgeTextColor = ThemeData.estimateBrightnessForColor(
              widget.selectedBadgeColor,
            ) ==
            Brightness.dark
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    final badgeTextColor = ThemeData.estimateBrightnessForColor(widget.badgeColor) ==
        Brightness.dark
      ? Colors.white
      : Theme.of(context).colorScheme.onSurface;
    final gapTooltip = widget.bucket.missingNumbers.isNotEmpty
        ? 'Missing: ${_formatMissingNumbers(widget.bucket.missingNumbers)}'
        : null;
    final activeIndicatorColor = widget.selected
      ? widget.selectedBadgeColor
      : widget.selectedBadgeColor.withValues(alpha: 0.9);
    final bgColor = widget.selected
        ? widget.selectionColor
        : _hovered
        ? widget.selectionColor.withValues(alpha: 0.28)
            : Colors.transparent;
    Widget row = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              left: BorderSide(
                color: widget.selected || _hovered
                    ? activeIndicatorColor
                    : Colors.transparent,
                width: 2,
              ),
              bottom: BorderSide(color: widget.dividerColor),
            ),
          ),
          child: SizedBox(
            height: 28 + widget.extraVerticalPadding * 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 4, right: 6),
              child: Row(
                children: [
                  Icon(
                    widget.selected
                        ? Icons.folder_open_outlined
                        : Icons.folder_outlined,
                    size: 16,
                    color: widget.selected ? widget.selectedBadgeColor : widget.mutedTextColor,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.bucket.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: widget.selected ? selectedTextColor : null,
                            fontWeight:
                                widget.selected ? FontWeight.w800 : FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    constraints: const BoxConstraints(minWidth: 26),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.selected ? widget.selectedBadgeColor : widget.badgeColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      widget.bucket.count.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: widget.selected
                                ? selectedBadgeTextColor
                                : badgeTextColor,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (gapTooltip != null) {
      row = Tooltip(
        message: gapTooltip,
        waitDuration: const Duration(milliseconds: 400),
        child: row,
      );
    }
    return row;
  }
}

String libraryBucketLabel(LibrarySeriesBucket bucket) {
  final completionPercent = bucket.completionPercent;
  if (completionPercent == null) {
    return '${bucket.title} ${bucket.count}';
  }
  return '${bucket.title} ${bucket.count} ($completionPercent%)';
}

/// Formats a list of missing issue numbers into compact ranges.
/// Example: [1,2,3,5,8,9] → "#1–3, #5, #8–9"
String _formatMissingNumbers(List<int> numbers) {
  if (numbers.isEmpty) return '';
  final sorted = numbers.toList()..sort();
  final parts = <String>[];
  var start = sorted.first;
  var end = start;
  for (var i = 1; i < sorted.length; i++) {
    if (sorted[i] == end + 1) {
      end = sorted[i];
    } else {
      parts.add(start == end ? '#$start' : '#$start–#$end');
      start = sorted[i];
      end = start;
    }
  }
  parts.add(start == end ? '#$start' : '#$start–#$end');
  if (parts.length > 10) {
    return '${parts.take(10).join(', ')} … +${parts.length - 10} more';
  }
  return parts.join(', ');
}
