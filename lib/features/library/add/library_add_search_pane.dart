part of 'library_add_dialog.dart';

class _SearchPane extends StatelessWidget {
  const _SearchPane({
    required this.type,
    required this.isBusy,
    required this.isMovieDesktopChrome,
    required this.error,
    required this.accent,
    required this.results,
    required this.providerResults,
    required this.queuedProviderIngests,
    required this.selectedProvider,
    required this.searchedProvider,
    required this.selectedResultId,
    required this.selectedProviderCandidateId,
    required this.checkedResultIds,
    required this.checkedProviderIds,
    required this.ownedCatalogItemIds,
    required this.providerQueryText,
    required this.providerSeriesText,
    required this.providerNumberText,
    required this.providerPublisherText,
    required this.providerYearText,
    required this.onSelectResult,
    required this.onSelectProviderCandidate,
    required this.onToggleResultCheck,
    required this.onToggleProviderCheck,
    required this.onSearchCore,
  });

  final LibraryTypeConfig type;
  final bool isBusy;
  final bool isMovieDesktopChrome;
  final String? error;
  final Color accent;
  final List<LibraryMetadataItem> results;
  final List<ProviderCandidate> providerResults;
  final Map<String, LibraryQueuedProviderIngest> queuedProviderIngests;
  final String selectedProvider;
  final bool searchedProvider;
  final String? selectedResultId;
  final String? selectedProviderCandidateId;
  final Set<String> checkedResultIds;
  final Set<String> checkedProviderIds;
  final Set<String> ownedCatalogItemIds;
  final String providerQueryText;
  final String providerSeriesText;
  final String providerNumberText;
  final String providerPublisherText;
  final String providerYearText;
  final ValueChanged<String> onSelectResult;
  final ValueChanged<String> onSelectProviderCandidate;
  final ValueChanged<String> onToggleResultCheck;
  final ValueChanged<String> onToggleProviderCheck;
  final VoidCallback onSearchCore;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panelRaised,
        border: Border(right: BorderSide(color: palette.divider)),
      ),
      child: _SearchResultsList(
        type: type,
        accent: accent,
        isMovieDesktopChrome: isMovieDesktopChrome,
        selectedProvider: selectedProvider,
        isBusy: isBusy,
        error: error,
        searchedProvider: searchedProvider,
        results: results,
        providerResults: providerResults,
        queuedProviderIngests: queuedProviderIngests,
        selectedResultId: selectedResultId,
        selectedProviderCandidateId: selectedProviderCandidateId,
        checkedResultIds: checkedResultIds,
        checkedProviderIds: checkedProviderIds,
        ownedCatalogItemIds: ownedCatalogItemIds,
        providerQueryText: providerQueryText,
        providerSeriesText: providerSeriesText,
        providerNumberText: providerNumberText,
        providerPublisherText: providerPublisherText,
        providerYearText: providerYearText,
        onSearchCore: onSearchCore,
        onSelectResult: onSelectResult,
        onSelectProviderCandidate: onSelectProviderCandidate,
        onToggleResultCheck: onToggleResultCheck,
        onToggleProviderCheck: onToggleProviderCheck,
      ),
    );
  }
}

class _SearchPaneNoticeStack extends StatelessWidget {
  const _SearchPaneNoticeStack({
    required this.error,
    required this.queuedProviderIngests,
    required this.isBusy,
    required this.accent,
    required this.onSearchCore,
  });

  final String? error;
  final Map<String, LibraryQueuedProviderIngest> queuedProviderIngests;
  final bool isBusy;
  final Color accent;
  final VoidCallback onSearchCore;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    if (error == null && queuedProviderIngests.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (queuedProviderIngests.isNotEmpty)
          _QueuedIngestNotice(
            count: queuedProviderIngests.length,
            accent: accent,
            onSearchCore: isBusy ? null : onSearchCore,
          ),
        if (error != null)
          Padding(
            padding: EdgeInsets.only(
              top: queuedProviderIngests.isNotEmpty ? 6 : 0,
            ),
            child: AppErrorBanner(error!),
          ),
        Divider(height: 1, thickness: 1, color: palette.divider),
      ],
    );
  }
}

class _QueuedIngestNotice extends StatelessWidget {
  const _QueuedIngestNotice({
    required this.count,
    required this.accent,
    required this.onSearchCore,
  });

  final int count;
  final Color accent;
  final VoidCallback? onSearchCore;

  @override
  Widget build(BuildContext context) {
    final jobLabel = count == 1 ? 'job' : 'jobs';
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: kAppBannerInfoBackground,
        border: Border.all(color: accent.withValues(alpha: 0.65)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        child: Row(
          children: [
            Icon(Icons.playlist_add_check, size: 18, color: accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$count Core ingest $jobLabel queued. Run or retry them in Admin, then search Core again.',
                style: TextStyle(
                  color: palette.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onSearchCore,
              style: libraryAddOutlinedButtonStyle(accent),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Search Core again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({
    required this.type,
    required this.accent,
    required this.isMovieDesktopChrome,
    required this.selectedProvider,
    required this.isBusy,
    required this.error,
    required this.searchedProvider,
    required this.results,
    required this.providerResults,
    required this.queuedProviderIngests,
    required this.selectedResultId,
    required this.selectedProviderCandidateId,
    required this.checkedResultIds,
    required this.checkedProviderIds,
    required this.ownedCatalogItemIds,
    required this.providerQueryText,
    required this.providerSeriesText,
    required this.providerNumberText,
    required this.providerPublisherText,
    required this.providerYearText,
    required this.onSearchCore,
    required this.onSelectResult,
    required this.onSelectProviderCandidate,
    required this.onToggleResultCheck,
    required this.onToggleProviderCheck,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final bool isMovieDesktopChrome;
  final String selectedProvider;
  final bool isBusy;
  final String? error;
  final bool searchedProvider;
  final List<LibraryMetadataItem> results;
  final List<ProviderCandidate> providerResults;
  final Map<String, LibraryQueuedProviderIngest> queuedProviderIngests;
  final String? selectedResultId;
  final String? selectedProviderCandidateId;
  final Set<String> checkedResultIds;
  final Set<String> checkedProviderIds;
  final Set<String> ownedCatalogItemIds;
  final String providerQueryText;
  final String providerSeriesText;
  final String providerNumberText;
  final String providerPublisherText;
  final String providerYearText;
  final VoidCallback onSearchCore;
  final ValueChanged<String> onSelectResult;
  final ValueChanged<String> onSelectProviderCandidate;
  final ValueChanged<String> onToggleResultCheck;
  final ValueChanged<String> onToggleProviderCheck;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final notice = _SearchPaneNoticeStack(
      error: error,
      queuedProviderIngests: queuedProviderIngests,
      isBusy: isBusy,
      accent: accent,
      onSearchCore: onSearchCore,
    );
    if (isBusy && results.isEmpty && providerResults.isEmpty) {
      return _SearchSkeletonList(notice: notice);
    }
    if (results.isEmpty && providerResults.isEmpty) {
      return ListView(
        padding: EdgeInsets.zero,
        children: [
          notice,
          SizedBox(
            height: 280,
            child: _NoSearchResults(
              type: type,
              accent: accent,
              selectedProvider: selectedProvider,
              searchedProvider: searchedProvider,
            ),
          ),
        ],
      );
    }
    if (isMovieDesktopChrome) {
      return _MovieSearchResultsGrid(
        type: type,
        accent: accent,
        results: results,
        providerResults: providerResults,
        queuedProviderIngests: queuedProviderIngests,
        selectedResultId: selectedResultId,
        selectedProviderCandidateId: selectedProviderCandidateId,
        checkedResultIds: checkedResultIds,
        ownedCatalogItemIds: ownedCatalogItemIds,
        providerLabel: type.metadataProviderLabel,
        queryText: providerQueryText,
        seriesText: providerSeriesText,
        numberText: providerNumberText,
        publisherText: providerPublisherText,
        yearText: providerYearText,
        onSelectResult: onSelectResult,
        onSelectProviderCandidate: onSelectProviderCandidate,
        onToggleResultCheck: onToggleResultCheck,
      );
    }
    final fallbackProviderLabel = _fallbackProviderLabel();
    // Hide mixed-provider summary; provider badges are sufficient.
    // final mixedProviderSummary = _mixedProviderSummary();
    final groups = _buildUnifiedGroups(
      coreResults: results,
      providerResults: providerResults,
    );
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        notice,
        if (fallbackProviderLabel != null)
          _ProviderFallbackNotice(
            requestedProvider: type.metadataProviderLabel(selectedProvider),
            fallbackProvider: fallbackProviderLabel,
          ),
        // mixed provider summary removed per UX preference.
        for (var i = 0; i < groups.length; i++) ...[
          _UnifiedGroupNode(
            key: ValueKey(groups[i].key),
            type: type,
            group: groups[i],
            accent: accent,
            selectedResultId: selectedResultId,
            selectedProviderCandidateId: selectedProviderCandidateId,
            checkedResultIds: checkedResultIds,
            ownedCatalogItemIds: ownedCatalogItemIds,
            queuedProviderIngests: queuedProviderIngests,
            providerLabel: type.metadataProviderLabel,
            onSelectResult: onSelectResult,
            onSelectProviderCandidate: onSelectProviderCandidate,
            onToggleResultCheck: onToggleResultCheck,
            onToggleProviderCheck: onToggleProviderCheck,
            queryText: providerQueryText,
            seriesText: providerSeriesText,
            numberText: providerNumberText,
            publisherText: providerPublisherText,
            yearText: providerYearText,
          ),
          if (i < groups.length - 1)
            Divider(height: 1, thickness: 1, color: palette.divider),
        ],
      ],
    );
  }

  String? _fallbackProviderLabel() {
    final providers = _providerIdsInOrder();
    if (providers.length != 1) {
      return null;
    }
    final onlyProvider = providers.first;
    if (onlyProvider != selectedProvider) {
      return type.metadataProviderLabel(onlyProvider);
    }
    return null;
  }

  List<String> _providerIdsInOrder() {
    final providers = <String>[];
    for (final item in providerResults) {
      if (!providers.contains(item.provider)) {
        providers.add(item.provider);
      }
    }
    return providers;
  }
}

class _MovieSearchResultsGrid extends StatelessWidget {
  const _MovieSearchResultsGrid({
    required this.type,
    required this.accent,
    required this.results,
    required this.providerResults,
    required this.queuedProviderIngests,
    required this.selectedResultId,
    required this.selectedProviderCandidateId,
    required this.checkedResultIds,
    required this.ownedCatalogItemIds,
    required this.providerLabel,
    required this.queryText,
    required this.seriesText,
    required this.numberText,
    required this.publisherText,
    required this.yearText,
    required this.onSelectResult,
    required this.onSelectProviderCandidate,
    required this.onToggleResultCheck,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final List<LibraryMetadataItem> results;
  final List<ProviderCandidate> providerResults;
  final Map<String, LibraryQueuedProviderIngest> queuedProviderIngests;
  final String? selectedResultId;
  final String? selectedProviderCandidateId;
  final Set<String> checkedResultIds;
  final Set<String> ownedCatalogItemIds;
  final String Function(String providerId) providerLabel;
  final String queryText;
  final String seriesText;
  final String numberText;
  final String publisherText;
  final String yearText;
  final ValueChanged<String> onSelectResult;
  final ValueChanged<String> onSelectProviderCandidate;
  final ValueChanged<String> onToggleResultCheck;

  @override
  Widget build(BuildContext context) {
    final entries = <_MovieSearchGridEntry>[
      for (final item in results) _MovieSearchGridEntry.core(item),
      for (final candidate in providerResults)
        _MovieSearchGridEntry.provider(candidate),
    ];
    final palette = appPalette(context);
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 174,
        mainAxisExtent: 292,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final item = entry.item;
        final candidate = entry.candidate;
        final isCore = item != null;
        final selected = isCore
            ? item.id == selectedResultId
            : candidate!.localCatalogId == selectedProviderCandidateId;
        final checked = isCore && checkedResultIds.contains(item.id);
        final title = isCore ? item.title : candidate!.title;
        final coverUrl = isCore ? item.displayCoverUrl : candidate!.imageUrl;
        final subtitle = isCore
            ? [
                if (item.releaseYear != null) item.releaseYear.toString(),
                if (item.publisher != null) item.publisher,
              ].whereType<String>().join(' · ')
            : [
                if (candidate != null) providerLabel(candidate.provider),
                if (candidate?.summary?.trim().isNotEmpty == true)
                  candidate?.summary,
              ].whereType<String>().join(' · ');
        final matchSummary = isCore
            ? _metadataItemMatchSummary(
                type: type,
                item: item,
                queryText: queryText,
                seriesText: seriesText,
                numberText: numberText,
                publisherText: publisherText,
                yearText: yearText,
              )
            : _providerCandidateMatchSummary(
                type: type,
                candidate: candidate!,
                queryText: queryText,
                seriesText: seriesText,
                numberText: numberText,
                publisherText: publisherText,
                yearText: yearText,
              );
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isCore
                ? () => onSelectResult(item.id)
                : () => onSelectProviderCandidate(candidate!.localCatalogId),
            borderRadius: BorderRadius.circular(8),
            child: Ink(
              decoration: BoxDecoration(
                color: selected
                    ? Color.alphaBlend(
                        accent.withValues(alpha: 0.22), palette.selection)
                    : palette.tableEvenRow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected ? accent : palette.divider,
                  width: selected ? 1.6 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LibraryCoverImage(
                                title: title,
                                imageUrl: coverUrl,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 6,
                            bottom: 6,
                            child: LibraryAddResultBadge(
                              isCore
                                  ? 'core'
                                  : providerLabel(candidate!.provider),
                              accent: accent,
                            ),
                          ),
                          if (isCore)
                            Positioned(
                              right: 4,
                              top: 4,
                              child: InkWell(
                                onTap: () => onToggleResultCheck(item.id),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    checked
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    size: 18,
                                    color: checked ? accent : Colors.white,
                                  ),
                                ),
                              ),
                            )
                          else if (queuedProviderIngests[
                                  candidate!.localCatalogId] !=
                              null)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Icon(
                                Icons.playlist_add_check,
                                size: 18,
                                color: accent,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if (matchSummary != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Matched on: $matchSummary',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: accent.withValues(alpha: 0.92),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                    if (isCore && ownedCatalogItemIds.contains(item.id)) ...[
                      const SizedBox(height: 5),
                      const LibraryAddResultBadge('In collection'),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MovieSearchGridEntry {
  const _MovieSearchGridEntry.core(this.item) : candidate = null;
  const _MovieSearchGridEntry.provider(this.candidate) : item = null;

  final LibraryMetadataItem? item;
  final ProviderCandidate? candidate;
}

class _SearchSkeletonList extends StatelessWidget {
  const _SearchSkeletonList({required this.notice});

  final Widget notice;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        notice,
        const Padding(
          padding: EdgeInsets.all(8),
          child: _ResultSectionHeader(label: 'Searching'),
        ),
        for (var index = 0; index < 6; index++) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color:
                    index.isEven ? palette.tableEvenRow : palette.tableOddRow,
                border: Border.all(color: palette.tableBottomBorder),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    _SkeletonBox(width: 42, height: 56),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SkeletonBox(width: 220, height: 13),
                          SizedBox(height: 8),
                          _SkeletonBox(width: 320, height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: palette.surfaceBright,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _ProviderFallbackNotice extends StatelessWidget {
  const _ProviderFallbackNotice({
    required this.requestedProvider,
    required this.fallbackProvider,
  });

  final String requestedProvider;
  final String fallbackProvider;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: kAppBannerWarningBackground,
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      child: Row(
        children: [
          const Icon(Icons.swap_horiz, size: 18, color: kAppHighlight),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$requestedProvider unavailable, $fallbackProvider fallback used.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultSectionHeader extends StatelessWidget {
  const _ResultSectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: palette.panelRaised,
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: palette.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.type,
    required this.item,
    required this.accent,
    required this.queryText,
    required this.seriesText,
    required this.numberText,
    required this.publisherText,
    required this.yearText,
    required this.selected,
    required this.checked,
    this.isOwned = false,
    required this.onSelect,
    required this.onToggleCheck,
  });

  final LibraryTypeConfig type;
  final LibraryMetadataItem item;
  final Color accent;
  final String queryText;
  final String seriesText;
  final String numberText;
  final String publisherText;
  final String yearText;
  final bool selected;
  final bool checked;
  final bool isOwned;
  final VoidCallback onSelect;
  final VoidCallback onToggleCheck;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final matchSummary = _metadataItemMatchSummary(
      type: type,
      item: item,
      queryText: queryText,
      seriesText: seriesText,
      numberText: numberText,
      publisherText: publisherText,
      yearText: yearText,
    );
    final resultDisplay =
        type.presentation.builder.buildSearchResultDisplay(item: item);
    final subtitle = resultDisplay?.secondaryLine ??
        [
          if (item.publisher != null) item.publisher,
          if (item.releaseYear != null) item.releaseYear.toString(),
          if (item.physicalFormatLabel != null) item.physicalFormatLabel,
          if (item.variant != null) item.variant,
          if (item.barcode != null) item.barcode,
        ].whereType<String>().join(' | ');
    final detailLine = resultDisplay?.detailLine;
    return InkWell(
      onTap: onSelect,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected
              ? Color.alphaBlend(
                  accent.withValues(alpha: 0.46), palette.selection)
              : palette.tableEvenRow,
          border: Border(
            left: BorderSide(
              color: selected ? accent : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Checkbox(
                  value: checked,
                  onChanged: (_) => onToggleCheck(),
                  activeColor: accent,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              SizedBox(
                width: 38,
                height: 56,
                child: LibraryCoverImage(
                  title: item.title,
                  itemNumber: item.itemNumber,
                  imageUrl: item.displayCoverUrl,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 170;
                    final showDetailLine =
                        detailLine != null && detailLine.trim().isNotEmpty;
                    final showMatchSummary =
                        matchSummary != null && (!compact || !showDetailLine);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          resultDisplay?.title ??
                              (item.itemNumber == null
                                  ? item.title
                                  : '${item.title} #${item.itemNumber}'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            maxLines: compact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: palette.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        if (showDetailLine) ...[
                          const SizedBox(height: 2),
                          Text(
                            detailLine,
                            maxLines: compact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: palette.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        if (showMatchSummary) ...[
                          const SizedBox(height: 3),
                          Text(
                            'Matched on: $matchSummary',
                            maxLines: compact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: accent.withValues(alpha: 0.9),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                        const SizedBox(height: 5),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              if (isOwned) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color:
                                          Colors.green.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  child: const Text(
                                    'In collection',
                                    style: TextStyle(
                                      color: Colors.greenAccent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                              ],
                              const LibraryAddResultBadge('core'),
                              const SizedBox(width: 4),
                              LibraryAddResultBadge(item.kind),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String? _metadataItemMatchSummary({
  required LibraryTypeConfig type,
  required LibraryMetadataItem item,
  required String queryText,
  required String seriesText,
  required String numberText,
  required String publisherText,
  required String yearText,
}) {
  final groupLabels = libraryMediaGroupLabels(type);
  final fieldLabels = type.mediaFields;
  final series = item.series;
  final reasons = <String>[];
  final seen = <String>{};

  void addIfMatch(String label, String needle, List<String?> haystacks) {
    final normalizedNeedle = needle.trim().toLowerCase();
    if (normalizedNeedle.isEmpty || !seen.add(label)) {
      return;
    }
    for (final haystack in haystacks) {
      final normalizedHaystack = haystack?.trim().toLowerCase();
      if (normalizedHaystack != null &&
          normalizedHaystack.isNotEmpty &&
          normalizedHaystack.contains(normalizedNeedle)) {
        reasons.add(label);
        return;
      }
    }
    seen.remove(label);
  }

  addIfMatch('Title', queryText, [item.title]);
  addIfMatch(groupLabels.series, seriesText, [series?.seriesTitle]);
  addIfMatch(groupLabels.publisher, publisherText, [item.publisher]);
  addIfMatch(fieldLabels.numberLabel, numberText, [
    item.itemNumber,
    series?.volumeName,
    series?.volumeNumber?.toString(),
    series?.seasonNumber?.toString(),
    series?.episodeNumber?.toString(),
    item.displayEditionLabel,
  ]);
  addIfMatch('Year', yearText, [
    item.releaseYear?.toString(),
    item.releaseDate?.year.toString(),
  ]);

  final generalQuery = queryText.trim();
  if (generalQuery.isNotEmpty) {
    addIfMatch(groupLabels.series, generalQuery, [series?.seriesTitle]);
    addIfMatch(groupLabels.publisher, generalQuery, [item.publisher]);
    addIfMatch(fieldLabels.numberLabel, generalQuery, [
      item.itemNumber,
      series?.volumeName,
      series?.volumeNumber?.toString(),
      series?.seasonNumber?.toString(),
      series?.episodeNumber?.toString(),
      item.displayEditionLabel,
      item.barcode,
    ]);
  }

  return reasons.isEmpty ? null : reasons.join(', ');
}

class _ProviderCandidateTile extends StatelessWidget {
  const _ProviderCandidateTile({
    required this.type,
    required this.candidate,
    required this.accent,
    required this.providerLabel,
    required this.queuedIngest,
    required this.providerQueryText,
    required this.providerSeriesText,
    required this.providerNumberText,
    required this.providerPublisherText,
    required this.providerYearText,
    required this.selected,
    required this.onSelect,
  });

  final LibraryTypeConfig type;
  final ProviderCandidate candidate;
  final Color accent;
  final String providerLabel;
  final LibraryQueuedProviderIngest? queuedIngest;
  final String providerQueryText;
  final String providerSeriesText;
  final String providerNumberText;
  final String providerPublisherText;
  final String providerYearText;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final matchSummary = _providerCandidateMatchSummary(
      type: type,
      candidate: candidate,
      queryText: providerQueryText,
      seriesText: providerSeriesText,
      numberText: providerNumberText,
      publisherText: providerPublisherText,
      yearText: providerYearText,
    );
    final subtitle = [
      providerLabel,
      if (candidate.isStub) 'Stub result',
      candidate.summary,
      candidate.providerItemId,
    ].whereType<String>().join(' | ');
    return InkWell(
      onTap: onSelect,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected
              ? Color.alphaBlend(
                  accent.withValues(alpha: 0.46), palette.selection)
              : palette.tableEvenRow,
          border: Border(
            left: BorderSide(
              color: selected ? accent : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: Row(
            children: [
              SizedBox(
                width: 42,
                height: 56,
                child: LibraryCoverImage(
                  title: candidate.title,
                  imageUrl: candidate.imageUrl,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 170;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          candidate.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            maxLines: compact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: palette.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        if (matchSummary != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            'Matched on: $matchSummary',
                            maxLines: compact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: accent.withValues(alpha: 0.9),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                        const SizedBox(height: 5),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              LibraryAddResultBadge(providerLabel),
                              if (candidate.isStub) ...[
                                const SizedBox(width: 5),
                                const LibraryAddResultBadge('stub'),
                              ],
                              if (queuedIngest != null) ...[
                                const SizedBox(width: 5),
                                LibraryAddResultBadge(
                                  '${queuedIngest!.statusLabel} ${queuedIngest!.shortId}',
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected ? Icons.check_circle : Icons.chevron_right,
                color: selected ? accent : palette.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String? _providerCandidateMatchSummary({
  required LibraryTypeConfig type,
  required ProviderCandidate candidate,
  required String queryText,
  required String seriesText,
  required String numberText,
  required String publisherText,
  required String yearText,
}) {
  final groupLabels = libraryMediaGroupLabels(type);
  final fieldLabels = type.mediaFields;
  final reasons = <String>[];
  final seen = <String>{};

  void addIfMatch(String label, String needle, List<String?> haystacks) {
    final normalizedNeedle = needle.trim().toLowerCase();
    if (normalizedNeedle.isEmpty || !seen.add(label)) {
      return;
    }
    for (final haystack in haystacks) {
      final normalizedHaystack = haystack?.trim().toLowerCase();
      if (normalizedHaystack != null &&
          normalizedHaystack.isNotEmpty &&
          normalizedHaystack.contains(normalizedNeedle)) {
        reasons.add(label);
        return;
      }
    }
    seen.remove(label);
  }

  addIfMatch('Title', queryText, [candidate.title]);
  addIfMatch(groupLabels.series, seriesText, [candidate.series?.seriesTitle]);
  addIfMatch(groupLabels.publisher, publisherText, [candidate.publisher]);
  addIfMatch(fieldLabels.numberLabel, numberText, [
    candidate.issueNumber,
    candidate.variantName,
  ]);
  addIfMatch('Year', yearText, [candidate.series?.volumeStartYear?.toString()]);

  final generalQuery = queryText.trim();
  if (generalQuery.isNotEmpty) {
    addIfMatch(
        groupLabels.series, generalQuery, [candidate.series?.seriesTitle]);
    addIfMatch(groupLabels.publisher, generalQuery, [candidate.publisher]);
    addIfMatch(fieldLabels.numberLabel, generalQuery, [
      candidate.issueNumber,
      candidate.variantName,
      candidate.series?.volumeStartYear?.toString(),
    ]);
    addIfMatch('Keyword', generalQuery, [
      candidate.summary,
      candidate.providerItemId,
    ]);
  }

  return reasons.isEmpty ? null : reasons.join(', ');
}

class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults({
    required this.type,
    required this.accent,
    required this.selectedProvider,
    required this.searchedProvider,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final String selectedProvider;
  final bool searchedProvider;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(type.workspace.icon, size: 28, color: accent),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Text(
                _message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _message {
    if (type.supportedMetadataProviders.isEmpty) {
      return 'No Core providers are configured for this library yet. Add a manual item to keep working locally.';
    }
    if (searchedProvider) {
      return 'No ${type.metadataProviderLabel(selectedProvider)} candidates found. Try a broader query or add a manual item.';
    }
    return 'Search Core, lookup a barcode, search ${type.metadataProviderLabel(selectedProvider)}, or add a manual item if Core is offline.';
  }
}
