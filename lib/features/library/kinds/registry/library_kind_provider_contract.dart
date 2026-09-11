import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_transport.dart';
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

typedef ProviderMetadataItemMapper = CatalogItemDto Function(
  ProviderMetadataEnvelope envelope,
);

typedef ProviderCorrectionBuilder = ProviderCorrectionPatch Function({
  required LibraryAddCatalogTransport preview,
  required LibraryAddCatalogTransport edited,
});

/// Validates the erased provider boundary before a kind-owned mapper runs.
///
/// Provider adapters may use different native DTOs, but every mapping must
/// hand the kind the same minimum identity and title contract.
void validateLibraryKindProviderEnvelope({
  required ProviderMetadataEnvelope envelope,
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
