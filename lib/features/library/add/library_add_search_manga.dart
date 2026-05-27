part of 'library_add_dialog.dart';

// Manga candidate tree widgets

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

