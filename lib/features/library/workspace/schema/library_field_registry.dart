import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
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
    this.customLinkedMetadataCandidates,
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
  final Iterable<String> Function(ShelfEntry)? customLinkedMetadataCandidates;

  Set<String> get defaultVisibleColumnIds =>
      {for (final col in defaultVisibleColumns) col.value};

  String get defaultSortId => defaultSort.value;

  String? get defaultGroupId => defaultGroup?.value;

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
      Object id) {
    final raw = id is LibraryFieldIdRuntime ? id.value : id.toString();
    for (final definition in columns) {
      if (definition.id.value == raw) return definition;
    }
    return null;
  }

  LibraryColumnDefinition<dynamic, TDto, Object?> columnDefinitionFor(
      Object columnId) {
    final definition = findColumnDefinition(columnId);
    if (definition != null) return definition;
    throw StateError(
        'Missing column definition for $columnId in $kindNamespace.');
  }

  LibrarySortDefinition<dynamic, TDto>? sortDefinitionForId(Object id) {
    final raw = id is LibrarySortIdRuntime ? id.value : id.toString();
    for (final definition in sorts) {
      if (definition.id.value == raw) return definition;
    }
    return null;
  }

  LibrarySortDefinition<dynamic, TDto> sortDefinitionFor(Object sortId) {
    final definition = findSortDefinition(sortId);
    if (definition != null) return definition;
    throw StateError('Missing sort definition for $sortId in $kindNamespace.');
  }

  LibraryGroupDefinition<dynamic, TDto, Object?>? groupDefinitionForId(
      Object id) {
    final raw = id is LibraryGroupIdRuntime ? id.value : id.toString();
    for (final definition in groups) {
      if (definition.id.value == raw) return definition;
    }
    return null;
  }

  LibraryGroupDefinition<dynamic, TDto, Object?> groupDefinitionFor(
      Object groupId) {
    final definition = findGroupDefinition(groupId);
    if (definition != null) return definition;
    throw StateError(
        'Missing group definition for $groupId in $kindNamespace.');
  }

  LibraryColumnDefinition<dynamic, TDto, Object?>? findColumnDefinition(
      Object id) {
    final raw = id is LibraryFieldIdRuntime ? id.value : id.toString();
    final direct = columnDefinitionForId(raw);
    if (direct != null) return direct;
    final qualified = columnDefinitionForId('$kindNamespace.$raw');
    if (qualified != null) return qualified;
    final decoded = preferenceCodec.decodeColumn(raw);
    if (decoded != null) return columnDefinitionForId(decoded.value);
    return null;
  }

  LibrarySortDefinition<dynamic, TDto>? findSortDefinition(Object id) {
    final raw = id is LibrarySortIdRuntime ? id.value : id.toString();
    final direct = sortDefinitionForId(raw);
    if (direct != null) return direct;
    final qualified = sortDefinitionForId('$kindNamespace.$raw');
    if (qualified != null) return qualified;
    final decoded = preferenceCodec.decodeSort(raw);
    if (decoded != null) return sortDefinitionForId(decoded.value);
    return null;
  }

  LibraryGroupDefinition<dynamic, TDto, Object?>? findGroupDefinition(
      Object id) {
    final raw = id is LibraryGroupIdRuntime ? id.value : id.toString();
    var normalized = raw.trim();
    if (normalized.startsWith('group.')) {
      normalized = normalized.substring(6);
    }
    final direct = groupDefinitionForId(normalized);
    if (direct != null) return direct;
    final qualified = groupDefinitionForId('$kindNamespace.$normalized');
    if (qualified != null) return qualified;
    final decoded = preferenceCodec.decodeGroup(normalized);
    if (decoded != null) return groupDefinitionForId(decoded.value);
    return null;
  }

  int compareEntries(
    LibraryProjectionRuntime left,
    LibraryProjectionRuntime right,
    Object sortId,
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
    final def = findSortDefinition(raw);
    if (def != null) return def.id;
    return DynamicLibrarySortId(raw);
  }

  LibraryGroupIdRuntime decodeGroupId(String raw) {
    final def = findGroupDefinition(raw);
    if (def != null) return def.id;
    return DynamicLibraryGroupId(raw);
  }

  LibraryFieldIdRuntime decodeColumnId(String raw) {
    final def = findColumnDefinition(raw);
    if (def != null) return def.id;
    return DynamicLibraryFieldId(raw);
  }

  Object? getGroupValue(LibraryProjectionRuntime item, Object groupId) {
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
    Object groupId,
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

  Object? getColumnValue(LibraryProjectionRuntime item, Object columnId) {
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
    Object sortId, {
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

  Iterable<String> linkedMetadataCandidates(ShelfEntry source) sync* {
    final item = source.catalogItem;
    if (item == null) return;
    final payload = item.kindMetadata.toSyncPayload();
    final series = ((payload['series_title'] ??
            (payload['series'] as Map?)?['series_title']) as String?)
        ?.trim();
    final itemNumber = payload['item_number'] as String?;
    final publisher = (payload['publisher'] ??
        (payload['publishing'] as Map?)?['original_publisher']) as String?;
    final variant = payload['variant'] as String?;
    final country = payload['country'] as String?;
    final language = payload['language'] as String?;
    final imprint = (payload['publishing'] as Map?)?['imprint'] as String?;

    yield* nonEmptyStrings([
      item.title,
      series,
      itemNumber,
      publisher,
      variant,
      imprint,
      country,
      language,
    ]);
    yield* nonEmptyStrings(item.searchAliases);
    final creators = payload['creators'] as List?;
    if (creators != null) {
      for (final credit in creators) {
        if (credit is Map) {
          final name = credit['name']?.toString().trim();
          if (name != null && name.isNotEmpty) {
            yield name;
          }
        }
      }
    }
    yield* nonEmptyStrings(
      (payload['genres'] as List?)?.map((e) => e.toString()),
    );

    if (customLinkedMetadataCandidates != null) {
      yield* customLinkedMetadataCandidates!(source);
    }
  }

  static Iterable<String> nonEmptyStrings(Iterable<String?>? values) sync* {
    if (values == null) return;
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        yield trimmed;
      }
    }
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
