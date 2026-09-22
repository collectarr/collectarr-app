import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_entity_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_field_registry.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_layout.dart';
import 'package:collectarr_app/features/library/workspace/table/media_table_columns.dart';
import 'package:collectarr_app/features/library/config/library_hierarchy_capability.dart';
import 'package:collectarr_app/features/library/tracking/library_tracking_topology.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:flutter/material.dart';

/// Workspace behavior owned by one concrete kind.
///
/// The registry may hold this behind the structural interface, but all field
/// and projection callbacks are bound to the concrete [TDto] implementation
/// when the kind contributor constructs the workspace.
abstract interface class LibraryEntityWorkspace {
  LibraryEntityScope get scope;
  LibraryFieldRegistry<LibraryWorkspaceDto> get fields;
  LibraryEntityWorkspaceProjector<LibraryWorkspaceDto> get projector;
}

final class TypedLibraryEntityWorkspace<TDto extends LibraryWorkspaceDto>
    implements LibraryEntityWorkspace {
  TypedLibraryEntityWorkspace({
    required this.scope,
    required LibraryFieldRegistry<TDto> fields,
    required this.projector,
  })  : typedFields = fields,
        structuralFields = fields.asStructural();

  @override
  final LibraryEntityScope scope;

  final LibraryFieldRegistry<TDto> typedFields;

  final LibraryFieldRegistry<LibraryWorkspaceDto> structuralFields;

  @override
  LibraryFieldRegistry<LibraryWorkspaceDto> get fields => structuralFields;

  @override
  final LibraryEntityWorkspaceProjector<TDto> projector;
}

abstract interface class LibraryKindWorkspace {
  LibraryTrackingTopology get trackingTopology;

  LibraryEntityWorkspace workspaceForScope(LibraryEntityScope scope);

  LibraryEntityWorkspaceProjector<LibraryWorkspaceDto> projectorForScope(
      LibraryEntityScope scope);

  LibraryFieldRegistry<LibraryWorkspaceDto> get fields;

  /// Selects the kind-owned schema from the structural workspace node.
  ///
  /// Generic workspace code supplies the node shape; it never interprets
  /// Music-specific entity names or fields.
  LibraryFieldRegistry<LibraryWorkspaceDto> fieldsForNode(
      LibraryEntityRef node);
  LibraryFieldRegistry<LibraryWorkspaceDto> fieldsForScope(
    LibraryEntityScope scope,
  );
  LibraryFieldRegistry<LibraryWorkspaceDto>? fieldsForGroupModeAcrossScopes(
      String raw);
  Object? groupValueAcrossScopes(
    LibraryProjectionItem item,
    String raw,
  );

  /// Resolves the concrete catalog target represented by a structural node
  /// for lifecycle operations. Kinds may refine a root reference (for
  /// example, a release node), while generic callers keep the result opaque.
  CatalogEntityRef trackingTargetForNode(
    LibraryEntityRef node,
    CatalogEntityRef rootRef,
  );
  List<LibraryGroupIdRuntime> get availableGroupIds;
  List<LibraryGroupIdRuntime> availableGroupIdsForScope(
    LibraryEntityScope scope,
  );
  List<LibrarySortIdRuntime> availableSortIdsForScope(
    LibraryEntityScope scope,
  );
  List<LibraryGroupIdRuntime> get availableGroupIdsForAllScopes;
  Set<String> get availableSortColumnIdsForAllScopes;
  LibraryGroupIdRuntime? resolveGroupIdAcrossScopes(String raw);

  Set<LibraryFieldIdRuntime> get defaultTableColumns;
  List<LibraryFieldIdRuntime> orderedTableColumns(
      Set<LibraryFieldIdRuntime> columns,
      {LibraryEntityRef? node});
  double tableWidthForColumns(Set<LibraryFieldIdRuntime> columns,
      Map<LibraryFieldIdRuntime, double> customWidths,
      {LibraryEntityRef? node});
  double tableColumnWidth(LibraryFieldIdRuntime column,
      Map<LibraryFieldIdRuntime, double> customWidths,
      {LibraryEntityRef? node});
  double defaultTableColumnWidth(LibraryFieldIdRuntime column,
      {LibraryEntityRef? node});
  String columnLabel(LibraryFieldIdRuntime column, {LibraryEntityRef? node});
  String columnDisplayName(LibraryFieldIdRuntime column,
      {LibraryEntityRef? node});
  LibraryTableColumnGroup columnGroup(LibraryFieldIdRuntime column,
      {LibraryEntityRef? node});
  String columnGroupLabel(LibraryTableColumnGroup group);
  bool columnIsNumeric(LibraryFieldIdRuntime column, {LibraryEntityRef? node});
  LibrarySortIdRuntime? columnSort(LibraryFieldIdRuntime column,
      {LibraryEntityRef? node});
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
    required LibraryEntityRef node,
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
    required LibraryEntityRef node,
  });
}

final class TypedLibraryKindWorkspace<TDto extends LibraryWorkspaceDto>
    implements LibraryKindWorkspace {
  TypedLibraryKindWorkspace({
    required this.entityWorkspaces,
    required this.hierarchy,
    required this.trackingTopology,
    this.trackingTargetResolver,
  }) {
    final missing = LibraryEntityScope.values
        .where((scope) => !entityWorkspaces.containsKey(scope))
        .toList(growable: false);
    if (missing.isNotEmpty) {
      throw StateError(
        'Workspace registry is missing entity scopes: '
        '${missing.map((scope) => scope.apiValue).join(', ')}.',
      );
    }
    for (final scope in LibraryEntityScope.values) {
      final workspace = entityWorkspaces[scope]!;
      if (workspace.scope != scope) {
        throw StateError(
          'Workspace registered for ${scope.apiValue} exposes '
          '${workspace.scope.apiValue}.',
        );
      }
    }
  }

  final Map<LibraryEntityScope, LibraryEntityWorkspace> entityWorkspaces;

  @override
  LibraryEntityWorkspace workspaceForScope(LibraryEntityScope scope) {
    final workspace = entityWorkspaces[scope];
    if (workspace == null) {
      throw StateError(
        'No workspace registered for entity scope ${scope.apiValue}.',
      );
    }
    return workspace;
  }

  @override
  LibraryEntityWorkspaceProjector<TDto> projectorForScope(
    LibraryEntityScope scope,
  ) =>
      workspaceForScope(scope).projector
          as LibraryEntityWorkspaceProjector<TDto>;

  LibraryFieldRegistry<TDto> _typedFieldsForScope(
    LibraryEntityScope scope,
  ) {
    final workspace = workspaceForScope(scope);
    if (workspace is! TypedLibraryEntityWorkspace<TDto>) {
      throw StateError(
        'Workspace for ${scope.apiValue} does not expose the registered '
        'typed DTO $TDto.',
      );
    }
    return workspace.typedFields;
  }

  LibraryFieldRegistry<TDto> _typedFieldsForNode(LibraryEntityRef node) =>
      _typedFieldsForScope(node.scope);

  @override
  LibraryFieldRegistry<LibraryWorkspaceDto> get fields =>
      workspaceForScope(LibraryEntityScope.work).fields;

  final CatalogEntityRef Function(
    LibraryEntityRef node,
    CatalogEntityRef rootRef,
  )? trackingTargetResolver;

  final LibraryHierarchyCapability hierarchy;

  @override
  final LibraryTrackingTopology trackingTopology;

  @override
  LibraryFieldRegistry<LibraryWorkspaceDto> fieldsForNode(
          LibraryEntityRef node) =>
      workspaceForScope(node.scope).fields;

  @override
  LibraryFieldRegistry<LibraryWorkspaceDto> fieldsForScope(
    LibraryEntityScope scope,
  ) =>
      workspaceForScope(scope).fields;

  @override
  LibraryFieldRegistry<LibraryWorkspaceDto>? fieldsForGroupModeAcrossScopes(
    String raw,
  ) {
    for (final scope in LibraryEntityScope.values) {
      final registry = fieldsForScope(scope);
      final groupId = registry.decodeGroupId(raw);
      if (registry.findGroupDefinition(groupId) != null) return registry;
    }
    return null;
  }

  @override
  Object? groupValueAcrossScopes(
    LibraryProjectionItem item,
    String raw,
  ) {
    for (final scope in LibraryEntityScope.values) {
      final registry = _typedFieldsForScope(scope);
      final groupId = registry.decodeGroupId(raw);
      final definition = registry.findGroupDefinition(groupId);
      if (definition == null) continue;
      final context = LibraryProjectionContext<TDto>(
        source: item.source,
        node: item.node,
        dto: item.dto as TDto,
      );
      return definition.getValue(context);
    }
    return null;
  }

  @override
  CatalogEntityRef trackingTargetForNode(
    LibraryEntityRef node,
    CatalogEntityRef rootRef,
  ) =>
      trackingTargetResolver?.call(node, rootRef) ?? rootRef;

  @override
  List<LibraryGroupIdRuntime> get availableGroupIds => [
        for (final definition in fields.groups) definition.id,
      ];

  @override
  List<LibraryGroupIdRuntime> availableGroupIdsForScope(
    LibraryEntityScope scope,
  ) {
    final scopedFields = _typedFieldsForScope(scope);
    final allGroups = [
      for (final definition in scopedFields.groups) definition.id,
    ];
    return allGroups;
  }

  @override
  List<LibraryGroupIdRuntime> get availableGroupIdsForAllScopes => [
        for (final scope in LibraryEntityScope.values)
          ...availableGroupIdsForScope(scope),
      ];

  @override
  List<LibrarySortIdRuntime> availableSortIdsForScope(
    LibraryEntityScope scope,
  ) {
    final scopedFields = _typedFieldsForScope(scope);
    final allSorts = [
      for (final definition in scopedFields.sorts) definition.id
    ];
    return allSorts;
  }

  @override
  Set<String> get availableSortColumnIdsForAllScopes => {
        for (final scope in LibraryEntityScope.values)
          for (final sort in availableSortIdsForScope(scope)) sort.value,
      };

  @override
  LibraryGroupIdRuntime? resolveGroupIdAcrossScopes(String raw) {
    for (final scope in LibraryEntityScope.values) {
      final registry = fieldsForScope(scope);
      final definition = registry.findGroupDefinition(
        registry.decodeGroupId(raw),
      );
      if (definition != null) return definition.id;
    }
    return null;
  }

  @override
  Set<LibraryFieldIdRuntime> get defaultTableColumns =>
      fields.defaultVisibleColumns;

  LibraryFieldRegistry<TDto> _fieldsForOptionalNode(LibraryEntityRef? node) =>
      node == null
          ? _typedFieldsForScope(LibraryEntityScope.work)
          : _typedFieldsForNode(node);

  @override
  List<LibraryFieldIdRuntime> orderedTableColumns(
      Set<LibraryFieldIdRuntime> columns,
      {LibraryEntityRef? node}) {
    final schema = _fieldsForOptionalNode(node);
    return orderedLibraryTableColumns(
      columns: columns,
      defaultColumns: schema.defaultVisibleColumns,
    );
  }

  @override
  double tableWidthForColumns(Set<LibraryFieldIdRuntime> columns,
      Map<LibraryFieldIdRuntime, double> customWidths,
      {LibraryEntityRef? node}) {
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
      {LibraryEntityRef? node}) {
    return standardMediaTableColumnWidth(
        _fieldsForOptionalNode(node), column, customWidths);
  }

  @override
  double defaultTableColumnWidth(LibraryFieldIdRuntime column,
      {LibraryEntityRef? node}) {
    return defaultPlannedMediaTableColumnWidth(
        _fieldsForOptionalNode(node), column);
  }

  @override
  String columnLabel(LibraryFieldIdRuntime column, {LibraryEntityRef? node}) {
    return standardMediaTableColumnLabelForType(
        _fieldsForOptionalNode(node), column);
  }

  @override
  String columnDisplayName(LibraryFieldIdRuntime column,
      {LibraryEntityRef? node}) {
    return standardMediaTableColumnDisplayNameForType(
        _fieldsForOptionalNode(node), column);
  }

  @override
  LibraryTableColumnGroup columnGroup(LibraryFieldIdRuntime column,
      {LibraryEntityRef? node}) {
    return standardMediaTableColumnGroup(_fieldsForOptionalNode(node), column);
  }

  @override
  String columnGroupLabel(LibraryTableColumnGroup group) {
    return standardMediaTableColumnGroupLabel(group);
  }

  @override
  bool columnIsNumeric(LibraryFieldIdRuntime column, {LibraryEntityRef? node}) {
    return standardMediaTableColumnIsNumeric(
        _fieldsForOptionalNode(node), column);
  }

  @override
  LibrarySortIdRuntime? columnSort(LibraryFieldIdRuntime column,
      {LibraryEntityRef? node}) {
    return standardMediaTableColumnSort(_fieldsForOptionalNode(node), column);
  }

  @override
  Widget buildTableCell(
    LibraryProjectionView item,
    LibraryFieldIdRuntime column,
  ) {
    validateProjection(item);
    return standardMediaTableCellTyped(
      _typedFieldsForNode(item.node),
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
    final nodeFields = _typedFieldsForNode(left.node);
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
    final nodeFields = _typedFieldsForNode(item.node);
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
    required LibraryEntityRef node,
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
    final nodeFields = _typedFieldsForNode(items.first.node);
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
    final nodeFields = _typedFieldsForNode(left.node);
    return nodeFields.compareEntries(left, right, sortId);
  }

  @override
  Object? groupValue(
    LibraryProjectionView item,
    LibraryGroupIdRuntime groupId,
  ) {
    validateProjection(item);
    final nodeFields = _typedFieldsForNode(item.node);
    return nodeFields.getGroupValue(item, groupId);
  }

  @override
  bool groupModeSupportsCompletion(LibraryGroupIdRuntime groupId) {
    return fieldsForGroupModeAcrossScopes(groupId.value)
            ?.findGroupDefinition(groupId)
            ?.sequenceValue !=
        null;
  }

  @override
  String? groupSequenceValueForEntry(
    LibraryProjectionView item,
    LibraryGroupIdRuntime groupId,
  ) {
    validateProjection(item);
    final nodeFields = _typedFieldsForNode(item.node);
    return nodeFields.getGroupSequenceValue(item, groupId);
  }

  @override
  Object? columnValue(
    LibraryProjectionView item,
    LibraryFieldIdRuntime columnId,
  ) {
    validateProjection(item);
    final nodeFields = _typedFieldsForNode(item.node);
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
    required LibraryEntityRef node,
  }) {
    final releaseState = node.scope == LibraryEntityScope.release
        ? LibraryReleaseState(
            isOwned: source.isOwned,
            isWishlisted: source.isWishlisted,
            isTracked: source.isTracked,
            trackingSummary: source.trackingSummary,
          )
        : null;
    return projectorForScope(node.scope).project(
      source: source,
      entity: node,
      releaseState: releaseState,
    );
  }
}
