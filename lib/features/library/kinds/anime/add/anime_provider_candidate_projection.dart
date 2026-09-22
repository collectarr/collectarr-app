import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/anime/provider/anime_provider_candidates.dart';

CatalogSearchCandidate animeCatalogTransportFromCoreItem(
  CatalogSearchCandidate item,
) {
  return item.mapTransport((transport) {
    final metadata = AnimeMetadata.fromJson(transport.payload);
    return item.withKindMetadata(metadata);
  });
}

CatalogSearchCandidate animeCatalogTransportFromTypedCandidate(
  AnimeProviderCandidate candidate,
) {
  final metadata = AnimeMetadata(
    title: candidate.title,
    itemNumber: candidate.issueNumber,
    publisher: candidate.publisher,
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
