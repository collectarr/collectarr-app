import 'package:collectarr_app/features/settings/ui_preferences.dart';
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
                height: 42,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (widget.trailing != null) widget.trailing!,
                  ],
                ),
              ),
          _SidebarSearchAndSort(
            controller: _searchController,
            sortMode: _sortMode,
            dividerColor: resolvedDividerColor,
            mutedTextColor: resolvedMutedTextColor,
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
                  selectionColor: resolvedSelectionColor,
                  selectedBadgeColor: widget.selectedBadgeColor,
                  badgeColor: resolvedBadgeColor,
                  mutedTextColor: resolvedMutedTextColor,
                  extraVerticalPadding: rowPadding,
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
    required this.dividerColor,
    required this.mutedTextColor,
    required this.onChanged,
    required this.onToggleSort,
  });

  final TextEditingController controller;
  final _SidebarSortMode sortMode;
  final Color dividerColor;
  final Color mutedTextColor;
  final VoidCallback onChanged;
  final VoidCallback onToggleSort;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 26,
              child: TextField(
                controller: controller,
                onChanged: (_) => onChanged(),
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Filter…',
                  hintStyle: TextStyle(fontSize: 12, color: mutedTextColor),
                  prefixIcon: Icon(Icons.search, size: 14, color: mutedTextColor),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 28, maxHeight: 26),
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
                      const BoxConstraints(minWidth: 24, maxHeight: 26),
                  contentPadding: const EdgeInsets.only(bottom: 10),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 2),
          Tooltip(
            message: sortMode == _SidebarSortMode.alphabetical
                ? 'Sort by count'
                : 'Sort alphabetically',
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: onToggleSort,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Icon(
                  sortMode == _SidebarSortMode.alphabetical
                      ? Icons.sort_by_alpha
                      : Icons.tag,
                  size: 16,
                  color: mutedTextColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LibrarySeriesRow extends StatelessWidget {
  const _LibrarySeriesRow({
    required this.bucket,
    required this.selected,
    required this.onTap,
    required this.selectionColor,
    required this.selectedBadgeColor,
    required this.badgeColor,
    required this.mutedTextColor,
    this.extraVerticalPadding = 4.0,
  });

  final LibrarySeriesBucket bucket;
  final bool selected;
  final VoidCallback onTap;
  final Color selectionColor;
  final Color selectedBadgeColor;
  final Color badgeColor;
  final Color mutedTextColor;
  final double extraVerticalPadding;

  @override
  Widget build(BuildContext context) {
    final selectedTextColor = ThemeData.estimateBrightnessForColor(
              selectionColor,
            ) ==
            Brightness.dark
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    final selectedBadgeTextColor = ThemeData.estimateBrightnessForColor(
              selectedBadgeColor,
            ) ==
            Brightness.dark
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    final badgeTextColor = ThemeData.estimateBrightnessForColor(badgeColor) ==
        Brightness.dark
      ? Colors.white
      : Theme.of(context).colorScheme.onSurface;
    final gapTooltip = bucket.missingNumbers.isNotEmpty
        ? 'Missing: ${_formatMissingNumbers(bucket.missingNumbers)}'
        : null;
    Widget row = Material(
      color: selected ? selectionColor : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: selectionColor.withValues(alpha: 0.35),
        child: SizedBox(
          height: 34 + extraVerticalPadding * 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 18,
                  decoration: BoxDecoration(
                    color: selected ? selectedBadgeColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bucket.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: selected ? selectedTextColor : null,
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w500,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                Badge(
                  label: Text(bucket.count.toString()),
                  backgroundColor: selected ? selectedBadgeColor : badgeColor,
                  textColor: selected ? selectedBadgeTextColor : badgeTextColor,
                ),
              ],
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
