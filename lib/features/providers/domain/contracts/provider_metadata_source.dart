import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/transport/provider_raw_envelope.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_descriptor.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_result.dart';

/// Provider-owned metadata source used by the non-Music adapters.
///
/// The response is a normalized wire envelope. Kind integrations decode it at
/// their own boundary; generic hosts never inspect the normalized payload.
abstract class ProviderMetadataSource implements ProviderMetadataCapability {
  ProviderDescriptor get descriptor;

  String get name => descriptor.name;

  bool get isConfigured;

  String get statusMessage;

  @override
  Future<List<ProviderSearchResult>> search(
    String query, {
    CatalogMediaKind? kind,
    int limit = 25,
  });

  @override
  Future<ProviderRawEnvelope> fetchItem(
    String providerItemId, {
    CatalogMediaKind? kind,
  });
}
