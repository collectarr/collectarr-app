import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/data/library_workspace_repository.dart';
import 'package:collectarr_app/features/library/workspace/data/library_workspace_query.dart';
import 'library_workspace_key.dart';

/// Input parameters for the [libraryLocalFacetValuesProvider].
class LibraryFacetValuesInput {
  const LibraryFacetValuesInput({
    required this.key,
    required this.facetId,
  });

  final LibraryWorkspaceKey key;
  final String facetId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryFacetValuesInput &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          facetId == other.facetId;

  @override
  int get hashCode => key.hashCode ^ facetId.hashCode;
}

/// Extract all unique local values for a given facet/group/column ID from the unfiltered
/// workspace entry list. For example, returns all publishers or genres actually
/// present in the user's local collection for this kind.
final libraryLocalFacetValuesProvider = StreamProvider.autoDispose
    .family<List<String>, LibraryFacetValuesInput>((ref, input) {
  final module = libraryKindRuntimeForKind(input.key.kind);
  final groupDef = module.fields.findGroupDefinition(input.facetId);
  final columnDef = module.fields.findColumnDefinition(input.facetId);

  if (groupDef == null && columnDef == null) {
    return Stream.value(const <String>[]);
  }

  Object? getValue(LibraryProjectionRuntime item) {
    final dto = item.dto;
    if (groupDef != null) return (groupDef as dynamic).getValue(dto);
    if (columnDef != null) return (columnDef as dynamic).getValue(dto);
    return null;
  }

  final repository = ref.watch(libraryWorkspaceRepositoryProvider);
  final query = LibraryWorkspaceQuery(
    kind: input.key.kind,
    searchQuery: '',
    facetValues: const {},
    sortId: null,
    sortAscending: true,
    groupId: null,
    visibleColumnIds: const {},
  );
  return repository.watchEntries(query).map((entries) {
    final values = <String>{};
    for (final entry in entries) {
      final raw = getValue(entry);
      if (raw == null) continue;
      if (raw is String) {
        final val = raw.trim();
        if (val.isNotEmpty) {
          values.add(val);
        }
      } else if (raw is Iterable) {
        for (final item in raw) {
          if (item is String) {
            final val = item.trim();
            if (val.isNotEmpty) {
              values.add(val);
            }
          } else if (item != null) {
            final val = item.toString().trim();
            if (val.isNotEmpty) {
              values.add(val);
            }
          }
        }
      } else {
        final val = raw.toString().trim();
        if (val.isNotEmpty) {
          values.add(val);
        }
      }
    }
    return values.toList(growable: false)..sort();
  });
});
