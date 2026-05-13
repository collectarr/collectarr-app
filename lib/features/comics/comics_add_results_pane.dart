import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_add_images.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/library/add/library_add_mode.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:flutter/material.dart';

class AddComicResultPane extends StatelessWidget {
  const AddComicResultPane({
    super.key,
    required this.mode,
    required this.serverResults,
    required this.providerResults,
    required this.pullListRows,
    required this.ownedItemIds,
    required this.wishlistItemIds,
    required this.selectedServerId,
    required this.selectedProviderId,
    required this.checkedServerIds,
    required this.includeVariants,
    required this.hideInShelf,
    required this.searchedServer,
    required this.searchedProvider,
    required this.isSearchingServer,
    required this.isSearchingProvider,
    required this.onIncludeVariantsChanged,
    required this.onHideInShelfChanged,
    required this.onSelectServer,
    required this.onToggleServerCheck,
    required this.collapsedSeries,
    required this.onToggleSeriesCollapsed,
    required this.onToggleSeriesCheck,
    required this.onCheckAllVisible,
    required this.onClearServerChecks,
    required this.onSelectProvider,
    required this.onSearchProvider,
    required this.onSearchPullListRow,
  });

  final LibraryAddMode mode;
  final List<CatalogItem> serverResults;
  final List<ProviderCandidate> providerResults;
  final List<PullListCandidate> pullListRows;
  final Set<String> ownedItemIds;
  final Set<String> wishlistItemIds;
  final String? selectedServerId;
  final String? selectedProviderId;
  final Set<String> checkedServerIds;
  final bool includeVariants;
  final bool hideInShelf;
  final bool searchedServer;
  final bool searchedProvider;
  final bool isSearchingServer;
  final bool isSearchingProvider;
  final ValueChanged<bool> onIncludeVariantsChanged;
  final ValueChanged<bool> onHideInShelfChanged;
  final ValueChanged<String> onSelectServer;
  final ValueChanged<String> onToggleServerCheck;
  final Set<String> collapsedSeries;
  final ValueChanged<String> onToggleSeriesCollapsed;
  final ValueChanged<Iterable<CatalogItem>> onToggleSeriesCheck;
  final ValueChanged<Iterable<CatalogItem>> onCheckAllVisible;
  final VoidCallback onClearServerChecks;
  final ValueChanged<String> onSelectProvider;
  final VoidCallback onSearchProvider;
  final ValueChanged<PullListCandidate> onSearchPullListRow;

  @override
  Widget build(BuildContext context) {
    if (mode == LibraryAddMode.pullList) {
      return _PullListResultsPane(
        rows: pullListRows,
        onSearchRow: onSearchPullListRow,
      );
    }
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF1D2022),
        border: Border(right: BorderSide(color: kClzDivider)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TinyCheckbox(
                    value: includeVariants,
                    label: 'Variants',
                    onChanged: onIncludeVariantsChanged,
                  ),
                  const SizedBox(width: 10),
                  _TinyCheckbox(
                    value: hideInShelf,
                    label: 'Hide in shelf',
                    onChanged: onHideInShelfChanged,
                  ),
                  const SizedBox(width: 10),
                  const Text('Issues:'),
                  const SizedBox(width: 4),
                  const _IssueSortButton(label: 'III', selected: true),
                  const _IssueSortButton(label: 'Asc'),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF3A3A3A))),
            ),
            child: const Text(
              'Collectarr Core results',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
          Expanded(
            child: _buildResults(),
          ),
          if (serverResults.isEmpty && searchedServer)
            Padding(
              padding: const EdgeInsets.all(8),
              child: OutlinedButton.icon(
                onPressed: isSearchingProvider ? null : onSearchProvider,
                icon: const Icon(Icons.manage_search),
                label: Text(
                  searchedProvider
                      ? 'Search ComicVine again'
                      : 'Search ComicVine',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (isSearchingServer || isSearchingProvider) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!searchedServer) {
      return const Center(
        child: Text(
          'Search Collectarr Core to add comics to your local collection.',
          textAlign: TextAlign.center,
        ),
      );
    }
    if (serverResults.isNotEmpty) {
      return _CoreResults(
        serverResults: serverResults,
        ownedItemIds: ownedItemIds,
        wishlistItemIds: wishlistItemIds,
        selectedServerId: selectedServerId,
        checkedServerIds: checkedServerIds,
        hideInShelf: hideInShelf,
        collapsedSeries: collapsedSeries,
        onCheckAllVisible: onCheckAllVisible,
        onClearServerChecks: onClearServerChecks,
        onToggleSeriesCollapsed: onToggleSeriesCollapsed,
        onToggleSeriesCheck: onToggleSeriesCheck,
        onSelectServer: onSelectServer,
        onToggleServerCheck: onToggleServerCheck,
      );
    }
    if (providerResults.isNotEmpty) {
      return ListView.builder(
        itemCount: providerResults.length,
        itemBuilder: (context, index) {
          final item = providerResults[index];
          return _AddResultRow(
            selected: item.providerItemId == selectedProviderId,
            checked: false,
            checkDisabled: true,
            cover: SizedBox(
              width: 42,
              height: 62,
              child: ProviderCandidateImage(candidate: item),
            ),
            title: item.title,
            subtitle: item.summary ?? 'ComicVine candidate',
            badges: const ['ComicVine'],
            trailing: 'propose',
            onTap: () => onSelectProvider(item.providerItemId),
            onToggleCheck: null,
          );
        },
      );
    }
    return const Center(
      child: Text(
        'No Collectarr Core matches yet. Try ComicVine to propose metadata.',
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _CoreResults extends StatelessWidget {
  const _CoreResults({
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
                    _AddResultRow(
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

class _PullListResultsPane extends StatelessWidget {
  const _PullListResultsPane({
    required this.rows,
    required this.onSearchRow,
  });

  final List<PullListCandidate> rows;
  final ValueChanged<PullListCandidate> onSearchRow;

  @override
  Widget build(BuildContext context) {
    final visibleRows = rows.isEmpty ? _pullListPlaceholderRows : rows;
    return ColoredBox(
      color: const Color(0xFF2E2E2E),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: const BoxDecoration(
              color: Color(0xFF252525),
              border: Border(bottom: BorderSide(color: Color(0xFF444444))),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Color(0xFF18B7EB), size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Local Pull List',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                LibraryAddResultBadge(
                  rows.isEmpty
                      ? 'needs local shelf'
                      : '${rows.length} suggestion${rows.length == 1 ? '' : 's'}',
                ),
              ],
            ),
          ),
          const _PullListPreviewHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: visibleRows.length,
              itemBuilder: (context, index) {
                final row = visibleRows[index];
                return _PullListPreviewRow(
                  row: row,
                  onSearch: rows.isEmpty ? null : () => onSearchRow(row),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              rows.isEmpty
                  ? 'Add a few owned or wishlist comics first. Pull List will use local series and wishlist gaps to search Collectarr Core for likely next issues.'
                  : 'Pull List is generated from the local shelf only. Use Search Core on a row to query server metadata for that next issue.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFCCCCCC)),
            ),
          ),
        ],
      ),
    );
  }
}

class PullListCandidate {
  const PullListCandidate({
    required this.series,
    required this.issue,
    required this.release,
    required this.status,
    this.publisher,
  });

  final String series;
  final String issue;
  final String release;
  final String status;
  final String? publisher;
}

List<PullListCandidate> pullListCandidates(ShelfState? shelf) {
  final entries = shelf?.entries ?? const <ShelfEntry>[];
  final bySeries = <String, List<ShelfEntry>>{};
  for (final entry in entries) {
    final item = entry.catalogItem;
    if (item == null || (!entry.isOwned && !entry.isWishlisted)) {
      continue;
    }
    bySeries.putIfAbsent(item.title, () => []).add(entry);
  }
  final rows = <PullListCandidate>[];
  for (final group in bySeries.entries) {
    final numbered = [
      for (final entry in group.value)
        if (_issueNumberSortValue(entry.catalogItem?.itemNumber) != null)
          (
            entry: entry,
            number: _issueNumberSortValue(entry.catalogItem?.itemNumber)!,
          ),
    ]..sort((a, b) => a.number.compareTo(b.number));
    if (numbered.isEmpty) {
      continue;
    }
    final last = numbered.last;
    final nextIssue = _formatIssueNumber(last.number + 1);
    final publisher = last.entry.catalogItem?.publisher;
    rows.add(
      PullListCandidate(
        series: group.key,
        issue: nextIssue,
        release: publisher ?? 'Collectarr Core',
        status: group.value.any((entry) => entry.isWishlisted)
            ? 'wishlist gap'
            : 'next issue',
        publisher: publisher,
      ),
    );
  }
  rows.sort((a, b) => a.series.toLowerCase().compareTo(b.series.toLowerCase()));
  return rows.take(25).toList(growable: false);
}

const _pullListPlaceholderRows = [
  PullListCandidate(
    series: 'Watched series',
    issue: 'next',
    release: 'local shelf',
    status: 'waiting',
  ),
  PullListCandidate(
    series: 'Wishlist gaps',
    issue: 'missing',
    release: 'Collectarr Core',
    status: 'planned',
  ),
  PullListCandidate(
    series: 'New releases',
    issue: 'weekly',
    release: 'ComicVine',
    status: 'planned',
  ),
];

class _PullListPreviewHeader extends StatelessWidget {
  const _PullListPreviewHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      color: const Color(0xFF383838),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: const Row(
        children: [
          Expanded(flex: 4, child: Text('Series')),
          Expanded(flex: 2, child: Text('Issue')),
          Expanded(flex: 3, child: Text('Release')),
          Expanded(flex: 3, child: Text('Status')),
          SizedBox(width: 96, child: Text('Action')),
        ],
      ),
    );
  }
}

class _PullListPreviewRow extends StatelessWidget {
  const _PullListPreviewRow({
    required this.row,
    required this.onSearch,
  });

  final PullListCandidate row;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF3B3B3B))),
      ),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(row.series)),
          Expanded(flex: 2, child: Text('#${row.issue}')),
          Expanded(flex: 3, child: Text(row.release)),
          Expanded(
            flex: 3,
            child: Text(
              row.status,
              style: const TextStyle(color: Color(0xFFBFEFFF)),
            ),
          ),
          SizedBox(
            width: 96,
            child: OutlinedButton(
              onPressed: onSearch,
              child: const Text('Search Core'),
            ),
          ),
        ],
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

class _TinyCheckbox extends StatelessWidget {
  const _TinyCheckbox({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            value ? Icons.check_box : Icons.check_box_outline_blank,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _IssueSortButton extends StatelessWidget {
  const _IssueSortButton({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      color: selected ? const Color(0xFF159AC8) : const Color(0xFF555555),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }
}

class _AddResultRow extends StatelessWidget {
  const _AddResultRow({
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

String _formatIssueNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toString();
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}
