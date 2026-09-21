import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/library/kinds/manga/provider/manga_provider_candidates.dart';

CatalogSearchCandidate mangaCatalogTransportFromCoreItem(
  CatalogSearchCandidate item,
) {
  return item.mapTransport((transport) {
    final metadata = MangaMetadata.fromJson(transport.payload);
    return item.withKindMetadata(metadata);
  });
}

CatalogSearchCandidate mangaCatalogTransportFromTypedCandidate(
  MangaProviderCandidate candidate,
) {
  final metadata = MangaMetadata(
    title: candidate.title,
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
    rawPayload: {
      if (candidate.imageUrl != null) 'cover_image_url': candidate.imageUrl,
    },
  );
  return providerCandidateFromTypedProjection(
    kind: candidate.kind,
    id: candidate.localCatalogId,
    title: candidate.title,
    synopsis: candidate.summary,
    coverImageUrl: candidate.imageUrl,
    publisher: candidate.publisher,
    itemNumber: candidate.issueNumber,
    variant: candidate.variantName,
    kindMetadata: metadata,
  );
}
