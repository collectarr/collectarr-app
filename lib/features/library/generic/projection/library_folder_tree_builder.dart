import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'library_projection_index.dart';

class LibraryFolderTreeBuilder {
  const LibraryFolderTreeBuilder();

  List<LibraryFolderTreeNode> buildTree({
    required List<LibraryFolderPreset> presets,
    required List<LibraryProjectionItem> items,
    required LibraryProjectionIndex index,
    required Set<String> expandedNodeIds,
  }) {
    if (presets.isEmpty || items.isEmpty) return const [];
    final primaryPreset = presets.first;
    final buckets = <String, int>{};

    for (final item in items) {
      final bucket = index.getGroupBucket(
        item,
        primaryPreset.primaryMode,
        (item, mode) => item.dto.publisher ?? 'Unknown',
      );
      buckets[bucket] = (buckets[bucket] ?? 0) + 1;
    }

    return [
      for (final entry in buckets.entries)
        LibraryFolderTreeNode(
          id: '${primaryPreset.primaryMode}:${entry.key}',
          label: entry.key,
          count: entry.value,
          cumulativeCount: entry.value,
          groupMode: primaryPreset.primaryMode,
          bucketValue: entry.key,
          children: const [],
          isExpanded: expandedNodeIds.contains('${primaryPreset.primaryMode}:${entry.key}'),
        ),
    ];
  }
}
