import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

/// Kind-owned correction values waiting to cross the admin HTTP boundary.
///
/// A concrete kind owns the typed fields and the diff semantics. The generic
/// orchestration layer only knows that the result can be encoded when it
/// reaches the HTTP transport edge.
abstract interface class ProviderCorrectionPatch {
  bool get isEmpty;
}

final class EmptyProviderCorrectionPatch implements ProviderCorrectionPatch {
  const EmptyProviderCorrectionPatch();

  @override
  bool get isEmpty => true;
}

T requireProviderKindMetadata<T>(CatalogSearchCandidate candidate) {
  final metadata = candidate.kindCapability.mapTransport(
    (transport) => transport.kindMetadata,
  );
  if (metadata is T) return metadata;
  throw StateError(
    'Provider correction requires typed ${T.toString()} metadata for '
    '${candidate.summary.kind.apiValue}:${candidate.reference.id}.',
  );
}

typedef ProviderCorrectionBuilder = ProviderCorrectionPatch Function({
  required CatalogSearchCandidate preview,
  required CatalogSearchCandidate edited,
});

typedef ProviderCorrectionWireEncoder = Map<String, Object?> Function(
  ProviderCorrectionPatch patch,
);
