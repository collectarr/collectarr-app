import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibrarySeriesBucket {
  const LibrarySeriesBucket({
    required this.title,
    required this.count,
    this.coverUrl,
    this.startYear,
    this.ownedCount,
  });

  final String title;
  final int count;
  final String? coverUrl;
  final int? startYear;
  final int? ownedCount;

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

class LibrarySeriesSidebar extends StatefulWidget {
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
  State<LibrarySeriesSidebar> createState() => _LibrarySeriesSidebarState();
}

enum _SidebarSortMode { alphabetical, byCount }

class _LibrarySeriesSidebarState extends State<LibrarySeriesSidebar> {
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
    final filtered = _filteredSorted;
    return DecoratedBox(
      decoration: BoxDecoration(color: widget.backgroundColor),
      child: Column(
        children: [
          widget.headerOverride ??
              Container(
                height: 42,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: widget.headerColor,
                  border:
                      Border(bottom: BorderSide(color: widget.dividerColor)),
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
            dividerColor: widget.dividerColor,
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
                return _LibrarySeriesRow(
                  bucket: bucket,
                  selected: selected,
                  onTap: () => widget.onSelectSeries(bucket.title),
                  selectionColor: widget.selectionColor,
                  selectedBadgeColor: widget.selectedBadgeColor,
                  badgeColor: widget.badgeColor,
                  mutedTextColor: widget.mutedTextColor,
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
    required this.onChanged,
    required this.onToggleSort,
  });

  final TextEditingController controller;
  final _SidebarSortMode sortMode;
  final Color dividerColor;
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
                  hintStyle:
                      const TextStyle(fontSize: 12, color: kAppTextMuted),
                  prefixIcon:
                      const Icon(Icons.search, size: 14, color: kAppTextMuted),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 28, maxHeight: 26),
                  suffixIcon: controller.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            controller.clear();
                            onChanged();
                          },
                          child: const Icon(Icons.close, size: 14,
                              color: kAppTextMuted),
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
                  color: kAppTextMuted,
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
  });

  final LibrarySeriesBucket bucket;
  final bool selected;
  final VoidCallback onTap;
  final Color selectionColor;
  final Color selectedBadgeColor;
  final Color badgeColor;
  final Color mutedTextColor;

  @override
  Widget build(BuildContext context) {
    final hasCover = bucket.coverUrl != null && bucket.coverUrl!.isNotEmpty;
    final subtitleParts = <String>[
      if (bucket.startYear != null) bucket.startYear.toString(),
      if (bucket.completionPercent != null) '${bucket.completionPercent}% complete',
    ];
    final hasSubtitle = subtitleParts.isNotEmpty;
    return Material(
      color: selected ? selectionColor : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: selectionColor.withValues(alpha: 0.35),
        child: SizedBox(
          height: hasSubtitle
              ? (hasCover ? 44 : 40)
              : (hasCover ? 40 : 36),
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
                              color: selected ? Colors.white : mutedTextColor,
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
                                    ? Colors.white70
                                    : mutedTextColor.withValues(alpha: 0.6),
                                fontSize: 10,
                              ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Badge(
                  label: Text(bucket.count.toString()),
                  backgroundColor: selected ? selectedBadgeColor : badgeColor,
                  textColor: selected ? kAppSurfaceDim : Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String libraryBucketLabel(LibrarySeriesBucket bucket) {
  final completionPercent = bucket.completionPercent;
  if (completionPercent == null) {
    return '${bucket.title} ${bucket.count}';
  }
  return '${bucket.title} ${bucket.count} ($completionPercent%)';
}
