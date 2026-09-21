import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
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
  final payload = _candidatePayload(candidate);
  final metadata = MangaMetadata.fromJson(payload);
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

Map<String, dynamic> _candidatePayload(MangaProviderCandidate candidate) => {
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
