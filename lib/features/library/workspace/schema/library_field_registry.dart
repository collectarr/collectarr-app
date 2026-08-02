import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';

/// Strongly typed registry owning column, sort, group, and default definitions for a specific [TKind] and [TDto].
final class LibraryFieldRegistry<TKind, TDto extends LibraryWorkspaceDto> {
  LibraryFieldRegistry({
    required this.kindNamespace,
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
  final List<LibraryColumnDefinition<TKind, TDto, Object?>> columns;
  final List<LibrarySortDefinition<TKind, TDto>> sorts;
  final List<LibraryGroupDefinition<TKind, TDto, Object?>> groups;

  final Set<LibraryFieldIdRuntime> defaultVisibleColumns;
  final LibrarySortId<TKind> defaultSort;
  final LibraryGroupIdRuntime? defaultGroup;

  final LibraryWorkspacePreferenceCodec<TKind> preferenceCodec;

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
