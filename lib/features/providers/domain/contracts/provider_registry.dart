import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_descriptor.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';

/// Composition root registry holding active client-side [ProviderConnector] instances.
abstract class ProviderConnectorRegistry {
  /// Register or replace a connector in the registry.
  void register(ProviderConnector connector);

  /// Unregister a connector by [id].
  void unregister(ProviderId id);

  /// Retrieve a registered connector by [ProviderId] or [String] name.
  ProviderConnector? get(Object idOrName);

  /// Retrieve a registered connector by typed [ProviderId].
  ProviderConnector? getById(ProviderId id);

  /// Retrieve a registered connector by string [name].
  ProviderConnector? getByName(String name);

  /// Retrieve a registered connector by [ProviderId] or string identifier.
  ProviderConnector? byId(Object idOrName);

  /// Retrieve all registered connectors.
  List<ProviderConnector> getAll();

  /// Retrieve all registered connectors that support the given [kind].
  List<ProviderConnector> getForKind(Object kind);

  /// Retrieve all registered connectors that support the given [kind].
  List<ProviderConnector> forKind(Object kind);

  /// Retrieve descriptors for all registered connectors.
  List<ProviderDescriptor> getDescriptors();

  /// Retrieve unique supported media kinds across all registered connectors.
  List<String> get supportedKinds;
}

/// In-memory implementation of [ProviderConnectorRegistry].
class InMemoryProviderConnectorRegistry implements ProviderConnectorRegistry {
  InMemoryProviderConnectorRegistry(
      [List<ProviderConnector>? initialConnectors]) {
    if (initialConnectors != null) {
      for (final connector in initialConnectors) {
        register(connector);
      }
    }
  }

  final Map<String, ProviderConnector> _connectors = {};
  final Map<ProviderId, ProviderConnector> _byId = {};

  @override
  void register(ProviderConnector connector) {
    _connectors[connector.descriptor.name.toLowerCase()] = connector;
    _connectors[connector.id.value.toLowerCase()] = connector;
    _byId[connector.id] = connector;
  }

  @override
  void unregister(ProviderId id) {
    final connector = _byId.remove(id);
    if (connector != null) {
      _connectors.remove(connector.descriptor.name.toLowerCase());
      _connectors.remove(connector.id.value.toLowerCase());
    }
  }

  @override
  ProviderConnector? get(Object idOrName) {
    if (idOrName is ProviderId) {
      return _byId[idOrName] ?? _connectors[idOrName.value.toLowerCase()];
    }
    final normalized = idOrName.toString().trim().toLowerCase();
    final direct = _connectors[normalized];
    if (direct != null) return direct;
    final providerId = ProviderId.fromValue(normalized);
    if (providerId != null) {
      return _byId[providerId] ?? _connectors[providerId.value.toLowerCase()];
    }
    return null;
  }

  @override
  ProviderConnector? getById(ProviderId id) =>
      _byId[id] ?? _connectors[id.value.toLowerCase()];

  @override
  ProviderConnector? getByName(String name) => get(name);

  @override
  ProviderConnector? byId(Object idOrName) => get(idOrName);

  @override
  List<ProviderConnector> getAll() {
    final unique = <ProviderConnector>{..._connectors.values, ..._byId.values};
    return List.unmodifiable(unique);
  }

  @override
  List<ProviderConnector> getForKind(Object kind) {
    final kindStr = kind is CatalogMediaKind
        ? kind.apiValue
        : kind.toString().trim().toLowerCase();
    final unique = <ProviderConnector>{..._connectors.values, ..._byId.values};
    return unique
        .where((connector) => connector.descriptor.supportsKind(kindStr))
        .toList(growable: false);
  }

  @override
  List<ProviderConnector> forKind(Object kind) => getForKind(kind);

  @override
  List<ProviderDescriptor> getDescriptors() {
    return getAll()
        .map((connector) => connector.descriptor)
        .toList(growable: false);
  }

  @override
  List<String> get supportedKinds {
    final kinds = <String>{};
    for (final connector in getAll()) {
      kinds.addAll(connector.descriptor.allSupportedKinds);
    }
    return kinds.toList(growable: false);
  }
}

typedef ProviderRegistry = ProviderConnectorRegistry;
typedef InMemoryProviderRegistry = InMemoryProviderConnectorRegistry;
