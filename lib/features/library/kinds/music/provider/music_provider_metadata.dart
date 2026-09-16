import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_candidates.dart';
import 'package:collectarr_app/features/providers/domain/models/library_entity_scope.dart';
import 'package:collectarr_app/features/providers/transport/provider_envelope.dart';

/// Music-owned provider transport.
///
/// Music metadata never crosses the provider boundary as the shared
/// cross-kind candidate. The payload is a typed Music release or release
/// group, and the Add host adapts it only after it has reached the kind
/// integration.
abstract interface class MusicProviderMetadataCapability {
  Future<List<MusicProviderCandidate>> searchCandidates(
    String query, {
    required CatalogMediaKind kind,
    required LibraryEntityScope entityScope,
    int limit = 25,
  });

  Future<ProviderEnvelope<MusicProviderCandidate>> fetchCandidate(
    String providerItemId,
  );
}
