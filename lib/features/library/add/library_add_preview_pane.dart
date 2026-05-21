part of 'library_add_dialog.dart';

class _LibraryAddPaneResizeDivider extends StatelessWidget {
  const _LibraryAddPaneResizeDivider({this.onDragDelta});

  final ValueChanged<double>? onDragDelta;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: onDragDelta == null
            ? null
            : (details) => onDragDelta!(details.delta.dx),
        child: Tooltip(
          message: 'Resize results pane',
          child: SizedBox(
            width: 10,
            child: Center(
              child: Container(width: 2, color: kClzDivider),
            ),
          ),
        ),
      ),
    );
  }
}

class _LibraryAddPreviewPane extends ConsumerWidget {
  const _LibraryAddPreviewPane({
    required this.type,
    required this.accent,
    required this.item,
    required this.candidate,
    required this.candidatePreview,
    required this.isFetchingPreview,
    required this.providerLabel,
    required this.searched,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final CatalogItem? item;
  final ProviderCandidate? candidate;
  final AdminProviderPreview? candidatePreview;
  final bool isFetchingPreview;
  final String providerLabel;
  final bool searched;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedItem = item;
    final selectedCandidate = candidate;
    if (selectedItem == null && selectedCandidate == null) {
      return ColoredBox(
        color: const Color(0xFF060606),
        child: Center(
          child: Text(
            searched
                ? 'Select a result or search $providerLabel.'
                : 'Search Collectarr Core to preview metadata.',
          ),
        ),
      );
    }
    final title = selectedItem?.title ?? selectedCandidate!.title;
    final itemNumber = selectedItem?.itemNumber;
    final preview = candidatePreview;
    final synopsis = selectedItem?.synopsis ??
        preview?.synopsis ??
        selectedCandidate?.summary;
    final coverUrl = selectedItem?.displayCoverUrl ??
        preview?.coverImageUrl ??
        selectedCandidate?.imageUrl;
    final rows = selectedItem == null
        ? (preview != null
            ? _metadataRowsForFullPreview(preview)
            : _metadataRowsForCandidate(selectedCandidate!))
        : _metadataRowsForItem(selectedItem, type);
    final provenanceRows = _provenanceRows(
      type: type,
      item: selectedItem,
      candidate: selectedCandidate,
      preview: preview,
      providerLabel: providerLabel,
    );
    final tracks = preview?.tracks ?? const [];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF020202),
            Color.alphaBlend(accent.withValues(alpha: 0.22), kClzCanvas),
            const Color(0xFF050505),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemNumber == null ? title : '$title #$itemNumber',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: accent,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          height: 1.02,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedItem == null
                            ? '$providerLabel candidate'
                            : 'Collectarr Core metadata',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                LibraryAddResultBadge(
                  selectedItem == null ? providerLabel : type.singularLabel,
                ),
              ],
            ),
            Divider(height: 22, color: accent.withValues(alpha: 0.42)),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        if (synopsis != null &&
                            synopsis.trim().isNotEmpty) ...[
                          Text('Plot', style: TextStyle(color: accent)),
                          const SizedBox(height: 6),
                          Text(synopsis),
                          const SizedBox(height: 22),
                        ],
                        Text('Source', style: TextStyle(color: accent)),
                        const SizedBox(height: 8),
                        for (final row in provenanceRows)
                          if (row.$2 != null && row.$2!.trim().isNotEmpty)
                            _LibraryAddPreviewMetadataRow(
                              label: row.$1,
                              value: row.$2!,
                            ),
                        const SizedBox(height: 22),
                        Text('Details', style: TextStyle(color: accent)),
                        const SizedBox(height: 8),
                        for (final row in rows)
                          if (row.$2 != null && row.$2!.trim().isNotEmpty)
                            _LibraryAddPreviewMetadataRow(
                              label: row.$1,
                              value: row.$2!,
                            ),
                        if (isFetchingPreview) ...[
                          const SizedBox(height: 16),
                          const Row(
                            children: [
                              SizedBox.square(
                                dimension: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Fetching full metadata...',
                                style: TextStyle(color: kClzTextMuted),
                              ),
                            ],
                          ),
                        ],
                        if (tracks.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          Text(
                            'Tracks (${tracks.length})',
                            style: TextStyle(color: accent),
                          ),
                          const SizedBox(height: 8),
                          for (var i = 0; i < tracks.length; i++)
                            _PreviewTrackRow(
                              index: i + 1,
                              track: tracks[i],
                              accent: accent,
                            ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 200,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0x99FFFFFF)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xCC000000),
                            blurRadius: 18,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: AspectRatio(
                        aspectRatio: 2 / 3,
                        child: LibraryCoverImage(
                          title: title,
                          itemNumber: itemNumber,
                          imageUrl: coverUrl,
                        ),
                      ),
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

List<(String, String?)> _metadataRowsForCandidate(
    ProviderCandidate candidate) {
  return [
    if (candidate.seriesTitle != null)
      ('Artist / Series', candidate.seriesTitle),
    if (candidate.issueNumber != null) ('Issue #', candidate.issueNumber),
    if (candidate.publisher != null) ('Publisher', candidate.publisher),
    if (candidate.volumeStartYear != null)
      ('Year', candidate.volumeStartYear.toString()),
    if (candidate.variantName != null) ('Variant', candidate.variantName),
    if (candidate.issueCount != null)
      ('Issues', candidate.issueCount.toString()),
    if (candidate.characterPreview.isNotEmpty)
      ('Characters', candidate.characterPreview.join(', ')),
    if (candidate.storyArcPreview.isNotEmpty)
      ('Story Arcs', candidate.storyArcPreview.join(', ')),
    ('Provider', candidate.provider),
    ('Provider ID', candidate.providerItemId),
  ];
}

List<(String, String?)> _metadataRowsForItem(
  CatalogItem item,
  LibraryTypeConfig type,
) {
  final labels = libraryMediaFieldLabels(type);
  return [
    if (item.seriesTitle != null) ('Series / Artist', item.seriesTitle),
    (labels.publisher, item.publisher),
    ('Released', item.releaseDate != null
        ? '${item.releaseDate!.year}-${item.releaseDate!.month.toString().padLeft(2, '0')}-${item.releaseDate!.day.toString().padLeft(2, '0')}'
        : item.releaseYear?.toString()),
    if (item.itemNumber != null) (labels.number, item.itemNumber),
    if (item.displayEditionLabel != null)
      (labels.variant, item.displayEditionLabel),
    (labels.barcode, item.barcode),
    if (item.trackCount != null) ('Tracks', item.trackCount.toString()),
    if (item.pageCount != null) ('Pages', item.pageCount.toString()),
    if (item.country != null) ('Country', item.country),
    if (item.language != null) ('Language', item.language),
    if (item.genres != null && item.genres!.isNotEmpty)
      ('Genres', item.genres!.join(', ')),
    if (item.creators != null && item.creators!.isNotEmpty)
      ('Creators', item.creators!
          .map((c) => c['name'] as String? ?? '')
          .where((n) => n.isNotEmpty)
          .join(', ')),
  ];
}

List<(String, String?)> _provenanceRows({
  required LibraryTypeConfig type,
  required CatalogItem? item,
  required ProviderCandidate? candidate,
  required AdminProviderPreview? preview,
  required String providerLabel,
}) {
  if (item != null) {
    return [
      ('Source', 'Collectarr Core catalog snapshot'),
      (
        'Image delivery',
        item.coverImageData != null
            ? 'Local offline image bytes'
            : item.displayCoverUrl != null
                ? 'External provider URL'
                : 'Generated fallback',
      ),
      ('Snapshot type', 'Cached metadata ready for local browsing'),
    ];
  }
  final resolvedProvider = preview?.provider ?? candidate?.provider ?? providerLabel;
  final resolvedProviderId = preview?.providerItemId ?? candidate?.providerItemId;
  final isStub = candidate?.isStub ?? false;
  final hasFullPreview = preview != null;
  return [
    (
      'Source',
      hasFullPreview
          ? 'Live provider preview'
          : isStub
              ? 'Search-only provider stub'
              : 'Provider search candidate',
    ),
    ('Provider', resolvedProvider),
    ('Provider ID', resolvedProviderId),
    (
      'Status',
      hasFullPreview
          ? 'Full preview loaded'
          : isStub
              ? 'Catalog ingest not available yet'
              : 'Preview pending',
    ),
    (
      'Default flow',
      type.metadataProviderLabel(type.defaultSupportedMetadataProvider),
    ),
    (
      'Image availability',
      (preview?.coverImageUrl ?? candidate?.imageUrl) != null
          ? 'Provider image available'
          : 'No provider image',
    ),
  ];
}

class _LibraryAddPreviewMetadataRow extends StatelessWidget {
  const _LibraryAddPreviewMetadataRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(
                color: kClzTextMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

List<(String, String?)> _metadataRowsForFullPreview(
    AdminProviderPreview preview) {
  final releaseDateStr = preview.releaseDate != null
      ? '${preview.releaseDate!.year}-${preview.releaseDate!.month.toString().padLeft(2, '0')}-${preview.releaseDate!.day.toString().padLeft(2, '0')}'
      : null;
  return [
    if (preview.seriesTitle != null) ('Artist / Series', preview.seriesTitle),
    if (preview.publisher != null) ('Label / Publisher', preview.publisher),
    if (preview.imprint != null) ('Imprint', preview.imprint),
    if (releaseDateStr != null) ('Released', releaseDateStr),
    if (preview.volumeStartYear != null)
      ('Year', preview.volumeStartYear.toString()),
    if (preview.itemNumber != null) ('Issue #', preview.itemNumber),
    if (preview.barcode != null) ('Barcode', preview.barcode),
    if (preview.isbn != null) ('ISBN', preview.isbn),
    if (preview.country != null) ('Country', preview.country),
    if (preview.language != null) ('Language', preview.language),
    if (preview.physicalFormatLabel != null)
      ('Format', preview.physicalFormatLabel),
    if (preview.variantName != null) ('Variant', preview.variantName),
    if (preview.trackCount != null) ('Tracks', preview.trackCount.toString()),
    if (preview.runtimeMinutes != null)
      ('Runtime', '${preview.runtimeMinutes} min'),
    if (preview.pageCount != null) ('Pages', preview.pageCount.toString()),
    if (preview.genres.isNotEmpty) ('Genres', preview.genres.join(', ')),
    if (preview.creators.isNotEmpty)
      ('Creators',
          preview.creators.map((c) => c.role != null ? '${c.name} (${c.role})' : c.name).join(', ')),
    if (preview.characters.isNotEmpty)
      ('Characters', preview.characters.join(', ')),
    if (preview.storyArcs.isNotEmpty)
      ('Story Arcs', preview.storyArcs.join(', ')),
    if (preview.seriesGroup != null) ('Series Group', preview.seriesGroup),
    ('Provider', preview.provider),
    ('Provider ID', preview.providerItemId),
  ];
}

class _PreviewTrackRow extends StatelessWidget {
  const _PreviewTrackRow({
    required this.index,
    required this.track,
    required this.accent,
  });

  final int index;
  final ProviderPreviewTrack track;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final duration = track.durationSeconds;
    final durationStr = duration != null
        ? '${duration ~/ 60}:${(duration % 60).toString().padLeft(2, '0')}'
        : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '${track.position ?? index}',
              style: TextStyle(
                color: accent.withValues(alpha: 0.7),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          if (durationStr != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                durationStr,
                style: const TextStyle(
                  color: kClzTextMuted,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A decorated dialog shell with resize handles on the right and bottom edges.
class _ResizableDialogShell extends StatelessWidget {
  const _ResizableDialogShell({
    required this.accent,
    required this.onResizeWidth,
    required this.onResizeHeight,
    required this.child,
  });

  final Color accent;
  final ValueChanged<double> onResizeWidth;
  final ValueChanged<double> onResizeHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: kClzPanel,
            border: Border.all(color: kClzDivider),
            boxShadow: const [
              BoxShadow(
                color: Color(0xCC000000),
                blurRadius: 22,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
        // Right edge resize handle.
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (d) => onResizeWidth(d.delta.dx * 2),
              child: const SizedBox(width: 6),
            ),
          ),
        ),
        // Bottom edge resize handle.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeRow,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: (d) => onResizeHeight(d.delta.dy * 2),
              child: const SizedBox(height: 6),
            ),
          ),
        ),
        // Bottom-right corner resize handle.
        Positioned(
          right: 0,
          bottom: 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeDownRight,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (d) {
                onResizeWidth(d.delta.dx * 2);
                onResizeHeight(d.delta.dy * 2);
              },
              child: const SizedBox(width: 12, height: 12),
            ),
          ),
        ),
      ],
    );
  }
}
