import 'package:flutter/material.dart';

class LibrarySeriesBucket {
  const LibrarySeriesBucket({required this.title, required this.count});

  final String title;
  final int count;
}

class LibrarySeriesSidebar extends StatelessWidget {
  const LibrarySeriesSidebar({
    super.key,
    required this.series,
    required this.selectedSeries,
    required this.onSelectSeries,
    this.title = 'Series',
    this.icon = Icons.folder,
    this.backgroundColor = const Color(0xFF1D1D1D),
    this.headerColor = const Color(0xFF303030),
    this.dividerColor = const Color(0xFF4A4A4A),
    this.accentColor = const Color(0xFF10A8D8),
    this.selectionColor = const Color(0xFF075F75),
    this.badgeColor = const Color(0xFF444444),
    this.selectedBadgeColor = const Color(0xFFFFD400),
    this.mutedTextColor = const Color(0xFFB8B8B8),
  });

  final List<LibrarySeriesBucket> series;
  final String? selectedSeries;
  final ValueChanged<String> onSelectSeries;
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Color headerColor;
  final Color dividerColor;
  final Color accentColor;
  final Color selectionColor;
  final Color badgeColor;
  final Color selectedBadgeColor;
  final Color mutedTextColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: backgroundColor),
      child: Column(
        children: [
          Container(
            height: 42,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: headerColor,
              border: Border(bottom: BorderSide(color: dividerColor)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: accentColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: series.length,
              itemBuilder: (context, index) {
                final bucket = series[index];
                final selected = bucket.title == selectedSeries;
                return _LibrarySeriesRow(
                  bucket: bucket,
                  selected: selected,
                  onTap: () => onSelectSeries(bucket.title),
                  selectionColor: selectionColor,
                  selectedBadgeColor: selectedBadgeColor,
                  badgeColor: badgeColor,
                  mutedTextColor: mutedTextColor,
                );
              },
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
    return Material(
      color: selected ? selectionColor : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: selectionColor.withValues(alpha: 0.35),
        child: SizedBox(
          height: 32,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    bucket.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: selected ? Colors.white : mutedTextColor,
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w500,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                Badge(
                  label: Text(bucket.count.toString()),
                  backgroundColor: selected ? selectedBadgeColor : badgeColor,
                  textColor: selected ? const Color(0xFF171717) : Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
