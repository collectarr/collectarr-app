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
        ? _metadataRowsForFullPreview(preview, type)
        : _metadataRowsForCandidate(selectedCandidate!, type))
        : _metadataRowsForItem(selectedItem, type);
    final provenanceRows = _provenanceRows(
      type: type,
      item: selectedItem,
      candidate: selectedCandidate,
      preview: preview,
      providerLabel: providerLabel,
    );
    final statusSummary = _previewStatusSummary(
      item: selectedItem,
      candidate: selectedCandidate,
      preview: preview,
      isFetchingPreview: isFetchingPreview,
    );
    final previewDiff = _previewDiffRows(
      type: type,
      candidate: selectedCandidate,
      preview: preview,
    );
    final discoverySections = _discoverySections(
      item: selectedItem,
      candidate: selectedCandidate,
      preview: preview,
    );
    final tracks = type.capabilities.showsTrackData
        ? _previewTracksForSelection(
            item: selectedItem,
            preview: preview,
          )
        : const <_PreviewTrackData>[];
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
            _LibraryAddPreviewStatusBanner(
              accent: accent,
              summary: statusSummary,
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        if (type.capabilities.showsSynopsis &&
                          synopsis != null &&
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
                        if (previewDiff.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          Text(
                            'Preview changes',
                            style: TextStyle(color: accent),
                          ),
                          const SizedBox(height: 8),
                          for (final row in previewDiff)
                            _LibraryAddPreviewDiffRow(row: row),
                        ],
                        if (discoverySections.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          Text('Discovery', style: TextStyle(color: accent)),
                          const SizedBox(height: 8),
                          for (final section in discoverySections)
                            _LibraryAddPreviewDiscoverySection(
                              title: section.title,
                              values: section.values,
                              accent: accent,
                            ),
                        ],
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
                        color: Color.alphaBlend(
                          accent.withValues(alpha: 0.08),
                          const Color(0xFFF1ECE2),
                        ),
                        border: Border.all(color: const Color(0x99FFFFFF)),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xCC000000),
                            blurRadius: 18,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: AspectRatio(
                          aspectRatio: 2 / 3,
                          child: LibraryCoverImage(
                            title: title,
                            itemNumber: itemNumber,
                            imageUrl: coverUrl,
                            borderRadius: 6,
                          ),
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
  ProviderCandidate candidate,
  LibraryTypeConfig type,
) {
  final labels = libraryMediaFieldLabels(type);
  final previewLabels = type.presentation.previewLabels;
  return [
    if (candidate.seriesTitle != null)
      (previewLabels.series, candidate.seriesTitle),
    if (candidate.issueNumber != null) (labels.number, candidate.issueNumber),
    if (candidate.publisher != null) (labels.publisher, candidate.publisher),
    if (candidate.volumeStartYear != null)
      ('Year', candidate.volumeStartYear.toString()),
    if (candidate.variantName != null) (labels.variant, candidate.variantName),
    if (candidate.issueCount != null)
      (previewLabels.itemCount, candidate.issueCount.toString()),
  ];
}

List<(String, String?)> _metadataRowsForItem(
  CatalogItem item,
  LibraryTypeConfig type,
) {
  final labels = libraryMediaFieldLabels(type);
  final previewLabels = type.presentation.previewLabels;
  return [
    if (item.seriesTitle != null) (previewLabels.series, item.seriesTitle),
    (labels.publisher, item.publisher),
    ('Released', item.releaseDate != null
        ? '${item.releaseDate!.year}-${item.releaseDate!.month.toString().padLeft(2, '0')}-${item.releaseDate!.day.toString().padLeft(2, '0')}'
        : item.releaseYear?.toString()),
    if (item.runtimeMinutes != null) ('Runtime', '${item.runtimeMinutes} min'),
    if (item.itemNumber != null) (labels.number, item.itemNumber),
    if (item.displayEditionLabel != null)
      (labels.variant, item.displayEditionLabel),
    (labels.barcode, item.barcode),
    if (type.capabilities.showsTrackData &&
      item.trackCount != null)
      ('Tracks', item.trackCount.toString()),
    if (item.catalogNumber != null) ('Catalog No.', item.catalogNumber),
    if (item.platforms != null && item.platforms!.isNotEmpty)
      ('Platforms', item.platforms!.join(', ')),
    if (item.pageCount != null) ('Pages', item.pageCount.toString()),
    if (item.country != null) ('Country', item.country),
    if (item.releaseStatus != null) ('Release Status', item.releaseStatus),
    if (item.language != null) ('Language', item.language),
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

class _LibraryAddPreviewDiffRow extends StatelessWidget {
  const _LibraryAddPreviewDiffRow({required this.row});

  final _PreviewDiffRow row;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              row.label,
              style: const TextStyle(
                color: kClzTextMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (row.before != null && row.before!.trim().isNotEmpty)
                  Text(
                    'Search: ${row.before}',
                    style: const TextStyle(color: kClzTextMuted),
                  )
                else
                  const Text(
                    'Search: missing',
                    style: TextStyle(color: kClzTextMuted),
                  ),
                const SizedBox(height: 2),
                Text(
                  'Preview: ${row.after}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewDiffRow {
  const _PreviewDiffRow({
    required this.label,
    required this.after,
    this.before,
  });

  final String label;
  final String? before;
  final String after;
}

List<(String, String?)> _metadataRowsForFullPreview(
  AdminProviderPreview preview,
  LibraryTypeConfig type,
) {
  final labels = libraryMediaFieldLabels(type);
  final previewLabels = type.presentation.previewLabels;
  final releaseDateStr = preview.releaseDate != null
      ? '${preview.releaseDate!.year}-${preview.releaseDate!.month.toString().padLeft(2, '0')}-${preview.releaseDate!.day.toString().padLeft(2, '0')}'
      : null;
  return [
    if (preview.seriesTitle != null) (previewLabels.series, preview.seriesTitle),
    if (preview.publisher != null) (labels.publisher, preview.publisher),
    if (preview.imprint != null) ('Imprint', preview.imprint),
    if (releaseDateStr != null) ('Released', releaseDateStr),
    if (preview.volumeStartYear != null)
      ('Year', preview.volumeStartYear.toString()),
    if (preview.itemNumber != null) (labels.number, preview.itemNumber),
    if (preview.barcode != null) (labels.barcode, preview.barcode),
    if (preview.isbn != null) ('ISBN', preview.isbn),
    if (preview.country != null) ('Country', preview.country),
    if (preview.language != null) ('Language', preview.language),
    if (preview.physicalFormatLabel != null)
      ('Format', preview.physicalFormatLabel),
    if (preview.variantName != null) (labels.variant, preview.variantName),
    if (collectarrLibraryTypes.capabilitiesForKind(preview.kind).showsTrackData &&
      preview.trackCount != null)
      ('Tracks', preview.trackCount.toString()),
    if (preview.catalogNumber != null)
      ('Catalog No.', preview.catalogNumber),
    if (preview.platforms.isNotEmpty)
      ('Platforms', preview.platforms.join(', ')),
    if (preview.runtimeMinutes != null)
      ('Runtime', '${preview.runtimeMinutes} min'),
    if (preview.pageCount != null) ('Pages', preview.pageCount.toString()),
    if (preview.releaseStatus != null)
      ('Release Status', preview.releaseStatus),
    if (preview.seriesGroup != null) ('Series Group', preview.seriesGroup),
  ];
}

String _previewStatusSummary({
  required CatalogItem? item,
  required ProviderCandidate? candidate,
  required AdminProviderPreview? preview,
  required bool isFetchingPreview,
}) {
  if (item != null) {
    return 'Using cached Collectarr Core metadata already stored in the app.';
  }
  if (preview != null) {
    return 'Live provider preview loaded. This is the best available metadata before ingest.';
  }
  if (candidate?.isStub ?? false) {
    return 'This result is a search-only stub. It can be added, but full catalog ingest is not available yet.';
  }
  if (isFetchingPreview) {
    return 'Fetching fuller provider metadata for the selected candidate.';
  }
  return 'This is a lightweight search candidate. Select it to inspect more provider metadata.';
}

List<_PreviewDiscoverySectionData> _discoverySections({
  required CatalogItem? item,
  required ProviderCandidate? candidate,
  required AdminProviderPreview? preview,
}) {
  final creators = item?.creators
          ?.map((credit) => credit['name']?.toString() ?? '')
          .where((name) => name.trim().isNotEmpty)
          .toList(growable: false) ??
      (preview?.creators
              .map((credit) => credit.role == null
                  ? credit.name
                  : '${credit.name} (${credit.role})')
              .toList(growable: false) ??
          const <String>[]);
  final characters = item?.characters ?? preview?.characters ?? candidate?.characterPreview ?? const <String>[];
  final storyArcs = item?.storyArcs ?? preview?.storyArcs ?? candidate?.storyArcPreview ?? const <String>[];
  final genres = item?.genres ?? preview?.genres ?? const <String>[];

  return [
    if (creators.isNotEmpty)
      _PreviewDiscoverySectionData('Creators', creators),
    if (characters.isNotEmpty)
      _PreviewDiscoverySectionData('Characters', characters),
    if (storyArcs.isNotEmpty)
      _PreviewDiscoverySectionData('Story Arcs', storyArcs),
    if (genres.isNotEmpty) _PreviewDiscoverySectionData('Genres', genres),
  ];
}

List<_PreviewDiffRow> _previewDiffRows({
  required LibraryTypeConfig type,
  required ProviderCandidate? candidate,
  required AdminProviderPreview? preview,
}) {
  if (candidate == null || preview == null) {
    return const <_PreviewDiffRow>[];
  }
  final labels = libraryMediaFieldLabels(type);
  final previewLabels = type.presentation.previewLabels;
  final rows = <_PreviewDiffRow>[];

  void addScalar(String label, String? before, String? after) {
    final normalizedBefore = _normalizePreviewDiffValue(before);
    final normalizedAfter = _normalizePreviewDiffValue(after);
    if (normalizedAfter == null || normalizedBefore == normalizedAfter) {
      return;
    }
    rows.add(_PreviewDiffRow(
      label: label,
      before: normalizedBefore,
      after: normalizedAfter,
    ));
  }

  void addList(String label, List<String> before, List<String> after) {
    final normalizedBefore = before
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    final normalizedAfter = after
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (normalizedAfter.isEmpty) {
      return;
    }
    final beforeValue = normalizedBefore.join(', ');
    final afterValue = normalizedAfter.join(', ');
    if (beforeValue == afterValue) {
      return;
    }
    rows.add(_PreviewDiffRow(
      label: label,
      before: beforeValue.isEmpty ? null : beforeValue,
      after: afterValue,
    ));
  }

  addScalar('Summary', candidate.summary, preview.synopsis);
  addScalar(previewLabels.series, candidate.seriesTitle, preview.seriesTitle);
  addScalar(labels.number, candidate.issueNumber, preview.itemNumber);
  addScalar(labels.publisher, candidate.publisher, preview.publisher);
  addScalar(
    'Year',
    candidate.volumeStartYear?.toString(),
    preview.releaseDate != null
        ? preview.releaseDate!.year.toString()
        : preview.volumeStartYear?.toString(),
  );
  addScalar(labels.variant, candidate.variantName, preview.variantName);
  addScalar(
    'Format',
    null,
    preview.physicalFormatLabel ?? preview.editionFormat ?? preview.physicalFormat,
  );
  addScalar(
    'Image',
    candidate.imageUrl == null ? null : 'Available',
    preview.coverImageUrl == null ? null : 'Available',
  );
  addList('Characters', candidate.characterPreview, preview.characters);
  addList('Story Arcs', candidate.storyArcPreview, preview.storyArcs);

  return rows;
}

String? _normalizePreviewDiffValue(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  return normalized;
}

class _LibraryAddPreviewStatusBanner extends StatelessWidget {
  const _LibraryAddPreviewStatusBanner({
    required this.accent,
    required this.summary,
  });

  final Color accent;
  final String summary;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 16, color: accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                summary,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewDiscoverySectionData {
  const _PreviewDiscoverySectionData(this.title, this.values);

  final String title;
  final List<String> values;
}

class _LibraryAddPreviewDiscoverySection extends StatelessWidget {
  const _LibraryAddPreviewDiscoverySection({
    required this.title,
    required this.values,
    required this.accent,
  });

  final String title;
  final List<String> values;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: accent.withValues(alpha: 0.95),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final value in values)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF183B44),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: const Color(0x8837C7E8)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewTrackRow extends StatelessWidget {
  const _PreviewTrackRow({
    required this.index,
    required this.track,
    required this.accent,
  });

  final int index;
  final _PreviewTrackData track;
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

class _PreviewTrackData {
  const _PreviewTrackData({
    required this.title,
    this.position,
    this.durationSeconds,
  });

  final String title;
  final int? position;
  final int? durationSeconds;
}

List<_PreviewTrackData> _previewTracksForSelection({
  required CatalogItem? item,
  required AdminProviderPreview? preview,
}) {
  if (item?.tracks != null && item!.tracks!.isNotEmpty) {
    return [
      for (final track in item.tracks!)
        _PreviewTrackData(
          title: (track['title'] as String?)?.trim() ?? 'Untitled track',
          position: track['position'] as int?,
          durationSeconds: track['duration_seconds'] as int?,
        ),
    ];
  }
  if (preview == null || preview.tracks.isEmpty) {
    return const [];
  }
  return [
    for (final track in preview.tracks)
      _PreviewTrackData(
        title: track.title,
        position: track.position,
        durationSeconds: track.durationSeconds,
      ),
  ];
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
