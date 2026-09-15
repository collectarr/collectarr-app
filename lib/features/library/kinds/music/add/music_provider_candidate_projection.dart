import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/providers/transport/provider_candidate.dart';

CatalogSearchCandidate musicCatalogTransportFromCoreItem(
  CatalogSearchCandidate item,
) {
  return item.mapTransport((transport) {
    final group = MusicCatalogMapper.mapMetadataItemToMusic(transport);
    return providerCandidateFromTypedPayload(
      kind: item.mediaKind,
      id: item.id,
      payload: group.toJson(),
      typedMetadata: group,
    );
  });
}

CatalogSearchCandidate musicCatalogTransportFromProviderCandidate(
  ProviderCandidate candidate,
) {
  final payload = _candidatePayload(candidate);
  final group = MusicCatalogMapper.mapMetadataItemToMusic(
    CatalogItemDto.fromJson(payload),
  );
  return providerCandidateFromTypedPayload(
    kind: candidate.kind,
    id: candidate.localCatalogId,
    payload: group.toJson(),
    typedMetadata: group,
  );
}

Map<String, dynamic> _candidatePayload(ProviderCandidate candidate) => {
      'id': candidate.localCatalogId,
      'kind': candidate.kind.apiValue,
      'title': candidate.parent?.title ?? candidate.title,
      if (candidate.parent != null) 'release_group_id': candidate.parent!.id,
      if (candidate.parent != null)
        'release_group_title': candidate.parent!.title,
      if (candidate.candidateType == 'release_group')
        'entity_type': 'music_release_group',
      if (candidate.candidateType != 'release_group')
        'releases': [
          {
            'id': candidate.providerItemId,
            'title': candidate.title,
            'release_group_id':
                candidate.parent?.id ?? candidate.localCatalogId,
          },
        ],
      'item_number': candidate.issueNumber,
      'issue_number': candidate.issueNumber,
      'synopsis': candidate.summary,
      'cover_image_url': candidate.imageUrl,
      if (candidate.mediumTypes.isNotEmpty)
        'medium_types': candidate.mediumTypes,
      if (candidate.mediumTypes.isNotEmpty)
        'format': candidate.mediumTypes.first,
      'variant': candidate.variantName,
      'publisher': candidate.publisher,
      if (candidate.artist != null) 'artist': candidate.artist,
      if (candidate.series != null)
        'series_title': candidate.series!.seriesTitle,
      if (candidate.series != null)
        'volume_start_year': candidate.series!.volumeStartYear,
      if (candidate.series != null)
        'release_year': candidate.series!.volumeStartYear,
    };
