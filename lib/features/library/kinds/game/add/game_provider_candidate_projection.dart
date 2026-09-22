import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/provider/game_provider_candidates.dart';

CatalogSearchCandidate gameCatalogTransportFromCoreItem(
  CatalogSearchCandidate item,
) {
  return item.mapTransport((transport) {
    final metadata = GameCatalogMetadata.fromJson(transport.payload);
    return item.withKindMetadata(metadata);
  });
}

CatalogSearchCandidate gameCatalogTransportFromTypedCandidate(
  GameProviderCandidate candidate,
) {
  final metadata = GameCatalogMetadata(
    title: candidate.title,
    synopsis: candidate.summary,
    publishers: candidate.publisher == null ? const [] : [candidate.publisher!],
    edition: candidate.variantName,
    series: candidate.series?.seriesTitle,
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
