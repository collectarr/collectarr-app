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
    required this.kinds,
    this.value,
    this.sortable = true,
    this.filterable = true,
    this.groupable = true,
    this.defaultWidth,
  });

  final String id;
  final String label;
  final LibraryColumnScope scope;
  final Set<CatalogMediaKind> kinds;
  final LibraryColumnValueBuilder? value;
  final bool sortable;
  final bool filterable;
  final bool groupable;
  final double? defaultWidth;

  bool supportsKind(CatalogMediaKind kind) {
    return kinds.contains(kind);
  }
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

  List<LibraryColumnDefinition> forKind(CatalogMediaKind kind) {
    return [
      for (final definition in definitions)
        if (definition.supportsKind(kind)) definition,
    ];
  }

  List<LibraryColumnDefinition> get workColumns => [
        for (final definition in definitions)
          if (definition.scope == LibraryColumnScope.work) definition,
      ];
}

LibraryColumnDefinition legacyLibraryColumnDefinition(
  Enum column, {
  required Set<CatalogMediaKind> kinds,
}) {
  return LibraryColumnDefinition(
    id: column.name,
    label: column.name,
    scope: LibraryColumnScope.work,
    kinds: kinds,
    sortable: true,
    filterable: true,
    groupable: true,
  );
}

LibraryColumnRegistry defaultLibraryColumnRegistry({
  required Set<CatalogMediaKind> kinds,
}) {
  return LibraryColumnRegistry(const []);
}
