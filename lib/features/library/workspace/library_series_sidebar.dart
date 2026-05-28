import 'package:cached_network_image/cached_network_image.dart';
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
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 6),
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
                      child: Icon(Icons.close, size: 14, color: mutedTextColor),
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
    final selectedTextColor =
        ThemeData.estimateBrightnessForColor(selectionColor) == Brightness.dark
            ? Colors.white
            : Theme.of(context).colorScheme.onSurface;
    final selectedMutedTextColor = selectedTextColor.withValues(alpha: 0.72);
    final selectedBadgeTextColor = ThemeData.estimateBrightnessForColor(
              selectedBadgeColor,
            ) ==
            Brightness.dark
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    final hasCover = bucket.coverUrl != null && bucket.coverUrl!.isNotEmpty;
    final owned = bucket.ownedCount;
    final total = bucket.count;
    final pct = bucket.completionPercent;
    final subtitleParts = <String>[
      if (bucket.startYear != null) bucket.startYear.toString(),
      if (owned != null) '$owned / $total owned',
      if (bucket.missingNumbers.isNotEmpty)
        '${bucket.missingNumbers.length} gaps',
    ];
    final hasSubtitle = subtitleParts.isNotEmpty;
    final gapTooltip = bucket.missingNumbers.isNotEmpty
        ? 'Missing: ${_formatMissingNumbers(bucket.missingNumbers)}'
        : null;
    Widget row = Material(
      color: selected ? selectionColor : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: selectionColor.withValues(alpha: 0.35),
        child: SizedBox(
          height: (hasSubtitle
              ? (hasCover ? 50 : 46)
              : (hasCover ? 40 : 36)) + extraVerticalPadding * 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                if (hasCover) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: SizedBox(
                      width: 22,
                      height: 28,
                      child: CachedNetworkImage(
                        imageUrl: bucket.coverUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => ColoredBox(
                          color: appPalette(context).surface,
                        ),
                        errorWidget: (_, __, ___) => ColoredBox(
                          color: appPalette(context).surface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bucket.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: selected ? selectedTextColor : mutedTextColor,
                              fontWeight:
                                  selected ? FontWeight.w800 : FontWeight.w500,
                            ),
                      ),
                      if (hasSubtitle)
                        Text(
                          subtitleParts.join(' | '),
                          maxLines: 1,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: selected
                                    ? selectedMutedTextColor
                                    : mutedTextColor.withValues(alpha: 0.6),
                                fontSize: 10,
                              ),
                        ),
                      if (pct != null) ...[                        
                        const SizedBox(height: 2),
                        _SeriesCompletionBar(
                          percent: pct,
                          selected: selected,
                          badgeColor: badgeColor,
                          selectedBadgeColor: selectedBadgeColor,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Badge(
                  label: Text(owned != null ? '$owned' : total.toString()),
                  backgroundColor: selected ? selectedBadgeColor : badgeColor,
                  textColor: selected ? selectedBadgeTextColor : Colors.white,
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

class _SeriesCompletionBar extends StatelessWidget {
  const _SeriesCompletionBar({
    required this.percent,
    required this.selected,
    required this.badgeColor,
    required this.selectedBadgeColor,
  });

  final int percent;
  final bool selected;
  final Color badgeColor;
  final Color selectedBadgeColor;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final barColor = percent >= 100
        ? const Color(0xFF4CAF50)
        : selected
            ? selectedBadgeColor
            : badgeColor;
    return SizedBox(
      height: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: percent / 100,
          backgroundColor: palette.divider,
          valueColor: AlwaysStoppedAnimation(barColor),
          minHeight: 4,
        ),
      ),
    );
  }
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
