import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
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
    this.customLinkedMetadataCandidates,
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
  final Iterable<String> Function(ShelfEntry)? customLinkedMetadataCandidates;

  Set<String> get defaultVisibleColumnIds =>
      {for (final col in defaultVisibleColumns) col.value};

  String get defaultSortId => defaultSort.value;

  String? get defaultGroupId => defaultGroup?.value;

  LibraryColumnDefinition<TKind, TDto, Object?>? columnDefinitionForId(
      String id) {
    for (final definition in columns) {
      if (definition.id.value == id) return definition;
    }
    return null;
  }

  LibraryColumnDefinition<TKind, TDto, Object?> columnDefinitionFor(
      String columnId) {
    final definition = columnDefinitionForId(columnId);
    if (definition != null) return definition;
    throw StateError(
        'Missing column definition for $columnId in $kindNamespace.');
  }

  LibrarySortDefinition<TKind, TDto>? sortDefinitionForId(String id) {
    for (final definition in sorts) {
      if (definition.id.value == id) return definition;
    }
    return null;
  }

  LibrarySortDefinition<TKind, TDto> sortDefinitionFor(String sortId) {
    final definition = findSortDefinition(sortId);
    if (definition != null) return definition;
    throw StateError('Missing sort definition for $sortId in $kindNamespace.');
  }

  LibraryGroupDefinition<TKind, TDto, Object?>? groupDefinitionForId(
      String id) {
    for (final definition in groups) {
      if (definition.id.value == id) return definition;
    }
    return null;
  }

  LibraryGroupDefinition<TKind, TDto, Object?> groupDefinitionFor(
      String groupId) {
    final definition = findGroupDefinition(groupId);
    if (definition != null) return definition;
    throw StateError('Missing group definition for $groupId in $kindNamespace.');
  }

  LibraryColumnDefinition<TKind, TDto, Object?>? findColumnDefinition(
      String id) {
    final direct = columnDefinitionForId(id);
    if (direct != null) return direct;
    final decoded = preferenceCodec.decodeColumn(id);
    if (decoded != null) return columnDefinitionForId(decoded.value);
    return null;
  }

  LibrarySortDefinition<TKind, TDto>? findSortDefinition(String id) {
    final direct = sortDefinitionForId(id);
    if (direct != null) return direct;
    final decoded = preferenceCodec.decodeSort(id);
    if (decoded != null) return sortDefinitionForId(decoded.value);
    return null;
  }

  LibraryGroupDefinition<TKind, TDto, Object?>? findGroupDefinition(
      String id) {
    final direct = groupDefinitionForId(id);
    if (direct != null) return direct;
    final decoded = preferenceCodec.decodeGroup(id);
    if (decoded != null) return groupDefinitionForId(decoded.value);
    return null;
  }

  void sortEntries(
    List<LibraryProjectionRuntime> items,
    String sortId, {
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
    final series = item.series?.seriesTitle?.trim();
    final country = item.country?.trim();
    final language = item.language?.trim();
    final publishing = item.publishing;

    yield* nonEmptyStrings([
      item.title,
      series,
      item.itemNumber,
      item.publisher,
      item.variant,
      publishing?.imprint,
      country,
      language,
    ]);
    yield* nonEmptyStrings(item.searchAliases);
    if (item.creators case final creators?) {
      for (final credit in creators) {
        final name = credit['name']?.toString().trim();
        if (name != null && name.isNotEmpty) {
          yield name;
        }
      }
    }
    yield* nonEmptyStrings(item.genres);

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
