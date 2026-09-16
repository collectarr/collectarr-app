import 'package:flutter/foundation.dart';

import '../domain/models/library_entity_scope.dart';
import '../domain/models/provider_attribution.dart';
import '../domain/models/provider_image_candidate.dart';
import '../domain/models/provider_provenance.dart';

/// Structural provider envelope.  Its payload is a typed candidate, never a
/// semantic JSON map.
@immutable
final class ProviderEnvelope<TPayload> {
  const ProviderEnvelope({
    this.schemaVersion = 'v1',
    required this.provider,
    required this.providerItemId,
    required this.entityScope,
    required this.payload,
    required this.provenance,
    this.images = const <ProviderImageCandidate>[],
    this.attribution,
  });

  final String schemaVersion;
  final String provider;
  final String providerItemId;
  final LibraryEntityScope entityScope;
  final TPayload payload;
  final ProviderProvenance provenance;
  final List<ProviderImageCandidate> images;
  final ProviderAttribution? attribution;
}
