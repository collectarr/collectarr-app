import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';

class LibraryTypeRegistry {
  const LibraryTypeRegistry(this.types);

  final List<LibraryTypeConfig> types;

  LibraryTypeConfig? byKind(Object? kind) {
    final normalized = catalogMediaKindFromValue(kind);
    for (final type in types) {
      if (type.workspace.kind == normalized) {
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

  List<LibraryMetadataProviderOption> providersForKind(Object? kind) {
    final type = byKind(kind);
    return type?.supportedMetadataProviders ?? const [];
  }

  LibraryTypeCapabilities capabilitiesForKind(Object? kind) {
    return byKind(kind)?.capabilities ?? const LibraryTypeCapabilities();
  }
}
