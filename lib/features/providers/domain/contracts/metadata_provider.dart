import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_descriptor.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_search_result.dart';

/// Core contract for client-side metadata providers.
///
/// Implementations must not expose raw JSON maps publicly. All responses
/// must be strongly-typed domain models ([ProviderSearchResult] and [NormalizedProviderEnvelopeV1]).
abstract class MetadataProvider {
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
  Future<List<ProviderSearchResult>> search(
    String query, {
    String? kind,
    int limit = 25,
  });

  /// Fetch full details for a specific item identified by [providerItemId]
  /// and return a standardized [NormalizedProviderEnvelopeV1].
  Future<NormalizedProviderEnvelopeV1> fetchItem(
    String providerItemId, {
    String? kind,
  });
}
