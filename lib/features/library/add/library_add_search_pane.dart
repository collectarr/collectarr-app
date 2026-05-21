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
  final List<CatalogItem> results;
  final List<ProviderCandidate> providerResults;
  final Map<String, _QueuedProviderIngest> queuedProviderIngests;
  final String selectedProvider;
  final bool searchedProvider;
  final String? selectedResultId;
  final String? selectedProviderCandidateId;
  final Set<String> checkedResultIds;
  final Set<String> checkedProviderIds;
  final ValueChanged<String> onSelectResult;
  final ValueChanged<String> onSelectProviderCandidate;
  final ValueChanged<String> onToggleResultCheck;
  final ValueChanged<String> onToggleProviderCheck;
  final VoidCallback onSearchCore;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF1D2022),
        border: Border(right: BorderSide(color: kClzDivider)),
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
            child: _ErrorBanner(error!),
          ),
        const Divider(height: 1, thickness: 1, color: kClzDivider),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF4A2630),
        border: Border.all(color: const Color(0xFF9D5D69)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              size: 18,
              color: Color(0xFFFFB4C0),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Color(0xFFFFD9DF),
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
        color: const Color(0xFF183246),
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
                  color: kClzTextMuted,
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
  final List<CatalogItem> results;
  final List<ProviderCandidate> providerResults;
  final Map<String, _QueuedProviderIngest> queuedProviderIngests;
  final String? selectedResultId;
  final String? selectedProviderCandidateId;
  final Set<String> checkedResultIds;
  final Set<String> checkedProviderIds;
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
                  item: item,
                  accent: accent,
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
          _ResultSectionHeader(
            label: '${type.metadataProviderLabel(selectedProvider)} candidates',
          ),
          if (type.workspace.kind == 'manga')
            _MangaCandidateTreeList(
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
                    candidate: candidate,
                    accent: accent,
                    providerLabel:
                        type.metadataProviderLabel(candidate.provider),
                    queuedIngest:
                        queuedProviderIngests[candidate.localCatalogId],
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
    for (final item in providerResults) {
      if (item.provider != selectedProvider) {
        return type.metadataProviderLabel(item.provider);
      }
    }
    return null;
  }

  List<Widget> _withDividers(BuildContext context, List<Widget> tiles) {
    const divider = Divider(height: 1, thickness: 1, color: kClzDivider);
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
            const Divider(height: 1, thickness: 1, color: kClzDivider),
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
                widget.accent.withValues(alpha: 0.46), kClzSelection)
            : kClzTableEvenRow,
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
                              color: kClzTextMuted,
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
                    color: widget.selected ? widget.accent : kClzTextMuted,
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
              style: TextStyle(color: kClzTextMuted),
            ),
          ),
        ],
      ),
      error: (_, __) => const Text(
        'Volumes/chapters are not available for this candidate right now.',
        style: TextStyle(color: kClzTextMuted),
      ),
      data: (volumes) {
        if (volumes.isEmpty) {
          return const Text(
            'No volume/chapter data returned for this candidate.',
            style: TextStyle(color: kClzTextMuted),
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
          border: Border.all(color: kClzDivider),
          color: const Color(0x1AFFFFFF),
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
                              color: kClzTextMuted,
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
                                  color: kClzTextMuted,
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
                color: index.isEven ? kClzTableEvenRow : kClzTableOddRow,
                border: Border.all(color: kClzTableBottomBorder),
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
        color: const Color(0xFF313B42),
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
        color: Color(0xFF3F3A1A),
        border: Border(bottom: _kLibraryAddBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.swap_horiz, size: 18, color: kClzYellow),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: const BoxDecoration(
        color: kClzPanelRaised,
        border: Border(bottom: _kLibraryAddBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: kClzTextMuted,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.item,
    required this.accent,
    required this.selected,
    required this.checked,
    required this.onSelect,
    required this.onToggleCheck,
  });

  final CatalogItem item;
  final Color accent;
  final bool selected;
  final bool checked;
  final VoidCallback onSelect;
  final VoidCallback onToggleCheck;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (item.publisher != null) item.publisher,
      if (item.releaseYear != null) item.releaseYear.toString(),
      if (item.physicalFormatLabel != null) item.physicalFormatLabel,
      if (item.variant != null) item.variant,
      if (item.barcode != null) item.barcode,
    ].whereType<String>().join(' | ');
    return InkWell(
      onTap: onSelect,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected
              ? Color.alphaBlend(accent.withValues(alpha: 0.46), kClzSelection)
              : kClzTableEvenRow,
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
                      item.itemNumber == null
                          ? item.title
                          : '${item.title} #${item.itemNumber}',
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
                          color: kClzTextMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
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

class _ProviderCandidateTile extends StatelessWidget {
  const _ProviderCandidateTile({
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
  Widget build(BuildContext context) {
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
              ? Color.alphaBlend(accent.withValues(alpha: 0.46), kClzSelection)
              : kClzTableEvenRow,
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
                          color: kClzTextMuted,
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
                color: selected ? accent : kClzTextMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
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
                  color: kClzTextMuted,
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
