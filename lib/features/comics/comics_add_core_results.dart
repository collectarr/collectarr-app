import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/comics/comics_add_images.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:flutter/material.dart';

class AddCoreResults extends StatelessWidget {
  const AddCoreResults({
    super.key,
    required this.serverResults,
    required this.ownedItemIds,
    required this.wishlistItemIds,
    required this.selectedServerId,
    required this.checkedServerIds,
    required this.hideInShelf,
    required this.collapsedSeries,
    required this.onCheckAllVisible,
    required this.onClearServerChecks,
    required this.onToggleSeriesCollapsed,
    required this.onToggleSeriesCheck,
    required this.onSelectServer,
    required this.onToggleServerCheck,
  });

  final List<CatalogItem> serverResults;
  final Set<String> ownedItemIds;
  final Set<String> wishlistItemIds;
  final String? selectedServerId;
  final Set<String> checkedServerIds;
  final bool hideInShelf;
  final Set<String> collapsedSeries;
  final ValueChanged<Iterable<CatalogItem>> onCheckAllVisible;
  final VoidCallback onClearServerChecks;
  final ValueChanged<String> onToggleSeriesCollapsed;
  final ValueChanged<Iterable<CatalogItem>> onToggleSeriesCheck;
  final ValueChanged<String> onSelectServer;
  final ValueChanged<String> onToggleServerCheck;

  @override
  Widget build(BuildContext context) {
    final visibleResults = hideInShelf
        ? serverResults
            .where((item) =>
                !ownedItemIds.contains(item.id) &&
                !wishlistItemIds.contains(item.id))
            .toList(growable: false)
        : serverResults;
    if (visibleResults.isEmpty) {
      return const Center(
        child: Text(
          'All matching comics are already in your local shelf.',
          textAlign: TextAlign.center,
        ),
      );
    }
    final addable = visibleResults
        .where((item) =>
            !ownedItemIds.contains(item.id) &&
            !wishlistItemIds.contains(item.id))
        .toList(growable: false);
    final groupedResults = _groupAddResultsBySeries(visibleResults);
    return Column(
      children: [
        _AddResultsSummaryBar(
          visibleCount: visibleResults.length,
          addableCount: addable.length,
          selectedCount: checkedServerIds.length,
          seriesCount: groupedResults.length,
          onSelectAll:
              addable.isEmpty ? null : () => onCheckAllVisible(addable),
          onClear: checkedServerIds.isEmpty ? null : onClearServerChecks,
        ),
        Expanded(
          child: ListView(
            children: [
              for (final group in groupedResults.entries) ...[
                Builder(
                  builder: (context) {
                    final groupAddable = group.value
                        .where((item) =>
                            !ownedItemIds.contains(item.id) &&
                            !wishlistItemIds.contains(item.id))
                        .toList(growable: false);
                    final selectedInGroup = group.value
                        .where((item) => checkedServerIds.contains(item.id))
                        .length;
                    final collapsed = collapsedSeries.contains(group.key);
                    return _AddSeriesHeader(
                      title: group.key,
                      subtitle: _addSeriesSubtitle(group.value),
                      count: group.value.length,
                      selectableCount: groupAddable.length,
                      selectedCount: selectedInGroup,
                      isCollapsed: collapsed,
                      canCheck: groupAddable.isNotEmpty,
                      onToggleCollapsed: () =>
                          onToggleSeriesCollapsed(group.key),
                      onToggleCheck: groupAddable.isEmpty
                          ? null
                          : () => onToggleSeriesCheck(groupAddable),
                    );
                  },
                ),
                if (!collapsedSeries.contains(group.key))
                  for (final item in group.value)
                    AddResultRow(
                      selected: item.id == selectedServerId,
                      checked: checkedServerIds.contains(item.id),
                      checkDisabled: ownedItemIds.contains(item.id) ||
                          wishlistItemIds.contains(item.id),
                      cover: SizedBox(
                        width: 38,
                        height: 56,
                        child: AddComicCoverImage(item: item),
                      ),
                      title: item.itemNumber == null
                          ? item.title
                          : '#${item.itemNumber}',
                      subtitle: _addResultSubtitle(item),
                      badges: [
                        ..._addResultBadges(item),
                        if (ownedItemIds.contains(item.id)) 'Owned',
                        if (wishlistItemIds.contains(item.id)) 'Wishlist',
                      ],
                      trailing: _addResultTrailing(item),
                      onTap: () => onSelectServer(item.id),
                      onToggleCheck: ownedItemIds.contains(item.id) ||
                              wishlistItemIds.contains(item.id)
                          ? null
                          : () => onToggleServerCheck(item.id),
                    ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class AddResultRow extends StatelessWidget {
  const AddResultRow({
    super.key,
    required this.selected,
    required this.checked,
    required this.checkDisabled,
    required this.cover,
    required this.title,
    required this.subtitle,
    required this.badges,
    required this.trailing,
    required this.onTap,
    required this.onToggleCheck,
  });

  final bool selected;
  final bool checked;
  final bool checkDisabled;
  final Widget cover;
  final String title;
  final String subtitle;
  final List<String> badges;
  final String trailing;
  final VoidCallback onTap;
  final VoidCallback? onToggleCheck;

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: selected ? kClzSelection : const Color(0xFF242729),
        border: Border(
          left: BorderSide(
            color: selected ? kClzYellow : Colors.transparent,
            width: 3,
          ),
          bottom: const BorderSide(color: Color(0xFF36393B)),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          child: Row(
            children: [
              Checkbox(
                value: checked,
                onChanged: checkDisabled ? null : (_) => onToggleCheck?.call(),
                visualDensity: VisualDensity.compact,
              ),
              cover,
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFDDDDDD),
                      ),
                    ),
                    if (badges.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          for (final badge in badges)
                            LibraryAddResultBadge(badge),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing.isNotEmpty)
                Text(
                  trailing,
                  style: const TextStyle(color: Color(0xFFBFEFFF)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddResultsSummaryBar extends StatelessWidget {
  const _AddResultsSummaryBar({
    required this.visibleCount,
    required this.addableCount,
    required this.selectedCount,
    required this.seriesCount,
    required this.onSelectAll,
    required this.onClear,
  });

  final int visibleCount;
  final int addableCount;
  final int selectedCount;
  final int seriesCount;
  final VoidCallback? onSelectAll;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      decoration: const BoxDecoration(
        color: Color(0xFF252525),
        border: Border(bottom: BorderSide(color: Color(0xFF444444))),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  LibraryAddResultBadge(
                    '$visibleCount result${visibleCount == 1 ? '' : 's'}',
                  ),
                  const SizedBox(width: 6),
                  LibraryAddResultBadge(
                    '$seriesCount series',
                  ),
                  const SizedBox(width: 6),
                  LibraryAddResultBadge(
                    '$selectedCount selected',
                  ),
                  if (addableCount != visibleCount) ...[
                    const SizedBox(width: 6),
                    LibraryAddResultBadge(
                      '$addableCount addable',
                    ),
                  ],
                ],
              ),
            ),
          ),
          Wrap(
            spacing: 4,
            children: [
              TextButton(
                onPressed: onSelectAll,
                child: const Text('Select all'),
              ),
              TextButton(
                onPressed: onClear,
                child: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddSeriesHeader extends StatelessWidget {
  const _AddSeriesHeader({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.selectableCount,
    required this.selectedCount,
    required this.isCollapsed,
    required this.canCheck,
    required this.onToggleCollapsed,
    required this.onToggleCheck,
  });

  final String title;
  final String subtitle;
  final int count;
  final int selectableCount;
  final int selectedCount;
  final bool isCollapsed;
  final bool canCheck;
  final VoidCallback onToggleCollapsed;
  final VoidCallback? onToggleCheck;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggleCollapsed,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFF232323),
          border: Border(bottom: BorderSide(color: Color(0xFF3A3A3A))),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(2, 5, 6, 5),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 32,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  tooltip: isCollapsed ? 'Expand series' : 'Collapse series',
                  onPressed: onToggleCollapsed,
                  icon: Icon(
                    isCollapsed
                        ? Icons.keyboard_arrow_right
                        : Icons.keyboard_arrow_down,
                    size: 18,
                  ),
                ),
              ),
              Checkbox(
                value: selectedCount == 0
                    ? false
                    : selectedCount >= selectableCount
                        ? true
                        : null,
                tristate: true,
                onChanged: canCheck ? (_) => onToggleCheck?.call() : null,
                visualDensity: VisualDensity.compact,
              ),
              const Icon(Icons.folder, size: 15, color: Color(0xFF18B7EB)),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFB8B8B8),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              if (selectedCount > 0) ...[
                LibraryAddResultBadge('$selectedCount selected'),
                const SizedBox(width: 6),
              ],
              LibraryAddResultBadge('$count issue${count == 1 ? '' : 's'}'),
            ],
          ),
        ),
      ),
    );
  }
}

Map<String, List<CatalogItem>> _groupAddResultsBySeries(
  List<CatalogItem> items,
) {
  final grouped = <String, List<CatalogItem>>{};
  final sortedItems = items.toList(growable: false)
    ..sort((a, b) {
      final series = a.title.toLowerCase().compareTo(b.title.toLowerCase());
      if (series != 0) {
        return series;
      }
      return _compareIssueNumbers(a.itemNumber, b.itemNumber);
    });
  for (final item in sortedItems) {
    grouped.putIfAbsent(item.title, () => []).add(item);
  }
  return grouped;
}

String _addSeriesSubtitle(List<CatalogItem> items) {
  final issues = items
      .map((item) => item.itemNumber)
      .whereType<String>()
      .where((value) => value.trim().isNotEmpty)
      .toList(growable: false);
  final publishers = items
      .map((item) => item.publisher)
      .whereType<String>()
      .where((value) => value.trim().isNotEmpty)
      .toList(growable: false);
  final publisher = publishers.isEmpty ? null : publishers.first;
  final years = items
      .map((item) => item.releaseYear)
      .whereType<int>()
      .toList(growable: false);
  final range = issues.isEmpty
      ? null
      : issues.length == 1
          ? '#${issues.first}'
          : '#${issues.first} - #${issues.last}';
  final yearRange = years.isEmpty
      ? null
      : years.length == 1 || years.toSet().length == 1
          ? years.first.toString()
          : '${years.reduce((a, b) => a < b ? a : b)}-${years.reduce((a, b) => a > b ? a : b)}';
  return [
    if (range != null) range,
    if (publisher != null) publisher,
    if (yearRange != null) yearRange,
  ].join(' | ');
}

String _addResultSubtitle(CatalogItem item) {
  final parts = [
    if (item.variant != null && item.variant!.isNotEmpty) item.variant,
    if (item.releaseDate != null) _formatDate(item.releaseDate!),
    if (item.publisher != null && item.publisher!.isNotEmpty) item.publisher,
    if (item.barcode != null && item.barcode!.isNotEmpty) item.barcode,
  ].whereType<String>().toList(growable: false);
  if (parts.isNotEmpty) {
    return parts.join('  |  ');
  }
  return item.synopsis ?? 'Metadata in Collectarr Core';
}

List<String> _addResultBadges(CatalogItem item) {
  return [
    if (item.publisher != null && item.publisher!.isNotEmpty) item.publisher!,
    if (item.releaseYear != null) item.releaseYear!.toString(),
  ];
}

String _addResultTrailing(CatalogItem item) {
  if (item.releaseDate != null) {
    return _formatDate(item.releaseDate!);
  }
  if (item.releaseYear != null) {
    return item.releaseYear!.toString();
  }
  return item.itemNumber == null ? '' : '#${item.itemNumber}';
}

int _compareIssueNumbers(String? left, String? right) {
  final leftNumber = _issueNumberSortValue(left);
  final rightNumber = _issueNumberSortValue(right);
  if (leftNumber != null && rightNumber != null) {
    final numeric = leftNumber.compareTo(rightNumber);
    if (numeric != 0) {
      return numeric;
    }
  }
  if (leftNumber != null) {
    return -1;
  }
  if (rightNumber != null) {
    return 1;
  }
  return _compareNullableStrings(left, right);
}

double? _issueNumberSortValue(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  final match = RegExp(r'^\s*(\d+(?:\.\d+)?)').firstMatch(value);
  return match == null ? null : double.tryParse(match.group(1)!);
}

int _compareNullableStrings(String? left, String? right) {
  final leftValue = left?.toLowerCase() ?? '';
  final rightValue = right?.toLowerCase() ?? '';
  if (leftValue.isEmpty && rightValue.isNotEmpty) {
    return 1;
  }
  if (leftValue.isNotEmpty && rightValue.isEmpty) {
    return -1;
  }
  return leftValue.compareTo(rightValue);
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}
