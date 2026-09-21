import '../../../domain/models/provider_attribution.dart';
import '../../../domain/models/provider_provenance.dart';

/// MusicBrainz protocol response with provider metadata retained at the wire
/// boundary. The Music kind integration owns the semantic mapping that turns
/// this response into a Music candidate.
final class MusicBrainzWireResponse<TPayload> {
  const MusicBrainzWireResponse({
    required this.providerItemId,
    required this.payload,
    required this.provenance,
    required this.attribution,
  });

  final String providerItemId;
  final TPayload payload;
  final ProviderProvenance provenance;
  final ProviderAttribution attribution;
}
