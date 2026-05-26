part of 'library_add_dialog.dart';

// Comic candidate tree widgets

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

