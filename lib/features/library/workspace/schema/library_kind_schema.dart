import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_field_registry.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';

/// Strongly-typed schema object holding all field, column, sort, group,
/// default workspace definitions, and preference codecs for a media kind [TKind].
class LibraryKindSchema<TKind, TDto extends LibraryWorkspaceDto> {
  LibraryKindSchema({
    required this.kindNamespace,
    required this.fields,
    required this.columns,
    required this.sorts,
    required this.groups,
    required this.defaultVisibleColumns,
    required this.defaultSort,
    this.defaultGroup,
    required this.preferenceCodec,
    this.customLinkedMetadataCandidates,
  }) : registry = LibraryFieldRegistry<TKind, TDto>(
          kindNamespace: kindNamespace,
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
  final Iterable<String> Function(ShelfEntry)? customLinkedMetadataCandidates;

  final LibraryFieldRegistry<TKind, TDto> registry;

  AnyLibraryFieldRegistry<TDto> toRegistry() {
    return AnyLibraryFieldRegistry<TDto>(
      groups: groups,
      sorts: sorts,
      columns: columns,
      defaultVisibleColumnIds: {for (final col in defaultVisibleColumns) col.value},
      defaultSortId: defaultSort.value,
      defaultGroupId: defaultGroup?.value ?? '',
      preferenceCodec: preferenceCodec,
      customLinkedMetadataCandidates: customLinkedMetadataCandidates,
    );
  }
}
