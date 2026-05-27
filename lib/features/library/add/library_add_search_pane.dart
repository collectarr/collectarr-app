part of 'library_add_dialog.dart';

class _SearchPane extends StatelessWidget {
  const _SearchPane({
    required this.type,
    required this.isBusy,
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
  final String? error;
  final Color accent;
  final List<LibraryMetadataItem> results;
  final List<ProviderCandidate> providerResults;
  final Map<String, _QueuedProviderIngest> queuedProviderIngests;
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
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: kAppSurfaceSubtle,
        border: Border(right: BorderSide(color: kAppDivider)),
      ),
      child: _SearchResultsList(
        type: type,
        accent: accent,
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
  final Map<String, _QueuedProviderIngest> queuedProviderIngests;
  final bool isBusy;
  final Color accent;
  final VoidCallback onSearchCore;

  @override
  Widget build(BuildContext context) {
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
        const Divider(height: 1, thickness: 1, color: kAppDivider),
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
                style: const TextStyle(
                  color: kAppTextMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onSearchCore,
              style: _libraryAddOutlinedButtonStyle(accent),
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
  final String selectedProvider;
  final bool isBusy;
  final String? error;
  final bool searchedProvider;
  final List<LibraryMetadataItem> results;
  final List<ProviderCandidate> providerResults;
  final Map<String, _QueuedProviderIngest> queuedProviderIngests;
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
    final fallbackProviderLabel = _fallbackProviderLabel();
    final mixedProviderSummary = _mixedProviderSummary();
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
        if (mixedProviderSummary != null)
          _ProviderMixedNotice(summary: mixedProviderSummary),
        for (var i = 0; i < groups.length; i++) ...[
          _UnifiedGroupNode(
            key: ValueKey(groups[i].key),
            type: type,
            group: groups[i],
            accent: accent,
            selectedResultId: selectedResultId,
            selectedProviderCandidateId: selectedProviderCandidateId,
            checkedResultIds: checkedResultIds,
            checkedProviderIds: checkedProviderIds,
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
            const Divider(height: 1, thickness: 1, color: kAppDivider),
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

  String? _mixedProviderSummary() {
    final providers = _providerIdsInOrder();
    if (providers.length <= 1) {
      return null;
    }
    final labels = providers.map(type.metadataProviderLabel).toList(growable: false);
    if (providers.contains(selectedProvider)) {
      return 'Showing matches from ${_joinLabels(labels)}.';
    }
    return 'Requested ${type.metadataProviderLabel(selectedProvider)}, but showing matches from ${_joinLabels(labels)}.';
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

  String _joinLabels(List<String> labels) {
    if (labels.length <= 1) {
      return labels.isEmpty ? 'providers' : labels.first;
    }
    if (labels.length == 2) {
      return '${labels.first} and ${labels.last}';
    }
    final leading = labels.take(labels.length - 1).join(', ');
    return '$leading, and ${labels.last}';
  }
}

class _SearchSkeletonList extends StatelessWidget {
  const _SearchSkeletonList({required this.notice});

  final Widget notice;

  @override
  Widget build(BuildContext context) {
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
                color: index.isEven ? kAppTableEvenRow : kAppTableOddRow,
                border: Border.all(color: kAppTableBottomBorder),
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
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: kAppSurfaceBright,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        color: kAppBannerWarningBackground,
        border: Border(bottom: _kLibraryAddBorder),
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

class _ProviderMixedNotice extends StatelessWidget {
  const _ProviderMixedNotice({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        color: kAppBannerInfoBackground,
        border: Border(bottom: _kLibraryAddBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.layers_outlined, size: 18, color: kAppTextMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              summary,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: const BoxDecoration(
        color: kAppPanelRaised,
        border: Border(bottom: _kLibraryAddBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: kAppTextMuted,
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
    final matchSummary = _metadataItemMatchSummary(
      type: type,
      item: item,
      queryText: queryText,
      seriesText: seriesText,
      numberText: numberText,
      publisherText: publisherText,
      yearText: yearText,
    );
    final musicDisplay =
        item.kind == 'music' ? _musicSearchResultDisplay(item) : null;
    final subtitle = musicDisplay?.secondaryLine ?? [
      if (item.publisher != null) item.publisher,
      if (item.releaseYear != null) item.releaseYear.toString(),
      if (item.physicalFormatLabel != null) item.physicalFormatLabel,
      if (item.variant != null) item.variant,
      if (item.barcode != null) item.barcode,
    ].whereType<String>().join(' | ');
    final detailLine = musicDisplay?.detailLine;
    return InkWell(
      onTap: onSelect,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected
              ? Color.alphaBlend(accent.withValues(alpha: 0.46), kAppSelection)
              : kAppTableEvenRow,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      musicDisplay?.title ??
                          (item.itemNumber == null
                              ? item.title
                              : '${item.title} #${item.itemNumber}'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: kAppTextMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if (detailLine != null && detailLine.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        detailLine,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: kAppTextMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if (matchSummary != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        'Matched on: $matchSummary',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: accent.withValues(alpha: 0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Row(
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
                                color: Colors.green.withValues(alpha: 0.6),
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
                  ],
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

_MusicSearchResultDisplay _musicSearchResultDisplay(LibraryMetadataItem item) {
  final subtitle = _firstMeaningfulMusicValue([
    item.publishing?.subtitle,
    item.series?.volumeName,
    if ((item.series?.volumeNumber ?? 0) > 1) 'Disc ${item.series!.volumeNumber}',
  ], disallow: {item.title.trim().toLowerCase()});
  final cleanedTitle = _stripTrailingMusicDescriptor(item.title, subtitle);
  final artist = item.series?.seriesTitle?.trim();
  final format = item.physicalFormatLabel?.trim().isNotEmpty == true
      ? item.physicalFormatLabel!.trim()
      : item.variant?.trim();
  final trackCount = item.music?.trackCount;
  final catalogNumber = item.music?.catalogNumber?.trim();
  final detailParts = <String>[
    if (subtitle != null && subtitle.isNotEmpty) subtitle,
    if (format != null && format.isNotEmpty) format,
    if (trackCount != null)
      '$trackCount ${trackCount == 1 ? 'track' : 'tracks'}',
    if (item.barcode?.trim().isNotEmpty == true) item.barcode!.trim(),
    if (catalogNumber != null && catalogNumber.isNotEmpty) catalogNumber,
  ];
  return _MusicSearchResultDisplay(
    title: cleanedTitle.isEmpty ? item.title : cleanedTitle,
    secondaryLine: artist?.isNotEmpty == true ? artist : subtitle,
    detailLine: detailParts.isEmpty ? null : detailParts.join(' - '),
  );
}

String _stripTrailingMusicDescriptor(String title, String? descriptor) {
  final trimmedTitle = title.trim();
  final trimmedDescriptor = descriptor?.trim();
  if (trimmedDescriptor == null || trimmedDescriptor.isEmpty) {
    return trimmedTitle;
  }
  final lowerTitle = trimmedTitle.toLowerCase();
  final lowerDescriptor = trimmedDescriptor.toLowerCase();
  for (final separator in [' - ', ' – ', ' — ', ': ', ' ']) {
    final suffix = '$separator$trimmedDescriptor';
    if (lowerTitle.endsWith(suffix.toLowerCase())) {
      return trimmedTitle.substring(0, trimmedTitle.length - suffix.length).trimRight();
    }
  }
  if (lowerTitle == lowerDescriptor) {
    return title;
  }
  return trimmedTitle;
}

String? _firstMeaningfulMusicValue(
  Iterable<String?> values, {
  Set<String> disallow = const <String>{},
}) {
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      continue;
    }
    if (disallow.contains(trimmed.toLowerCase())) {
      continue;
    }
    return trimmed;
  }
  return null;
}

class _MusicSearchResultDisplay {
  const _MusicSearchResultDisplay({
    required this.title,
    required this.secondaryLine,
    required this.detailLine,
  });

  final String title;
  final String? secondaryLine;
  final String? detailLine;
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
  final _QueuedProviderIngest? queuedIngest;
  final String providerQueryText;
  final String providerSeriesText;
  final String providerNumberText;
  final String providerPublisherText;
  final String providerYearText;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
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
              ? Color.alphaBlend(accent.withValues(alpha: 0.46), kAppSelection)
              : kAppTableEvenRow,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: kAppTextMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if (matchSummary != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        'Matched on: $matchSummary',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: accent.withValues(alpha: 0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        LibraryAddResultBadge(providerLabel),
                        if (candidate.isStub)
                          const LibraryAddResultBadge('stub'),
                        if (queuedIngest != null)
                          LibraryAddResultBadge(
                            '${queuedIngest!.statusLabel} ${queuedIngest!.shortId}',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected ? Icons.check_circle : Icons.chevron_right,
                color: selected ? accent : kAppTextMuted,
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
    addIfMatch(groupLabels.series, generalQuery, [candidate.series?.seriesTitle]);
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
                style: const TextStyle(
                  color: kAppTextMuted,
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
