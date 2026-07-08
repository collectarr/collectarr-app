import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

enum LibraryColumnScope { work, release, ownedCopy, tracking, custom }

typedef LibraryColumnValueBuilder = Object? Function(
  LibraryWorkspaceEntry entry,
  LibraryProjectionContext context,
);

class LibraryProjectionContext {
  const LibraryProjectionContext({
    required this.kind,
    required this.entry,
    this.adapter,
    this.sortColumnId,
  });

  final CatalogMediaKind kind;
  final Object? adapter;
  final LibraryWorkspaceEntry entry;
  final String? sortColumnId;
}

class LibraryColumnDefinition {
  const LibraryColumnDefinition({
    required this.id,
    required this.label,
    required this.scope,
    this.value,
    this.sortable = true,
    this.filterable = true,
    this.groupable = true,
    this.defaultWidth,
  });

  final String id;
  final String label;
  final LibraryColumnScope scope;
  final LibraryColumnValueBuilder? value;
  final bool sortable;
  final bool filterable;
  final bool groupable;
  final double? defaultWidth;
}

class LibraryColumnRegistry {
  const LibraryColumnRegistry(this.definitions);

  final List<LibraryColumnDefinition> definitions;

  LibraryColumnDefinition? byId(String id) {
    for (final definition in definitions) {
      if (definition.id == id) {
        return definition;
      }
    }
    return null;
  }

  List<LibraryColumnDefinition> get workColumns => [
        for (final definition in definitions)
          if (definition.scope == LibraryColumnScope.work) definition,
      ];
}
