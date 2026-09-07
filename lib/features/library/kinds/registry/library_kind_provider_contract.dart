import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';

/// Structural contract for a kind-owned provider mapper.
///
/// The provider layer owns transport and native DTOs. A kind owns the
/// semantic mapping from the normalized provider boundary into its catalog
/// representation and correction payload.
abstract interface class LibraryKindProviderMapper {
  CatalogItemDto metadataItemFromEnvelope(NormalizedProviderEnvelopeV1 envelope);

  Map<String, Object?> buildCorrections({
    required CatalogItemDto preview,
    required CatalogItemDto edited,
  });
}

abstract interface class TypedLibraryKindProviderMapper<TCatalog>
    implements LibraryKindProviderMapper {
  TCatalog catalogFromEnvelope(NormalizedProviderEnvelopeV1 envelope);
}

/// Validates the erased provider boundary before a kind-owned mapper runs.
///
/// Provider adapters may use different native DTOs, but every mapping must
/// hand the kind the same minimum identity and title contract.
void validateLibraryKindProviderEnvelope({
  required NormalizedProviderEnvelopeV1 envelope,
  required CatalogMediaKind expectedKind,
}) {
  final actualKind = catalogMediaKindFromApiValue(envelope.kind);
  if (actualKind != expectedKind) {
    throw StateError(
      '${expectedKind.apiValue} provider integration received ${envelope.kind} data',
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
