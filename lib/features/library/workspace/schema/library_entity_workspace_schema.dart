import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_field_registry.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';

/// Strongly typed field and table schema owned by one library entity level.
///
/// A kind may register one of these per work, release, and copy. The generic
/// host only receives the selected entity schema and never combines fields
/// from different levels.
class LibraryEntityWorkspaceSchema<TKind, TDto extends LibraryWorkspaceDto> {
  LibraryEntityWorkspaceSchema({
    required this.kindNamespace,
    required this.entityScope,
    required this.fields,
    required this.columns,
    required this.sorts,
    required this.groups,
    required this.primaryColumn,
    required this.defaultVisibleColumns,
    required this.defaultSort,
    this.defaultGroup,
    required this.preferenceCodec,
  });

  final String kindNamespace;
  final LibraryEntityScope entityScope;
  final List<LibraryFieldDefinition<TKind, TDto, Object?>> fields;
  final List<LibraryColumnDefinition<TKind, TDto, Object?>> columns;
  final List<LibrarySortDefinition<TKind, TDto>> sorts;
  final List<LibraryGroupDefinition<TKind, TDto, Object?>> groups;

  final LibraryFieldIdRuntime primaryColumn;
  final Set<LibraryFieldIdRuntime> defaultVisibleColumns;
  final LibrarySortId<TKind> defaultSort;
  final LibraryGroupIdRuntime? defaultGroup;

  final LibraryWorkspacePreferenceCodec<TKind> preferenceCodec;

  /// Materializes the definitions that belong to one structural scope.
  ///
  /// Field definitions are the source of truth. Columns, sorts, and groups
  /// are filtered by their explicit scope or, for definitions created through
  /// the field factories, by the scope of the field they reference.
  LibraryEntityWorkspaceSchema<TKind, TDto> forScope(
    LibraryEntityScope scope, {
    LibraryFieldIdRuntime? primaryColumn,
    LibrarySortId<TKind>? defaultSort,
    LibraryGroupIdRuntime? defaultGroup,
  }) {
    final fieldScopes = <String, LibraryEntityScope>{
      for (final field in fields) field.id.value: field.entityScope,
    };
    LibraryEntityScope? scopeFor(String id, LibraryEntityScope? explicit) =>
        explicit ?? fieldScopes[id];
    final scopedFields = fields
        .where((field) => field.entityScope == scope)
        .toList(growable: false);
    final scopedColumns = columns
        .where(
            (column) => scopeFor(column.id.value, column.entityScope) == scope)
        .toList(growable: false);
    final scopedSorts = sorts
        .where((sort) => scopeFor(sort.id.value, sort.entityScope) == scope)
        .toList(growable: false);
    final scopedGroups = groups
        .where((group) => scopeFor(group.id.value, group.entityScope) == scope)
        .toList(growable: false);
    if (scopedSorts.isEmpty) {
      throw StateError(
        'No workspace sorts registered for $kindNamespace/${scope.apiValue}.',
      );
    }
    final scopedDefaultSort = defaultSort ??
        (scope == entityScope
            ? this.defaultSort
            : (throw StateError(
                'A default sort must be declared for '
                '$kindNamespace/${scope.apiValue}.',
              )));
    final hasDefaultSort = scopedSorts.any(
      (sort) => sort.id.value == scopedDefaultSort.value,
    );
    if (!hasDefaultSort) {
      throw StateError(
        'Default workspace sort ${scopedDefaultSort.value} is not registered for '
        '$kindNamespace/${scope.apiValue}.',
      );
    }
    final scopedDefaultVisibleColumns = defaultVisibleColumns
        .where((id) => scopedColumns.any(
              (column) => column.id.value == id.value,
            ))
        .toList(growable: false);
    final requestedPrimaryColumn = primaryColumn ?? this.primaryColumn;
    final requestedPrimaryIsRegistered = scopedColumns.any(
      (column) => column.id.value == requestedPrimaryColumn.value,
    );
    final scopedPrimaryColumn = requestedPrimaryIsRegistered
        ? requestedPrimaryColumn
        : primaryColumn == null && scopedDefaultVisibleColumns.isNotEmpty
            ? scopedDefaultVisibleColumns.first
            : throw StateError(
                'Primary workspace column ${requestedPrimaryColumn.value} is '
                'not registered for $kindNamespace/${scope.apiValue}.',
              );
    final scopedDefaultGroup = defaultGroup ?? this.defaultGroup;
    LibraryGroupDefinition<TKind, TDto, Object?>? selectedGroup;
    if (scopedDefaultGroup != null) {
      for (final group in scopedGroups) {
        if (group.id.value == scopedDefaultGroup.value) {
          selectedGroup = group;
          break;
        }
      }
      if (selectedGroup == null) {
        throw StateError(
          'Default workspace group ${scopedDefaultGroup.value} is not registered '
          'for $kindNamespace/${scope.apiValue}.',
        );
      }
    }
    return LibraryEntityWorkspaceSchema<TKind, TDto>(
      kindNamespace: kindNamespace,
      entityScope: scope,
      fields: scopedFields,
      columns: scopedColumns,
      sorts: scopedSorts,
      groups: scopedGroups,
      primaryColumn: scopedPrimaryColumn,
      defaultVisibleColumns: {
        ...scopedDefaultVisibleColumns,
        scopedPrimaryColumn
      },
      defaultSort: scopedDefaultSort,
      defaultGroup: selectedGroup?.id,
      preferenceCodec: preferenceCodec,
    );
  }

  /// Creates an isolated runtime registry for this entity workspace.
  ///
  /// The schema definitions are immutable inputs, but the registry is the
  /// runtime boundary consumed by one structural entity scope. Returning a
  /// fresh instance prevents work/release/copy workspaces from sharing the
  /// same registry object by accident.
  LibraryFieldRegistry<TDto> toRegistry() {
    // Scope is semantic ownership, not presentation metadata. A registry
    // must fail if a caller hands it a definition owned by another entity;
    // silently rebinding it hides broken kind registrations.
    for (final field in fields) {
      if (field.entityScope != entityScope) {
        throw StateError(
          'Field ${field.id.value} belongs to ${field.entityScope.apiValue}, '
          'but is registered for ${entityScope.apiValue} in $kindNamespace.',
        );
      }
    }
    for (final column in columns) {
      if (column.entityScope != null && column.entityScope != entityScope) {
        throw StateError(
          'Column ${column.id.value} belongs to '
          '${column.entityScope!.apiValue}, but is registered for '
          '${entityScope.apiValue} in $kindNamespace.',
        );
      }
    }
    for (final sort in sorts) {
      if (sort.entityScope != null && sort.entityScope != entityScope) {
        throw StateError(
          'Sort ${sort.id.value} belongs to ${sort.entityScope!.apiValue}, '
          'but is registered for ${entityScope.apiValue} in $kindNamespace.',
        );
      }
    }
    for (final group in groups) {
      if (group.entityScope != null && group.entityScope != entityScope) {
        throw StateError(
          'Group ${group.id.value} belongs to '
          '${group.entityScope!.apiValue}, but is registered for '
          '${entityScope.apiValue} in $kindNamespace.',
        );
      }
    }
    return LibraryFieldRegistry<TDto>(
      kindNamespace: kindNamespace,
      entityScope: entityScope,
      fields: fields,
      columns: columns,
      sorts: sorts,
      groups: groups,
      primaryColumn: primaryColumn,
      defaultVisibleColumns: defaultVisibleColumns,
      defaultSort: defaultSort,
      defaultGroup: defaultGroup,
      preferenceCodec: preferenceCodec,
    );
  }
}
