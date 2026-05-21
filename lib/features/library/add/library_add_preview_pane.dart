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
    required this.providerLabel,
    required this.searched,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final CatalogItem? item;
  final ProviderCandidate? candidate;
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
    final synopsis = selectedItem?.synopsis ?? selectedCandidate?.summary;
    final coverUrl =
        selectedItem?.displayCoverUrl ?? selectedCandidate?.imageUrl;
    final rows = selectedItem == null
        ? <(String, String?)>[
            if (selectedCandidate?.seriesTitle != null)
              ('Artist / Series', selectedCandidate?.seriesTitle),
          ]
        : _metadataRowsForItem(selectedItem, type);
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
                        Text('Plot', style: TextStyle(color: accent)),
                        const SizedBox(height: 6),
                        Text(synopsis ?? 'No metadata summary available yet.'),
                        const SizedBox(height: 22),
                        Text('Details', style: TextStyle(color: accent)),
                        const SizedBox(height: 8),
                        for (final row in rows)
                          if (row.$2 != null && row.$2!.trim().isNotEmpty)
                            _LibraryAddPreviewMetadataRow(
                              label: row.$1,
                              value: row.$2!,
                            ),
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
