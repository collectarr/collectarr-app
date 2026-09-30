import 'library_add_pane_dependencies.dart';

class LibraryAddPaneResizeDivider extends StatelessWidget {
  const LibraryAddPaneResizeDivider({super.key, this.onDragDelta});

  final ValueChanged<double>? onDragDelta;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
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
              child: Container(width: 2, color: palette.divider),
            ),
          ),
        ),
      ),
    );
  }
}

class LibraryAddPreviewPane extends ConsumerWidget {
  const LibraryAddPreviewPane({
    super.key,
    required this.type,
    required this.accent,
    required this.isWideLayout,
    required this.previewPaneBuilder,
    required this.item,
    required this.isFetchingPreview,
    required this.searched,
  });

  final LibraryKindRegistration type;
  final Color accent;
  final bool isWideLayout;
  final LibraryAddPreviewPaneBuilder? previewPaneBuilder;
  final CatalogSearchCandidate? item;
  final bool isFetchingPreview;
  final bool searched;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = appPalette(context);
    final selectedItem = item;
    if (selectedItem == null) {
      return ColoredBox(
        color: palette.panel,
        child: Center(
          child: Text(
            searched
                ? 'Select a catalog result or add and propose one manually.'
                : 'Search Collectarr Core to preview catalog metadata.',
            style: TextStyle(
              color: palette.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }
    final title = libraryPresentationForKind(type.kind)
        .builder
        .buildAddPreviewTitle(item: selectedItem);
    final itemNumber = libraryPresentationForKind(type.kind)
        .builder
        .buildAddPreviewItemNumber(item: selectedItem);
    final presentation = libraryPresentationForKind(type.kind).builder;
    final synopsis = presentation.showAddPreviewDescription
        ? presentation.buildAddPreviewSynopsis(item: selectedItem)
        : null;
    final coverUrl = selectedItem.summary.imageUrl;
    final rows = _metadataRowsForItem(selectedItem, type);
    final previewRequest = LibraryAddPreviewPaneRequest(
      type: type,
      accent: accent,
      item: selectedItem,
      isFetchingPreview: isFetchingPreview,
      searched: searched,
    );
    final launcherPreview = previewPaneBuilder?.call(context, previewRequest);
    if (launcherPreview != null) {
      return launcherPreview;
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.panelRaised,
            Color.alphaBlend(accent.withValues(alpha: 0.12), palette.panel),
            palette.panel,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
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
                          color: libraryAccentTextColor(accent, palette.panel),
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          height: 1.02,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Collectarr Core catalog item',
                        style: const TextStyle(fontSize: 16),
                      ),
                      _buildPreviewFormatBadges(
                        libraryPresentationForKind(type.kind)
                            .builder
                            .buildAddPreviewFormatBadges(item: selectedItem),
                      ),
                    ],
                  ),
                ),
                LibraryAddResultBadge(
                  type.identity.singularLabel,
                ),
              ],
            ),
            Divider(height: 18, color: accent.withValues(alpha: 0.42)),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        if (synopsis != null && synopsis.trim().isNotEmpty) ...[
                          Text(
                            'Plot',
                            style: TextStyle(
                              color:
                                  libraryAccentTextColor(accent, palette.panel),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(synopsis),
                          const SizedBox(height: 22),
                        ],
                        const SizedBox(height: 22),
                        Text(
                          'Details',
                          style: TextStyle(
                            color:
                                libraryAccentTextColor(accent, palette.panel),
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (final row in rows)
                          if (row.$2 != null && row.$2!.trim().isNotEmpty)
                            _LibraryAddPreviewMetadataRow(
                              label: row.$1,
                              value: row.$2!,
                            ),
                        if (isFetchingPreview) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const SizedBox.square(
                                dimension: 14,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Fetching full metadata...',
                                style: TextStyle(color: palette.textMuted),
                              ),
                            ],
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
                        color: appPalette(context)
                            .surfaceSubtle
                            .withValues(alpha: 0.74),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: AspectRatio(
                          aspectRatio: 2 / 3,
                          child: LibraryInteractiveCover(
                            title: title,
                            itemNumber: itemNumber,
                            imageUrl: coverUrl,
                            accentColor: accent,
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

List<(String, String?)> libraryAddMetadataRowsForItem(
  CatalogSearchCandidate item,
  LibraryKindRegistration type,
) =>
    _metadataRowsForItem(item, type);

class LibraryAddPreviewMetadataRow extends StatelessWidget {
  const LibraryAddPreviewMetadataRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) =>
      _LibraryAddPreviewMetadataRow(label: label, value: value);
}

Widget _buildPreviewFormatBadges(
  List<LibraryFormatBadgeDescriptor> formatValues,
) {
  if (formatValues.isEmpty) return const SizedBox.shrink();
  final seen = <String>{};
  final badges = <Widget>[];
  for (final format in formatValues) {
    if (seen.add(format.key)) {
      badges.add(FormatBadge.fromDescriptor(descriptor: format));
    }
  }
  if (badges.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Wrap(spacing: 4, runSpacing: 4, children: badges),
  );
}

List<(String, String?)> _metadataRowsForItem(
  CatalogSearchCandidate item,
  LibraryKindRegistration type,
) =>
    libraryPresentationForKind(type.kind).builder.buildAddPreviewMetadataRows(
          item: item,
          previewLabels: libraryPresentationForKind(type.kind).previewLabels,
        );

class _LibraryAddPreviewMetadataRow extends StatelessWidget {
  const _LibraryAddPreviewMetadataRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: TextStyle(
                color: palette.textMuted,
                fontWeight: FontWeight.w700,
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
