import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_import_capability.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart'
    show musicKindImport;

final Map<CatalogMediaKind, LibraryKindImportCapability> collectarrKindImports =
    Map.unmodifiable(<CatalogMediaKind, LibraryKindImportCapability>{
  CatalogMediaKind.music: musicKindImport,
  // Game imports no guided source yet.
  CatalogMediaKind.game: const LibraryKindImportCapability(),
});
