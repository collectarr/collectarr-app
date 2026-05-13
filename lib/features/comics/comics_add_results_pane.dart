import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/comics/comics_add_core_results.dart';
import 'package:collectarr_app/features/comics/comics_add_images.dart';
import 'package:collectarr_app/features/comics/comics_add_pull_list.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/library/add/library_add_mode.dart';
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
      return AddCoreResults(
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
          return AddResultRow(
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
