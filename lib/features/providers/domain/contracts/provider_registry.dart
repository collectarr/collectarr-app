import 'package:collectarr_app/features/providers/domain/contracts/metadata_provider.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_descriptor.dart';

/// Registry holding active client-side [MetadataProvider] instances.
abstract class ProviderRegistry {
  /// Register or replace a provider in the registry.
  void register(MetadataProvider provider);

  /// Unregister a provider by [name].
  void unregister(String name);

  /// Retrieve a registered provider by [name], or return `null` if not registered.
  MetadataProvider? get(String name);

  /// Retrieve all registered providers.
  List<MetadataProvider> getAll();

  /// Retrieve all registered providers that support the given [kind].
  List<MetadataProvider> getForKind(String kind);

  /// Retrieve descriptors for all registered providers.
  List<ProviderDescriptor> getDescriptors();
}

/// In-memory implementation of [ProviderRegistry].
class InMemoryProviderRegistry implements ProviderRegistry {
  InMemoryProviderRegistry([List<MetadataProvider>? initialProviders]) {
    if (initialProviders != null) {
      for (final provider in initialProviders) {
        register(provider);
      }
    }
  }

  final Map<String, MetadataProvider> _providers = {};

  @override
  void register(MetadataProvider provider) {
    _providers[provider.name.trim().toLowerCase()] = provider;
  }

  @override
  void unregister(String name) {
    _providers.remove(name.trim().toLowerCase());
  }

  @override
  MetadataProvider? get(String name) {
    return _providers[name.trim().toLowerCase()];
  }

  @override
  List<MetadataProvider> getAll() {
    return List.unmodifiable(_providers.values);
  }

  @override
  List<MetadataProvider> getForKind(String kind) {
    final normalizedKind = kind.trim().toLowerCase();
    return _providers.values
        .where((provider) => provider.descriptor.supportsKind(normalizedKind))
        .toList(growable: false);
  }

  @override
  List<ProviderDescriptor> getDescriptors() {
    return _providers.values
        .map((provider) => provider.descriptor)
        .toList(growable: false);
  }
}
