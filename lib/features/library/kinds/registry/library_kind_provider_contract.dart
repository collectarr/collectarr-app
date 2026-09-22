import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_raw_envelope.dart';
import 'package:collectarr_app/features/providers/transport/provider_patch.dart';

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

/// Common typed correction surface shared by non-Music provider kinds.
///
/// The fields remain typed until the HTTP edge. This interface exists only so
/// that the edge encoder can handle the common part without making every kind
/// expose a map-shaped correction.
abstract interface class CommonProviderCorrectionPatch
    implements ProviderCorrectionPatch {
  ProviderPatch<String> get title;
  ProviderPatch<String> get synopsis;
  ProviderPatch<String> get coverImageUrl;
  ProviderPatch<String> get publisher;
  ProviderPatch<String> get barcode;
  ProviderPatch<String> get physicalFormat;
  ProviderPatch<String> get physicalFormatLabel;
  ProviderPatch<String> get editionTitle;
  ProviderPatch<String> get itemNumber;
  ProviderPatch<String> get variant;
  ProviderPatch<DateTime> get releaseDate;
}

/// Typed kind-owned provider mapping contract.
///
/// The provider layer owns transport and native DTOs. A kind owns the
/// semantic mapping from the normalized provider boundary into its concrete
/// catalog representation. The API/transport projections used by Add and
/// admin are registered as tear-off functions at the composition root; they
/// are not part of this typed domain contract.
abstract interface class TypedLibraryKindProviderMapper<TCatalog> {
  TCatalog catalogFromEnvelope(ProviderRawEnvelope envelope);
}

typedef ProviderMetadataCandidateMapper = CatalogSearchCandidate Function(
  ProviderRawEnvelope envelope,
);

T requireProviderKindMetadata<T>(CatalogSearchCandidate candidate) {
  final metadata = candidate.mapTransport(
    (transport) => transport.kindMetadata,
  );
  if (metadata is T) return metadata;
  throw StateError(
    'Provider correction requires typed ${T.toString()} metadata for '
    '${candidate.kind.apiValue}:${candidate.id}.',
  );
}

/// Re-enters the mixed search transport only after a kind has completed its
/// typed mapping. Semantic construction happens in the kind-owned mapper;
/// this boundary only wraps the resulting catalog transport.
CatalogSearchCandidate providerCandidateFromTypedTransport(
  CatalogItemDto transport,
) {
  return CatalogSearchCandidate.fromItem(transport);
}

typedef ProviderCorrectionBuilder = ProviderCorrectionPatch Function({
  required CatalogSearchCandidate preview,
  required CatalogSearchCandidate edited,
});

/// Validates the erased provider boundary before a kind-owned mapper runs.
///
/// Provider adapters may use different native DTOs, but every mapping must
/// hand the kind the same minimum identity and title contract.
void validateLibraryKindProviderEnvelope({
  required ProviderRawEnvelope envelope,
  required CatalogMediaKind expectedKind,
}) {
  final actualKind = envelope.kind;
  if (actualKind != expectedKind) {
    throw StateError(
      '${expectedKind.apiValue} provider integration received ${envelope.kind.apiValue} data',
    );
  }
  if (envelope.provider.trim().isEmpty) {
    throw StateError(
      '${expectedKind.apiValue} provider integration received an envelope without a provider',
    );
  }
  if (envelope.providerItemId.trim().isEmpty) {
    throw StateError(
      '${expectedKind.apiValue} provider integration received an envelope without a provider item ID',
    );
  }
  final title = envelope.payload['title']?.toString().trim();
  if (title == null || title.isEmpty) {
    throw StateError(
      '${expectedKind.apiValue} provider integration received an envelope without a title',
    );
  }
}
