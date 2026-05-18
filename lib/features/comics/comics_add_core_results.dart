import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/comics/comics_add_images.dart';
import 'package:collectarr_app/features/comics/comics_add_result_row.dart';
import 'package:collectarr_app/features/comics/comics_add_results_summary_bar.dart';
import 'package:collectarr_app/features/comics/comics_add_series_header.dart';
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
    required this.includeVariants,
    required this.hideInShelf,
    required this.issueSortAscending,
    this.flatIssues = false,
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
  final bool includeVariants;
  final bool hideInShelf;
  final bool issueSortAscending;
  final bool flatIssues;
  final Set<String> collapsedSeries;
  final ValueChanged<Iterable<CatalogItem>> onCheckAllVisible;
  final VoidCallback onClearServerChecks;
  final ValueChanged<String> onToggleSeriesCollapsed;
  final ValueChanged<Iterable<CatalogItem>> onToggleSeriesCheck;
  final ValueChanged<String> onSelectServer;
  final ValueChanged<String> onToggleServerCheck;

  @override
  Widget build(BuildContext context) {
    final visibleResults = serverResults.where((item) {
      if (!includeVariants && _looksLikeVariant(item.variant)) {
        return false;
      }
      if (hideInShelf &&
          (ownedItemIds.contains(item.id) ||
              wishlistItemIds.contains(item.id))) {
        return false;
      }
      return true;
    }).toList(growable: false);
    if (visibleResults.isEmpty) {
      return Center(
        child: Text(
          _emptyFilterMessage(),
          textAlign: TextAlign.center,
        ),
      );
    }
    final addable = visibleResults
        .where((item) =>
            !ownedItemIds.contains(item.id) &&
            !wishlistItemIds.contains(item.id))
        .toList(growable: false);
    final groupedResults = _groupAddResultsBySeries(
      visibleResults,
      issueSortAscending: issueSortAscending,
    );
    return Column(
      children: [
        AddResultsSummaryBar(
          visibleCount: visibleResults.length,
          addableCount: addable.length,
          selectedCount: checkedServerIds.length,
          seriesCount: groupedResults.length,
          onSelectAll:
              addable.isEmpty ? null : () => onCheckAllVisible(addable),
          onClear: checkedServerIds.isEmpty ? null : onClearServerChecks,
        ),
        Expanded(
          child: flatIssues
              ? _CoreFlatIssueResults(
                  items: _sortedFlatItems(
                    visibleResults,
                    issueSortAscending: issueSortAscending,
                  ),
                  ownedItemIds: ownedItemIds,
                  wishlistItemIds: wishlistItemIds,
                  selectedServerId: selectedServerId,
                  checkedServerIds: checkedServerIds,
                  onSelectServer: onSelectServer,
                  onToggleServerCheck: onToggleServerCheck,
                )
              : ListView(
                  children: [
                    for (final group in groupedResults) ...[
                      Builder(
                        builder: (context) {
                          final groupAddable = group.items
                              .where((item) =>
                                  !ownedItemIds.contains(item.id) &&
                                  !wishlistItemIds.contains(item.id))
                              .toList(growable: false);
                          final selectedInGroup = group.items
                              .where(
                                  (item) => checkedServerIds.contains(item.id))
                              .length;
                          final collapsed =
                              collapsedSeries.contains(group.collapseKey);
                          return AddSeriesHeader(
                            title: group.title,
                            subtitle: _addSeriesSubtitle(group.items),
                            count: group.issueCount,
                            selectableCount: groupAddable.length,
                            selectedCount: selectedInGroup,
                            isCollapsed: collapsed,
                            canCheck: groupAddable.isNotEmpty,
                            onToggleCollapsed: () =>
                                onToggleSeriesCollapsed(group.collapseKey),
                            onToggleCheck: groupAddable.isEmpty
                                ? null
                                : () => onToggleSeriesCheck(groupAddable),
                          );
                        },
                      ),
                      _AnimatedCollapseSection(
                        visible: !collapsedSeries.contains(group.collapseKey),
                        child: Column(
                          children: [
                            for (final issue in group.issues)
                              Builder(
                                builder: (context) {
                                  final issueAddable = issue.items
                                      .where((item) =>
                                          !ownedItemIds.contains(item.id) &&
                                          !wishlistItemIds.contains(item.id))
                                      .toList(growable: false);
                                  final selectedInIssue = issue.items
                                      .where((item) =>
                                          checkedServerIds.contains(item.id))
                                      .length;
                                  final collapsed = collapsedSeries
                                      .contains(issue.collapseKey);
                                  return Column(
                                    children: [
                                      _AddIssueHeader(
                                        title: issue.issueLabel,
                                        subtitle:
                                            _addIssueSubtitle(issue.items),
                                        count: issue.items.length,
                                        selectedCount: selectedInIssue,
                                        selectableCount: issueAddable.length,
                                        isCollapsed: collapsed,
                                        canCheck: issueAddable.isNotEmpty,
                                        onToggleCollapsed: () =>
                                            onToggleSeriesCollapsed(
                                          issue.collapseKey,
                                        ),
                                        onToggleCheck: issueAddable.isEmpty
                                            ? null
                                            : () => onToggleSeriesCheck(
                                                  issueAddable,
                                                ),
                                      ),
                                      _AnimatedCollapseSection(
                                        visible: !collapsed,
                                        child: Column(
                                          children: [
                                            for (final item
                                                in issue.sortedItems)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 28,
                                                ),
                                                child: AddResultRow(
                                                  selected: item.id ==
                                                      selectedServerId,
                                                  checked: checkedServerIds
                                                      .contains(item.id),
                                                  checkDisabled: ownedItemIds
                                                          .contains(item.id) ||
                                                      wishlistItemIds
                                                          .contains(item.id),
                                                  cover: SizedBox(
                                                    width: 38,
                                                    height: 56,
                                                    child: AddComicCoverImage(
                                                      item: item,
                                                    ),
                                                  ),
                                                  title: _addResultTitle(item),
                                                  subtitle:
                                                      _addResultSubtitle(item),
                                                  badges: [
                                                    ..._addResultBadges(item),
                                                    if (ownedItemIds
                                                        .contains(item.id))
                                                      'Owned',
                                                    if (wishlistItemIds
                                                        .contains(item.id))
                                                      'Wishlist',
                                                  ],
                                                  trailing:
                                                      _addResultTrailing(item),
                                                  onTap: () =>
                                                      onSelectServer(item.id),
                                                  onToggleCheck: ownedItemIds
                                                              .contains(
                                                            item.id,
                                                          ) ||
                                                          wishlistItemIds
                                                              .contains(item.id)
                                                      ? null
                                                      : () =>
                                                          onToggleServerCheck(
                                                            item.id,
                                                          ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _AnimatedCollapseSection extends StatelessWidget {
  const _AnimatedCollapseSection({
    required this.visible,
    required this.child,
  });

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: visible
            ? KeyedSubtree(
                key: const ValueKey('expanded'),
                child: child,
              )
            : const SizedBox.shrink(key: ValueKey('collapsed')),
      ),
    );
  }
}

String _emptyFilterMessage() {
  return 'No matching comics are visible with the current filters.';
}

class _CoreFlatIssueResults extends StatelessWidget {
  const _CoreFlatIssueResults({
    required this.items,
    required this.ownedItemIds,
    required this.wishlistItemIds,
    required this.selectedServerId,
    required this.checkedServerIds,
    required this.onSelectServer,
    required this.onToggleServerCheck,
  });

  final List<CatalogItem> items;
  final Set<String> ownedItemIds;
  final Set<String> wishlistItemIds;
  final String? selectedServerId;
  final Set<String> checkedServerIds;
  final ValueChanged<String> onSelectServer;
  final ValueChanged<String> onToggleServerCheck;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (final item in items)
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
            title: [
              _addIssueLabel(item),
              if (_addResultTitle(item) != 'Standard cover')
                _addResultTitle(item),
            ].join(' | '),
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
    );
  }
}

class _AddIssueHeader extends StatelessWidget {
  const _AddIssueHeader({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.selectedCount,
    required this.selectableCount,
    required this.isCollapsed,
    required this.canCheck,
    required this.onToggleCollapsed,
    required this.onToggleCheck,
  });

  final String title;
  final String subtitle;
  final int count;
  final int selectedCount;
  final int selectableCount;
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
          color: Color(0xFF2A2D2F),
          border: Border(bottom: BorderSide(color: Color(0xFF3A3A3A))),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 5, 6, 5),
          child: Row(
            children: [
              Tooltip(
                message: isCollapsed ? 'Expand issue' : 'Collapse issue',
                child: Icon(
                  isCollapsed
                      ? Icons.keyboard_arrow_right
                      : Icons.keyboard_arrow_down,
                  size: 18,
                ),
              ),
              const SizedBox(width: 4),
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
              const Icon(Icons.menu_book, size: 15, color: kClzAccent),
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
              LibraryAddResultBadge('$count cover${count == 1 ? '' : 's'}'),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddSeriesGroup {
  const _AddSeriesGroup({
    required this.title,
    required this.collapseKey,
    required this.issues,
  });

  final String title;
  final String collapseKey;
  final List<_AddIssueGroup> issues;

  List<CatalogItem> get items => [
        for (final issue in issues) ...issue.items,
      ];

  int get issueCount => issues.length;
}

class _AddIssueGroup {
  const _AddIssueGroup({
    required this.issueLabel,
    required this.issueSortValue,
    required this.collapseKey,
    required this.items,
  });

  final String issueLabel;
  final double? issueSortValue;
  final String collapseKey;
  final List<CatalogItem> items;

  List<CatalogItem> get sortedItems {
    final standards = <CatalogItem>[];
    final variants = <CatalogItem>[];
    for (final item in items) {
      if (_looksLikeVariant(item.variant)) {
        variants.add(item);
      } else {
        standards.add(item);
      }
    }
    variants.sort(
      (left, right) => _addResultTitle(left).compareTo(_addResultTitle(right)),
    );
    return [...standards, ...variants];
  }
}

List<_AddSeriesGroup> _groupAddResultsBySeries(
  List<CatalogItem> items, {
  required bool issueSortAscending,
}) {
  final grouped = <String, Map<String, List<CatalogItem>>>{};
  final seriesTitles = <String, String>{};
  final issueLabels = <String, Map<String, String>>{};
  final issueSortValues = <String, Map<String, double?>>{};
  final sortedItems = items.toList(growable: false)
    ..sort((a, b) {
      final series = a.title.toLowerCase().compareTo(b.title.toLowerCase());
      if (series != 0) {
        return series;
      }
      return _compareIssueNumbers(a.itemNumber, b.itemNumber);
    });
  for (final item in sortedItems) {
    final seriesKey = _normalizedCoreKey(item.title);
    final issueLabel = _addIssueLabel(item);
    final issueKey = _normalizedCoreKey('${item.title} $issueLabel');
    grouped
        .putIfAbsent(seriesKey, () => <String, List<CatalogItem>>{})
        .putIfAbsent(issueKey, () => <CatalogItem>[])
        .add(item);
    seriesTitles.putIfAbsent(seriesKey, () => item.title);
    issueLabels
        .putIfAbsent(seriesKey, () => <String, String>{})
        .putIfAbsent(issueKey, () => issueLabel);
    issueSortValues
        .putIfAbsent(seriesKey, () => <String, double?>{})
        .putIfAbsent(issueKey, () => _issueNumberSortValue(item.itemNumber));
  }
  final groups = [
    for (final seriesEntry in grouped.entries)
      _AddSeriesGroup(
        title: seriesTitles[seriesEntry.key] ?? seriesEntry.key,
        collapseKey: 'core-series:${seriesEntry.key}',
        issues: [
          for (final issueEntry in seriesEntry.value.entries)
            _AddIssueGroup(
              issueLabel:
                  issueLabels[seriesEntry.key]?[issueEntry.key] ?? 'Issue',
              issueSortValue: issueSortValues[seriesEntry.key]?[issueEntry.key],
              collapseKey: 'core-issue:${issueEntry.key}',
              items: issueEntry.value,
            ),
        ]..sort(
            (left, right) => issueSortAscending
                ? _compareAddIssueGroups(left, right)
                : _compareAddIssueGroups(right, left),
          ),
      ),
  ];
  groups.sort((left, right) => left.title.compareTo(right.title));
  return groups;
}

int _compareAddIssueGroups(_AddIssueGroup left, _AddIssueGroup right) {
  final leftSort = left.issueSortValue;
  final rightSort = right.issueSortValue;
  if (leftSort != null && rightSort != null) {
    final numeric = leftSort.compareTo(rightSort);
    if (numeric != 0) {
      return numeric;
    }
  }
  if (leftSort != null) {
    return -1;
  }
  if (rightSort != null) {
    return 1;
  }
  return left.issueLabel.compareTo(right.issueLabel);
}

List<CatalogItem> _sortedFlatItems(
  List<CatalogItem> items, {
  required bool issueSortAscending,
}) {
  final sorted = items.toList(growable: false)
    ..sort((left, right) {
      final issueCompare = _compareIssueNumbers(
        left.itemNumber,
        right.itemNumber,
      );
      if (issueCompare != 0) {
        return issueSortAscending ? issueCompare : -issueCompare;
      }
      final leftVariant = _looksLikeVariant(left.variant);
      final rightVariant = _looksLikeVariant(right.variant);
      if (leftVariant != rightVariant) {
        return leftVariant ? 1 : -1;
      }
      return _addResultTitle(left).compareTo(_addResultTitle(right));
    });
  return sorted;
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

String _addIssueSubtitle(List<CatalogItem> items) {
  final standardCount =
      items.where((item) => !_looksLikeVariant(item.variant)).length;
  final variantCount = items.length - standardCount;
  final dates = items
      .map((item) => item.releaseDate)
      .whereType<DateTime>()
      .toList(growable: false);
  final releaseDate = dates.isEmpty ? null : _formatDate(dates.first);
  return [
    if (standardCount > 0)
      '$standardCount standard cover${standardCount == 1 ? '' : 's'}',
    if (variantCount > 0)
      '$variantCount variant cover${variantCount == 1 ? '' : 's'}',
    if (releaseDate != null) releaseDate,
  ].join(' | ');
}

String _addIssueLabel(CatalogItem item) {
  final itemNumber = item.itemNumber?.trim();
  if (itemNumber != null && itemNumber.isNotEmpty) {
    return '#$itemNumber';
  }
  return 'Unnumbered issue';
}

String _addResultTitle(CatalogItem item) {
  final variant = item.variant?.trim();
  if (variant == null || variant.isEmpty) {
    return 'Standard cover';
  }
  if (!_looksLikeVariant(variant)) {
    return 'Standard cover | $variant';
  }
  return variant;
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

bool _looksLikeVariant(String? value) {
  final text = value?.trim().toLowerCase();
  if (text == null || text.isEmpty) {
    return false;
  }
  if (text == 'cover a' ||
      text == 'regular cover' ||
      text == 'standard cover' ||
      text == 'standard edition') {
    return false;
  }
  return text.contains('variant') ||
      text.contains('virgin') ||
      text.contains('foil') ||
      text.contains('exclusive') ||
      text.contains('incentive') ||
      text.contains('ratio') ||
      text.contains('second printing') ||
      text.contains('third printing');
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

String _normalizedCoreKey(String title) {
  final normalized = title
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return normalized.isEmpty ? 'unknown' : normalized;
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}
