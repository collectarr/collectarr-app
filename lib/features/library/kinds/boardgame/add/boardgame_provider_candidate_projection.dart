import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/providers/transport/provider_candidate.dart';

CatalogSearchCandidate boardGameCatalogTransportFromCoreItem(
  CatalogSearchCandidate item,
) {
  return item.mapTransport((transport) {
    final metadata = BoardGameMetadata.fromJson(transport.payload);
    return providerCandidateFromTypedPayload(
      kind: item.mediaKind,
      id: item.id,
      payload: metadata.toJson(),
      typedMetadata: metadata,
    );
  });
}

CatalogSearchCandidate boardGameCatalogTransportFromProviderCandidate(
  ProviderCandidate candidate,
) {
  final payload = _candidatePayload(candidate);
  final metadata = BoardGameMetadata.fromJson(payload);
  return providerCandidateFromTypedPayload(
    kind: candidate.kind,
    id: candidate.localCatalogId,
    payload: metadata.toJson(),
    typedMetadata: metadata,
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
