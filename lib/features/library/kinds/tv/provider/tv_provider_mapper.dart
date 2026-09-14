import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/library/kinds/tv/contracts/tv_contracts.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_metadata_envelope.dart';
import 'tv_provider_typed_mapper.dart';

class TvLibraryKindProviderMapper
    implements TypedLibraryKindProviderMapper<TvCatalog> {
  const TvLibraryKindProviderMapper();

  @override
  TvCatalog catalogFromEnvelope(ProviderMetadataEnvelope envelope) {
    return TvCatalog.fromJson(
      TvProviderTypedMapper.payloadFromEnvelope(envelope),
    );
  }

  CatalogSearchCandidate catalogCandidateFromEnvelope(
    ProviderMetadataEnvelope envelope,
  ) {
    final catalog = catalogFromEnvelope(envelope);
    return providerCandidateFromTypedPayload(
      kind: CatalogMediaKind.tv,
      id: envelope.providerItemId,
      payload: catalog.toJson(),
    );
  }

  ProviderCorrectionPatch buildCorrections({
    required CatalogSearchCandidate preview,
    required CatalogSearchCandidate edited,
  }) {
    final corrections = <String, Object?>{};
    if (edited.title != preview.title) corrections['title'] = edited.title;
    if (edited.synopsis != preview.synopsis) {
      corrections['synopsis'] = edited.synopsis;
    }
    final previewPayload = preview.mapTransport((dto) => dto.payload);
    final editedPayload = edited.mapTransport((dto) => dto.payload);
    for (final entry in editedPayload.entries) {
      if (previewPayload[entry.key] != entry.value) {
        corrections[entry.key] = entry.value;
      }
    }
    return ProviderCorrectionPatch(corrections);
  }
}
