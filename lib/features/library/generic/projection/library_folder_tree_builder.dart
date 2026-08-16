import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';

import 'library_grouping_engine.dart';
import 'library_projection_index.dart';

class LibraryFolderTreeBuilder {
  const LibraryFolderTreeBuilder({
    this.groupingEngine = const LibraryGroupingEngine(),
  });

  final LibraryGroupingEngine groupingEngine;

  List<LibraryFolderTreeNode> buildTree({
    required List<LibraryProjectionItem> items,
    required LibraryTypeConfig type,
    required LibraryFolderPreset preset,
    Set<String> expandedNodeIds = const {},
    String? selectedNodeId,
    LibraryProjectionIndex? index,
  }) {
    final nodes = _buildFolderTreeNodes(
      items,
      type: type,
      modes: preset.modes,
      depth: 0,
      pathBuckets: const <String>[],
      expandedNodeIds: expandedNodeIds,
      selectedNodeId: selectedNodeId,
      index: index,
    );
    return [
      LibraryFolderTreeNode(
        id: 'root',
        label: genericAllBucketLabel(type),
        count: items.length,
        cumulativeCount: items.length,
        groupMode: preset.primaryMode,
        children: nodes,
        isExpanded: true,
      ),
    ];
  }

  List<LibraryFolderTreeNode> _buildFolderTreeNodes(
    List<LibraryProjectionItem> items, {
    required LibraryTypeConfig type,
    required List<String> modes,
    required int depth,
    required List<String> pathBuckets,
    required Set<String> expandedNodeIds,
    required String? selectedNodeId,
    LibraryProjectionIndex? index,
  }) {
    if (depth >= modes.length) {
      return const <LibraryFolderTreeNode>[];
    }

    final groupMode = modes[depth];
    final buckets = groupingEngine
        .buildBuckets(items, type, groupMode, index: index)
        .where((bucket) => bucket.title != genericAllBucketLabel(type));
    final children = <LibraryFolderTreeNode>[];

    for (final bucket in buckets) {
      final nextPath = [...pathBuckets, bucket.title];
      final childItems = [
        for (final item in items)
          if ((index != null
                  ? index.getGroupBucket(
                      item,
                      groupMode,
                      (it, mode) =>
                          groupingEngine.getGroupBucketForItem(it, type, mode),
                    )
                  : groupingEngine.getGroupBucketForItem(
                      item, type, groupMode)) ==
              bucket.title)
            item,
      ];
      final subtree = _buildFolderTreeNodes(
        childItems,
        type: type,
        modes: modes,
        depth: depth + 1,
        pathBuckets: nextPath,
        expandedNodeIds: expandedNodeIds,
        selectedNodeId: selectedNodeId,
        index: index,
      );
      final id = libraryFolderTreeNodeId(modes: modes, buckets: nextPath);
      final descendantSelected =
          selectedNodeId != null && selectedNodeId.startsWith('$id|');
      children.add(
        LibraryFolderTreeNode(
          id: id,
          label: bucket.title,
          count: bucket.count,
          cumulativeCount: bucket.count,
          groupMode: groupMode,
          bucketValue: bucket.title,
          children: subtree,
          isExpanded: expandedNodeIds.contains(id) ||
              descendantSelected ||
              (subtree.isNotEmpty && subtree.any((node) => node.isExpanded)),
        ),
      );
    }

    return children;
  }
}
