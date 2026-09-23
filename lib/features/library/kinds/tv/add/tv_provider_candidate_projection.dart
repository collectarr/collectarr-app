import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/provider/tv_provider_candidates.dart';

CatalogSearchCandidate tvCatalogTransportFromCoreItem(
  CatalogSearchCandidate item,
) {
  return item.kindCapability.mapTransport((transport) {
    final metadata = TvSeriesMetadata.fromJson(transport.payload);
    return item.kindCapability.withKindMetadata(metadata);
  });
}

CatalogSearchCandidate tvCatalogTransportFromTypedCandidate(
  TvProviderCandidate candidate,
) {
  final metadata = TvSeriesMetadata(
    title: candidate.title,
    synopsis: candidate.summary,
    publisher: candidate.publisher,
    itemNumber: candidate.issueNumber,
    variant: candidate.variantName,
    seriesTitle: candidate.series?.seriesTitle,
    series: candidate.series == null
        ? null
        : CatalogSeriesDetailsDto(
            seriesTitle: candidate.series!.seriesTitle,
            volumeStartYear: candidate.series!.volumeStartYear,
          ),
  );
  return CatalogSearchCandidate.fromItem(
    CatalogItemDto.raw(
      id: candidate.localCatalogId,
      mediaKind: candidate.kind,
      common: CatalogCommonDto(
        title: candidate.title,
        synopsis: candidate.summary,
        coverImageUrl: candidate.imageUrl,
      ),
      kindMetadata: metadata,
    ),
  );
}
