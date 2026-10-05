import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_target_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_field_registry.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_layout.dart';
import 'package:collectarr_app/features/library/workspace/table/media_table_columns.dart';
import 'package:collectarr_app/features/library/tracking/library_tracking_topology.dart';
import 'package:flutter/material.dart';

/// Workspace behavior entry by one concrete kind.
///
/// The kind registry holds this interface while field and projection
/// callbacks remain bound to the concrete [TDto] implementation.
abstract interface class LibraryTargetWorkspace {
  LibraryFieldRegistry<LibraryWorkspaceDto> get fields;
  LibraryTargetWorkspaceProjector<LibraryWorkspaceDto> get projector;
}

final class TypedLibraryTargetWorkspace<TDto extends LibraryWorkspaceDto>
    implements LibraryTargetWorkspace {
  TypedLibraryTargetWorkspace({
    required LibraryFieldRegistry<TDto> fields,
    required this.projector,
  })  : typedFields = fields,
        structuralFields = fields.asStructural();

  final LibraryFieldRegistry<TDto> typedFields;

  final LibraryFieldRegistry<LibraryWorkspaceDto> structuralFields;

  @override
  LibraryFieldRegistry<LibraryWorkspaceDto> get fields => structuralFields;

  @override
  final LibraryTargetWorkspaceProjector<TDto> projector;
}

abstract interface class LibraryKindWorkspace {
  LibraryTrackingTopology get trackingTopology;

  LibraryTargetWorkspace workspaceForTarget(LibraryTargetRef target);

  LibraryTargetWorkspaceProjector<LibraryWorkspaceDto> projectorForTarget(
    LibraryTargetRef target,
  );

  LibraryFieldRegistry<LibraryWorkspaceDto> get fields;

  LibraryFieldRegistry<LibraryWorkspaceDto> fieldsForTarget(
    LibraryTargetRef target,
  );
  LibraryFieldRegistry<LibraryWorkspaceDto> get libraryEntryFields;

  LibraryFieldRegistry<LibraryWorkspaceDto>? fieldsForGroupModeAcrossTargets(
      String raw);
  Object? groupValueAcrossTargets(
    LibraryProjectionItem item,
    String raw,
  );

  List<LibraryGroupIdRuntime> get availableGroupIds;
  List<LibraryGroupIdRuntime> get libraryEntryGroupIds;
  List<LibrarySortIdRuntime> get libraryEntrySortIds;
  List<LibraryGroupIdRuntime> get availableGroupIdsForAllTargets;
  Set<String> get availableSortColumnIdsForAllTargets;
  LibraryGroupIdRuntime? resolveGroupIdAcrossTargets(String raw);

  Set<LibraryFieldIdRuntime> get defaultTableColumns;
  List<LibraryFieldIdRuntime> orderedTableColumns(
      Set<LibraryFieldIdRuntime> columns,
      {LibraryTargetRef? target});
  double tableWidthForColumns(Set<LibraryFieldIdRuntime> columns,
      Map<LibraryFieldIdRuntime, double> customWidths,
      {LibraryTargetRef? target});
  double tableColumnWidth(LibraryFieldIdRuntime column,
      Map<LibraryFieldIdRuntime, double> customWidths,
      {LibraryTargetRef? target});
  double defaultTableColumnWidth(LibraryFieldIdRuntime column,
      {LibraryTargetRef? target});
  String columnLabel(LibraryFieldIdRuntime column, {LibraryTargetRef? target});
  String columnDisplayName(LibraryFieldIdRuntime column,
      {LibraryTargetRef? target});
  LibraryTableColumnGroup columnGroup(LibraryFieldIdRuntime column,
      {LibraryTargetRef? target});
  String columnGroupLabel(LibraryTableColumnGroup group);
  bool columnIsNumeric(LibraryFieldIdRuntime column,
      {LibraryTargetRef? target});
  LibrarySortIdRuntime? columnSort(LibraryFieldIdRuntime column,
      {LibraryTargetRef? target});
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
    required LibraryWorkspaceContext source,
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
    required WorkspaceItem item,
    required PersonalOverlay personal,
  });
}

final class TypedLibraryKindWorkspace<TDto extends LibraryWorkspaceDto>
    implements LibraryKindWorkspace {
  TypedLibraryKindWorkspace({
    required this.catalogItemWorkspace,
    required this.libraryEntryWorkspace,
    required this.trackingTopology,
  });

  final TypedLibraryTargetWorkspace<TDto> catalogItemWorkspace;
  final TypedLibraryTargetWorkspace<TDto> libraryEntryWorkspace;

  @override
  LibraryTargetWorkspace workspaceForTarget(LibraryTargetRef target) =>
      switch (target) {
        CatalogTargetRef() => catalogItemWorkspace,
        EntryTargetRef() => libraryEntryWorkspace,
      };

  @override
  LibraryTargetWorkspaceProjector<TDto> projectorForTarget(
    LibraryTargetRef target,
  ) =>
      workspaceForTarget(target).projector
          as LibraryTargetWorkspaceProjector<TDto>;

  LibraryFieldRegistry<TDto> _typedLibraryEntryFields() {
    return libraryEntryWorkspace.typedFields;
  }

  LibraryFieldRegistry<TDto> _typedFieldsForTarget(LibraryTargetRef target) =>
      switch (target) {
        CatalogTargetRef() => catalogItemWorkspace.typedFields,
        EntryTargetRef() => libraryEntryWorkspace.typedFields,
      };

  @override
  LibraryFieldRegistry<LibraryWorkspaceDto> get fields =>
      catalogItemWorkspace.fields;

  @override
  final LibraryTrackingTopology trackingTopology;

  @override
  LibraryFieldRegistry<LibraryWorkspaceDto> fieldsForTarget(
    LibraryTargetRef target,
  ) =>
      switch (target) {
        CatalogTargetRef() => catalogItemWorkspace.fields,
        EntryTargetRef() => libraryEntryWorkspace.fields,
      };

  @override
  LibraryFieldRegistry<LibraryWorkspaceDto> get libraryEntryFields =>
      libraryEntryWorkspace.fields;

  @override
  LibraryFieldRegistry<LibraryWorkspaceDto>? fieldsForGroupModeAcrossTargets(
    String raw,
  ) {
    for (final registry in [
      catalogItemWorkspace.fields,
      libraryEntryWorkspace.fields,
    ]) {
      final groupId = registry.decodeGroupId(raw);
      if (registry.findGroupDefinition(groupId) != null) return registry;
    }
    return null;
  }

  @override
  Object? groupValueAcrossTargets(
    LibraryProjectionItem item,
    String raw,
  ) {
    for (final registry in [
      catalogItemWorkspace.typedFields,
      libraryEntryWorkspace.typedFields,
    ]) {
      final groupId = registry.decodeGroupId(raw);
      final definition = registry.findGroupDefinition(groupId);
      if (definition == null) continue;
      final context = LibraryProjectionContext<TDto>(
        item: item.source.item,
        personal: item.source.personal,
        dto: item.dto as TDto,
      );
      return definition.getValue(context);
    }
    return null;
  }

  @override
  List<LibraryGroupIdRuntime> get availableGroupIds => [
        for (final definition in fields.groups) definition.id,
      ];

  @override
  List<LibraryGroupIdRuntime> get libraryEntryGroupIds {
    final scopedFields = _typedLibraryEntryFields();
    final allGroups = [
      for (final definition in scopedFields.groups) definition.id,
    ];
    return allGroups;
  }

  @override
  List<LibraryGroupIdRuntime> get availableGroupIdsForAllTargets {
    final seenIds = <String>{};
    return [
      for (final groupId in [
        ...availableGroupIds,
        ...libraryEntryGroupIds,
      ])
        if (seenIds.add(groupId.value)) groupId,
    ];
  }

  @override
  List<LibrarySortIdRuntime> get libraryEntrySortIds {
    final scopedFields = _typedLibraryEntryFields();
    final allSorts = [
      for (final definition in scopedFields.sorts) definition.id
    ];
    return allSorts;
  }

  @override
  Set<String> get availableSortColumnIdsForAllTargets => {
        for (final sort in [
          ...fields.sorts.map((sort) => sort.id),
          ...libraryEntrySortIds,
        ])
          sort.value,
      };

  @override
  LibraryGroupIdRuntime? resolveGroupIdAcrossTargets(String raw) {
    for (final registry in [
      catalogItemWorkspace.fields,
      libraryEntryWorkspace.fields,
    ]) {
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

  LibraryFieldRegistry<TDto> _fieldsForOptionalTarget(
          LibraryTargetRef? target) =>
      target == null
          ? catalogItemWorkspace.typedFields
          : _typedFieldsForTarget(target);

  @override
  List<LibraryFieldIdRuntime> orderedTableColumns(
      Set<LibraryFieldIdRuntime> columns,
      {LibraryTargetRef? target}) {
    final schema = _fieldsForOptionalTarget(target);
    return orderedLibraryTableColumns(
      columns: columns,
      defaultColumns: schema.defaultVisibleColumns,
    );
  }

  @override
  double tableWidthForColumns(Set<LibraryFieldIdRuntime> columns,
      Map<LibraryFieldIdRuntime, double> customWidths,
      {LibraryTargetRef? target}) {
    final schema = _fieldsForOptionalTarget(target);
    return standardMediaTableWidthForColumns(
      fields: schema,
      columns: columns,
      customWidths: customWidths,
    );
  }

  @override
  double tableColumnWidth(LibraryFieldIdRuntime column,
      Map<LibraryFieldIdRuntime, double> customWidths,
      {LibraryTargetRef? target}) {
    return standardMediaTableColumnWidth(
        _fieldsForOptionalTarget(target), column, customWidths);
  }

  @override
  double defaultTableColumnWidth(LibraryFieldIdRuntime column,
      {LibraryTargetRef? target}) {
    return defaultPlannedMediaTableColumnWidth(
        _fieldsForOptionalTarget(target), column);
  }

  @override
  String columnLabel(LibraryFieldIdRuntime column,
      {LibraryTargetRef? target}) {
    return standardMediaTableColumnLabelForType(
        _fieldsForOptionalTarget(target), column);
  }

  @override
  String columnDisplayName(LibraryFieldIdRuntime column,
      {LibraryTargetRef? target}) {
    return standardMediaTableColumnDisplayNameForType(
        _fieldsForOptionalTarget(target), column);
  }

  @override
  LibraryTableColumnGroup columnGroup(LibraryFieldIdRuntime column,
      {LibraryTargetRef? target}) {
    return standardMediaTableColumnGroup(
        _fieldsForOptionalTarget(target), column);
  }

  @override
  String columnGroupLabel(LibraryTableColumnGroup group) {
    return standardMediaTableColumnGroupLabel(group);
  }

  @override
  bool columnIsNumeric(LibraryFieldIdRuntime column,
      {LibraryTargetRef? target}) {
    return standardMediaTableColumnIsNumeric(
        _fieldsForOptionalTarget(target), column);
  }

  @override
  LibrarySortIdRuntime? columnSort(LibraryFieldIdRuntime column,
      {LibraryTargetRef? target}) {
    return standardMediaTableColumnSort(
        _fieldsForOptionalTarget(target), column);
  }

  @override
  Widget buildTableCell(
    LibraryProjectionView item,
    LibraryFieldIdRuntime column,
  ) {
    validateProjection(item);
    return standardMediaTableCellTyped(
      _typedFieldsForTarget(item.target),
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
    final targetFields = _typedFieldsForTarget(left.target);
    for (final rule in rules) {
      final sortDef = targetFields.findSortDefinition(rule.sortId);
      if (sortDef != null) {
        final result = sortDef.compare(
          LibraryProjectionContext<TDto>(
            item: left.source.item,
            personal: left.source.personal,
            dto: left.dto as TDto,
          ),
          LibraryProjectionContext<TDto>(
            item: right.source.item,
            personal: right.source.personal,
            dto: right.dto as TDto,
          ),
        );
        if (result != 0) return rule.ascending ? result : -result;
      }
    }
    return left.dto.primaryLabel.toLowerCase().compareTo(
          right.dto.primaryLabel.toLowerCase(),
        );
  }

  @override
  String? subgroupKeyForEntry(
    LibraryProjectionView item,
    LibraryGroupIdRuntime groupId,
  ) {
    validateProjection(item);
    final targetFields = _typedFieldsForTarget(item.target);
    final subgroupKey = targetFields.findGroupDefinition(groupId)?.subgroupKey;
    if (subgroupKey == null) return null;
    return subgroupKey(
      LibraryProjectionContext<TDto>(
        item: item.source.item,
        personal: item.source.personal,
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
    required LibraryWorkspaceContext source,
  }) {
    return LibraryProjectionItem<TDto>(
      source: source,
      dto: createWorkspaceDto(
        item: source.item,
        personal: source.personal,
      ) as TDto,
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
    final targetFields = _typedFieldsForTarget(items.first.target);
    targetFields.sortEntries(items, sortId, ascending: ascending);
  }

  @override
  int compare(
    LibraryProjectionView left,
    LibraryProjectionView right,
    LibrarySortIdRuntime sortId,
  ) {
    validateProjection(left);
    validateProjection(right);
    final targetFields = _typedFieldsForTarget(left.target);
    return targetFields.compareEntries(left, right, sortId);
  }

  @override
  Object? groupValue(
    LibraryProjectionView item,
    LibraryGroupIdRuntime groupId,
  ) {
    validateProjection(item);
    final targetFields = _typedFieldsForTarget(item.target);
    return targetFields.getGroupValue(item, groupId);
  }

  @override
  bool groupModeSupportsCompletion(LibraryGroupIdRuntime groupId) {
    return fieldsForGroupModeAcrossTargets(groupId.value)
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
    final targetFields = _typedFieldsForTarget(item.target);
    return targetFields.getGroupSequenceValue(item, groupId);
  }

  @override
  Object? columnValue(
    LibraryProjectionView item,
    LibraryFieldIdRuntime columnId,
  ) {
    validateProjection(item);
    final targetFields = _typedFieldsForTarget(item.target);
    return targetFields.getColumnValue(item, columnId);
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
    required WorkspaceItem item,
    required PersonalOverlay personal,
  }) {
    return projectorForTarget(item.target).project(
      item: item,
      personal: personal,
    );
  }
}
