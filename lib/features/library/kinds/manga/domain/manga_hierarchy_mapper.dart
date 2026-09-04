import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_hierarchy.dart';

final class MangaHierarchyMapper {
  const MangaHierarchyMapper._();

  static MangaSeriesHierarchy fromChapterRows({
    required String seriesId,
    required Iterable<Map<String, dynamic>> rows,
  }) {
    final volumes = <int, List<MangaChapterHierarchyNode>>{};
    final volumeTitles = <int, String>{};
    String? seriesTitle;

    var rowIndex = 0;
    for (final row in rows) {
      rowIndex++;
      final chapterNumber =
          _intValue(row['chapter_number'] ?? row['number']) ?? rowIndex;
      final volumeNumber = _intValue(row['volume_number']) ?? chapterNumber;
      final chapterTitle = _textValue(row['chapter_title'] ?? row['title']);
      final volumeTitle = _textValue(row['volume_title']);
      seriesTitle ??= _textValue(row['series_title']);
      if (volumeTitle != null) {
        volumeTitles[volumeNumber] = volumeTitle;
      }
      volumes.putIfAbsent(volumeNumber, () => []).add(
            MangaChapterHierarchyNode(
              chapterId: (row['id'] ?? 'chapter_$chapterNumber').toString(),
              chapterNumber: chapterNumber,
              title: chapterTitle ?? 'Chapter $chapterNumber',
              pageCount: _intValue(row['page_count']),
              releaseDate: _textValue(row['release_date']),
            ),
          );
    }

    for (final chapters in volumes.values) {
      chapters.sort(
        (left, right) => left.chapterNumber.compareTo(right.chapterNumber),
      );
    }

    final sortedVolumeNumbers = volumes.keys.toList()..sort();
    return MangaSeriesHierarchy(
      seriesId: seriesId,
      seriesTitle: seriesTitle ?? seriesId,
      volumes: [
        for (final volumeNumber in sortedVolumeNumbers)
          MangaVolumeHierarchyNode(
            volumeId: '$seriesId-volume-$volumeNumber',
            volumeNumber: volumeNumber,
            title: volumeTitles[volumeNumber] ?? 'Volume $volumeNumber',
            chapterCount: volumes[volumeNumber]!.length,
            chapters: List.unmodifiable(volumes[volumeNumber]!),
          ),
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
                metadata: {
                  'number': chapter.chapterNumber,
                  if (chapter.releaseDate != null)
                    'releaseDate': chapter.releaseDate,
                },
              ),
          ],
          metadata: {'number': volume.volumeNumber},
        ),
    ];
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
