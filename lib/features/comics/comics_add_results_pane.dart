import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/comics/comics_add_core_results.dart';
import 'package:collectarr_app/features/comics/comics_add_images.dart';
import 'package:collectarr_app/features/comics/comics_add_pull_list.dart';
import 'package:collectarr_app/features/comics/comics_add_result_row.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/library/add/library_add_mode.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/comics/comics_add_pull_list.dart'
    show PullListCandidate, pullListCandidates;

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
    required this.checkedProviderIds,
    required this.includeVariants,
    required this.hideInShelf,
    required this.issueSortAscending,
    required this.searchedServer,
    required this.searchedProvider,
    required this.isSearchingServer,
    required this.isSearchingProvider,
    required this.selectedProvider,
    required this.providerLabel,
    required this.onIncludeVariantsChanged,
    required this.onHideInShelfChanged,
    required this.onIssueSortAscendingChanged,
    required this.onSelectServer,
    required this.onToggleServerCheck,
    required this.onToggleProviderCheck,
    required this.collapsedSeries,
    required this.onToggleSeriesCollapsed,
    required this.onToggleSeriesCheck,
    required this.onCheckAllVisible,
    required this.onClearServerChecks,
    required this.onSelectProvider,
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
  final Set<String> checkedProviderIds;
  final bool includeVariants;
  final bool hideInShelf;
  final bool issueSortAscending;
  final bool searchedServer;
  final bool searchedProvider;
  final bool isSearchingServer;
  final bool isSearchingProvider;
  final String selectedProvider;
  final String Function(String provider) providerLabel;
  final ValueChanged<bool> onIncludeVariantsChanged;
  final ValueChanged<bool> onHideInShelfChanged;
  final ValueChanged<bool> onIssueSortAscendingChanged;
  final ValueChanged<String> onSelectServer;
  final ValueChanged<String> onToggleServerCheck;
  final ValueChanged<String> onToggleProviderCheck;
  final Set<String> collapsedSeries;
  final ValueChanged<String> onToggleSeriesCollapsed;
  final ValueChanged<Iterable<CatalogItem>> onToggleSeriesCheck;
  final ValueChanged<Iterable<CatalogItem>> onCheckAllVisible;
  final VoidCallback onClearServerChecks;
  final ValueChanged<String> onSelectProvider;
  final ValueChanged<PullListCandidate> onSearchPullListRow;

  @override
  Widget build(BuildContext context) {
    final selectedProviderLabel = providerLabel(selectedProvider);
    final visibleProviderResults = _visibleProviderResults();
    final resultsHeading = _resultsHeading();
    final selectedResultLabel = _selectedResultLabel(visibleProviderResults);
    if (mode == LibraryAddMode.pullList) {
      return PullListResultsPane(
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
                  _IssueSortButton(
                    label: 'Asc',
                    tooltip: 'Sort issues ascending',
                    selected: issueSortAscending,
                    onPressed: () => onIssueSortAscendingChanged(true),
                  ),
                  _IssueSortButton(
                    label: 'Desc',
                    tooltip: 'Sort issues descending',
                    selected: !issueSortAscending,
                    onPressed: () => onIssueSortAscendingChanged(false),
                  ),
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
            child: Text(
              resultsHeading,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
          if (selectedResultLabel != null)
            _SelectedResultStrip(label: selectedResultLabel),
          Expanded(
            child: _buildResults(
              selectedProviderLabel,
              visibleProviderResults,
            ),
          ),
        ],
      ),
    );
  }

  String _resultsHeading() {
    if (!searchedServer || isSearchingServer || serverResults.isNotEmpty) {
      return 'Collectarr Core results';
    }
    return 'Provider results';
  }

  Widget _buildResults(
    String selectedProviderLabel,
    List<ProviderCandidate> visibleProviderResults,
  ) {
    if (isSearchingServer) {
      return const _SearchSkeletonState(
        label: 'Searching Collectarr Core...',
      );
    }
    if (isSearchingProvider) {
      return const _SearchSkeletonState(
        label: 'Searching metadata providers...',
      );
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
      return AddCoreResults(
        serverResults: serverResults,
        ownedItemIds: ownedItemIds,
        wishlistItemIds: wishlistItemIds,
        selectedServerId: selectedServerId,
        checkedServerIds: checkedServerIds,
        includeVariants: includeVariants,
        hideInShelf: hideInShelf,
        issueSortAscending: issueSortAscending,
        flatIssues: mode == LibraryAddMode.addIssue,
        collapsedSeries: collapsedSeries,
        onCheckAllVisible: onCheckAllVisible,
        onClearServerChecks: onClearServerChecks,
        onToggleSeriesCollapsed: onToggleSeriesCollapsed,
        onToggleSeriesCheck: onToggleSeriesCheck,
        onSelectServer: onSelectServer,
        onToggleServerCheck: onToggleServerCheck,
      );
    }
    if (visibleProviderResults.isNotEmpty) {
      if (mode == LibraryAddMode.addIssue) {
        return _ProviderFlatIssueList(
          results: visibleProviderResults,
          issueSortAscending: issueSortAscending,
          selectedProviderId: selectedProviderId,
          checkedProviderIds: checkedProviderIds,
          providerLabel: providerLabel,
          onSelectProvider: onSelectProvider,
          onToggleProviderCheck: onToggleProviderCheck,
        );
      }
      return _ProviderIssueTree(
        results: visibleProviderResults,
        issueSortAscending: issueSortAscending,
        selectedProviderId: selectedProviderId,
        checkedProviderIds: checkedProviderIds,
        collapsedSeries: collapsedSeries,
        providerLabel: providerLabel,
        onSelectProvider: onSelectProvider,
        onToggleProviderCheck: onToggleProviderCheck,
        onToggleIssueCollapsed: onToggleSeriesCollapsed,
      );
    }
    return Center(
      child: Text(
        _emptyProviderMessage(selectedProviderLabel),
        textAlign: TextAlign.center,
      ),
    );
  }

  String? _selectedResultLabel(
    List<ProviderCandidate> visibleProviderResults,
  ) {
    final serverId = selectedServerId;
    if (serverId != null) {
      for (final item in serverResults) {
        if (item.id == serverId) {
          return [
            item.title,
            if (item.itemNumber != null && item.itemNumber!.trim().isNotEmpty)
              '#${item.itemNumber}',
            if (item.variant != null && item.variant!.trim().isNotEmpty)
              item.variant,
          ].join(' | ');
        }
      }
    }
    final providerId = selectedProviderId;
    if (providerId != null) {
      for (final item in visibleProviderResults) {
        if (item.providerItemId == providerId) {
          final identity = _providerCandidateIdentity(item);
          return [
            identity.seriesTitle,
            identity.issueLabel,
            identity.variantLabel,
          ].join(' | ');
        }
      }
    }
    return null;
  }

  List<ProviderCandidate> _visibleProviderResults() {
    return providerResults.where((item) {
      if (!includeVariants && item.isVariant) {
        return false;
      }
      if (hideInShelf &&
          (ownedItemIds.contains(item.localCatalogId) ||
              wishlistItemIds.contains(item.localCatalogId))) {
        return false;
      }
      return true;
    }).toList(growable: false);
  }

  String _emptyProviderMessage(String selectedProviderLabel) {
    if (providerResults.isNotEmpty) {
      return 'No provider matches are visible with the current filters.';
    }
    if (searchedProvider) {
      return 'No Collectarr Core or provider matches found.';
    }
    return 'No Collectarr Core matches found. Searching metadata providers next.';
  }
}

class _ProviderIssueTree extends StatelessWidget {
  const _ProviderIssueTree({
    required this.results,
    required this.issueSortAscending,
    required this.selectedProviderId,
    required this.checkedProviderIds,
    required this.collapsedSeries,
    required this.providerLabel,
    required this.onSelectProvider,
    required this.onToggleProviderCheck,
    required this.onToggleIssueCollapsed,
  });

  final List<ProviderCandidate> results;
  final bool issueSortAscending;
  final String? selectedProviderId;
  final Set<String> checkedProviderIds;
  final Set<String> collapsedSeries;
  final String Function(String provider) providerLabel;
  final ValueChanged<String> onSelectProvider;
  final ValueChanged<String> onToggleProviderCheck;
  final ValueChanged<String> onToggleIssueCollapsed;

  @override
  Widget build(BuildContext context) {
    final groups = _groupProviderResultsBySeries(
      results,
      issueSortAscending: issueSortAscending,
    );
    return ListView(
      children: [
        for (final series in groups) ...[
          _ProviderSeriesHeader(
            group: series,
            isCollapsed: collapsedSeries.contains(series.collapseKey),
            onToggleCollapsed: () => onToggleIssueCollapsed(series.collapseKey),
          ),
          _AnimatedCollapseSection(
            visible: !collapsedSeries.contains(series.collapseKey),
            child: Column(
              children: [
                for (final issue in series.issues)
                  Builder(
                    builder: (context) {
                      final issueCollapsed =
                          collapsedSeries.contains(issue.collapseKey);
                      return Column(
                        children: [
                          _ProviderIssueHeader(
                            group: issue,
                            isCollapsed: issueCollapsed,
                            onToggleCollapsed: () =>
                                onToggleIssueCollapsed(issue.collapseKey),
                          ),
                          _AnimatedCollapseSection(
                            visible: !issueCollapsed,
                            child: Column(
                              children: [
                                for (final item in issue.sortedItems)
                                  _ProviderIssueRow(
                                    candidate: item,
                                    selected: item.providerItemId ==
                                        selectedProviderId,
                                    checked: checkedProviderIds
                                        .contains(item.providerItemId),
                                    providerLabel: providerLabel(item.provider),
                                    isChild: _providerCandidateIdentity(item)
                                        .isVariant,
                                    onSelect: () =>
                                        onSelectProvider(item.providerItemId),
                                    onToggleCheck: () => onToggleProviderCheck(
                                      item.providerItemId,
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
    );
  }
}

class _SelectedResultStrip extends StatelessWidget {
  const _SelectedResultStrip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 5, 8, 6),
      decoration: BoxDecoration(
        color: kClzSelection.withValues(alpha: 0.7),
        border: const Border(bottom: BorderSide(color: Color(0xFF4B5F69))),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: kClzYellow, size: 15),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Selected: $label',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
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

class _ProviderFlatIssueList extends StatelessWidget {
  const _ProviderFlatIssueList({
    required this.results,
    required this.issueSortAscending,
    required this.selectedProviderId,
    required this.checkedProviderIds,
    required this.providerLabel,
    required this.onSelectProvider,
    required this.onToggleProviderCheck,
  });

  final List<ProviderCandidate> results;
  final bool issueSortAscending;
  final String? selectedProviderId;
  final Set<String> checkedProviderIds;
  final String Function(String provider) providerLabel;
  final ValueChanged<String> onSelectProvider;
  final ValueChanged<String> onToggleProviderCheck;

  @override
  Widget build(BuildContext context) {
    final sortedResults = results.toList(growable: false)
      ..sort(
        (left, right) => issueSortAscending
            ? _compareProviderCandidates(left, right)
            : _compareProviderCandidates(right, left),
      );
    return ListView(
      children: [
        for (final item in sortedResults)
          _ProviderFlatIssueRow(
            candidate: item,
            selected: item.providerItemId == selectedProviderId,
            checked: checkedProviderIds.contains(item.providerItemId),
            providerLabel: providerLabel(item.provider),
            onSelect: () => onSelectProvider(item.providerItemId),
            onToggleCheck: () => onToggleProviderCheck(item.providerItemId),
          ),
      ],
    );
  }
}

class _ProviderFlatIssueRow extends StatelessWidget {
  const _ProviderFlatIssueRow({
    required this.candidate,
    required this.selected,
    required this.checked,
    required this.providerLabel,
    required this.onSelect,
    required this.onToggleCheck,
  });

  final ProviderCandidate candidate;
  final bool selected;
  final bool checked;
  final String providerLabel;
  final VoidCallback onSelect;
  final VoidCallback onToggleCheck;

  @override
  Widget build(BuildContext context) {
    final identity = _providerCandidateIdentity(candidate);
    final title = [
      identity.issueLabel,
      if (identity.variantLabel != 'Standard cover') identity.variantLabel,
    ].join(' | ');
    return AddResultRow(
      key: ValueKey(
        'provider-flat-${candidate.provider}-${candidate.providerItemId}',
      ),
      selected: selected,
      checked: checked,
      checkDisabled: false,
      cover: SizedBox(
        width: 42,
        height: 62,
        child: ProviderCandidateImage(
          key: ValueKey(
            'provider-flat-cover-${candidate.provider}-${candidate.providerItemId}-${candidate.imageUrl ?? ''}',
          ),
          candidate: candidate,
          fallbackTitle: title,
        ),
      ),
      title: title,
      subtitle: _providerCandidateSubtitle(candidate, providerLabel),
      badges: [
        providerLabel,
        if (identity.isVariant) 'variant',
      ],
      trailing: 'propose',
      onTap: onSelect,
      onToggleCheck: onToggleCheck,
    );
  }
}

class _ProviderSeriesHeader extends StatelessWidget {
  const _ProviderSeriesHeader({
    required this.group,
    required this.isCollapsed,
    required this.onToggleCollapsed,
  });

  final _ProviderSeriesGroup group;
  final bool isCollapsed;
  final VoidCallback onToggleCollapsed;

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
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
          child: Row(
            children: [
              Tooltip(
                message: isCollapsed ? 'Expand series' : 'Collapse series',
                child: Icon(
                  isCollapsed
                      ? Icons.keyboard_arrow_right
                      : Icons.keyboard_arrow_down,
                  size: 18,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.folder_open, size: 16, color: kClzAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      group.subtitle,
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
              const SizedBox(width: 8),
              LibraryAddResultBadge('${group.issueCount} issue'
                  '${group.issueCount == 1 ? '' : 's'}'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderIssueHeader extends StatelessWidget {
  const _ProviderIssueHeader({
    required this.group,
    required this.isCollapsed,
    required this.onToggleCollapsed,
  });

  final _ProviderIssueGroup group;
  final bool isCollapsed;
  final VoidCallback onToggleCollapsed;

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
              const Icon(Icons.menu_book, size: 16, color: kClzAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.issueLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      group.subtitle,
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
              const SizedBox(width: 8),
              LibraryAddResultBadge(
                '${group.totalCount} cover'
                '${group.totalCount == 1 ? '' : 's'}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderIssueRow extends StatelessWidget {
  const _ProviderIssueRow({
    required this.candidate,
    required this.selected,
    required this.checked,
    required this.providerLabel,
    required this.isChild,
    required this.onSelect,
    required this.onToggleCheck,
  });

  final ProviderCandidate candidate;
  final bool selected;
  final bool checked;
  final String providerLabel;
  final bool isChild;
  final VoidCallback onSelect;
  final VoidCallback onToggleCheck;

  @override
  Widget build(BuildContext context) {
    final variantLabel = _providerVariantLabel(candidate);
    return Padding(
      padding: EdgeInsets.only(left: isChild ? 50 : 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isChild)
            const SizedBox(
              width: 18,
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 13),
                  child: Icon(
                    Icons.subdirectory_arrow_right,
                    color: Color(0xFF7D8A92),
                    size: 14,
                  ),
                ),
              ),
            ),
          Expanded(
            child: AddResultRow(
              key: ValueKey(
                'provider-row-${candidate.provider}-${candidate.providerItemId}',
              ),
              selected: selected,
              checked: checked,
              checkDisabled: false,
              cover: SizedBox(
                width: 42,
                height: 62,
                child: ProviderCandidateImage(
                  key: ValueKey(
                    'provider-cover-${candidate.provider}-${candidate.providerItemId}-${candidate.imageUrl ?? ''}',
                  ),
                  candidate: candidate,
                  fallbackTitle: variantLabel,
                ),
              ),
              title: variantLabel,
              subtitle: _providerCandidateSubtitle(candidate, providerLabel),
              badges: [
                providerLabel,
                if (candidate.isVariant) 'variant',
              ],
              trailing: 'propose',
              onTap: onSelect,
              onToggleCheck: onToggleCheck,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderIssueGroup {
  const _ProviderIssueGroup({
    required this.issueLabel,
    required this.issueSortValue,
    required this.collapseKey,
    required this.items,
  });

  final String issueLabel;
  final double? issueSortValue;
  final String collapseKey;
  final List<ProviderCandidate> items;

  ProviderCandidate get cover {
    for (final item in items) {
      if (!item.isVariant) {
        return item;
      }
    }
    return items.first;
  }

  List<ProviderCandidate> get sortedItems {
    final standards = <ProviderCandidate>[];
    final variants = <ProviderCandidate>[];
    for (final item in items) {
      if (item.isVariant) {
        variants.add(item);
      } else {
        standards.add(item);
      }
    }
    variants.sort(
      (left, right) =>
          _providerVariantLabel(left).compareTo(_providerVariantLabel(right)),
    );
    return [...standards, ...variants];
  }

  int get totalCount => items.length;

  int get standardCount => items.where((item) => !item.isVariant).length;

  int get variantCount => items.length - standardCount;

  String get subtitle {
    return [
      if (standardCount > 0)
        '$standardCount standard cover${standardCount == 1 ? '' : 's'}',
      if (variantCount > 0)
        '$variantCount variant cover${variantCount == 1 ? '' : 's'}',
    ].join(' | ');
  }
}

class _ProviderSeriesGroup {
  const _ProviderSeriesGroup({
    required this.title,
    required this.collapseKey,
    required this.issues,
  });

  final String title;
  final String collapseKey;
  final List<_ProviderIssueGroup> issues;

  int get issueCount => issues.length;

  int get totalCount =>
      issues.fold(0, (total, issue) => total + issue.items.length);

  int get variantCount =>
      issues.fold(0, (total, issue) => total + issue.variantCount);

  String get subtitle {
    return [
      '$issueCount issue${issueCount == 1 ? '' : 's'}',
      '$totalCount cover${totalCount == 1 ? '' : 's'}',
      if (variantCount > 0)
        '$variantCount variant${variantCount == 1 ? '' : 's'}',
    ].join(' | ');
  }
}

List<_ProviderSeriesGroup> _groupProviderResultsBySeries(
  List<ProviderCandidate> results, {
  required bool issueSortAscending,
}) {
  final grouped = <String, Map<String, List<ProviderCandidate>>>{};
  final seriesTitles = <String, String>{};
  final issueLabels = <String, Map<String, String>>{};
  final issueSortValues = <String, Map<String, double?>>{};
  for (final item in results) {
    final identity = _providerCandidateIdentity(item);
    final seriesKey =
        _normalizedProviderKey(item.provider, identity.seriesTitle);
    final issueKey = _normalizedProviderKey(
      item.provider,
      '${identity.seriesTitle} ${identity.issueLabel}',
    );
    grouped
        .putIfAbsent(seriesKey, () => <String, List<ProviderCandidate>>{})
        .putIfAbsent(issueKey, () => <ProviderCandidate>[])
        .add(item);
    seriesTitles.putIfAbsent(seriesKey, () => identity.seriesTitle);
    issueLabels
        .putIfAbsent(seriesKey, () => <String, String>{})
        .putIfAbsent(issueKey, () => identity.issueLabel);
    issueSortValues
        .putIfAbsent(seriesKey, () => <String, double?>{})
        .putIfAbsent(issueKey, () => identity.issueSortValue);
  }
  final seriesGroups = [
    for (final seriesEntry in grouped.entries)
      _ProviderSeriesGroup(
        title: seriesTitles[seriesEntry.key] ?? seriesEntry.key,
        collapseKey: 'provider-series:${seriesEntry.key}',
        issues: [
          for (final issueEntry in seriesEntry.value.entries)
            _ProviderIssueGroup(
              issueLabel:
                  issueLabels[seriesEntry.key]?[issueEntry.key] ?? 'Issue',
              issueSortValue: issueSortValues[seriesEntry.key]?[issueEntry.key],
              collapseKey: 'provider-issue:${issueEntry.key}',
              items: issueEntry.value,
            ),
        ]..sort(
            (left, right) => issueSortAscending
                ? _compareProviderIssueGroups(left, right)
                : _compareProviderIssueGroups(right, left),
          ),
      ),
  ];
  seriesGroups.sort((left, right) => left.title.compareTo(right.title));
  return seriesGroups;
}

int _compareProviderIssueGroups(
  _ProviderIssueGroup left,
  _ProviderIssueGroup right,
) {
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

int _compareProviderCandidates(
  ProviderCandidate left,
  ProviderCandidate right,
) {
  final leftIdentity = _providerCandidateIdentity(left);
  final rightIdentity = _providerCandidateIdentity(right);
  final issueCompare = _compareProviderIdentityIssues(
    leftIdentity,
    rightIdentity,
  );
  if (issueCompare != 0) {
    return issueCompare;
  }
  if (leftIdentity.isVariant != rightIdentity.isVariant) {
    return leftIdentity.isVariant ? 1 : -1;
  }
  return leftIdentity.variantLabel.compareTo(rightIdentity.variantLabel);
}

int _compareProviderIdentityIssues(
  _ProviderCandidateIdentity left,
  _ProviderCandidateIdentity right,
) {
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

String _providerIssueTitle(ProviderCandidate candidate) {
  final identity = _providerCandidateIdentity(candidate);
  return '${identity.seriesTitle} ${identity.issueLabel}'.trim();
}

_ProviderCandidateIdentity _providerCandidateIdentity(
  ProviderCandidate candidate,
) {
  final title = candidate.title.trim();
  final bracketMatch = RegExp(r'\s*\[[^\]]+\]\s*$').firstMatch(title);
  final bracketLabel = bracketMatch == null
      ? null
      : title
          .substring(bracketMatch.start, bracketMatch.end)
          .replaceAll(RegExp(r'^\s*\[|\]\s*$'), '')
          .trim();
  final titleWithoutBracket = bracketMatch == null
      ? title
      : title.substring(0, bracketMatch.start).trim();
  final issueMatch = RegExp(
    r'^(.+?)\s+#\s*([A-Za-z0-9][A-Za-z0-9./-]*)(.*)$',
  ).firstMatch(titleWithoutBracket);
  if (issueMatch == null) {
    return _ProviderCandidateIdentity(
      seriesTitle:
          titleWithoutBracket.isEmpty ? candidate.title : titleWithoutBracket,
      issueLabel: 'Result',
      variantLabel: _providerVariantLabelFromParts(
        candidate,
        bracketLabel: bracketLabel,
      ),
    );
  }

  final seriesTitle = issueMatch.group(1)!.trim();
  final issueNumber = issueMatch.group(2)!.trim();
  final trailing = issueMatch.group(3)!.trim().replaceFirst(
        RegExp(r'^[\s:|\-]+'),
        '',
      );
  return _ProviderCandidateIdentity(
    seriesTitle: seriesTitle.isEmpty ? titleWithoutBracket : seriesTitle,
    issueLabel: '#$issueNumber',
    issueSortValue: double.tryParse(issueNumber),
    variantLabel: _providerVariantLabelFromParts(
      candidate,
      bracketLabel: bracketLabel,
      trailingLabel: trailing,
    ),
  );
}

String _providerVariantLabel(ProviderCandidate candidate) {
  return _providerCandidateIdentity(candidate).variantLabel;
}

String _providerVariantLabelFromParts(
  ProviderCandidate candidate, {
  String? bracketLabel,
  String? trailingLabel,
}) {
  final title = candidate.title.trim();
  final cleanTrailing = trailingLabel == null || trailingLabel.trim().isEmpty
      ? null
      : trailingLabel.trim();
  if (candidate.isVariant) {
    return bracketLabel == null || bracketLabel.isEmpty
        ? cleanTrailing ?? 'Variant cover'
        : bracketLabel;
  }
  if (bracketLabel != null && bracketLabel.isNotEmpty) {
    return 'Standard cover | $bracketLabel';
  }
  return cleanTrailing ?? (title.isEmpty ? 'Standard cover' : 'Standard cover');
}

String _providerCandidateSubtitle(
  ProviderCandidate candidate,
  String providerLabel,
) {
  final issueTitle = _providerIssueTitle(candidate);
  final summary = candidate.summary?.trim();
  return [
    issueTitle,
    if (summary != null && summary.isNotEmpty) summary,
  ].join(' | ').trim().isEmpty
      ? '$providerLabel candidate'
      : [
          issueTitle,
          if (summary != null && summary.isNotEmpty) summary,
        ].join(' | ');
}

String _normalizedProviderKey(String provider, String title) {
  final normalized = '$provider $title'
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return normalized.isEmpty ? provider : normalized;
}

class _ProviderCandidateIdentity {
  const _ProviderCandidateIdentity({
    required this.seriesTitle,
    required this.issueLabel,
    required this.variantLabel,
    this.issueSortValue,
  });

  final String seriesTitle;
  final String issueLabel;
  final double? issueSortValue;
  final String variantLabel;

  bool get isVariant =>
      variantLabel != 'Standard cover' &&
      !variantLabel.startsWith('Standard cover |');
}

class _SearchSkeletonState extends StatelessWidget {
  const _SearchSkeletonState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _PulseSkeleton(
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 7,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return _SkeletonResultRow(
                    shortSubtitle: index.isOdd,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseSkeleton extends StatefulWidget {
  const _PulseSkeleton({required this.child});

  final Widget child;

  @override
  State<_PulseSkeleton> createState() => _PulseSkeletonState();
}

class _PulseSkeletonState extends State<_PulseSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.44, end: 0.82).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}

class _SkeletonResultRow extends StatelessWidget {
  const _SkeletonResultRow({required this.shortSubtitle});

  final bool shortSubtitle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF242729),
        border: Border(bottom: BorderSide(color: Color(0xFF36393B))),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            _SkeletonBox(width: 18, height: 18, radius: 3),
            const SizedBox(width: 10),
            _SkeletonBox(width: 42, height: 62, radius: 3),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FractionallySizedBox(
                    widthFactor: 0.78,
                    child: _SkeletonBox(height: 13, radius: 3),
                  ),
                  const SizedBox(height: 8),
                  FractionallySizedBox(
                    widthFactor: shortSubtitle ? 0.46 : 0.66,
                    child: const _SkeletonBox(height: 11, radius: 3),
                  ),
                  const SizedBox(height: 9),
                  const FractionallySizedBox(
                    widthFactor: 0.34,
                    child: _SkeletonBox(height: 16, radius: 4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    this.width,
    required this.height,
    required this.radius,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF536A78),
        borderRadius: BorderRadius.circular(radius),
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
  const _IssueSortButton({
    required this.label,
    required this.tooltip,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final String tooltip;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF159AC8) : const Color(0xFF555555),
            border: Border.all(
              color: selected ? kClzAccent : const Color(0xFF666666),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}
