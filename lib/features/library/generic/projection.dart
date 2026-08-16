import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/projection/library_folder_tree_builder.dart';
import 'package:collectarr_app/features/library/generic/projection/library_grouping_engine.dart';
import 'package:collectarr_app/features/library/generic/projection/library_projection_engine.dart';
import 'package:collectarr_app/features/library/generic/projection/library_projection_query.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/generic/quick_view.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_shelf_entry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_series_sidebar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

export 'projection/library_filter_engine.dart';
export 'projection/library_folder_tree_builder.dart';
export 'projection/library_grouping_engine.dart';
export 'projection/library_projection_engine.dart';
export 'projection/library_projection_index.dart';
export 'projection/library_projection_query.dart';
export 'projection/library_search_index.dart';
export 'projection/library_series_gap_analyzer.dart';
export 'projection/library_toolbar_stats_calculator.dart';
export 'projection_item.dart';
export 'quick_view.dart';

part 'projection_service.dart';

class LibraryLinkedMetadataFilter {
  const LibraryLinkedMetadataFilter({required this.value});

  final String value;

  String get chipLabel => 'Metadata: $value';
}

class LibraryBucketScopeFilter {
  const LibraryBucketScopeFilter({
    required this.groupMode,
    required this.bucket,
  });

  final String groupMode;
  final String bucket;
}

class LibraryFolderTreeNode {
  const LibraryFolderTreeNode({
    required this.id,
    required this.label,
    required this.count,
    required this.cumulativeCount,
    required this.groupMode,
    this.bucketValue,
    required this.children,
    required this.isExpanded,
  });

  final String id;
  final String label;
  final int count;
  final int cumulativeCount;
  final String groupMode;
  final String? bucketValue;
  final List<LibraryFolderTreeNode> children;
  final bool isExpanded;

  bool get hasChildren => children.isNotEmpty;

  LibraryFolderTreeNode copyWith({
    String? id,
    String? label,
    int? count,
    int? cumulativeCount,
    String? groupMode,
    String? bucketValue,
    List<LibraryFolderTreeNode>? children,
    bool? isExpanded,
  }) {
    return LibraryFolderTreeNode(
      id: id ?? this.id,
      label: label ?? this.label,
      count: count ?? this.count,
      cumulativeCount: cumulativeCount ?? this.cumulativeCount,
      groupMode: groupMode ?? this.groupMode,
      bucketValue: bucketValue ?? this.bucketValue,
      children: children ?? this.children,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

class LibraryFolderPreset {
  LibraryFolderPreset({required Iterable<String> modes})
      : modes = List<String>.unmodifiable(modes) {
    if (this.modes.isEmpty) {
      throw ArgumentError('Folder presets must contain at least one mode.');
    }
    if (this.modes.length > 3) {
      throw ArgumentError('Folder presets support at most three modes.');
    }
    if (this.modes.toSet().length != this.modes.length) {
      throw ArgumentError('Folder presets cannot repeat the same mode.');
    }
  }

  factory LibraryFolderPreset.single(String mode) =>
      LibraryFolderPreset(modes: [mode]);

  factory LibraryFolderPreset.parse(String raw, [LibraryTypeConfig? type]) {
    final names = raw
        .split('>')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty);
    final modes = <String>[];
    for (final name in names) {
      final mode = libraryGroupModeFromStorageValue(name, type);
      if (mode == null) {
        throw ArgumentError('Unknown folder preset mode: $name');
      }
      modes.add(mode);
    }
    return LibraryFolderPreset(modes: modes);
  }

  final List<String> modes;

  String get primaryMode => modes.first;

  String get storageValue => modes.map(libraryGroupModeStorageValue).join('>');

  String? nextModeAfter(String mode) {
    final index = modes.indexOf(mode);
    if (index == -1 || index >= modes.length - 1) {
      return null;
    }
    return modes[index + 1];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is LibraryFolderPreset && listEquals(other.modes, modes);
  }

  @override
  int get hashCode => Object.hashAll(modes);
}

LibraryFolderPreset? sanitizeLibraryFolderPreset(
  LibraryFolderPreset? preset, {
  Iterable<String>? allowedModes,
}) {
  if (preset == null) {
    return null;
  }
  final allowed = allowedModes == null ? null : Set<String>.from(allowedModes);
  if (allowed != null && preset.modes.any((mode) => !allowed.contains(mode))) {
    return null;
  }
  return preset;
}

String genericFolderPresetLabel(
  LibraryFolderPreset preset,
  LibraryTypeConfig type,
) {
  return preset.modes
      .map((mode) => genericGroupModeLabel(mode, type))
      .join(' / ');
}

IconData genericFolderPresetIcon(
  LibraryFolderPreset preset, [
  LibraryTypeConfig? type,
]) {
  return genericGroupModeIcon(preset.primaryMode, type);
}

LibraryGroupDefinition<dynamic, dynamic, Object?>?
    libraryGroupModeDefinitionOrNull(
  String mode, [
  LibraryTypeConfig? type,
]) {
  if (type != null) {
    final module = libraryKindRuntimeForType(type);
    return module.fields.findGroupDefinition(mode);
  }
  return null;
}

String genericGroupModeLabel(
  String mode,
  LibraryTypeConfig type,
) {
  if (mode == 'publisher' &&
      type.presentation.groupLabels.publisherMode.isNotEmpty) {
    return type.presentation.groupLabels.publisherMode;
  }
  return libraryGroupModeDefinitionOrNull(mode, type)?.label ?? mode;
}

String? genericGroupModeDrilldownChildMode(
  String mode,
  LibraryTypeConfig type,
) {
  return libraryGroupModeDefinitionOrNull(mode, type)?.drilldownChildId;
}

bool libraryAllowsGroupDrilldown({
  required String currentMode,
  required String? childMode,
  LibraryTypeConfig? type,
}) {
  if (childMode == null || childMode == currentMode) {
    return false;
  }
  if (type != null) {
    final def = libraryGroupModeDefinitionOrNull(currentMode, type);
    if (def?.drilldownChildId != null) {
      return childMode == def!.drilldownChildId;
    }
  }
  return true;
}

String genericGroupModeFolderSetLabel(
  String mode,
  LibraryTypeConfig type,
) {
  return genericFolderPresetLabel(LibraryFolderPreset.single(mode), type);
}

String genericGroupModeSidebarTitle(
  String mode,
  LibraryTypeConfig type,
) {
  return libraryGroupModeDefinitionOrNull(mode, type)?.resolvedSidebarTitle ??
      genericGroupModeLabel(mode, type);
}

IconData genericGroupModeIcon(
  String mode, [
  LibraryTypeConfig? type,
]) {
  return libraryGroupModeDefinitionOrNull(mode, type)?.icon ??
      Icons.account_tree_outlined;
}

LibraryGroupPresentation genericGroupPresentationForMode(
  String mode, [
  LibraryTypeConfig? type,
]) {
  return libraryGroupModeDefinitionOrNull(mode, type)?.presentation ??
      LibraryGroupPresentation.inlineHeaders;
}

List<String> libraryGroupModesForType(
  LibraryTypeConfig type,
) {
  return [for (final mode in type.availableGroupModes) mode.toString()];
}

String libraryDefaultGroupMode(LibraryTypeConfig type) {
  return libraryGroupModesForType(type).first;
}

String libraryGroupModeStorageValue(String mode, [LibraryTypeConfig? type]) {
  final def = libraryGroupModeDefinitionOrNull(mode, type);
  return 'group.${def?.id.value ?? mode}';
}

String? libraryGroupModeFromStorageValue(String value,
    [LibraryTypeConfig? type]) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    return null;
  }
  final candidate =
      normalized.startsWith('group.') ? normalized.substring(6) : normalized;

  if (type != null) {
    final module = libraryKindRuntimeForType(type);
    return module.fields.findGroupDefinition(candidate)?.id.value;
  }

  return candidate;
}

class LibraryProjection {
  const LibraryProjection({
    required this.allItems,
    required this.filteredItems,
    required this.buckets,
    required this.selectedItem,
    required this.counts,
  });

  factory LibraryProjection.fromShelf({
    required ShelfState shelf,
    required LibraryTypeConfig type,
    required LibraryMediaAdapter adapter,
    required LibraryWorkspaceViewState viewState,
    LibraryWorkspaceBrowserMode browserMode = LibraryWorkspaceBrowserMode.media,
    String? releaseFolderTitleItemId,
    required String query,
    LibraryLinkedMetadataFilter? linkedMetadataFilter,
    required String? selectedBucket,
    required String? selectedItemId,
    required LibraryQuickView? quickView,
    LibraryCollectionStatusScope collectionStatusScope =
        LibraryCollectionStatusScope.all,
    required String groupMode,
    List<LibraryBucketScopeFilter> bucketScopeFilters = const [],
    List<LibrarySeriesBucket>? overrideBuckets,
    Set<String>? constrainedItemIds,
    LibraryFilterSelection filterSelection = LibraryFilterSelection.none,
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<String>> customFieldValuesByItem = const {},
    Map<String, Map<String, String>> customFieldValuesByDefinitionByItem =
        const {},
    Set<String> activeLoanOwnedItemIds = const {},
    LibrarySearchTarget searchTarget = LibrarySearchTarget.all,
  }) {
    return const LibraryProjectionService().build(
      shelf: shelf,
      type: type,
      adapter: adapter,
      viewState: viewState,
      browserMode: browserMode,
      releaseFolderTitleItemId: releaseFolderTitleItemId,
      query: query,
      linkedMetadataFilter: linkedMetadataFilter,
      selectedBucket: selectedBucket,
      selectedItemId: selectedItemId,
      quickView: quickView,
      collectionStatusScope: collectionStatusScope,
      groupMode: groupMode,
      bucketScopeFilters: bucketScopeFilters,
      overrideBuckets: overrideBuckets,
      constrainedItemIds: constrainedItemIds,
      filterSelection: filterSelection,
      customFieldDefinitions: customFieldDefinitions,
      customFieldValuesByItem: customFieldValuesByItem,
      customFieldValuesByDefinitionByItem: customFieldValuesByDefinitionByItem,
      activeLoanOwnedItemIds: activeLoanOwnedItemIds,
      searchTarget: searchTarget,
    );
  }

  final List<LibraryProjectionItem> allItems;
  final List<LibraryProjectionItem> filteredItems;
  final List<LibrarySeriesBucket> buckets;
  final LibraryProjectionItem? selectedItem;
  final LibraryToolbarCounts counts;
}

List<LibrarySeriesBucket> libraryBucketsForItems(
  List<LibraryProjectionItem> items,
  LibraryTypeConfig type,
  String groupMode,
) {
  return const LibraryGroupingEngine().buildBuckets(items, type, groupMode);
}

List<GroupShelfEntry> libraryGroupEntriesForItems(
  List<LibraryProjectionItem> items,
  LibraryTypeConfig type,
  String groupMode, {
  LibraryGroupPresentation? presentationOverride,
}) {
  return const LibraryGroupingEngine().buildGroupEntries(
    items,
    type,
    groupMode,
    presentationOverride: presentationOverride,
  );
}

LibraryProjectionItem? librarySelectedItem(
  List<LibraryProjectionItem> items,
  String? selectedItemId,
) {
  if (selectedItemId == null) {
    return null;
  }
  for (final item in items) {
    if (item.node.id == selectedItemId) {
      return item;
    }
  }
  return null;
}

String genericBucketForItem(
  LibraryProjectionItem item,
  LibraryTypeConfig type,
) {
  return const LibraryGroupingEngine().getGroupBucketForItem(
    item,
    type,
    libraryDefaultGroupMode(type),
  );
}

String genericBucketForItemMode(
  LibraryProjectionItem item,
  LibraryTypeConfig type,
  Object groupMode,
) {
  return const LibraryGroupingEngine().getGroupBucketForItem(
    item,
    type,
    groupMode.toString(),
  );
}

String genericAllBucketLabel(LibraryTypeConfig type) {
  return '[All ${type.pluralLabel}]';
}

String libraryFolderTreeNodeId({
  required List<String> modes,
  required List<String> buckets,
}) {
  final segments = <String>[];
  for (var index = 0; index < buckets.length; index += 1) {
    segments.add(
      '${libraryGroupModeStorageValue(modes[index])}=${Uri.encodeComponent(buckets[index])}',
    );
  }
  return segments.join('|');
}

List<LibraryFolderTreeNode> libraryFolderTreeNodesForItems(
  List<LibraryProjectionItem> items,
  LibraryTypeConfig type,
  LibraryFolderPreset preset, {
  Set<String> expandedNodeIds = const {},
  String? selectedNodeId,
}) {
  return const LibraryFolderTreeBuilder().buildTree(
    items: items,
    type: type,
    preset: preset,
    expandedNodeIds: expandedNodeIds,
    selectedNodeId: selectedNodeId,
  );
}

bool libraryEntryMatchesLinkedMetadataFilter(
  LibraryProjectionRuntime item,
  String value,
  LibraryMediaAdapter adapter,
) {
  final normalized = value.trim().toLowerCase();
  if (normalized.isEmpty) {
    return true;
  }
  for (final candidate
      in adapter.linkedMetadataCandidatesForEntry(item.source)) {
    if (candidate.trim().toLowerCase() == normalized) {
      return true;
    }
  }
  return false;
}
