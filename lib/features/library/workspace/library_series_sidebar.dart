import 'package:cached_network_image/cached_network_image.dart';
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

class LibrarySeriesSidebar extends StatelessWidget {
  const LibrarySeriesSidebar({
    super.key,
    required this.series,
    required this.selectedSeries,
    required this.onSelectSeries,
    this.title = 'Series',
    this.icon = Icons.folder,
    this.trailing,
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
  final Widget? trailing;
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
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                if (trailing != null) trailing!,
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
                        placeholder: (_, __) => const ColoredBox(
                          color: Color(0xFF333333),
                        ),
                        errorWidget: (_, __, ___) => const ColoredBox(
                          color: Color(0xFF333333),
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

String libraryBucketLabel(LibrarySeriesBucket bucket) {
  final completionPercent = bucket.completionPercent;
  if (completionPercent == null) {
    return '${bucket.title} ${bucket.count}';
  }
  return '${bucket.title} ${bucket.count} (${completionPercent}%)';
}
