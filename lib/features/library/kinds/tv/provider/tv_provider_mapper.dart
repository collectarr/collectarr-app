import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/library/kinds/tv/contracts/tv_contracts.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_raw_envelope.dart';
import 'tv_provider_typed_mapper.dart';

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
      publisher: catalog.publisher,
      barcode: catalog.releases.firstOrNull?.barcode,
      physicalFormat: catalog.releases.firstOrNull?.seasonOrSeriesBoxSet,
      transportPayload: envelope.payload.toJson(),
      kindMetadata: catalog,
    );
  }

  ProviderCorrectionPatch buildCorrections({
    required CatalogSearchCandidate preview,
    required CatalogSearchCandidate edited,
  }) {
    return buildProviderCommonCorrections(
      preview: preview,
      edited: edited,
    );
  }
}
