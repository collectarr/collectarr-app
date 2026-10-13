import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';

/// Strongly typed registry owning column, sort, group, and default definitions for [TDto].
final class LibraryFieldRegistry<TDto extends LibraryWorkspaceDto> {
  LibraryFieldRegistry({
    required this.kindNamespace,
    this.fields = const [],
    required this.columns,
    required this.sorts,
    required this.groups,
    required this.primaryColumn,
    required this.defaultVisibleColumns,
    required this.defaultSort,
    this.defaultGroup,
    this.containedSearchValues,
  }) : _fieldsById = {
          for (final field in fields) field.id.value: field,
        } {
    _validate();
  }

  final String kindNamespace;
  final List<LibraryFieldDefinition<dynamic, TDto, Object?>> fields;
  final List<LibraryColumnDefinition<dynamic, TDto, Object?>> columns;
  final List<LibrarySortDefinition<dynamic, TDto>> sorts;
  final List<LibraryGroupDefinition<dynamic, TDto, Object?>> groups;

  final LibraryFieldIdRuntime primaryColumn;
  final Set<LibraryFieldIdRuntime> defaultVisibleColumns;
  final LibrarySortIdRuntime defaultSort;
  final LibraryGroupIdRuntime? defaultGroup;
  final Iterable<String> Function(TDto dto)? containedSearchValues;
  final Map<String, LibraryFieldDefinition<dynamic, TDto, Object?>> _fieldsById;

  LibraryFieldDefinition<dynamic, TDto, Object?>? fieldDefinitionForId(
    String id,
  ) =>
      _fieldsById[id];

  /// Returns the registry view exposed to generic workspace code.
  ///
  /// Kind-entry definitions retain their concrete DTO callback types. The
  /// generic host receives a structural registry whose callbacks validate and
  /// adapt the already-projected [LibraryWorkspaceDto] instead of asking the
  /// host to cast the kind DTO itself.
  LibraryFieldRegistry<LibraryWorkspaceDto> asStructural() {
    LibraryProjectionContext<TDto> typedContext(
      LibraryProjectionContext<LibraryWorkspaceDto> context,
    ) {
      return LibraryProjectionContext<TDto>(
        item: context.item,
        personal: context.personal,
        dto: context.dto as TDto,
      );
    }

    return LibraryFieldRegistry<LibraryWorkspaceDto>(
      kindNamespace: kindNamespace,
      fields: [
        for (final field in fields)
          LibraryFieldDefinition<dynamic, LibraryWorkspaceDto, Object?>(
            metadata: field.metadata,
            id: field.id,
            cellValue: field.cellValue,
            getValue: (context) => field.getValue(typedContext(context)),
          ),
      ],
      columns: [
        for (final column in columns)
          LibraryColumnDefinition<dynamic, LibraryWorkspaceDto, Object?>(
            metadata: column.metadata,
            id: column.id,
            group: column.group,
            displayName: column.displayName,
            allowSortInteraction: column.sortable,
            allowGroupInteraction: column.groupable,
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
            bucketVocabulary: group.bucketVocabulary,
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
            bucketValueMutator: group.bucketValueMutator,
            entryBucketValueMutator: group.entryBucketValueMutator,
            getValue: (context) => group.getValue(typedContext(context)),
          ),
      ],
      primaryColumn: primaryColumn,
      defaultVisibleColumns: defaultVisibleColumns,
      defaultSort: defaultSort,
      defaultGroup: defaultGroup,
      containedSearchValues: containedSearchValues == null
          ? null
          : (dto) => containedSearchValues!(dto as TDto),
    );
  }

  LibraryColumnDefinition<dynamic, TDto, Object?>? columnDefinition(
          LibraryFieldIdRuntime id) =>
      findColumnDefinition(id);

  Iterable<String> searchValuesFor(LibraryProjectionView item) sync* {
    final context = LibraryProjectionContext<TDto>(
      item: item.source.item,
      personal: item.source.personal,
      dto: item.dto as TDto,
    );
    for (final field in fields) {
      if (!field.searchable) continue;
      final value = field.getValue(context);
      if (value is String) {
        yield value;
      } else if (value is Iterable) {
        for (final entry in value) {
          if (entry is String) yield entry;
        }
      }
    }
  }

  Iterable<String> containedSearchValuesFor(LibraryProjectionView item) =>
      containedSearchValues?.call(item.dto as TDto) ?? const [];

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
      item: left.source.item,
      personal: left.source.personal,
      dto: left.dto as TDto,
    );
    final rightContext = LibraryProjectionContext<TDto>(
      item: right.source.item,
      personal: right.source.personal,
      dto: right.dto as TDto,
    );
    return sortDef.compare(leftContext, rightContext);
  }

  LibrarySortIdRuntime decodeSortId(String raw) {
    return _findSortDefinitionByValue(raw)?.id ?? DynamicLibrarySortId(raw);
  }

  LibraryGroupIdRuntime decodeGroupId(String raw) {
    return _findGroupDefinitionByValue(raw)?.id ?? DynamicLibraryGroupId(raw);
  }

  LibraryFieldIdRuntime decodeColumnId(String raw) {
    return _findColumnDefinitionByValue(raw)?.id ?? DynamicLibraryFieldId(raw);
  }

  Object? getGroupValue(
    LibraryProjectionView item,
    LibraryGroupIdRuntime groupId,
  ) {
    final groupDef = findGroupDefinition(groupId);
    if (groupDef == null) return null;
    final context = LibraryProjectionContext<TDto>(
      item: item.source.item,
      personal: item.source.personal,
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
      item: item.source.item,
      personal: item.source.personal,
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
      item: item.source.item,
      personal: item.source.personal,
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
        item: l.source.item,
        personal: l.source.personal,
        dto: l.dto as TDto,
      );
      final rightContext = LibraryProjectionContext<TDto>(
        item: r.source.item,
        personal: r.source.personal,
        dto: r.dto as TDto,
      );
      final result = sortDef.compare(leftContext, rightContext);
      if (result != 0) {
        return ascending ? result : -result;
      }
      final titleCmp = l.dto.primaryLabel.compareTo(r.dto.primaryLabel);
      if (titleCmp != 0) return titleCmp;
      return l.target.id.compareTo(r.target.id);
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
    final metadataByFieldId = <String, LibraryKindFieldMetadata>{};
    for (final field in fields) {
      if (field.id.value != field.metadata.id) {
        throw StateError(
          'Field metadata ID ${field.metadata.id} does not match typed field '
          'ID ${field.id.value} in $kindNamespace.',
        );
      }
      if (metadataByFieldId.containsKey(field.id.value)) {
        throw StateError(
          'Duplicate field metadata ID ${field.id.value} registered for '
          '$kindNamespace.',
        );
      }
      metadataByFieldId[field.id.value] = field.metadata;
    }

    final columnIds = <String>{};
    for (final col in columns) {
      if (col.id.value != col.metadata.id) {
        throw StateError(
          'Column metadata ID ${col.metadata.id} does not match typed column '
          'ID ${col.id.value} in $kindNamespace.',
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
      final metadata = metadataByFieldId[sort.id.value];
      if (metadata != null && !metadata.sortable) {
        throw StateError(
          'Sort ${sort.id.value} is registered for a field whose metadata '
          'does not allow sorting in $kindNamespace.',
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
      final metadata = metadataByFieldId[grp.id.value];
      if (metadata != null && !metadata.groupable) {
        throw StateError(
          'Group ${grp.id.value} is registered for a field whose metadata '
          'does not allow grouping in $kindNamespace.',
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
        'definitions for $kindNamespace.',
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
