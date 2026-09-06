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
import 'package:flutter/material.dart';

/// Workspace behavior owned by one concrete kind.
///
/// The registry may hold this behind the structural interface, but all field
/// and projection callbacks are bound to the concrete [TDto] implementation
/// when the kind module constructs the workspace.
abstract interface class LibraryKindWorkspace {
  LibraryFieldRegistry<LibraryWorkspaceDto> get fields;
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
  );
  double tableWidthForColumns(
    Set<LibraryFieldIdRuntime> columns,
    Map<LibraryFieldIdRuntime, double> customWidths,
  );
  double tableColumnWidth(
    LibraryFieldIdRuntime column,
    Map<LibraryFieldIdRuntime, double> customWidths,
  );
  double defaultTableColumnWidth(LibraryFieldIdRuntime column);
  String columnLabel(LibraryFieldIdRuntime column);
  String columnDisplayName(LibraryFieldIdRuntime column);
  LibraryTableColumnGroup columnGroup(LibraryFieldIdRuntime column);
  String columnGroupLabel(LibraryTableColumnGroup group);
  bool columnIsNumeric(LibraryFieldIdRuntime column);
  LibrarySortIdRuntime? columnSort(LibraryFieldIdRuntime column);
  Widget buildTableCell(
    LibraryProjectionRuntime item,
    LibraryFieldIdRuntime column,
  );

  int compareEntriesByRules(
    LibraryProjectionRuntime left,
    LibraryProjectionRuntime right,
    Iterable<LibrarySortRuleRuntime> rules,
  );
  String? subgroupKeyForEntry(
    LibraryProjectionRuntime item,
    LibraryGroupIdRuntime groupId,
  );
  int compareSubgroupKeys(String left, String right);

  LibraryProjectionRuntime project({
    required ShelfEntry source,
    required LibraryNodeRef node,
  });

  void sort(
    List<LibraryProjectionRuntime> items,
    LibrarySortIdRuntime sortId, {
    bool ascending = true,
  });
  int compare(
    LibraryProjectionRuntime left,
    LibraryProjectionRuntime right,
    LibrarySortIdRuntime sortId,
  );
  Object? groupValue(
    LibraryProjectionRuntime item,
    LibraryGroupIdRuntime groupId,
  );
  bool groupModeSupportsCompletion(LibraryGroupIdRuntime groupId);
  String? groupSequenceValueForEntry(
    LibraryProjectionRuntime item,
    LibraryGroupIdRuntime groupId,
  );
  Object? columnValue(
    LibraryProjectionRuntime item,
    LibraryFieldIdRuntime columnId,
  );
  void validateProjection(LibraryProjectionRuntime item);
  LibraryWorkspaceDto createWorkspaceDto({
    required ShelfEntry source,
    required LibraryNodeRef node,
  });
}

final class TypedLibraryKindWorkspace<TDto extends LibraryWorkspaceDto>
    implements LibraryKindWorkspace {
  const TypedLibraryKindWorkspace({
    required this.fields,
    required this.projector,
    required this.hierarchy,
  });

  @override
  final LibraryFieldRegistry<TDto> fields;

  @override
  final LibraryWorkspaceProjector<TDto> projector;

  final LibraryHierarchyCapability hierarchy;

  @override
  List<LibraryGroupIdRuntime> get availableGroupIds => [
        for (final definition in fields.groups) definition.id,
      ];

  @override
  List<LibraryGroupIdRuntime> availableGroupIdsForBrowserMode(
    LibraryWorkspaceBrowserMode browserMode,
  ) {
    final allGroups = availableGroupIds;
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
    final allSorts = [for (final definition in fields.sorts) definition.id];
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

  @override
  List<LibraryFieldIdRuntime> orderedTableColumns(
    Set<LibraryFieldIdRuntime> columns,
  ) {
    return orderedLibraryTableColumns(
      columns: columns,
      defaultColumns: fields.defaultVisibleColumns,
    );
  }

  @override
  double tableWidthForColumns(
    Set<LibraryFieldIdRuntime> columns,
    Map<LibraryFieldIdRuntime, double> customWidths,
  ) {
    return plannedMediaTableWidthForColumns(
      fields: fields,
      columns: columns,
      customWidths: customWidths,
    );
  }

  @override
  double tableColumnWidth(
    LibraryFieldIdRuntime column,
    Map<LibraryFieldIdRuntime, double> customWidths,
  ) {
    return plannedMediaTableColumnWidth(fields, column, customWidths);
  }

  @override
  double defaultTableColumnWidth(LibraryFieldIdRuntime column) {
    return defaultPlannedMediaTableColumnWidth(fields, column);
  }

  @override
  String columnLabel(LibraryFieldIdRuntime column) {
    return plannedMediaTableColumnLabelForType(fields, column);
  }

  @override
  String columnDisplayName(LibraryFieldIdRuntime column) {
    return plannedMediaTableColumnDisplayNameForType(fields, column);
  }

  @override
  LibraryTableColumnGroup columnGroup(LibraryFieldIdRuntime column) {
    return plannedMediaTableColumnGroup(fields, column);
  }

  @override
  String columnGroupLabel(LibraryTableColumnGroup group) {
    return plannedMediaTableColumnGroupLabel(group);
  }

  @override
  bool columnIsNumeric(LibraryFieldIdRuntime column) {
    return plannedMediaTableColumnIsNumeric(fields, column);
  }

  @override
  LibrarySortIdRuntime? columnSort(LibraryFieldIdRuntime column) {
    return plannedMediaTableColumnSort(fields, column);
  }

  @override
  Widget buildTableCell(
    LibraryProjectionRuntime item,
    LibraryFieldIdRuntime column,
  ) {
    validateProjection(item);
    return plannedMediaTableCellTyped(fields, item, column);
  }

  @override
  int compareEntriesByRules(
    LibraryProjectionRuntime left,
    LibraryProjectionRuntime right,
    Iterable<LibrarySortRuleRuntime> rules,
  ) {
    validateProjection(left);
    validateProjection(right);
    for (final rule in rules) {
      final sortDef = fields.findSortDefinition(rule.sortId);
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
    LibraryProjectionRuntime item,
    LibraryGroupIdRuntime groupId,
  ) {
    validateProjection(item);
    final subgroupKey = fields.findGroupDefinition(groupId)?.subgroupKey;
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
    return plannedMediaCompareSubgroupKeys(left, right);
  }

  @override
  LibraryProjectionRuntime project({
    required ShelfEntry source,
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
    List<LibraryProjectionRuntime> items,
    LibrarySortIdRuntime sortId, {
    bool ascending = true,
  }) {
    for (final item in items) {
      validateProjection(item);
    }
    fields.sortEntries(items, sortId, ascending: ascending);
  }

  @override
  int compare(
    LibraryProjectionRuntime left,
    LibraryProjectionRuntime right,
    LibrarySortIdRuntime sortId,
  ) {
    validateProjection(left);
    validateProjection(right);
    return fields.compareEntries(left, right, sortId);
  }

  @override
  Object? groupValue(
    LibraryProjectionRuntime item,
    LibraryGroupIdRuntime groupId,
  ) {
    validateProjection(item);
    return fields.getGroupValue(item, groupId);
  }

  @override
  bool groupModeSupportsCompletion(LibraryGroupIdRuntime groupId) {
    return fields.findGroupDefinition(groupId)?.sequenceValue != null;
  }

  @override
  String? groupSequenceValueForEntry(
    LibraryProjectionRuntime item,
    LibraryGroupIdRuntime groupId,
  ) {
    validateProjection(item);
    return fields.getGroupSequenceValue(item, groupId);
  }

  @override
  Object? columnValue(
    LibraryProjectionRuntime item,
    LibraryFieldIdRuntime columnId,
  ) {
    validateProjection(item);
    return fields.getColumnValue(item, columnId);
  }

  @override
  void validateProjection(LibraryProjectionRuntime item) {
    if (item.dto is! TDto) {
      throw ArgumentError(
        'Invalid projection item DTO "${item.dto.runtimeType}". '
        'Expected "$TDto".',
      );
    }
  }

  @override
  LibraryWorkspaceDto createWorkspaceDto({
    required ShelfEntry source,
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
          ),
        ),
      LibraryCopyNodeRef() => projector.projectCopy(
          source: source,
          node: node,
        ),
    };
  }
}
