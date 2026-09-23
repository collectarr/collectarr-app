import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/provider/boardgame_provider_candidates.dart';

CatalogSearchCandidate boardGameCatalogTransportFromCoreItem(
  CatalogSearchCandidate item,
) {
  return item.kindCapability.mapTransport((transport) {
    final metadata = BoardGameMetadata.fromJson(transport.payload);
    return item.kindCapability.withKindMetadata(metadata);
  });
}

CatalogSearchCandidate boardGameCatalogTransportFromTypedCandidate(
  BoardGameProviderCandidate candidate,
) {
  final metadata = BoardGameMetadata(
    title: candidate.title,
    synopsis: candidate.summary,
    publishers: candidate.publisher == null ? const [] : [candidate.publisher!],
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
