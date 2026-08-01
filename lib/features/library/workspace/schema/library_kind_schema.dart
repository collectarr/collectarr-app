import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';

/// Strongly-typed schema object holding all field, column, sort, group,
/// and default workspace definitions for a media kind.
class LibraryKindSchema<TDto> {
  const LibraryKindSchema({
    required this.fields,
    required this.columns,
    required this.sorts,
    required this.groups,
    required this.defaultVisibleColumnIds,
    required this.defaultSortId,
    required this.defaultGroupId,
    this.customLinkedMetadataCandidates,
  });

  final List<LibraryFieldDefinition<TDto, Object?>> fields;
  final List<LibraryColumnDefinition<TDto, Object?>> columns;
  final List<LibrarySortDefinition<TDto>> sorts;
  final List<LibraryGroupDefinition<TDto, Object?>> groups;
  final Set<String> defaultVisibleColumnIds;
  final String defaultSortId;
  final String defaultGroupId;
  final Iterable<String> Function(ShelfEntry)? customLinkedMetadataCandidates;

  /// Converts this schema to [AnyLibraryFieldRegistry<TDto>] for consumption by [LibraryKindModule].
  AnyLibraryFieldRegistry<TDto> toRegistry() {
    return AnyLibraryFieldRegistry<TDto>(
      groups: groups,
      sorts: sorts,
      columns: columns,
      defaultVisibleColumnIds: defaultVisibleColumnIds,
      defaultSortId: defaultSortId,
      defaultGroupId: defaultGroupId,
      customLinkedMetadataCandidates: customLinkedMetadataCandidates,
    );
  }
}
