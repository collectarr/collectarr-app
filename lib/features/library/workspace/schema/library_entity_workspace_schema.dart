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
    this.entityScope = LibraryEntityScope.work,
    required this.fields,
    required this.columns,
    required this.sorts,
    required this.groups,
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
    LibraryEntityScope scope,
  ) {
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
    final selectedSort = scopedSorts.any(
      (sort) => sort.id.value == defaultSort.value,
    )
        ? defaultSort
        : scopedSorts.first.id;
    LibraryGroupDefinition<TKind, TDto, Object?>? selectedGroup;
    for (final group in scopedGroups) {
      if (group.id.value == defaultGroup?.value) {
        selectedGroup = group;
        break;
      }
    }
    selectedGroup ??= scopedGroups.isEmpty ? null : scopedGroups.first;
    return LibraryEntityWorkspaceSchema<TKind, TDto>(
      kindNamespace: kindNamespace,
      entityScope: scope,
      fields: scopedFields,
      columns: scopedColumns,
      sorts: scopedSorts,
      groups: scopedGroups,
      defaultVisibleColumns: defaultVisibleColumns
          .where((id) =>
              scopedColumns.any((column) => column.id.value == id.value))
          .toSet(),
      defaultSort: selectedSort,
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
    // A dedicated schema may intentionally reuse a kind field definition
    // (for example Music's title/cover definitions) at another structural
    // boundary. Rebind only those explicitly selected definitions; scoped
    // schemas produced by forScope already carry the correct scope and keep
    // their original instances.
    final scopedFields = [
      for (final field in fields)
        field.entityScope == entityScope
            ? field
            : field.withEntityScope(entityScope),
    ];
    final scopedColumns = [
      for (final column in columns)
        column.entityScope == entityScope
            ? column
            : column.withEntityScope(entityScope),
    ];
    final scopedSorts = [
      for (final sort in sorts)
        sort.entityScope == entityScope
            ? sort
            : sort.withEntityScope(entityScope),
    ];
    final scopedGroups = [
      for (final group in groups)
        group.entityScope == entityScope
            ? group
            : group.copyWith(entityScope: entityScope),
    ];
    return LibraryFieldRegistry<TDto>(
      kindNamespace: kindNamespace,
      entityScope: entityScope,
      fields: scopedFields,
      columns: scopedColumns,
      sorts: scopedSorts,
      groups: scopedGroups,
      defaultVisibleColumns: defaultVisibleColumns,
      defaultSort: defaultSort,
      defaultGroup: defaultGroup,
      preferenceCodec: preferenceCodec,
    );
  }
}
