import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_import_capability.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_import_registry.dart';

LibraryKindImportCapability libraryImportForKind(CatalogMediaKind kind) {
  return collectarrKindImports[kind] ??
      collectarrKindImports[CatalogMediaKind.music]!;
}
