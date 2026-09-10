import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/transport/provider_metadata_envelope.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_descriptor.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_result.dart';

/// Core contract for client-side metadata providers, unified with [MetadataCapability].
abstract class MetadataProvider implements MetadataCapability {
  /// Static capabilities and metadata for this provider.
  ProviderDescriptor get descriptor;

  /// Unique provider identifier (e.g. 'openlibrary', 'anilist', 'tmdb').
  String get name => descriptor.name;

  /// Whether this provider has required credentials / configuration present to operate.
  bool get isConfigured;

  /// User-facing status explanation (e.g. 'API key configured' or 'Ready without key').
  String get statusMessage;

  /// Search for metadata items matching [query].
  ///
  /// Optional [kind] can be specified to restrict search scope where supported.
  @override
  Future<List<ProviderSearchResult>> search(
    String query, {
    CatalogMediaKind? kind,
    int limit = 25,
  });

  @override
  Future<ProviderMetadataEnvelope> fetchItem(
    String providerItemId, {
    CatalogMediaKind? kind,
  });
}
