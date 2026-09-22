import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/provider/comic_provider_candidates.dart';

CatalogSearchCandidate comicCatalogTransportFromCoreItem(
  CatalogSearchCandidate item,
) {
  return item.mapTransport((transport) {
    final metadata = ComicMedia.fromJson(transport.payload);
    return item.withKindMetadata(metadata);
  });
}

CatalogSearchCandidate comicCatalogTransportFromTypedCandidate(
  ComicProviderCandidate candidate,
) {
  final metadata = ComicMedia(
    title: candidate.title,
    synopsis: candidate.summary,
    issueNumber: candidate.issueNumber,
    publisher: candidate.publisher,
    variant: candidate.variantName,
    seriesTitle: candidate.series?.seriesTitle,
    series: candidate.series == null
        ? null
        : CatalogSeriesDetailsDto(
            seriesTitle: candidate.series!.seriesTitle,
            volumeStartYear: candidate.series!.volumeStartYear,
          ),
    rawPayload: {
      if (candidate.imageUrl != null) 'cover_image_url': candidate.imageUrl,
    },
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
