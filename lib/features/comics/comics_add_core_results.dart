import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/comics/comics_add_images.dart';
import 'package:collectarr_app/features/comics/comics_add_result_row.dart';
import 'package:collectarr_app/features/comics/comics_add_results_summary_bar.dart';
import 'package:collectarr_app/features/comics/comics_add_series_header.dart';
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
    final groupedResults = _groupAddResultsBySeries(visibleResults);
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
                    return AddSeriesHeader(
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

String _emptyFilterMessage() {
  return 'No matching comics are visible with the current filters.';
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

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}
