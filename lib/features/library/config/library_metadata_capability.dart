import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_metadata_provider_models.dart';

/// Encapsulates metadata provider configuration and behavior for a media kind.
class LibraryMetadataCapability {
  const LibraryMetadataCapability({
    required this.defaultProviderId,
    required this.providers,
    this.supportsServerCompare = false,
  });

  final String defaultProviderId;
  final List<LibraryMetadataProviderOption> providers;
  final bool supportsServerCompare;

  List<LibraryMetadataProviderOption> supportedProvidersForKind(
      CatalogMediaKind kind) {
    if (kind == CatalogMediaKind.unknown) {
      return providers;
    }
    return [
      for (final option in providers)
        if (option.supportsKind(kind)) option,
    ];
  }

  LibraryMetadataProviderOption? defaultSupportedOption(CatalogMediaKind kind) {
    final supported = supportedProvidersForKind(kind);
    for (final option in supported) {
      if (option.id == defaultProviderId) {
        return option;
      }
    }
    return supported.isEmpty ? null : supported.first;
  }

  bool supportsProvider(String providerId, [CatalogMediaKind? kind]) {
    final list = kind != null ? supportedProvidersForKind(kind) : providers;
    return list.any((option) => option.id == providerId);
  }

  String providerLabel(String providerId) {
    for (final option in providers) {
      if (option.id == providerId) {
        return option.label;
      }
    }
    return providerId;
  }
}
