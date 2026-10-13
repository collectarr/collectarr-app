import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_export_capability.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';

/// Kind-owned report fields assembled at the application composition root.
final Map<CatalogMediaKind, LibraryExportCapability>
    collectarrKindExportCapabilities =
    Map.unmodifiable(<CatalogMediaKind, LibraryExportCapability>{
  CatalogMediaKind.music: musicKindExport,
});
