import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_field_registry.dart';

/// Strongly typed field and table schema for one workspace surface.
///
/// A kind registers separate schemas for Catalog Items and local entries. The
/// target type selects the schema; field declarations do not repeat that fact.
class LibraryWorkspaceSchema<TKind, TDto extends LibraryWorkspaceDto> {
  LibraryWorkspaceSchema({
    required this.kindNamespace,
    required this.fields,
    required this.columns,
    required this.sorts,
    required this.groups,
    required this.primaryColumn,
    required this.defaultVisibleColumns,
    required this.defaultSort,
    this.defaultGroup,
  });

  final String kindNamespace;
  final List<LibraryFieldDefinition<TKind, TDto, Object?>> fields;
  final List<LibraryColumnDefinition<TKind, TDto, Object?>> columns;
  final List<LibrarySortDefinition<TKind, TDto>> sorts;
  final List<LibraryGroupDefinition<TKind, TDto, Object?>> groups;

  final LibraryFieldIdRuntime primaryColumn;
  final Set<LibraryFieldIdRuntime> defaultVisibleColumns;
  final LibrarySortId<TKind> defaultSort;
  final LibraryGroupIdRuntime? defaultGroup;

  /// Creates an isolated runtime registry for this workspace surface.
  ///
  /// Catalog and library-entry schemas get distinct registries so their field
  /// definitions cannot leak across targets.
  LibraryFieldRegistry<TDto> toRegistry() {
    return LibraryFieldRegistry<TDto>(
      kindNamespace: kindNamespace,
      fields: fields,
      columns: columns,
      sorts: sorts,
      groups: groups,
      primaryColumn: primaryColumn,
      defaultVisibleColumns: defaultVisibleColumns,
      defaultSort: defaultSort,
      defaultGroup: defaultGroup,
    );
  }
}
