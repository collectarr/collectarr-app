import 'package:collectarr_app/features/library/config/library_type_config.dart';

class LibraryTypeRegistry {
  const LibraryTypeRegistry(this.types);

  final List<LibraryTypeConfig> types;

  LibraryTypeConfig? byKind(String kind) {
    final normalized = kind.trim().toLowerCase();
    for (final type in types) {
      if (type.workspace.kind == normalized) {
        return type;
      }
    }
    return null;
  }

  List<String> get supportedKinds {
    return {
      for (final type in types) type.workspace.kind,
    }.toList();
  }

  List<LibraryMetadataProviderOption> providersForKind(String kind) {
    final type = byKind(kind);
    return type?.supportedMetadataProviders ?? const [];
  }
}
