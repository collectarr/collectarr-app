import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';

class LibraryTypeRegistry {
  LibraryTypeRegistry(this.types);

  final List<LibraryTypeConfig> types;

  LibraryTypeConfig? byKind(CatalogMediaKind kind) {
    for (final type in types) {
      if (type.workspace.kind == kind) {
        return type;
      }
    }
    return null;
  }

  List<String> get supportedKinds {
    return {
      for (final type in types) type.workspace.kind.apiValue,
    }.toList();
  }

  List<LibraryMetadataProviderOption> providersForKind(CatalogMediaKind kind) {
    final type = byKind(kind);
    return type?.supportedMetadataProviders ?? const [];
  }

  LibraryTypeCapabilities capabilitiesForKind(CatalogMediaKind kind) {
    return byKind(kind)?.capabilities ?? const LibraryTypeCapabilities.empty();
  }
}
