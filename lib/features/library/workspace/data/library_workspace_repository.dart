import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'library_workspace_query.dart';

abstract class LibraryWorkspaceRepository {
  Stream<List<LibraryProjectionRuntime>> watchEntries(
      LibraryWorkspaceQuery query);
}

class LocalLibraryWorkspaceRepository implements LibraryWorkspaceRepository {
  LocalLibraryWorkspaceRepository(this.ref);
  final Ref ref;

  @override
  Stream<List<LibraryProjectionRuntime>> watchEntries(
      LibraryWorkspaceQuery query) {
    final controller = StreamController<List<LibraryProjectionRuntime>>();
    final listener = ref.listen<AsyncValue<ShelfState>>(
      shelfProvider,
      (previous, next) {
        if (next is AsyncData<ShelfState>) {
          controller.add(_processEntries(next.value.entries, query));
        } else if (next is AsyncError<ShelfState>) {
          controller.addError(next.error, next.stackTrace);
        }
      },
      fireImmediately: true,
    );
    controller.onCancel = listener.close;

    return controller.stream;
  }

  List<LibraryProjectionRuntime> _processEntries(
    List<ShelfEntry> shelfEntries,
    LibraryWorkspaceQuery query,
  ) {
    final module = libraryKindRuntimeForKind(query.kind);

    final items = <LibraryProjectionRuntime>[];
    for (final source in shelfEntries) {
      final catalogItem = source.catalogItem;
      if (catalogItem != null && catalogItem.kind == query.kind.apiValue) {
        final node = LibraryTitleNodeRef(titleItemId: catalogItem.id);
        items.add(module.workspace.project(source: source, node: node));
      }
    }

    var filtered = items;

    final queryStr = query.searchQuery.trim().toLowerCase();
    if (queryStr.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.dto.title.toLowerCase().contains(queryStr);
      }).toList();
    }

    if (query.collectionId != null) {
      filtered = filtered.where((item) {
        return item.source.ownedItem?.locationId == query.collectionId;
      }).toList();
    }

    if (query.scopeId != null) {
      filtered = filtered.where((item) {
        return item.node.titleItemId == query.scopeId;
      }).toList();
    }

    if (query.facetValues.isNotEmpty) {
      filtered = filtered.where((item) {
        for (final facetEntry in query.facetValues.entries) {
          final facetId = facetEntry.key;
          final selectedValues = facetEntry.value;
          if (selectedValues.isEmpty) {
            continue;
          }
          final values = module.facets?.getFacetValues?.call(item, facetId) ??
              const <String>[];
          final hasMatch = values.any((val) => selectedValues.contains(val));
          if (!hasMatch) {
            return false;
          }
        }
        return true;
      }).toList();
    }

    if (query.presentationLevelId != null) {
      filtered = filtered.where((item) {
        if (query.presentationLevelId == 'title') {
          return item.node.scope == LibraryBrowserScope.title;
        } else if (query.presentationLevelId == 'release') {
          return item.node.scope == LibraryBrowserScope.release;
        } else if (query.presentationLevelId == 'copy') {
          return item.node.scope == LibraryBrowserScope.copy;
        }
        return true;
      }).toList();
    }

    filtered.sort((left, right) =>
        left.dto.title.toLowerCase().compareTo(right.dto.title.toLowerCase()));

    return filtered;
  }
}

final libraryWorkspaceRepositoryProvider =
    Provider.autoDispose<LibraryWorkspaceRepository>((ref) {
  return LocalLibraryWorkspaceRepository(ref);
});
