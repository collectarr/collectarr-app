part of 'library_add_dialog.dart';

// ---------------------------------------------------------------------------
// Unified series-first search results.
//
// Merges Core results (LibraryMetadataItem) and Provider candidates
// (ProviderCandidate) into series groups, displayed collapsed by default
// so the user picks a series first, then drills down into individual items.
// ---------------------------------------------------------------------------

// -- Data model --------------------------------------------------------------

class _UnifiedSearchGroup {
  const _UnifiedSearchGroup({
    required this.key,
    required this.title,
    this.publisher,
    this.year,
    this.coverUrl,
    this.coreItems = const [],
    this.seriesCandidate,
    this.providerItems = const [],
    this.sources = const {},
  });

  final String key;
  final String title;
  final String? publisher;
  final int? year;
  final String? coverUrl;
  final List<LibraryMetadataItem> coreItems;
  final ProviderCandidate? seriesCandidate;
  final List<ProviderCandidate> providerItems;
  final Set<String> sources;

  int get childCount => coreItems.length + providerItems.length;
  bool get isSingleton =>
      coreItems.length + providerItems.length + (seriesCandidate != null ? 1 : 0) == 1;
}

// -- Grouping logic ----------------------------------------------------------

/// Extracts the series title from a Core [LibraryMetadataItem].
String _coreGroupTitle(LibraryMetadataItem item) {
  final seriesTitle = item.series?.seriesTitle?.trim();
  if (seriesTitle != null && seriesTitle.isNotEmpty) {
    return seriesTitle;
  }
  return item.title;
}

/// Extracts the series title from a [ProviderCandidate] for any media type.
String _providerGroupTitle(ProviderCandidate candidate) {
  final seriesTitle = candidate.series?.seriesTitle?.trim();
  if (seriesTitle != null && seriesTitle.isNotEmpty) {
    return seriesTitle;
  }
  final titleMeta = _comicTitleIssueMetadata(candidate.title);
  if (titleMeta != null) {
    return titleMeta.seriesTitle;
  }
  return candidate.title.trim().isEmpty ? 'Untitled' : candidate.title.trim();
}

/// Returns true when the candidate represents a series rather than an
/// individual item (issue, episode, etc.).
bool _isSeriesCandidate(ProviderCandidate candidate) {
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

/// Builds a unified list of [_UnifiedSearchGroup] from Core and Provider
/// results.  Provider groups are created first (preserving search order),
/// then Core items are merged into matching groups or added as new groups
/// at the top.
List<_UnifiedSearchGroup> _buildUnifiedGroups({
  required List<LibraryMetadataItem> coreResults,
  required List<ProviderCandidate> providerResults,
}) {
  final orderedKeys = <String>[];
  final titles = <String, String>{};
  final publishers = <String, String?>{};
  final years = <String, int?>{};
  final coverUrls = <String, String?>{};
  final coreItems = <String, List<LibraryMetadataItem>>{};
  final seriesCandidates = <String, ProviderCandidate>{};
  final providerItemsMap = <String, List<ProviderCandidate>>{};
  final sourceSets = <String, Set<String>>{};

  // -- index used to merge Core items into existing Provider groups ----------
  // Maps lowercase title → first key that uses that title.
  final titleIndex = <String, String>{};

  void ensureKey(String key, String title) {
    if (!titles.containsKey(key)) {
      orderedKeys.add(key);
      titles[key] = title;
      coreItems[key] = [];
      providerItemsMap[key] = [];
      sourceSets[key] = {};
    }
    titleIndex.putIfAbsent(title.toLowerCase(), () => key);
  }

  // 1. Process Provider results first.
  for (final candidate in providerResults) {
    final groupTitle = _providerGroupTitle(candidate);
    final key = '${candidate.provider}::${groupTitle.toLowerCase()}';
    ensureKey(key, groupTitle);

    sourceSets[key]!.add(candidate.provider);
    publishers[key] ??= candidate.publisher;
    years[key] ??= candidate.series?.volumeStartYear;
    coverUrls[key] ??= candidate.imageUrl;

    if (_isSeriesCandidate(candidate)) {
      seriesCandidates.putIfAbsent(key, () => candidate);
    } else {
      providerItemsMap[key]!.add(candidate);
    }
  }

  // 2. Process Core results — merge into a matching Provider group when the
  //    titles match, otherwise create a Core-only group at the front.
  final coreOnlyKeys = <String>[];
  for (final item in coreResults) {
    final groupTitle = _coreGroupTitle(item);
    final lowerTitle = groupTitle.toLowerCase();
    final existingKey = titleIndex[lowerTitle];

    if (existingKey != null) {
      coreItems[existingKey]!.add(item);
      sourceSets[existingKey]!.add('core');
      coverUrls[existingKey] ??= item.displayCoverUrl;
    } else {
      final key = 'core::$lowerTitle';
      if (!titles.containsKey(key)) {
        coreOnlyKeys.add(key);
      }
      ensureKey(key, groupTitle);
      coreItems[key]!.add(item);
      sourceSets[key]!.add('core');
      publishers[key] ??= item.publisher;
      years[key] ??= item.releaseYear;
      coverUrls[key] ??= item.displayCoverUrl;
    }
  }

  // Reorder: put core-only groups at the top (they are the best matches).
  // Remove core-only keys from orderedKeys to avoid duplicates.
  final coreOnlySet = coreOnlyKeys.toSet();
  final finalKeys = [
    ...coreOnlyKeys,
    ...orderedKeys.where((k) => !coreOnlySet.contains(k)),
  ];

  // Sort provider items within each group (numeric by issue number).
  for (final key in finalKeys) {
    providerItemsMap[key]?.sort(_compareComicIssueCandidates);
  }

  return [
    for (final key in finalKeys)
      if (titles.containsKey(key))
        _UnifiedSearchGroup(
          key: key,
          title: titles[key]!,
          publisher: publishers[key],
          year: years[key],
          coverUrl: coverUrls[key],
          coreItems: coreItems[key]!,
          seriesCandidate: seriesCandidates[key],
          providerItems: providerItemsMap[key]!,
          sources: sourceSets[key]!,
        ),
  ];
}

// -- Widgets -----------------------------------------------------------------

class _UnifiedGroupNode extends StatefulWidget {
  const _UnifiedGroupNode({
    super.key,
    required this.type,
    required this.group,
    required this.accent,
    required this.selectedResultId,
    required this.selectedProviderCandidateId,
    required this.checkedResultIds,
    required this.checkedProviderIds,
    required this.ownedCatalogItemIds,
    required this.queuedProviderIngests,
    required this.providerLabel,
    required this.onSelectResult,
    required this.onSelectProviderCandidate,
    required this.onToggleResultCheck,
    required this.onToggleProviderCheck,
    required this.queryText,
    required this.seriesText,
    required this.numberText,
    required this.publisherText,
    required this.yearText,
  });

  final LibraryTypeConfig type;
  final _UnifiedSearchGroup group;
  final Color accent;
  final String? selectedResultId;
  final String? selectedProviderCandidateId;
  final Set<String> checkedResultIds;
  final Set<String> checkedProviderIds;
  final Set<String> ownedCatalogItemIds;
  final Map<String, _QueuedProviderIngest> queuedProviderIngests;
  final String Function(String providerId) providerLabel;
  final ValueChanged<String> onSelectResult;
  final ValueChanged<String> onSelectProviderCandidate;
  final ValueChanged<String> onToggleResultCheck;
  final ValueChanged<String> onToggleProviderCheck;
  final String queryText;
  final String seriesText;
  final String numberText;
  final String publisherText;
  final String yearText;

  @override
  State<_UnifiedGroupNode> createState() => _UnifiedGroupNodeState();
}

class _UnifiedGroupNodeState extends State<_UnifiedGroupNode> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = _hasSelectedChild;
  }

  @override
  void didUpdateWidget(_UnifiedGroupNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_hasSelectedChild && !_expanded) {
      _expanded = true;
    }
  }

  bool get _hasSelectedChild {
    if (widget.group.coreItems.any(
      (item) => item.id == widget.selectedResultId,
    )) {
      return true;
    }
    if (widget.group.seriesCandidate?.localCatalogId ==
        widget.selectedProviderCandidateId) {
      return true;
    }
    return widget.group.providerItems.any(
      (c) => c.localCatalogId == widget.selectedProviderCandidateId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;

    // Singleton groups (one item, no series candidate) — show inline.
    if (group.isSingleton) {
      if (group.coreItems.length == 1) {
        return _SearchResultTile(
          type: widget.type,
          item: group.coreItems.first,
          accent: widget.accent,
          queryText: widget.queryText,
          seriesText: widget.seriesText,
          numberText: widget.numberText,
          publisherText: widget.publisherText,
          yearText: widget.yearText,
          selected: group.coreItems.first.id == widget.selectedResultId,
          checked: widget.checkedResultIds.contains(group.coreItems.first.id),
          isOwned:
              widget.ownedCatalogItemIds.contains(group.coreItems.first.id),
          onSelect: () => widget.onSelectResult(group.coreItems.first.id),
          onToggleCheck: () =>
              widget.onToggleResultCheck(group.coreItems.first.id),
        );
      }
      if (group.providerItems.length == 1) {
        final candidate = group.providerItems.first;
        return KeyedSubtree(
          key: ValueKey(candidate.localCatalogId),
          child: _ProviderCandidateTile(
            type: widget.type,
            candidate: candidate,
            accent: widget.accent,
            providerLabel: widget.providerLabel(candidate.provider),
            queuedIngest:
                widget.queuedProviderIngests[candidate.localCatalogId],
            providerQueryText: widget.queryText,
            providerSeriesText: widget.seriesText,
            providerNumberText: widget.numberText,
            providerPublisherText: widget.publisherText,
            providerYearText: widget.yearText,
            selected:
                candidate.localCatalogId == widget.selectedProviderCandidateId,
            onSelect: () =>
                widget.onSelectProviderCandidate(candidate.localCatalogId),
          ),
        );
      }
      if (group.seriesCandidate != null) {
        final candidate = group.seriesCandidate!;
        return KeyedSubtree(
          key: ValueKey(candidate.localCatalogId),
          child: _ProviderCandidateTile(
            type: widget.type,
            candidate: candidate,
            accent: widget.accent,
            providerLabel: widget.providerLabel(candidate.provider),
            queuedIngest:
                widget.queuedProviderIngests[candidate.localCatalogId],
            providerQueryText: widget.queryText,
            providerSeriesText: widget.seriesText,
            providerNumberText: widget.numberText,
            providerPublisherText: widget.publisherText,
            providerYearText: widget.yearText,
            selected:
                candidate.localCatalogId == widget.selectedProviderCandidateId,
            onSelect: () =>
                widget.onSelectProviderCandidate(candidate.localCatalogId),
          ),
        );
      }
    }

    // Multi-item group — collapsed by default.
    final highlighted = _hasSelectedChild;
    final subtitleParts = <String>[
      for (final src in group.sources)
        src == 'core' ? 'Core' : widget.providerLabel(src),
      if (group.publisher != null && group.publisher!.trim().isNotEmpty)
        group.publisher!,
      if (group.year != null) group.year.toString(),
      '${group.childCount} ${group.childCount == 1 ? 'item' : 'items'}',
    ];

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
          // -- Group header --
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              child: Row(
                children: [
                  Icon(
                    _expanded ? Icons.expand_more : Icons.chevron_right,
                    color: widget.accent,
                    size: 22,
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 42,
                    height: 56,
                    child: LibraryCoverImage(
                      title: group.title,
                      imageUrl: group.coverUrl,
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
                            subtitleParts.join(' · '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: kAppTextMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: kAppTextMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          // -- Expanded children --
          if (_expanded) _buildChildren(),
        ],
      ),
    );
  }

  Widget _buildChildren() {
    final group = widget.group;
    return Padding(
      padding: const EdgeInsets.fromLTRB(46, 0, 0, 6),
      child: Column(
        children: [
          // Series-level candidate (if any).
          if (group.seriesCandidate != null) ...[
            _UnifiedChildTile(
              title: '${group.title} (series)',
              subtitle: widget.providerLabel(group.seriesCandidate!.provider),
              imageUrl: group.seriesCandidate!.imageUrl,
              selected: group.seriesCandidate!.localCatalogId ==
                  widget.selectedProviderCandidateId,
              accent: widget.accent,
              badges: const ['series'],
              onTap: () => widget.onSelectProviderCandidate(
                group.seriesCandidate!.localCatalogId,
              ),
            ),
            const Divider(height: 1, thickness: 1, color: kAppDivider),
          ],
          // Core items.
          for (var i = 0; i < group.coreItems.length; i++) ...[
            _UnifiedCoreChildTile(
              type: widget.type,
              item: group.coreItems[i],
              accent: widget.accent,
              selected: group.coreItems[i].id == widget.selectedResultId,
              checked:
                  widget.checkedResultIds.contains(group.coreItems[i].id),
              isOwned:
                  widget.ownedCatalogItemIds.contains(group.coreItems[i].id),
              onSelect: () =>
                  widget.onSelectResult(group.coreItems[i].id),
              onToggleCheck: () =>
                  widget.onToggleResultCheck(group.coreItems[i].id),
            ),
            if (i < group.coreItems.length - 1 ||
                group.providerItems.isNotEmpty)
              const Divider(height: 1, thickness: 1, color: kAppDivider),
          ],
          // Provider items.
          for (var i = 0; i < group.providerItems.length; i++) ...[
            _UnifiedProviderChildTile(
              candidate: group.providerItems[i],
              accent: widget.accent,
              providerLabel:
                  widget.providerLabel(group.providerItems[i].provider),
              queuedIngest: widget.queuedProviderIngests[
                  group.providerItems[i].localCatalogId],
              selected: group.providerItems[i].localCatalogId ==
                  widget.selectedProviderCandidateId,
              onSelect: () => widget.onSelectProviderCandidate(
                group.providerItems[i].localCatalogId,
              ),
            ),
            if (i < group.providerItems.length - 1)
              const Divider(height: 1, thickness: 1, color: kAppDivider),
          ],
        ],
      ),
    );
  }
}

// -- Compact child tiles for items inside a group ----------------------------

class _UnifiedChildTile extends StatelessWidget {
  const _UnifiedChildTile({
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.selected,
    required this.accent,
    this.badges = const [],
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String? imageUrl;
  final bool selected;
  final Color accent;
  final List<String> badges;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? kAppSelection : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                height: 42,
                child: LibraryCoverImage(
                  title: title,
                  imageUrl: imageUrl,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? Colors.white : kAppTextBright,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        for (final badge in badges) ...[
                          LibraryAddResultBadge(badge),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color:
                                  selected ? Colors.white70 : kAppTextMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: accent, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnifiedCoreChildTile extends StatelessWidget {
  const _UnifiedCoreChildTile({
    required this.type,
    required this.item,
    required this.accent,
    required this.selected,
    required this.checked,
    this.isOwned = false,
    required this.onSelect,
    required this.onToggleCheck,
  });

  final LibraryTypeConfig type;
  final LibraryMetadataItem item;
  final Color accent;
  final bool selected;
  final bool checked;
  final bool isOwned;
  final VoidCallback onSelect;
  final VoidCallback onToggleCheck;

  @override
  Widget build(BuildContext context) {
    final displayTitle = _coreChildDisplayTitle(item);
    final subtitleParts = <String>[
      if (item.publisher != null) item.publisher!,
      if (item.releaseYear != null) item.releaseYear.toString(),
      if (item.physicalFormatLabel != null) item.physicalFormatLabel!,
      if (item.variant != null) item.variant!,
    ];
    return Material(
      color: selected ? kAppSelection : Colors.transparent,
      child: InkWell(
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            children: [
              SizedBox(
                width: 18,
                child: Checkbox(
                  value: checked,
                  onChanged: (_) => onToggleCheck(),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  activeColor: accent,
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 30,
                height: 42,
                child: LibraryCoverImage(
                  title: item.title,
                  imageUrl: item.displayCoverUrl,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? Colors.white : kAppTextBright,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    if (subtitleParts.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const LibraryAddResultBadge('Core'),
                          const SizedBox(width: 4),
                          if (isOwned) ...[
                            Icon(Icons.inventory_2,
                                size: 12, color: accent),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              subtitleParts.join(' · '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: selected
                                    ? Colors.white70
                                    : kAppTextMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: accent, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

String _coreChildDisplayTitle(LibraryMetadataItem item) {
  if (item.itemNumber != null && item.itemNumber!.trim().isNotEmpty) {
    return '${item.title} #${item.itemNumber}';
  }
  return item.title;
}

class _UnifiedProviderChildTile extends StatelessWidget {
  const _UnifiedProviderChildTile({
    required this.candidate,
    required this.accent,
    required this.providerLabel,
    this.queuedIngest,
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
  Widget build(BuildContext context) {
    final displayTitle = _providerChildDisplayTitle(candidate);
    final subtitleParts = <String>[
      providerLabel,
      if (candidate.publisher != null &&
          candidate.publisher!.trim().isNotEmpty)
        candidate.publisher!,
      if (candidate.variantName != null &&
          candidate.variantName!.trim().isNotEmpty)
        candidate.variantName!,
    ];
    return Material(
      color: selected ? kAppSelection : Colors.transparent,
      child: InkWell(
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                height: 42,
                child: LibraryCoverImage(
                  title: candidate.title,
                  imageUrl: candidate.imageUrl,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? Colors.white : kAppTextBright,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 4,
                      runSpacing: 3,
                      children: [
                        LibraryAddResultBadge(providerLabel),
                        if (candidate.isVariant)
                          const LibraryAddResultBadge('variant'),
                        if (queuedIngest != null)
                          LibraryAddResultBadge(
                            '${queuedIngest!.statusLabel} '
                            '${queuedIngest!.shortId}',
                          ),
                        Text(
                          subtitleParts.skip(1).join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color:
                                selected ? Colors.white70 : kAppTextMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: accent, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

String _providerChildDisplayTitle(ProviderCandidate candidate) {
  final issueNumber = candidate.issueNumber?.trim();
  if (issueNumber != null && issueNumber.isNotEmpty) {
    final seriesTitle = candidate.series?.seriesTitle?.trim();
    if (seriesTitle != null && seriesTitle.isNotEmpty) {
      return '$seriesTitle #$issueNumber';
    }
    return '${candidate.title} #$issueNumber';
  }
  return candidate.title;
}
