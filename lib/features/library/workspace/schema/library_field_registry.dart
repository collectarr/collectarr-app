import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';

/// Strongly typed registry owning column, sort, group, and default definitions for [TDto].
final class LibraryFieldRegistry<TDto extends LibraryWorkspaceDto> {
  LibraryFieldRegistry({
    required this.kindNamespace,
    this.fields = const [],
    required this.columns,
    required this.sorts,
    required this.groups,
    required this.defaultVisibleColumns,
    required this.defaultSort,
    this.defaultGroup,
    required this.preferenceCodec,
  }) {
    _validate();
  }

  final String kindNamespace;
  final List<LibraryFieldDefinition<dynamic, TDto, Object?>> fields;
  final List<LibraryColumnDefinition<dynamic, TDto, Object?>> columns;
  final List<LibrarySortDefinition<dynamic, TDto>> sorts;
  final List<LibraryGroupDefinition<dynamic, TDto, Object?>> groups;

  final Set<LibraryFieldIdRuntime> defaultVisibleColumns;
  final LibrarySortIdRuntime defaultSort;
  final LibraryGroupIdRuntime? defaultGroup;

  final LibraryWorkspacePreferenceCodec<dynamic> preferenceCodec;

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

  LibraryGroupDefinition<dynamic, TDto, Object?>? findGroupDefinition(
      LibraryGroupIdRuntime id) {
    final raw = id.value;
    var normalized = raw.trim();
    if (normalized.startsWith('group.')) {
      normalized = normalized.substring(6);
    }
    final direct = _findGroupDefinitionByValue(normalized);
    if (direct != null) return direct;
    return null;
  }

  int compareEntries(
    LibraryProjectionRuntime left,
    LibraryProjectionRuntime right,
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
    final direct = _findSortDefinitionByValue(raw);
    if (direct != null) return direct.id;
    final decoded = preferenceCodec.decodeSort(raw);
    final def =
        decoded == null ? null : _findSortDefinitionByValue(decoded.value);
    if (def != null) return def.id;
    return DynamicLibrarySortId(raw);
  }

  LibraryGroupIdRuntime decodeGroupId(String raw) {
    final normalized =
        raw.trim().startsWith('group.') ? raw.trim().substring(6) : raw.trim();
    final direct = _findGroupDefinitionByValue(normalized);
    if (direct != null) return direct.id;
    final decoded = preferenceCodec.decodeGroup(normalized);
    final def =
        decoded == null ? null : _findGroupDefinitionByValue(decoded.value);
    if (def != null) return def.id;
    return DynamicLibraryGroupId(raw);
  }

  LibraryFieldIdRuntime decodeColumnId(String raw) {
    final direct = _findColumnDefinitionByValue(raw);
    if (direct != null) return direct.id;
    final decoded = preferenceCodec.decodeColumn(raw);
    final def =
        decoded == null ? null : _findColumnDefinitionByValue(decoded.value);
    if (def != null) return def.id;
    return DynamicLibraryFieldId(raw);
  }

  Object? getGroupValue(
    LibraryProjectionRuntime item,
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
    LibraryProjectionRuntime item,
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
    LibraryProjectionRuntime item,
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
    List<LibraryProjectionRuntime> items,
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
      final titleCmp = l.dto.title.compareTo(r.dto.title);
      if (titleCmp != 0) return titleCmp;
      return l.node.id.compareTo(r.node.id);
    });
  }

  LibraryColumnDefinition<dynamic, TDto, Object?>? _findColumnDefinitionByValue(
      String value) {
    final direct = columnDefinitionForId(DynamicLibraryFieldId(value));
    if (direct != null) return direct;
    return columnDefinitionForId(
      DynamicLibraryFieldId('$kindNamespace.$value'),
    );
  }

  LibrarySortDefinition<dynamic, TDto>? _findSortDefinitionByValue(
    String value,
  ) {
    final direct = sortDefinitionForId(DynamicLibrarySortId(value));
    if (direct != null) return direct;
    return sortDefinitionForId(
      DynamicLibrarySortId('$kindNamespace.$value'),
    );
  }

  LibraryGroupDefinition<dynamic, TDto, Object?>? _findGroupDefinitionByValue(
      String value) {
    final direct = groupDefinitionForId(DynamicLibraryGroupId(value));
    if (direct != null) return direct;
    return groupDefinitionForId(
      DynamicLibraryGroupId('$kindNamespace.$value'),
    );
  }

  void _validate() {
    final columnIds = <String>{};
    for (final col in columns) {
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
