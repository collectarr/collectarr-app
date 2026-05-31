import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/add/library_add_reference_type.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:flutter/material.dart';

Widget buildComicAddPreviewPane(
  BuildContext context,
  LibraryAddPreviewPaneRequest request,
) {
  return _ComicAddPreviewPane(request: request);
}

class _ComicAddPreviewPane extends StatelessWidget {
  const _ComicAddPreviewPane({required this.request});

  final LibraryAddPreviewPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final selectedItem = request.item;
    final selectedCandidate = request.candidate;
    final selectedBundle =
        request.referenceType == LibraryAddReferenceType.bundleRelease
            ? request.selectedBundleReleaseDetail
            : null;
    final title = selectedBundle?.title ??
        selectedItem?.title ??
        selectedCandidate!.title;
    final itemNumber =
        selectedBundle == null ? selectedItem?.itemNumber : null;
    final preview = request.candidatePreview;
    final synopsis = selectedItem?.synopsis ??
        preview?.synopsis ??
        selectedCandidate?.summary;
    final coverUrl = selectedBundle?.coverImageUrl ??
        selectedItem?.displayCoverUrl ??
        preview?.coverImageUrl ??
        selectedCandidate?.imageUrl;
    final rows = selectedItem == null
        ? (preview != null
            ? libraryAddMetadataRowsForFullPreview(preview, request.type)
        : libraryAddMetadataRowsForCandidate(selectedCandidate!, request.type))
        : libraryAddMetadataRowsForItem(selectedItem, request.type);
    final discoverySections = libraryAddPreviewDiscoverySections(
      item: selectedItem,
      candidate: selectedCandidate,
      preview: preview,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.panelRaised,
            Color.alphaBlend(
              request.accent.withValues(alpha: 0.1),
              palette.panel,
            ),
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
                          color: request.accent,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1.02,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Issue identity',
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          LibraryAddResultBadge(
                            selectedItem == null
                                ? request.providerLabel
                                : request.type.singularLabel,
                            accent: request.accent,
                          ),
                          if (itemNumber != null)
                            LibraryAddResultBadge(
                              '#$itemNumber',
                              accent: request.accent,
                            ),
                          if (selectedItem?.displayEditionLabel?.trim().isNotEmpty ==
                              true)
                            LibraryAddResultBadge(
                              selectedItem!.displayEditionLabel!,
                              accent: request.accent,
                            ),
                          if (selectedItem?.releaseYear != null)
                            LibraryAddResultBadge(
                              selectedItem!.releaseYear.toString(),
                              accent: request.accent,
                            ),
                        ],
                      ),
                      if (synopsis != null && synopsis.trim().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Story summary',
                          style: TextStyle(
                            color: request.accent,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          synopsis,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.textPrimary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                SizedBox(
                  width: 196,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: palette.surfaceSubtle.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: request.accent.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: AspectRatio(
                        aspectRatio: 2 / 3,
                        child: LibraryInteractiveCover(
                          title: title,
                          itemNumber: itemNumber,
                          imageUrl: coverUrl,
                          accentColor: request.accent,
                          borderRadius: 6,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  if (selectedItem != null) ...[
                    LibraryAddReferenceSelector(
                      type: request.type,
                      accent: request.accent,
                      addTarget: request.addTarget,
                      referenceType: request.referenceType,
                      item: selectedItem,
                      bundleReleases: request.availableBundleReleases,
                      selectedBundleReleaseId: request.selectedBundleReleaseId,
                      selectedEditionId: request.selectedEditionId,
                      selectedVariantId: request.selectedVariantId,
                      isLoadingBundleReleases: request.isLoadingBundleReleases,
                      onReferenceTypeChanged: request.onReferenceTypeChanged,
                      onEditionSelected: request.onEditionSelected,
                      onVariantSelected: request.onVariantSelected,
                      onBundleReleaseSelected: request.onBundleReleaseSelected,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (selectedItem != null &&
                      request.referenceType ==
                          LibraryAddReferenceType.bundleRelease) ...[
                    Text(
                      'Bundle contents',
                      style: TextStyle(
                        color: request.accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (request.selectedBundleReleaseId != null &&
                        request.isLoadingBundleReleaseDetail)
                      Row(
                        children: [
                          const SizedBox.square(
                            dimension: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Loading bundle contents...',
                            style: TextStyle(color: palette.textMuted),
                          ),
                        ],
                      )
                    else if (selectedBundle != null)
                      BundleReleaseDetailCard(
                        detail: selectedBundle,
                        accent: request.accent,
                      )
                    else
                      Text(
                        'Select a bundle release to preview its members.',
                        style: TextStyle(color: palette.textMuted),
                      ),
                    const SizedBox(height: 14),
                  ],
                  Text(
                    'Issue details',
                    style: TextStyle(
                      color: request.accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final row in rows)
                    if (row.$2 != null && row.$2!.trim().isNotEmpty)
                      LibraryAddPreviewMetadataRow(
                        label: row.$1,
                        value: row.$2!,
                      ),
                  if (discoverySections.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      'Discovery',
                      style: TextStyle(
                        color: request.accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final section in discoverySections)
                      LibraryAddPreviewDiscoverySection(
                        title: section.title,
                        values: section.values,
                        accent: request.accent,
                      ),
                  ],
                  if (request.isFetchingPreview) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const SizedBox.square(
                          dimension: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
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
          ],
        ),
      ),
    );
  }
}