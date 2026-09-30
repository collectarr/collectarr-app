import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_hierarchy.dart';

final class MangaHierarchyMapper {
  const MangaHierarchyMapper._();

  static MangaSeriesHierarchy fromCatalogItems({
    required CatalogItemDto selected,
    required Iterable<CatalogItemDto> items,
  }) {
    final selectedSeries = _mapValue(selected.payload['series']);
    final selectedSeriesId = _textValue(
          selectedSeries?['series_id'] ?? selected.payload['series_id'],
        ) ??
        selected.id;
    final selectedSeriesTitle = _textValue(
          selectedSeries?['series_title'] ??
              selected.payload['series_title'] ??
              selected.title,
        ) ??
        selected.title;
    final siblings = items.where((item) {
      if (item.id == selected.id) return true;
      final series = _mapValue(item.payload['series']);
      final seriesId = _textValue(
        series?['series_id'] ?? item.payload['series_id'],
      );
      if (seriesId != null) return seriesId == selectedSeriesId;
      final seriesTitle = _textValue(
        series?['series_title'] ?? item.payload['series_title'],
      );
      return selectedSeriesId == selected.id &&
          seriesTitle?.toLowerCase() == selectedSeriesTitle.toLowerCase();
    }).toList()
      ..sort(
          (left, right) => _volumeNumber(left).compareTo(_volumeNumber(right)));

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
    final rawChapters = item.payload['chapters'];
    final chapters = <MangaChapterHierarchyNode>[];
    if (rawChapters is Iterable) {
      var index = 0;
      for (final rawChapter in rawChapters) {
        if (rawChapter is! Map) continue;
        index++;
        final chapter = Map<String, dynamic>.from(rawChapter);
        final number =
            _intValue(chapter['chapter_number'] ?? chapter['number']) ?? index;
        chapters.add(
          MangaChapterHierarchyNode(
            chapterId:
                _textValue(chapter['id']) ?? '${item.id}:chapter:$number',
            chapterNumber: number,
            title: _textValue(chapter['chapter_title'] ?? chapter['title']),
            pageCount: _intValue(chapter['page_count']),
            releaseDate: _textValue(chapter['release_date']),
          ),
        );
      }
    }
    chapters.sort(
        (left, right) => left.chapterNumber.compareTo(right.chapterNumber));
    return MangaVolumeHierarchyNode(
      volumeId: item.id,
      volumeNumber: _volumeNumber(item),
      title: item.resolvedDisplayTitle,
      chapterCount: chapters.isEmpty ? null : chapters.length,
      chapters: List.unmodifiable(chapters),
    );
  }

  static int _volumeNumber(CatalogItemDto item) =>
      _intValue(item.payload['volume_number'] ?? item.itemNumber) ?? 0;

  static Map<String, dynamic>? _mapValue(Object? value) {
    if (value is! Map) return null;
    return Map<String, dynamic>.from(value);
  }

  static String? _textValue(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static int? _intValue(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString().trim() ?? '');
  }
}
