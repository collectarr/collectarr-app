import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_hierarchy.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';

final class MangaHierarchyMapper {
  const MangaHierarchyMapper._();

  static MangaSeriesHierarchy fromCatalogItems({
    required CatalogItemDto selected,
    required Iterable<CatalogItemDto> items,
  }) {
    final selectedMetadata = MangaMetadata.fromJson(selected.kindData);
    final selectedSeriesTitle =
        selectedMetadata.seriesTitle?.trim().isNotEmpty == true
            ? selectedMetadata.seriesTitle!.trim()
            : selectedMetadata.title;
    final selectedSeriesId = selectedMetadata.seriesGroup?.trim().isNotEmpty ==
            true
        ? selectedMetadata.seriesGroup!.trim()
        : selectedSeriesTitle;
    final siblings = items.where((item) {
      if (item.id == selected.id) return true;
      final metadata = MangaMetadata.fromJson(item.kindData);
      final seriesId = metadata.seriesGroup?.trim();
      if (seriesId != null && seriesId.isNotEmpty) {
        return seriesId == selectedSeriesId;
      }
      final seriesTitle = metadata.seriesTitle?.trim();
      return seriesTitle != null &&
          seriesTitle.isNotEmpty &&
          seriesTitle.toLowerCase() == selectedSeriesTitle.toLowerCase();
    }).toList()
      ..sort((left, right) {
        final leftNumber = MangaMetadata.fromJson(left.kindData).volumeNumber;
        final rightNumber =
            MangaMetadata.fromJson(right.kindData).volumeNumber;
        return (leftNumber ?? 0).compareTo(rightNumber ?? 0);
      });

    return MangaSeriesHierarchy(
      seriesId: selectedSeriesId,
      seriesTitle: selectedSeriesTitle,
      volumes: [
        for (final item in siblings) _volumeFromCatalogItem(item),
      ],
    );
  }

  static List<LibraryHierarchyNode> toLibraryNodes(
    MangaSeriesHierarchy hierarchy,
  ) {
    return [
      for (final volume in hierarchy.volumes)
        LibraryHierarchyNode(
          id: volume.volumeId,
          label: volume.title ?? 'Volume ${volume.volumeNumber}',
          secondaryLabel: '${volume.chapters.length} chapters',
          level: LibraryHierarchyLevel.container,
          totalCount: volume.chapterCount ?? volume.chapters.length,
          children: [
            for (final chapter in volume.chapters)
              LibraryHierarchyNode(
                id: chapter.chapterId,
                label: chapter.title ?? 'Chapter ${chapter.chapterNumber}',
                secondaryLabel: chapter.pageCount == null
                    ? null
                    : '${chapter.pageCount} pages',
                level: LibraryHierarchyLevel.leaf,
                totalCount: chapter.pageCount,
                extras: {
                  'number': chapter.chapterNumber,
                  if (chapter.releaseDate != null)
                    'releaseDate': chapter.releaseDate,
                },
              ),
          ],
          extras: {'number': volume.volumeNumber},
        ),
    ];
  }

  static MangaVolumeHierarchyNode _volumeFromCatalogItem(
    CatalogItemDto item,
  ) {
    final metadata = MangaMetadata.fromJson(item.kindData);
    final chapters = [
      for (var index = 0; index < metadata.chapters.length; index++)
        _chapterFromMetadata(item.id, index, metadata.chapters[index]),
    ];
    chapters.sort(
        (left, right) => left.chapterNumber.compareTo(right.chapterNumber));
    return MangaVolumeHierarchyNode(
      volumeId: item.id,
      volumeNumber: metadata.volumeNumber ?? 0,
      title: metadata.volumeName ?? metadata.title,
      chapterCount: chapters.isEmpty ? null : chapters.length,
      chapters: List.unmodifiable(chapters),
    );
  }

  static MangaChapterHierarchyNode _chapterFromMetadata(
    String itemId,
    int index,
    MangaChapter chapter,
  ) {
    final number = chapter.chapterNumber ?? index + 1;
    return MangaChapterHierarchyNode(
      chapterId: chapter.id ?? '$itemId:chapter:$number',
      chapterNumber: number,
      title: chapter.title,
      pageCount: chapter.pageCount,
      releaseDate: chapter.releaseDate?.isoString,
    );
  }
}
