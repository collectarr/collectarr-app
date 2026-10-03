import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/kinds/movie/catalog/movie_catalog_fields.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_physical_media_formats.dart';
import 'package:flutter/material.dart';

Widget buildMovieAddPreviewPane(
  BuildContext context,
  LibraryAddPreviewPaneRequest request,
) {
  return _MovieAddPreviewPane(request: request);
}

class _MovieAddPreviewPane extends StatelessWidget {
  const _MovieAddPreviewPane({required this.request});

  final LibraryAddPreviewPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final selectedItem = request.item;
    if (selectedItem == null) return const SizedBox.shrink();
    final title = selectedItem.summary.primaryLabel;
    final itemNumber = selectedItem.movieCatalogFields.itemNumber;
    final synopsis = selectedItem.movieCatalogFields.synopsis;
    final coverUrl = selectedItem.movieCatalogFields.coverImageUrl;
    final rows = libraryAddMetadataRowsForItem(selectedItem, request.type);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border(left: BorderSide(color: palette.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 132,
                  child: AspectRatio(
                    aspectRatio: 2 / 3,
                    child: LibraryInteractiveCover(
                      title: title,
                      itemNumber: itemNumber,
                      imageUrl: coverUrl,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemNumber == null ? title : '$title #$itemNumber',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          height: 1.02,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Release overview',
                        style: TextStyle(
                          color: request.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          LibraryAddResultBadge(
                            'library',
                            accent: request.accent,
                          ),
                          if (selectedItem.movieCatalogFields.releaseYear !=
                              null)
                            LibraryAddResultBadge(
                              selectedItem.movieCatalogFields.releaseYear
                                  .toString(),
                              accent: request.accent,
                            ),
                          if (selectedItem.movieCatalogFields.physicalFormat
                              case final format?
                              when moviePhysicalMediaFormatLabel(format) !=
                                  null)
                            LibraryAddResultBadge(
                              moviePhysicalMediaFormatLabel(format)!,
                              accent: request.accent,
                            ),
                        ],
                      ),
                      if (synopsis != null && synopsis.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          synopsis,
                          maxLines: 8,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView(
                children: [
                  Text(
                    'Details',
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
