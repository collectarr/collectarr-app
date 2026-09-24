import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';

/// Strongly typed registry owning column, sort, group, and default definitions for [TDto].
final class LibraryFieldRegistry<TDto extends LibraryWorkspaceDto> {
  LibraryFieldRegistry({
    required this.kindNamespace,
    required this.entityScope,
    this.fields = const [],
    required this.columns,
    required this.sorts,
    required this.groups,
    required this.primaryColumn,
    required this.defaultVisibleColumns,
    required this.defaultSort,
    this.defaultGroup,
    required this.preferenceCodec,
  }) {
    _validate();
  }

  final String kindNamespace;
  final LibraryEntityScope entityScope;
  final List<LibraryFieldDefinition<dynamic, TDto, Object?>> fields;
  final List<LibraryColumnDefinition<dynamic, TDto, Object?>> columns;
  final List<LibrarySortDefinition<dynamic, TDto>> sorts;
  final List<LibraryGroupDefinition<dynamic, TDto, Object?>> groups;

  final LibraryFieldIdRuntime primaryColumn;
  final Set<LibraryFieldIdRuntime> defaultVisibleColumns;
  final LibrarySortIdRuntime defaultSort;
  final LibraryGroupIdRuntime? defaultGroup;

  final LibraryWorkspacePreferenceCodec<dynamic> preferenceCodec;

  /// Returns the registry view exposed to generic workspace code.
  ///
  /// Kind-owned definitions retain their concrete DTO callback types. The
  /// generic host receives a structural registry whose callbacks validate and
  /// adapt the already-projected [LibraryWorkspaceDto] instead of asking the
  /// host to cast the kind DTO itself.
  LibraryFieldRegistry<LibraryWorkspaceDto> asStructural() {
    LibraryProjectionContext<TDto> typedContext(
      LibraryProjectionContext<LibraryWorkspaceDto> context,
    ) {
      return LibraryProjectionContext<TDto>(
        source: context.source,
        node: context.node,
        dto: context.dto as TDto,
      );
    }

    return LibraryFieldRegistry<LibraryWorkspaceDto>(
      kindNamespace: kindNamespace,
      entityScope: entityScope,
      fields: [
        for (final field in fields)
          LibraryFieldDefinition<dynamic, LibraryWorkspaceDto, Object?>(
            id: field.id,
            label: field.label,
            entityScope: field.entityScope,
            origin: field.origin,
            sortable: field.sortable,
            groupable: field.groupable,
            cellValue: field.cellValue,
            getValue: (context) => field.getValue(typedContext(context)),
          ),
      ],
      columns: [
        for (final column in columns)
          LibraryColumnDefinition<dynamic, LibraryWorkspaceDto, Object?>(
            id: column.id,
            label: column.label,
            entityScope: column.entityScope,
            group: column.group,
            displayName: column.displayName,
            sortable: column.sortable,
            groupable: column.groupable,
            isNumeric: column.isNumeric,
            sortId: column.sortId,
            defaultWidth: column.defaultWidth,
            minWidth: column.minWidth,
            maxWidth: column.maxWidth,
            cellValue: column.cellValue == null
                ? null
                : (context) => column.cellValue!(typedContext(context)),
            getValue: (context) => column.getValue(typedContext(context)),
          ),
      ],
      sorts: [
        for (final sort in sorts)
          LibrarySortDefinition<dynamic, LibraryWorkspaceDto>(
            id: sort.id,
            label: sort.label,
            group: sort.group,
            defaultAscending: sort.defaultAscending,
            entityScope: sort.entityScope,
            compare: (left, right) => sort.compare(
              typedContext(left),
              typedContext(right),
            ),
          ),
      ],
      groups: [
        for (final group in groups)
          LibraryGroupDefinition<dynamic, LibraryWorkspaceDto, Object?>(
            id: group.id,
            label: group.label,
            sidebarTitle: group.sidebarTitle,
            icon: group.icon,
            presentation: group.presentation,
            supportsBucketManagement: group.supportsBucketManagement,
            supportsJump: group.supportsJump,
            sequenceValue: group.sequenceValue == null
                ? null
                : (context) => group.sequenceValue!(typedContext(context)),
            subgroupKey: group.subgroupKey == null
                ? null
                : (context) => group.subgroupKey!(typedContext(context)),
            bucketManagerListLabel: group.bucketManagerListLabel,
            drilldownChildId: group.drilldownChildId,
            folderSetLabel: group.folderSetLabel,
            category: group.category,
            entityScope: group.entityScope,
            bucketValueMutator: group.bucketValueMutator,
            ownedBucketValueMutator: group.ownedBucketValueMutator,
            getValue: (context) => group.getValue(typedContext(context)),
          ),
      ],
      primaryColumn: primaryColumn,
      defaultVisibleColumns: defaultVisibleColumns,
      defaultSort: defaultSort,
      defaultGroup: defaultGroup,
      preferenceCodec: preferenceCodec,
    );
  }

  LibraryColumnDefinition<dynamic, TDto, Object?>? columnDefinition(
          LibraryFieldIdRuntime id) =>
      findColumnDefinition(id);

  LibrarySortDefinition<dynamic, TDto>? sortDefinition(
          LibrarySortIdRuntime id) =>
      findSortDefinition(id);

  LibraryGroupDefinition<dynamic, TDto, Object?>? groupDefinition(
          LibraryGroupIdRuntime id) =>
      findGroupDefinition(id);

  LibraryColumnDefinition<dynamic, TDto, Object?>? columnDefinitionForId(
      LibraryFieldIdRuntime id) {
    for (final definition in columns) {
      if (definition.id.value == id.value) return definition;
    }
    return null;
  }

  LibraryColumnDefinition<dynamic, TDto, Object?> columnDefinitionFor(
      LibraryFieldIdRuntime columnId) {
    final definition = findColumnDefinition(columnId);
    if (definition != null) return definition;
    throw StateError(
        'Missing column definition for $columnId in $kindNamespace.');
  }

  LibrarySortDefinition<dynamic, TDto>? sortDefinitionForId(
      LibrarySortIdRuntime id) {
    for (final definition in sorts) {
      if (definition.id.value == id.value) return definition;
    }
    return null;
  }

  LibrarySortDefinition<dynamic, TDto> sortDefinitionFor(
      LibrarySortIdRuntime sortId) {
    final definition = findSortDefinition(sortId);
    if (definition != null) return definition;
    throw StateError('Missing sort definition for $sortId in $kindNamespace.');
  }

  LibraryGroupDefinition<dynamic, TDto, Object?>? groupDefinitionForId(
      LibraryGroupIdRuntime id) {
    for (final definition in groups) {
      if (definition.id.value == id.value) return definition;
    }
    return null;
  }

  LibraryGroupDefinition<dynamic, TDto, Object?> groupDefinitionFor(
      LibraryGroupIdRuntime groupId) {
    final definition = findGroupDefinition(groupId);
    if (definition != null) return definition;
    throw StateError(
        'Missing group definition for $groupId in $kindNamespace.');
  }

  LibraryColumnDefinition<dynamic, TDto, Object?>? findColumnDefinition(
      LibraryFieldIdRuntime id) {
    final raw = id.value;
    final direct = _findColumnDefinitionByValue(raw);
    if (direct != null) return direct;
    return null;
  }

  LibrarySortDefinition<dynamic, TDto>? findSortDefinition(
      LibrarySortIdRuntime id) {
    final raw = id.value;
    final direct = _findSortDefinitionByValue(raw);
    if (direct != null) return direct;
    return null;
  }

  LibrarySortIdRuntime? sortIdForColumn(LibraryFieldIdRuntime columnId) {
    for (final definition in sorts) {
      if (definition.id.value == columnId.value) {
        return definition.id;
      }
    }
    return null;
  }

  LibraryGroupDefinition<dynamic, TDto, Object?>? findGroupDefinition(
      LibraryGroupIdRuntime id) {
    return _findGroupDefinitionByValue(id.value);
  }

  int compareEntries(
    LibraryProjectionView left,
    LibraryProjectionView right,
    LibrarySortIdRuntime sortId,
  ) {
    final sortDef = findSortDefinition(sortId);
    if (sortDef == null) return 0;
    final leftContext = LibraryProjectionContext<TDto>(
      source: left.source,
      node: left.node,
      dto: left.dto as TDto,
    );
    final rightContext = LibraryProjectionContext<TDto>(
      source: right.source,
      node: right.node,
      dto: right.dto as TDto,
    );
    return sortDef.compare(leftContext, rightContext);
  }

  LibrarySortIdRuntime decodeSortId(String raw) {
    final decoded = preferenceCodec.decodeSort(raw, entityScope);
    final direct =
        decoded == null ? null : _findSortDefinitionByValue(decoded.value);
    if (direct != null) return direct.id;
    final canonical = _findSortDefinitionByValue(raw);
    if (canonical != null) return canonical.id;
    final trimmed = raw.trim();
    final normalized = trimmed.startsWith('sort.')
        ? trimmed.substring('sort.'.length)
        : trimmed;
    final namespaced = _findSortDefinitionByValue('$kindNamespace.$normalized');
    if (namespaced != null) return namespaced.id;
    return DynamicLibrarySortId(raw);
  }

  LibraryGroupIdRuntime decodeGroupId(String raw) {
    final decoded = preferenceCodec.decodeGroup(raw, entityScope);
    final canonical =
        decoded == null ? null : _findGroupDefinitionByValue(decoded.value);
    if (canonical != null) return canonical.id;
    final trimmed = raw.trim();
    final normalized = trimmed.startsWith('group.')
        ? trimmed.substring('group.'.length)
        : trimmed;
    // Prefer the kind-owned definition before collapsing a namespaced
    // semantic alias to the structural shared ID. A book.location group must
    // resolve to the Book registry entry, not the generic `location` ID.
    final direct = _findGroupDefinitionByValue(normalized);
    if (direct != null) return direct.id;
    // Older route/query payloads may omit the kind namespace. Resolve that
    // spelling against the owning registry before treating it as a shared
    // structural identifier (for example `publisher` -> `book.publisher`).
    final namespaced =
        _findGroupDefinitionByValue('$kindNamespace.$normalized');
    if (namespaced != null) return namespaced.id;
    final sharedGroup = switch (normalized) {
      'title' => LibraryStandardGroupIds.title,
      'location' => LibraryStandardGroupIds.location,
      'ownership' => LibraryStandardGroupIds.ownership,
      _ when normalized == '$kindNamespace.location' =>
        LibraryStandardGroupIds.location,
      _ => null,
    };
    if (sharedGroup != null) {
      return sharedGroup;
    }
    return DynamicLibraryGroupId(raw);
  }

  LibraryFieldIdRuntime decodeColumnId(String raw) {
    final decoded = preferenceCodec.decodeColumn(raw, entityScope);
    final direct =
        decoded == null ? null : _findColumnDefinitionByValue(decoded.value);
    if (direct != null) return direct.id;
    final canonical = _findColumnDefinitionByValue(raw);
    if (canonical != null) return canonical.id;
    final trimmed = raw.trim();
    final normalized = trimmed.startsWith('field.')
        ? trimmed.substring('field.'.length)
        : trimmed;
    final namespaced =
        _findColumnDefinitionByValue('$kindNamespace.$normalized');
    if (namespaced != null) return namespaced.id;
    return DynamicLibraryFieldId(raw);
  }

  Object? getGroupValue(
    LibraryProjectionView item,
    LibraryGroupIdRuntime groupId,
  ) {
    final groupDef = findGroupDefinition(groupId);
    if (groupDef == null) return null;
    final context = LibraryProjectionContext<TDto>(
      source: item.source,
      node: item.node,
      dto: item.dto as TDto,
    );
    return groupDef.getValue(context);
  }

  String? getGroupSequenceValue(
    LibraryProjectionView item,
    LibraryGroupIdRuntime groupId,
  ) {
    final groupDef = findGroupDefinition(groupId);
    final sequenceValue = groupDef?.sequenceValue;
    if (sequenceValue == null) {
      return null;
    }
    final context = LibraryProjectionContext<TDto>(
      source: item.source,
      node: item.node,
      dto: item.dto as TDto,
    );
    return sequenceValue(context);
  }

  Object? getColumnValue(
    LibraryProjectionView item,
    LibraryFieldIdRuntime columnId,
  ) {
    final columnDef = findColumnDefinition(columnId);
    if (columnDef == null) return null;
    final context = LibraryProjectionContext<TDto>(
      source: item.source,
      node: item.node,
      dto: item.dto as TDto,
    );
    return columnDef.getValue(context);
  }

  void sortEntries(
    List<LibraryProjectionView> items,
    LibrarySortIdRuntime sortId, {
    required bool ascending,
  }) {
    final sortDef = sortDefinitionFor(sortId);

    items.sort((l, r) {
      final leftContext = LibraryProjectionContext<TDto>(
        source: l.source,
        node: l.node,
        dto: l.dto as TDto,
      );
      final rightContext = LibraryProjectionContext<TDto>(
        source: r.source,
        node: r.node,
        dto: r.dto as TDto,
      );
      final result = sortDef.compare(leftContext, rightContext);
      if (result != 0) {
        return ascending ? result : -result;
      }
      final titleCmp = l.dto.primaryLabel.compareTo(r.dto.primaryLabel);
      if (titleCmp != 0) return titleCmp;
      return l.node.id.compareTo(r.node.id);
    });
  }

  LibraryColumnDefinition<dynamic, TDto, Object?>? _findColumnDefinitionByValue(
      String value) {
    for (final definition in columns) {
      if (definition.id.value == value) return definition;
    }
    return null;
  }

  LibrarySortDefinition<dynamic, TDto>? _findSortDefinitionByValue(
    String value,
  ) {
    for (final definition in sorts) {
      if (definition.id.value == value) return definition;
    }
    return null;
  }

  LibraryGroupDefinition<dynamic, TDto, Object?>? _findGroupDefinitionByValue(
      String value) {
    for (final definition in groups) {
      if (definition.id.value == value) return definition;
    }
    return null;
  }

  void _validate() {
    for (final field in fields) {
      if (field.entityScope != entityScope) {
        throw StateError(
          'Field ${field.id.value} is scoped to '
          '${field.entityScope.apiValue}, but registered for '
          '${entityScope.apiValue} in $kindNamespace.',
        );
      }
    }
    final columnIds = <String>{};
    for (final col in columns) {
      if (col.entityScope != null && col.entityScope != entityScope) {
        throw StateError(
          'Column ${col.id.value} is scoped to '
          '${col.entityScope!.apiValue}, but registered for '
          '${entityScope.apiValue} in $kindNamespace.',
        );
      }
      if (!col.id.value.startsWith('$kindNamespace.')) {
        throw StateError(
            'Column ID ${col.id.value} does not match kind namespace $kindNamespace.');
      }
      if (!columnIds.add(col.id.value)) {
        throw StateError(
            'Duplicate column ID ${col.id.value} registered for $kindNamespace.');
      }
    }

    final sortIds = <String>{};
    for (final sort in sorts) {
      if (sort.entityScope != null && sort.entityScope != entityScope) {
        throw StateError(
          'Sort ${sort.id.value} is scoped to '
          '${sort.entityScope!.apiValue}, but registered for '
          '${entityScope.apiValue} in $kindNamespace.',
        );
      }
      if (!sort.id.value.startsWith('$kindNamespace.')) {
        throw StateError(
            'Sort ID ${sort.id.value} does not match kind namespace $kindNamespace.');
      }
      if (!sortIds.add(sort.id.value)) {
        throw StateError(
            'Duplicate sort ID ${sort.id.value} registered for $kindNamespace.');
      }
    }

    final groupIds = <String>{};
    for (final grp in groups) {
      if (grp.entityScope != null && grp.entityScope != entityScope) {
        throw StateError(
          'Group ${grp.id.value} is scoped to '
          '${grp.entityScope!.apiValue}, but registered for '
          '${entityScope.apiValue} in $kindNamespace.',
        );
      }
      if (!grp.id.value.startsWith('$kindNamespace.')) {
        throw StateError(
            'Group ID ${grp.id.value} does not match kind namespace $kindNamespace.');
      }
      if (!groupIds.add(grp.id.value)) {
        throw StateError(
            'Duplicate group ID ${grp.id.value} registered for $kindNamespace.');
      }
    }

    for (final defaultCol in defaultVisibleColumns) {
      if (!columnIds.contains(defaultCol.value)) {
        throw StateError(
            'Default visible column ${defaultCol.value} is missing from column definitions for $kindNamespace.');
      }
    }

    if (!columnIds.contains(primaryColumn.value)) {
      throw StateError(
        'Primary column ${primaryColumn.value} is missing from column '
        'definitions for $kindNamespace/${entityScope.apiValue}.',
      );
    }

    if (!sortIds.contains(defaultSort.value)) {
      throw StateError(
          'Default sort ${defaultSort.value} is missing from sort definitions for $kindNamespace.');
    }

    if (defaultGroup != null && !groupIds.contains(defaultGroup!.value)) {
      throw StateError(
          'Default group ${defaultGroup!.value} is missing from group definitions for $kindNamespace.');
    }
  }
}
