import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'library_workspace_query.dart';

abstract class LibraryWorkspaceRepository {
  Stream<List<LibraryProjectionView>> watchEntries(LibraryWorkspaceQuery query);
}

class LocalLibraryWorkspaceRepository implements LibraryWorkspaceRepository {
  LocalLibraryWorkspaceRepository(this.ref);
  final Ref ref;

  @override
  Stream<List<LibraryProjectionView>> watchEntries(
      LibraryWorkspaceQuery query) {
    final controller = StreamController<List<LibraryProjectionView>>();
    final listener = ref.listen<AsyncValue<ShelfState>>(
      shelfProvider,
      (previous, next) {
        if (next is AsyncData<ShelfState>) {
          controller.add(
            _processEntries(next.value.entries, query),
          );
        } else if (next is AsyncError<ShelfState>) {
          controller.addError(next.error, next.stackTrace);
        }
      },
      fireImmediately: true,
    );
    controller.onCancel = listener.close;

    return controller.stream;
  }

  List<LibraryProjectionView> _processEntries(
    List<LibraryWorkspaceSource> shelfEntries,
    LibraryWorkspaceQuery query,
  ) {
    final registration = libraryKindRegistrationForKind(query.kind);
    final workspace = libraryKindWorkspaceForKind(query.kind);

    final items = <LibraryProjectionView>[];
    for (final source in shelfEntries) {
      final catalogRef = source.catalogRef;
      if (catalogRef?.mediaKind == query.kind) {
        final node = LibraryWorkRef(workId: catalogRef!.id);
        items.add(workspace.project(source: source, node: node));
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
        return item.source.locationPath == query.collectionId;
      }).toList();
    }

    if (query.scopeId != null) {
      filtered = filtered.where((item) {
        return item.node.workId == query.scopeId;
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
          final values = libraryKindFacetModuleForKind(registration.kind)
                  ?.getFacetValues
                  ?.call(
                    item,
                    facetId,
                  ) ??
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
          return item.node.scope == LibraryEntityScope.work;
        } else if (query.presentationLevelId == 'release') {
          return item.node.scope == LibraryEntityScope.release;
        } else if (query.presentationLevelId == 'copy') {
          return item.node.scope == LibraryEntityScope.copy;
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
