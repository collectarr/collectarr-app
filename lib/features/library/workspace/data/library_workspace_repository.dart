import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'library_workspace_query.dart';

abstract class LibraryWorkspaceRepository {
  Stream<List<LibraryWorkspaceEntry>> watchEntries(LibraryWorkspaceQuery query);
}

class LocalLibraryWorkspaceRepository implements LibraryWorkspaceRepository {
  LocalLibraryWorkspaceRepository(this.ref);
  final Ref ref;

  @override
  Stream<List<LibraryWorkspaceEntry>> watchEntries(LibraryWorkspaceQuery query) {
    final controller = StreamController<List<LibraryWorkspaceEntry>>();

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

    final current = ref.read(shelfProvider);
    if (current is AsyncData<ShelfState>) {
      controller.add(_processEntries(current.value.entries, query));
    }

    controller.onCancel = () {
      listener.close();
    };

    return controller.stream;
  }

  List<LibraryWorkspaceEntry> _processEntries(
    List<ShelfEntry> shelfEntries,
    LibraryWorkspaceQuery query,
  ) {
    final module = libraryKindModuleForKind(query.kind);
    final type = module.type;

    final entries = <LibraryWorkspaceEntry>[];
    for (final source in shelfEntries) {
      final catalogItem = source.catalogItem;
      if (catalogItem != null && catalogItem.kind == query.kind.apiValue) {
        entries.add(type.presentation.workspaceEntryBuilder(source));
      }
    }

    final queryStr = query.searchQuery.trim().toLowerCase();
    var filtered = entries;
    if (queryStr.isNotEmpty) {
      filtered = entries.where((entry) {
        return entry.resolvedTitle.toLowerCase().contains(queryStr) ||
            (entry.publisher?.toLowerCase().contains(queryStr) ?? false) ||
            (entry.itemNumber?.toLowerCase().contains(queryStr) ?? false);
      }).toList();
    }

    if (query.sortId != null) {
      final sortDef = module.fields.sortDefinitionFor(query.sortId!);
      filtered.sort((left, right) {
        final result = sortDef.compare(left, right);
        return query.sortAscending ? result : -result;
      });
    } else {
      filtered.sort((left, right) =>
          left.resolvedTitle.toLowerCase().compareTo(right.resolvedTitle.toLowerCase()));
    }

    return filtered;
  }
}

final libraryWorkspaceRepositoryProvider =
    Provider<LibraryWorkspaceRepository>((ref) {
  return LocalLibraryWorkspaceRepository(ref);
});
