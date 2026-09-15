import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_field_registry.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_layout.dart';
import 'package:collectarr_app/features/library/workspace/table/media_table_columns.dart';
import 'package:collectarr_app/features/library/config/library_hierarchy_capability.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:flutter/material.dart';

/// Workspace behavior owned by one concrete kind.
///
/// The registry may hold this behind the structural interface, but all field
/// and projection callbacks are bound to the concrete [TDto] implementation
/// when the kind contributor constructs the workspace.
abstract interface class LibraryKindWorkspace {
  LibraryFieldRegistry<LibraryWorkspaceDto> get fields;

  /// Selects the kind-owned schema from the structural workspace node.
  ///
  /// Generic workspace code supplies the node shape; it never interprets
  /// Music-specific entity names or fields.
  LibraryFieldRegistry<LibraryWorkspaceDto> fieldsForNode(LibraryNodeRef node);
  LibraryFieldRegistry<LibraryWorkspaceDto> fieldsForBrowserMode(
    LibraryWorkspaceBrowserMode browserMode,
  );

  /// Resolves the concrete catalog target represented by a structural node
  /// for lifecycle operations. Kinds may refine a root reference (for
  /// example, a release node), while generic callers keep the result opaque.
  CatalogEntityRef trackingTargetForNode(
    LibraryNodeRef node,
    CatalogEntityRef rootRef,
  );
  LibraryWorkspaceProjector<LibraryWorkspaceDto> get projector;

  List<LibraryGroupIdRuntime> get availableGroupIds;
  List<LibraryGroupIdRuntime> availableGroupIdsForBrowserMode(
    LibraryWorkspaceBrowserMode browserMode,
  );
  List<LibrarySortIdRuntime> availableSortIdsForBrowserMode(
    LibraryWorkspaceBrowserMode browserMode,
  );

  Set<LibraryFieldIdRuntime> get defaultTableColumns;
  List<LibraryFieldIdRuntime> orderedTableColumns(
      Set<LibraryFieldIdRuntime> columns,
      {LibraryNodeRef? node});
  double tableWidthForColumns(Set<LibraryFieldIdRuntime> columns,
      Map<LibraryFieldIdRuntime, double> customWidths,
      {LibraryNodeRef? node});
  double tableColumnWidth(LibraryFieldIdRuntime column,
      Map<LibraryFieldIdRuntime, double> customWidths,
      {LibraryNodeRef? node});
  double defaultTableColumnWidth(LibraryFieldIdRuntime column,
      {LibraryNodeRef? node});
  String columnLabel(LibraryFieldIdRuntime column, {LibraryNodeRef? node});
  String columnDisplayName(LibraryFieldIdRuntime column,
      {LibraryNodeRef? node});
  LibraryTableColumnGroup columnGroup(LibraryFieldIdRuntime column,
      {LibraryNodeRef? node});
  String columnGroupLabel(LibraryTableColumnGroup group);
  bool columnIsNumeric(LibraryFieldIdRuntime column, {LibraryNodeRef? node});
  LibrarySortIdRuntime? columnSort(LibraryFieldIdRuntime column,
      {LibraryNodeRef? node});
  Widget buildTableCell(
    LibraryProjectionView item,
    LibraryFieldIdRuntime column,
  );

  int compareEntriesByRules(
    LibraryProjectionView left,
    LibraryProjectionView right,
    Iterable<LibrarySortRuleRuntime> rules,
  );
  String? subgroupKeyForEntry(
    LibraryProjectionView item,
    LibraryGroupIdRuntime groupId,
  );
  int compareSubgroupKeys(String left, String right);

  LibraryProjectionView project({
    required LibraryWorkspaceSource source,
    required LibraryNodeRef node,
  });

  void sort(
    List<LibraryProjectionView> items,
    LibrarySortIdRuntime sortId, {
    bool ascending = true,
  });
  int compare(
    LibraryProjectionView left,
    LibraryProjectionView right,
    LibrarySortIdRuntime sortId,
  );
  Object? groupValue(
    LibraryProjectionView item,
    LibraryGroupIdRuntime groupId,
  );
  bool groupModeSupportsCompletion(LibraryGroupIdRuntime groupId);
  String? groupSequenceValueForEntry(
    LibraryProjectionView item,
    LibraryGroupIdRuntime groupId,
  );
  Object? columnValue(
    LibraryProjectionView item,
    LibraryFieldIdRuntime columnId,
  );
  void validateProjection(LibraryProjectionView item);
  LibraryWorkspaceDto createWorkspaceDto({
    required LibraryWorkspaceSource source,
    required LibraryNodeRef node,
  });
}

final class TypedLibraryKindWorkspace<TDto extends LibraryWorkspaceDto>
    implements LibraryKindWorkspace {
  const TypedLibraryKindWorkspace({
    required this.fields,
    required this.projector,
    required this.hierarchy,
    this.nodeSchemaResolver,
    this.browserModeSchemaResolver,
    this.trackingTargetResolver,
  });

  @override
  final LibraryFieldRegistry<TDto> fields;

  final LibraryFieldRegistry<TDto> Function(LibraryNodeRef node)?
      nodeSchemaResolver;

  final LibraryFieldRegistry<TDto> Function(
    LibraryWorkspaceBrowserMode browserMode,
  )? browserModeSchemaResolver;

  final CatalogEntityRef Function(
    LibraryNodeRef node,
    CatalogEntityRef rootRef,
  )? trackingTargetResolver;

  @override
  final LibraryWorkspaceProjector<TDto> projector;

  final LibraryHierarchyCapability hierarchy;

  @override
  LibraryFieldRegistry<LibraryWorkspaceDto> fieldsForNode(
          LibraryNodeRef node) =>
      nodeSchemaResolver?.call(node) ?? fields;

  @override
  LibraryFieldRegistry<LibraryWorkspaceDto> fieldsForBrowserMode(
    LibraryWorkspaceBrowserMode browserMode,
  ) =>
      browserModeSchemaResolver?.call(browserMode) ?? fields;

  @override
  CatalogEntityRef trackingTargetForNode(
    LibraryNodeRef node,
    CatalogEntityRef rootRef,
  ) =>
      trackingTargetResolver?.call(node, rootRef) ?? rootRef;

  @override
  List<LibraryGroupIdRuntime> get availableGroupIds => [
        for (final definition in fields.groups) definition.id,
      ];

  @override
  List<LibraryGroupIdRuntime> availableGroupIdsForBrowserMode(
    LibraryWorkspaceBrowserMode browserMode,
  ) {
    final scopedFields =
        fieldsForBrowserMode(browserMode) as LibraryFieldRegistry<TDto>;
    final allGroups = [
      for (final definition in scopedFields.groups) definition.id,
    ];
    if (!hierarchy.scopesOptionsByBrowserMode) return allGroups;
    final scopedGroups = browserMode == LibraryWorkspaceBrowserMode.releases
        ? hierarchy.releaseScopeGroupIds
        : hierarchy.mediaScopeGroupIds;
    if (scopedGroups == null) return allGroups;
    return [
      for (final groupId in allGroups)
        if (scopedGroups.any((id) => id.sameIdentityAs(groupId))) groupId,
    ];
  }

  @override
  List<LibrarySortIdRuntime> availableSortIdsForBrowserMode(
    LibraryWorkspaceBrowserMode browserMode,
  ) {
    final scopedFields =
        fieldsForBrowserMode(browserMode) as LibraryFieldRegistry<TDto>;
    final allSorts = [
      for (final definition in scopedFields.sorts) definition.id
    ];
    if (!hierarchy.scopesOptionsByBrowserMode) return allSorts;
    final scopedSorts = browserMode == LibraryWorkspaceBrowserMode.releases
        ? hierarchy.releaseScopeSortIds
        : hierarchy.mediaScopeSortIds;
    if (scopedSorts == null) return allSorts;
    return [
      for (final sortId in allSorts)
        if (scopedSorts.any((id) => id.sameIdentityAs(sortId))) sortId,
    ];
  }

  @override
  Set<LibraryFieldIdRuntime> get defaultTableColumns =>
      fields.defaultVisibleColumns;

  LibraryFieldRegistry<TDto> _fieldsForOptionalNode(LibraryNodeRef? node) =>
      node == null ? fields : fieldsForNode(node) as LibraryFieldRegistry<TDto>;

  @override
  List<LibraryFieldIdRuntime> orderedTableColumns(
      Set<LibraryFieldIdRuntime> columns,
      {LibraryNodeRef? node}) {
    final schema = _fieldsForOptionalNode(node);
    return orderedLibraryTableColumns(
      columns: columns,
      defaultColumns: schema.defaultVisibleColumns,
    );
  }

  @override
  double tableWidthForColumns(Set<LibraryFieldIdRuntime> columns,
      Map<LibraryFieldIdRuntime, double> customWidths,
      {LibraryNodeRef? node}) {
    final schema = _fieldsForOptionalNode(node);
    return standardMediaTableWidthForColumns(
      fields: schema,
      columns: columns,
      customWidths: customWidths,
    );
  }

  @override
  double tableColumnWidth(LibraryFieldIdRuntime column,
      Map<LibraryFieldIdRuntime, double> customWidths,
      {LibraryNodeRef? node}) {
    return standardMediaTableColumnWidth(
        _fieldsForOptionalNode(node), column, customWidths);
  }

  @override
  double defaultTableColumnWidth(LibraryFieldIdRuntime column,
      {LibraryNodeRef? node}) {
    return defaultPlannedMediaTableColumnWidth(
        _fieldsForOptionalNode(node), column);
  }

  @override
  String columnLabel(LibraryFieldIdRuntime column, {LibraryNodeRef? node}) {
    return standardMediaTableColumnLabelForType(
        _fieldsForOptionalNode(node), column);
  }

  @override
  String columnDisplayName(LibraryFieldIdRuntime column,
      {LibraryNodeRef? node}) {
    return standardMediaTableColumnDisplayNameForType(
        _fieldsForOptionalNode(node), column);
  }

  @override
  LibraryTableColumnGroup columnGroup(LibraryFieldIdRuntime column,
      {LibraryNodeRef? node}) {
    return standardMediaTableColumnGroup(_fieldsForOptionalNode(node), column);
  }

  @override
  String columnGroupLabel(LibraryTableColumnGroup group) {
    return standardMediaTableColumnGroupLabel(group);
  }

  @override
  bool columnIsNumeric(LibraryFieldIdRuntime column, {LibraryNodeRef? node}) {
    return standardMediaTableColumnIsNumeric(
        _fieldsForOptionalNode(node), column);
  }

  @override
  LibrarySortIdRuntime? columnSort(LibraryFieldIdRuntime column,
      {LibraryNodeRef? node}) {
    return standardMediaTableColumnSort(_fieldsForOptionalNode(node), column);
  }

  @override
  Widget buildTableCell(
    LibraryProjectionView item,
    LibraryFieldIdRuntime column,
  ) {
    validateProjection(item);
    return standardMediaTableCellTyped(
      fieldsForNode(item.node) as LibraryFieldRegistry<TDto>,
      item,
      column,
    );
  }

  @override
  int compareEntriesByRules(
    LibraryProjectionView left,
    LibraryProjectionView right,
    Iterable<LibrarySortRuleRuntime> rules,
  ) {
    validateProjection(left);
    validateProjection(right);
    final nodeFields = fieldsForNode(left.node) as LibraryFieldRegistry<TDto>;
    for (final rule in rules) {
      final sortDef = nodeFields.findSortDefinition(rule.sortId);
      if (sortDef != null) {
        final result = sortDef.compare(
          LibraryProjectionContext<TDto>(
            source: left.source,
            node: left.node,
            dto: left.dto as TDto,
          ),
          LibraryProjectionContext<TDto>(
            source: right.source,
            node: right.node,
            dto: right.dto as TDto,
          ),
        );
        if (result != 0) return rule.ascending ? result : -result;
      }
    }
    return left.dto.title.toLowerCase().compareTo(
          right.dto.title.toLowerCase(),
        );
  }

  @override
  String? subgroupKeyForEntry(
    LibraryProjectionView item,
    LibraryGroupIdRuntime groupId,
  ) {
    validateProjection(item);
    final nodeFields = fieldsForNode(item.node) as LibraryFieldRegistry<TDto>;
    final subgroupKey = nodeFields.findGroupDefinition(groupId)?.subgroupKey;
    if (subgroupKey == null) return null;
    return subgroupKey(
      LibraryProjectionContext<TDto>(
        source: item.source,
        node: item.node,
        dto: item.dto as TDto,
      ),
    );
  }

  @override
  int compareSubgroupKeys(String left, String right) {
    return standardMediaCompareSubgroupKeys(left, right);
  }

  @override
  LibraryProjectionView project({
    required LibraryWorkspaceSource source,
    required LibraryNodeRef node,
  }) {
    return LibraryProjectionItem<TDto>(
      source: source,
      node: node,
      dto: createWorkspaceDto(source: source, node: node) as TDto,
    );
  }

  @override
  void sort(
    List<LibraryProjectionView> items,
    LibrarySortIdRuntime sortId, {
    bool ascending = true,
  }) {
    for (final item in items) {
      validateProjection(item);
    }
    if (items.isEmpty) return;
    final nodeFields =
        fieldsForNode(items.first.node) as LibraryFieldRegistry<TDto>;
    nodeFields.sortEntries(items, sortId, ascending: ascending);
  }

  @override
  int compare(
    LibraryProjectionView left,
    LibraryProjectionView right,
    LibrarySortIdRuntime sortId,
  ) {
    validateProjection(left);
    validateProjection(right);
    final nodeFields = fieldsForNode(left.node) as LibraryFieldRegistry<TDto>;
    return nodeFields.compareEntries(left, right, sortId);
  }

  @override
  Object? groupValue(
    LibraryProjectionView item,
    LibraryGroupIdRuntime groupId,
  ) {
    validateProjection(item);
    final nodeFields = fieldsForNode(item.node) as LibraryFieldRegistry<TDto>;
    return nodeFields.getGroupValue(item, groupId);
  }

  @override
  bool groupModeSupportsCompletion(LibraryGroupIdRuntime groupId) {
    return fields.findGroupDefinition(groupId)?.sequenceValue != null;
  }

  @override
  String? groupSequenceValueForEntry(
    LibraryProjectionView item,
    LibraryGroupIdRuntime groupId,
  ) {
    validateProjection(item);
    final nodeFields = fieldsForNode(item.node) as LibraryFieldRegistry<TDto>;
    return nodeFields.getGroupSequenceValue(item, groupId);
  }

  @override
  Object? columnValue(
    LibraryProjectionView item,
    LibraryFieldIdRuntime columnId,
  ) {
    validateProjection(item);
    final nodeFields = fieldsForNode(item.node) as LibraryFieldRegistry<TDto>;
    return nodeFields.getColumnValue(item, columnId);
  }

  @override
  void validateProjection(LibraryProjectionView item) {
    if (item.dto is! TDto) {
      throw ArgumentError(
        'Invalid projection item DTO "${item.dto.runtimeType}". '
        'Expected "$TDto".',
      );
    }
  }

  @override
  LibraryWorkspaceDto createWorkspaceDto({
    required LibraryWorkspaceSource source,
    required LibraryNodeRef node,
  }) {
    return switch (node) {
      LibraryTitleNodeRef() => projector.projectTitle(
          source: source,
          node: node,
        ),
      LibraryReleaseNodeRef() => projector.projectRelease(
          source: source,
          node: node,
          releaseState: LibraryReleaseState(
            isOwned: source.isOwned,
            isWishlisted: source.isWishlisted,
            isTracked: source.isTracked,
            trackingSummary: source.trackingSummary,
          ),
        ),
      LibraryCopyNodeRef() => projector.projectCopy(
          source: source,
          node: node,
        ),
    };
  }
}
