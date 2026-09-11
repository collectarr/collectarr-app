import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/providers/transport/provider_candidate.dart';

CatalogSearchCandidate movieCatalogTransportFromCoreItem(
  CatalogSearchCandidate item,
) {
  return item.mapTransport(
    (transport) => CatalogSearchCandidate.fromItem(
      transport.withKindMetadata(
        MovieCatalogMetadata.fromJson(transport.payload),
      ),
    ),
  );
}

CatalogSearchCandidate movieCatalogTransportFromProviderCandidate(
  ProviderCandidate candidate,
) {
  final payload = _candidatePayload(candidate);
  final item = CatalogItemDto.fromJson(payload);
  return CatalogSearchCandidate.fromItem(
    item.withKindMetadata(MovieCatalogMetadata.fromJson(payload)),
  );
}

Map<String, dynamic> _candidatePayload(ProviderCandidate candidate) => {
      'id': candidate.localCatalogId,
      'kind': candidate.kind.apiValue,
      'title': candidate.title,
      'item_number': candidate.issueNumber,
      'issue_number': candidate.issueNumber,
      'synopsis': candidate.summary,
      'cover_image_url': candidate.imageUrl,
      'variant': candidate.variantName,
      'publisher': candidate.publisher,
      if (candidate.series != null)
        'series_title': candidate.series!.seriesTitle,
      if (candidate.series != null)
        'volume_start_year': candidate.series!.volumeStartYear,
      if (candidate.series != null)
        'release_year': candidate.series!.volumeStartYear,
    };
