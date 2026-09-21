import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/library/kinds/tv/contracts/tv_contracts.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_raw_envelope.dart';
import 'tv_provider_typed_mapper.dart';
import 'tv_provider_correction_patch.dart';

class TvLibraryKindProviderMapper
    implements TypedLibraryKindProviderMapper<TvCatalog> {
  const TvLibraryKindProviderMapper();

  @override
  TvCatalog catalogFromEnvelope(ProviderRawEnvelope envelope) {
    return TvCatalog.fromJson(
      TvProviderTypedMapper.payloadFromEnvelope(envelope),
    );
  }

  CatalogSearchCandidate catalogCandidateFromEnvelope(
    ProviderRawEnvelope envelope,
  ) {
    final catalog = catalogFromEnvelope(envelope);
    return providerCandidateFromTypedProjection(
      kind: catalog.mediaKind,
      id: catalog.id,
      title: catalog.title,
      synopsis: catalog.synopsis,
      coverImageUrl: catalog.displayCoverUrl,
      releaseDate: catalog.firstAirDate,
      originalTitle: catalog.originalTitle,
      barcode: catalog.releases.firstOrNull?.barcode,
      physicalFormat: catalog.releases.firstOrNull?.seasonOrSeriesBoxSet,
      kindMetadata: catalog,
    );
  }

  ProviderCorrectionPatch buildCorrections({
    required CatalogSearchCandidate preview,
    required CatalogSearchCandidate edited,
  }) {
    return TvProviderCorrectionPatch.fromCandidates(
      preview: preview,
      edited: edited,
    );
  }
}
