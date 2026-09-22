import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
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
    return providerCandidateFromTypedTransport(
      CatalogItemDto.raw(
        id: catalog.id,
        mediaKind: catalog.mediaKind,
        common: CatalogCommonDto(
          title: catalog.title,
          originalTitle: catalog.originalTitle,
          synopsis: catalog.synopsis,
          coverImageUrl: catalog.displayCoverUrl,
          releaseDate: catalog.firstAirDate,
        ),
        payload: const <String, dynamic>{},
        kindMetadata: catalog,
      ),
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
