import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_metadata_envelope.dart';

/// Kind-owned correction values waiting to cross the admin HTTP boundary.
///
/// The keys are interpreted only by the owning kind while constructing the
/// patch. Generic orchestration treats the patch as opaque transport data.
final class ProviderCorrectionPatch {
  const ProviderCorrectionPatch(this.fields);

  const ProviderCorrectionPatch.empty() : fields = const {};

  final Map<String, Object?> fields;

  bool get isEmpty => fields.isEmpty;
}

/// Typed kind-owned provider mapping contract.
///
/// The provider layer owns transport and native DTOs. A kind owns the
/// semantic mapping from the normalized provider boundary into its concrete
/// catalog representation. The API/transport projections used by Add and
/// admin are registered as tear-off functions at the composition root; they
/// are not part of this typed domain contract.
abstract interface class TypedLibraryKindProviderMapper<TCatalog> {
  TCatalog catalogFromEnvelope(ProviderMetadataEnvelope envelope);
}

typedef ProviderMetadataCandidateMapper = CatalogSearchCandidate Function(
  ProviderMetadataEnvelope envelope,
);

/// Re-enters the generic search transport only after a kind has completed its
/// typed provider mapping. The payload is serialized once at this boundary;
/// generic Add code receives a structural candidate and never a Core DTO.
CatalogSearchCandidate providerCandidateFromTypedPayload({
  required CatalogMediaKind kind,
  required String id,
  required Map<String, dynamic> payload,
  JsonEncodable? typedMetadata,
}) {
  final candidate = CatalogSearchCandidate.fromJson({
    ...payload,
    'id': id,
    'kind': kind.apiValue,
  });
  if (typedMetadata == null) return candidate;
  return candidate.mapTransport(
    (transport) => CatalogSearchCandidate.fromItem(
      transport.withKindMetadata(typedMetadata),
    ),
  );
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
  required ProviderMetadataEnvelope envelope,
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
  final title = envelope.normalized['title']?.toString().trim();
  if (title == null || title.isEmpty) {
    throw StateError(
      '${expectedKind.apiValue} provider integration received an envelope without a title',
    );
  }
}
