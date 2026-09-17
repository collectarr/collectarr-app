import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/library/kinds/movie/provider/movie_provider_candidates.dart';

CatalogSearchCandidate movieCatalogTransportFromCoreItem(
  CatalogSearchCandidate item,
) {
  return item.mapTransport((transport) {
    final metadata = MovieCatalogMetadata.fromJson(transport.payload);
    return providerCandidateFromTypedPayload(
      kind: item.mediaKind,
      id: item.id,
      payload: metadata.toJson(),
      typedMetadata: metadata,
    );
  });
}

CatalogSearchCandidate movieCatalogTransportFromTypedCandidate(
  MovieProviderCandidate candidate,
) {
  final payload = _candidatePayload(candidate);
  final metadata = MovieCatalogMetadata.fromJson(payload);
  return providerCandidateFromTypedPayload(
    kind: candidate.kind,
    id: candidate.localCatalogId,
    payload: metadata.toJson(),
    typedMetadata: metadata,
  );
}

Map<String, dynamic> _candidatePayload(MovieProviderCandidate candidate) => {
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
