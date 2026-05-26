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
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        notice,
        if (results.isNotEmpty) ...[
          const _ResultSectionHeader(label: 'Collectarr Core'),
          ..._withDividers(
            context,
            [
              for (final item in results)
                _SearchResultTile(
                  type: type,
                  item: item,
                  accent: accent,
                  queryText: providerQueryText,
                  seriesText: providerSeriesText,
                  numberText: providerNumberText,
                  publisherText: providerPublisherText,
                  yearText: providerYearText,
                  selected: item.id == selectedResultId,
                  checked: checkedResultIds.contains(item.id),
                  onSelect: () => onSelectResult(item.id),
                  onToggleCheck: () => onToggleResultCheck(item.id),
                ),
            ],
          ),
        ],
        if (providerResults.isNotEmpty) ...[
          if (fallbackProviderLabel != null)
            _ProviderFallbackNotice(
              requestedProvider: type.metadataProviderLabel(selectedProvider),
              fallbackProvider: fallbackProviderLabel,
            ),
          if (mixedProviderSummary != null)
            _ProviderMixedNotice(summary: mixedProviderSummary),
          _ResultSectionHeader(
            label: _providerSectionLabel(),
          ),
          if (_usesTreeProviderCandidates(type))
            _ProviderCandidateTreeList(
              type: type,
              results: providerResults,
              accent: accent,
              selectedProviderCandidateId: selectedProviderCandidateId,
              queuedProviderIngests: queuedProviderIngests,
              providerLabel: type.metadataProviderLabel,
              onSelectProviderCandidate: onSelectProviderCandidate,
            )
          else
            ..._withDividers(
              context,
              [
                for (final candidate in providerResults)
                  _ProviderCandidateTile(
                  type: type,
                    candidate: candidate,
                    accent: accent,
                    providerLabel:
                        type.metadataProviderLabel(candidate.provider),
                    queuedIngest:
                        queuedProviderIngests[candidate.localCatalogId],
                  providerQueryText: providerQueryText,
                  providerSeriesText: providerSeriesText,
                  providerNumberText: providerNumberText,
                  providerPublisherText: providerPublisherText,
                  providerYearText: providerYearText,
                    selected:
                        candidate.localCatalogId == selectedProviderCandidateId,
                    onSelect: () =>
                        onSelectProviderCandidate(candidate.localCatalogId),
                  ),
              ],
            ),
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

  String _providerSectionLabel() {
    final providers = _providerIdsInOrder();
    if (providers.length == 1) {
      return '${type.metadataProviderLabel(providers.first)} candidates';
    }
    return 'Provider candidates';
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

  List<Widget> _withDividers(BuildContext context, List<Widget> tiles) {
    const divider = Divider(height: 1, thickness: 1, color: kAppDivider);
    final separated = <Widget>[];
    for (var index = 0; index < tiles.length; index++) {
      if (index > 0) {
        separated.add(divider);
      }
      separated.add(tiles[index]);
    }
    return separated;
  }
}

bool _usesTreeProviderCandidates(LibraryTypeConfig type) {
  return switch (type.workspace.kind) {
    CatalogMediaKind.comic || CatalogMediaKind.manga => true,
    _ => type.presentation.usesTreeProviderCandidates,
  };
}

class _ProviderCandidateTreeList extends StatelessWidget {
  const _ProviderCandidateTreeList({
    required this.type,
    required this.results,
    required this.accent,
    required this.selectedProviderCandidateId,
    required this.queuedProviderIngests,
    required this.providerLabel,
    required this.onSelectProviderCandidate,
  });

  final LibraryTypeConfig type;
  final List<ProviderCandidate> results;
  final Color accent;
  final String? selectedProviderCandidateId;
  final Map<String, _QueuedProviderIngest> queuedProviderIngests;
  final String Function(String providerId) providerLabel;
  final ValueChanged<String> onSelectProviderCandidate;

  @override
  Widget build(BuildContext context) {
    if (type.workspace.kind == CatalogMediaKind.comic) {
      return _ComicCandidateTreeList(
        type: type,
        results: results,
        accent: accent,
        selectedProviderCandidateId: selectedProviderCandidateId,
        queuedProviderIngests: queuedProviderIngests,
        providerLabel: providerLabel,
        onSelectProviderCandidate: onSelectProviderCandidate,
      );
    }
    return _MangaCandidateTreeList(
      results: results,
      accent: accent,
      selectedProviderCandidateId: selectedProviderCandidateId,
      queuedProviderIngests: queuedProviderIngests,
      providerLabel: providerLabel,
      onSelectProviderCandidate: onSelectProviderCandidate,
    );
  }
}

class _ComicCandidateTreeList extends StatelessWidget {
  const _ComicCandidateTreeList({
    required this.type,
    required this.results,
    required this.accent,
    required this.selectedProviderCandidateId,
    required this.queuedProviderIngests,
    required this.providerLabel,
    required this.onSelectProviderCandidate,
  });

  final LibraryTypeConfig type;
  final List<ProviderCandidate> results;
  final Color accent;
  final String? selectedProviderCandidateId;
  final Map<String, _QueuedProviderIngest> queuedProviderIngests;
  final String Function(String providerId) providerLabel;
  final ValueChanged<String> onSelectProviderCandidate;

  @override
  Widget build(BuildContext context) {
    final groups = _groupComicCandidateSeries(results);
    return Column(
      children: [
        for (var i = 0; i < groups.length; i++) ...[
          _ComicCandidateSeriesNode(
            key: ValueKey(groups[i].key),
            type: type,
            group: groups[i],
            accent: accent,
            selectedProviderCandidateId: selectedProviderCandidateId,
            queuedProviderIngests: queuedProviderIngests,
            providerLabel: providerLabel,
            onSelectProviderCandidate: onSelectProviderCandidate,
          ),
          if (i < groups.length - 1)
            const Divider(height: 1, thickness: 1, color: kAppDivider),
        ],
      ],
    );
  }
}

class _ComicCandidateSeriesGroup {
  const _ComicCandidateSeriesGroup({
    required this.key,
    required this.title,
    required this.provider,
    required this.publisher,
    required this.year,
    required this.seriesCandidate,
    required this.issueCandidates,
  });

  final String key;
  final String title;
  final String provider;
  final String? publisher;
  final int? year;
  final ProviderCandidate? seriesCandidate;
  final List<ProviderCandidate> issueCandidates;
}

List<_ComicCandidateSeriesGroup> _groupComicCandidateSeries(
  List<ProviderCandidate> results,
) {
  final orderedKeys = <String>[];
  final titles = <String, String>{};
  final providers = <String, String>{};
  final publishers = <String, String?>{};
  final years = <String, int?>{};
  final seriesCandidates = <String, ProviderCandidate>{};
  final issueCandidates = <String, List<ProviderCandidate>>{};

  for (final candidate in results) {
    final title = _comicSeriesTitle(candidate);
    final key = '${candidate.provider}::${title.toLowerCase()}';
    if (!titles.containsKey(key)) {
      orderedKeys.add(key);
      titles[key] = title;
      providers[key] = candidate.provider;
      publishers[key] = candidate.publisher;
      years[key] = candidate.series?.volumeStartYear;
      issueCandidates[key] = <ProviderCandidate>[];
    }
    publishers[key] ??= candidate.publisher;
    years[key] ??= candidate.series?.volumeStartYear;
    if (_isComicSeriesCandidate(candidate)) {
      seriesCandidates.putIfAbsent(key, () => candidate);
      continue;
    }
    issueCandidates[key]!.add(candidate);
  }

  return [
    for (final key in orderedKeys)
      _ComicCandidateSeriesGroup(
        key: key,
        title: titles[key]!,
        provider: providers[key]!,
        publisher: publishers[key],
        year: years[key],
        seriesCandidate: seriesCandidates[key],
        issueCandidates: [
          ...issueCandidates[key]!..sort(_compareComicIssueCandidates),
        ],
      ),
  ];
}

bool _isComicSeriesCandidate(ProviderCandidate candidate) {
  if (candidate.candidateType == 'series') {
    return true;
  }
  if (candidate.candidateType == 'issue' || candidate.isVariant) {
    return false;
  }
  final issueNumber = candidate.issueNumber?.trim();
  if (issueNumber != null && issueNumber.isNotEmpty) {
    return false;
  }
  return _comicTitleIssueMetadata(candidate.title) == null;
}

String _comicSeriesTitle(ProviderCandidate candidate) {
  final seriesTitle = candidate.series?.seriesTitle?.trim();
  if (seriesTitle != null && seriesTitle.isNotEmpty) {
    return seriesTitle;
  }
  final titleMetadata = _comicTitleIssueMetadata(candidate.title);
  if (titleMetadata != null) {
    return titleMetadata.seriesTitle;
  }
  final title = candidate.title.trim();
  return title.isEmpty ? 'Untitled series' : title;
}

class _ComicTitleIssueMetadata {
  const _ComicTitleIssueMetadata({
    required this.seriesTitle,
    required this.issueNumber,
  });

  final String seriesTitle;
  final String issueNumber;
}

_ComicTitleIssueMetadata? _comicTitleIssueMetadata(String title) {
  final trimmed = title.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  final match = RegExp(r'^(.*?)\s+#\s*([^\s\[]+)').firstMatch(trimmed);
  if (match == null) {
    return null;
  }
  final seriesTitle = (match.group(1) ?? '').trim();
  final issueNumber = (match.group(2) ?? '').trim();
  if (seriesTitle.isEmpty || issueNumber.isEmpty) {
    return null;
  }
  return _ComicTitleIssueMetadata(
    seriesTitle: seriesTitle,
    issueNumber: issueNumber,
  );
}

int _compareComicIssueCandidates(
  ProviderCandidate left,
  ProviderCandidate right,
) {
  final byIssue = _compareComicIssueNumbers(
    left.issueNumber,
    right.issueNumber,
  );
  if (byIssue != 0) {
    return byIssue;
  }
  return left.title.toLowerCase().compareTo(right.title.toLowerCase());
}

int _compareComicIssueNumbers(String? left, String? right) {
  final normalizedLeft = left?.trim();
  final normalizedRight = right?.trim();
  if (normalizedLeft == null || normalizedLeft.isEmpty) {
    return normalizedRight == null || normalizedRight.isEmpty ? 0 : 1;
  }
  if (normalizedRight == null || normalizedRight.isEmpty) {
    return -1;
  }
  final issuePattern = RegExp(r'^(\d+)([A-Za-z]*)$');
  final leftMatch = issuePattern.firstMatch(normalizedLeft);
  final rightMatch = issuePattern.firstMatch(normalizedRight);
  if (leftMatch != null && rightMatch != null) {
    final leftNumber = int.parse(leftMatch.group(1)!);
    final rightNumber = int.parse(rightMatch.group(1)!);
    if (leftNumber != rightNumber) {
      return leftNumber.compareTo(rightNumber);
    }
    return (leftMatch.group(2) ?? '')
        .toLowerCase()
        .compareTo((rightMatch.group(2) ?? '').toLowerCase());
  }
  return normalizedLeft.toLowerCase().compareTo(normalizedRight.toLowerCase());
}

class _ComicCandidateSeriesNode extends StatefulWidget {
  const _ComicCandidateSeriesNode({
    super.key,
    required this.type,
    required this.group,
    required this.accent,
    required this.selectedProviderCandidateId,
    required this.queuedProviderIngests,
    required this.providerLabel,
    required this.onSelectProviderCandidate,
  });

  final LibraryTypeConfig type;
  final _ComicCandidateSeriesGroup group;
  final Color accent;
  final String? selectedProviderCandidateId;
  final Map<String, _QueuedProviderIngest> queuedProviderIngests;
  final String Function(String providerId) providerLabel;
  final ValueChanged<String> onSelectProviderCandidate;

  @override
  State<_ComicCandidateSeriesNode> createState() =>
      _ComicCandidateSeriesNodeState();
}

class _ComicCandidateSeriesNodeState extends State<_ComicCandidateSeriesNode> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = true;
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final seriesCandidate = group.seriesCandidate;
    final isSelected =
        seriesCandidate?.localCatalogId == widget.selectedProviderCandidateId;
    final hasSelectedChild = group.issueCandidates.any(
      (candidate) =>
          candidate.localCatalogId == widget.selectedProviderCandidateId,
    );
    final highlighted = isSelected || hasSelectedChild;
    final rootImageUrl =
        seriesCandidate?.imageUrl ??
        (group.issueCandidates.isEmpty ? null : group.issueCandidates.first.imageUrl);
    final subtitleParts = <String>[
      widget.providerLabel(group.provider),
      if (group.publisher != null && group.publisher!.trim().isNotEmpty)
        group.publisher!,
      if (group.year != null) group.year.toString(),
      if (group.issueCandidates.isNotEmpty)
        '${group.issueCandidates.length} ${group.issueCandidates.length == 1 ? 'issue' : 'issues'}',
    ];
    final queuedIngest = seriesCandidate == null
        ? null
        : widget.queuedProviderIngests[seriesCandidate.localCatalogId];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlighted
            ? Color.alphaBlend(
                widget.accent.withValues(alpha: 0.38),
                kAppSelection,
              )
            : kAppTableEvenRow,
        border: Border(
          left: BorderSide(
            color: highlighted ? widget.accent : Colors.transparent,
            width: 4,
          ),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: seriesCandidate == null
                ? (group.issueCandidates.isEmpty
                    ? null
                    : () => setState(() => _expanded = !_expanded))
                : () => widget.onSelectProviderCandidate(
                      seriesCandidate.localCatalogId,
                    ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              child: Row(
                children: [
                  IconButton(
                    tooltip: _expanded ? 'Collapse issues' : 'Expand issues',
                    onPressed: group.issueCandidates.isEmpty
                        ? null
                        : () => setState(() => _expanded = !_expanded),
                    icon: Icon(
                      _expanded ? Icons.expand_more : Icons.chevron_right,
                      color: widget.accent,
                      size: 20,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  SizedBox(
                    width: 42,
                    height: 56,
                    child: LibraryCoverImage(
                      title: group.title,
                      imageUrl: rootImageUrl,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (subtitleParts.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitleParts.join(' | '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: kAppTextMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 5,
                          runSpacing: 4,
                          children: [
                            LibraryAddResultBadge(
                              widget.providerLabel(group.provider),
                            ),
                            if (seriesCandidate != null)
                              const LibraryAddResultBadge('series'),
                            if (queuedIngest != null)
                              LibraryAddResultBadge(
                                '${queuedIngest.statusLabel} ${queuedIngest.shortId}',
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isSelected
                        ? Icons.check_circle
                        : (_expanded ? Icons.expand_less : Icons.expand_more),
                    color: isSelected ? widget.accent : kAppTextMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded && group.issueCandidates.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(56, 0, 12, 8),
              child: Column(
                children: [
                  for (var i = 0; i < group.issueCandidates.length; i++) ...[
                    _ComicCandidateIssueNode(
                      type: widget.type,
                      candidate: group.issueCandidates[i],
                      accent: widget.accent,
                      providerLabel: widget.providerLabel,
                      queuedIngest: widget.queuedProviderIngests[
                        group.issueCandidates[i].localCatalogId
                      ],
                      selected: group.issueCandidates[i].localCatalogId ==
                          widget.selectedProviderCandidateId,
                      onSelect: () => widget.onSelectProviderCandidate(
                        group.issueCandidates[i].localCatalogId,
                      ),
                    ),
                    if (i < group.issueCandidates.length - 1)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: kAppDivider,
                      ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ComicCandidateIssueNode extends StatelessWidget {
  const _ComicCandidateIssueNode({
    required this.type,
    required this.candidate,
    required this.accent,
    required this.providerLabel,
    required this.queuedIngest,
    required this.selected,
    required this.onSelect,
  });

  final LibraryTypeConfig type;
  final ProviderCandidate candidate;
  final Color accent;
  final String Function(String providerId) providerLabel;
  final _QueuedProviderIngest? queuedIngest;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final labels = type.mediaFields;
    final titleIssueMetadata = _comicTitleIssueMetadata(candidate.title);
    final resolvedIssueNumber = candidate.issueNumber?.trim().isNotEmpty ?? false
        ? candidate.issueNumber!.trim()
        : titleIssueMetadata?.issueNumber;
    final subtitleParts = <String>[
      if (resolvedIssueNumber != null && resolvedIssueNumber.isNotEmpty)
        '${labels.numberLabel}: $resolvedIssueNumber',
      if (candidate.variantName != null && candidate.variantName!.trim().isNotEmpty)
        candidate.variantName!,
      if (candidate.publisher != null && candidate.publisher!.trim().isNotEmpty)
        candidate.publisher!,
    ];
    return InkWell(
      onTap: onSelect,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected
              ? Color.alphaBlend(accent.withValues(alpha: 0.28), kAppSelection)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: selected ? accent : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              const Icon(
                Icons.subdirectory_arrow_right,
                size: 16,
                color: kAppTextMuted,
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 30,
                height: 42,
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
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitleParts.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitleParts.join(' | '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: kAppTextMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        LibraryAddResultBadge(providerLabel(candidate.provider)),
                        if (candidate.isVariant)
                          const LibraryAddResultBadge('variant'),
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
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MangaCandidateTreeList extends StatelessWidget {
  const _MangaCandidateTreeList({
    required this.results,
    required this.accent,
    required this.selectedProviderCandidateId,
    required this.queuedProviderIngests,
    required this.providerLabel,
    required this.onSelectProviderCandidate,
  });

  final List<ProviderCandidate> results;
  final Color accent;
  final String? selectedProviderCandidateId;
  final Map<String, _QueuedProviderIngest> queuedProviderIngests;
  final String Function(String providerId) providerLabel;
  final ValueChanged<String> onSelectProviderCandidate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < results.length; i++) ...[
          _MangaCandidateNode(
            key: ValueKey(results[i].localCatalogId),
            candidate: results[i],
            accent: accent,
            providerLabel: providerLabel(results[i].provider),
            queuedIngest: queuedProviderIngests[results[i].localCatalogId],
            selected: results[i].localCatalogId == selectedProviderCandidateId,
            onSelect: () =>
                onSelectProviderCandidate(results[i].localCatalogId),
          ),
          if (i < results.length - 1)
            const Divider(height: 1, thickness: 1, color: kAppDivider),
        ],
      ],
    );
  }
}

class _MangaCandidateNode extends ConsumerStatefulWidget {
  const _MangaCandidateNode({
    super.key,
    required this.candidate,
    required this.accent,
    required this.providerLabel,
    required this.queuedIngest,
    required this.selected,
    required this.onSelect,
  });

  final ProviderCandidate candidate;
  final Color accent;
  final String providerLabel;
  final _QueuedProviderIngest? queuedIngest;
  final bool selected;
  final VoidCallback onSelect;

  @override
  ConsumerState<_MangaCandidateNode> createState() =>
      _MangaCandidateNodeState();
}

class _MangaCandidateNodeState extends ConsumerState<_MangaCandidateNode> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final candidate = widget.candidate;
    final subtitle = [
      widget.providerLabel,
      if (candidate.summary != null && candidate.summary!.trim().isNotEmpty)
        candidate.summary,
    ].whereType<String>().join(' | ');
    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.selected
            ? Color.alphaBlend(
                widget.accent.withValues(alpha: 0.46), kAppSelection)
            : kAppTableEvenRow,
        border: Border(
          left: BorderSide(
            color: widget.selected ? widget.accent : Colors.transparent,
            width: 4,
          ),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: widget.onSelect,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    tooltip: _expanded ? 'Collapse volumes' : 'Expand volumes',
                    onPressed: () => setState(() => _expanded = !_expanded),
                    icon: Icon(
                      _expanded ? Icons.expand_more : Icons.chevron_right,
                      color: widget.accent,
                      size: 20,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
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
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 5,
                          runSpacing: 4,
                          children: [
                            LibraryAddResultBadge(widget.providerLabel),
                            if (widget.queuedIngest != null)
                              LibraryAddResultBadge(
                                '${widget.queuedIngest!.statusLabel} ${widget.queuedIngest!.shortId}',
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    widget.selected ? Icons.check_circle : Icons.chevron_right,
                    color: widget.selected ? widget.accent : kAppTextMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(56, 0, 12, 10),
              child: _MangaCandidateVolumes(
                candidate: candidate,
                accent: widget.accent,
              ),
            ),
        ],
      ),
    );
  }
}

class _MangaCandidateVolumes extends ConsumerWidget {
  const _MangaCandidateVolumes({
    required this.candidate,
    required this.accent,
  });

  final ProviderCandidate candidate;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volumesAsync = ref.watch(
      volumesProvider(
        (
          provider: candidate.provider,
          providerItemId: candidate.providerItemId
        ),
      ),
    );
    return volumesAsync.when(
      loading: () => Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Loading volumes and chapters...',
              style: TextStyle(color: kAppTextMuted),
            ),
          ),
        ],
      ),
      error: (_, __) => const Text(
        'Volumes/chapters are not available for this candidate right now.',
        style: TextStyle(color: kAppTextMuted),
      ),
      data: (volumes) {
        if (volumes.isEmpty) {
          return const Text(
            'No volume/chapter data returned for this candidate.',
            style: TextStyle(color: kAppTextMuted),
          );
        }
        return Column(
          children: [
            for (final volume in volumes)
              _MangaVolumeNode(
                volume: volume,
                accent: accent,
              ),
          ],
        );
      },
    );
  }
}

class _MangaVolumeNode extends StatefulWidget {
  const _MangaVolumeNode({
    required this.volume,
    required this.accent,
  });

  final Season volume;
  final Color accent;

  @override
  State<_MangaVolumeNode> createState() => _MangaVolumeNodeState();
}

class _MangaVolumeNodeState extends State<_MangaVolumeNode> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final volume = widget.volume;
    final chapters = volume.episodes;
    final count = volume.episodeCount ?? chapters.length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: kAppDivider),
          color: Colors.white.withValues(alpha: 0.1),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: chapters.isEmpty
                  ? null
                  : () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  children: [
                    if (volume.posterUrl != null && volume.posterUrl!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SizedBox(
                          width: 28,
                          height: 38,
                          child: LibraryCoverImage(
                            title: volume.title,
                            imageUrl: volume.posterUrl,
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.menu_book,
                          size: 18,
                          color: widget.accent,
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            volume.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '$count chapter${count == 1 ? '' : 's'}',
                            style: const TextStyle(
                              color: kAppTextMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (chapters.isNotEmpty)
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        size: 18,
                      ),
                  ],
                ),
              ),
            ),
            if (_expanded && chapters.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 12, 10),
                child: Column(
                  children: [
                    for (final chapter in chapters)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 64,
                              child: Text(
                                'Ch. ${chapter.episodeNumber}',
                                style: const TextStyle(
                                  color: kAppTextMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                chapter.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
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
