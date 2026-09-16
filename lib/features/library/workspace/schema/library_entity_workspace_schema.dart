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
    required this.fields,
    required this.columns,
    required this.sorts,
    required this.groups,
    required this.defaultVisibleColumns,
    required this.defaultSort,
    this.defaultGroup,
    required this.preferenceCodec,
  }) : registry = LibraryFieldRegistry<TDto>(
          kindNamespace: kindNamespace,
          fields: fields,
          columns: columns,
          sorts: sorts,
          groups: groups,
          defaultVisibleColumns: defaultVisibleColumns,
          defaultSort: defaultSort,
          defaultGroup: defaultGroup,
          preferenceCodec: preferenceCodec,
        );

  final String kindNamespace;
  final List<LibraryFieldDefinition<TKind, TDto, Object?>> fields;
  final List<LibraryColumnDefinition<TKind, TDto, Object?>> columns;
  final List<LibrarySortDefinition<TKind, TDto>> sorts;
  final List<LibraryGroupDefinition<TKind, TDto, Object?>> groups;

  final Set<LibraryFieldIdRuntime> defaultVisibleColumns;
  final LibrarySortId<TKind> defaultSort;
  final LibraryGroupIdRuntime? defaultGroup;

  final LibraryWorkspacePreferenceCodec<TKind> preferenceCodec;

  final LibraryFieldRegistry<TDto> registry;

  LibraryFieldRegistry<TDto> toRegistry() => registry;
}
