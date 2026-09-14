import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';

CatalogSearchCandidate mergeProviderAddResult({
  required CatalogSearchCandidate ingested,
  required CatalogSearchCandidate edited,
}) {
  final merged = ingested.copyWith(
    title: edited.title,
    displayTitle: edited.displayTitle ?? ingested.displayTitle,
    localizedTitle: edited.localizedTitle ?? ingested.localizedTitle,
    originalTitle: edited.originalTitle ?? ingested.originalTitle,
    searchAliases: edited.searchAliases ?? ingested.searchAliases,
    sortKey: edited.sortKey ?? ingested.sortKey,
    synopsis: edited.synopsis ?? ingested.synopsis,
    coverImageUrl: edited.coverImageUrl ?? ingested.coverImageUrl,
    thumbnailImageUrl: edited.thumbnailImageUrl ?? ingested.thumbnailImageUrl,
    coverImageData: edited.coverImageData ?? ingested.coverImageData,
  );
  return edited.mapTransport(
    (transport) => CatalogSearchCandidate.fromItem(
      merged.mapTransport(
        (mergedTransport) =>
            mergedTransport.withKindMetadata(transport.kindMetadata),
      ),
    ),
  );
}

CatalogSearchCandidate mergeResolvedProviderAddItem({
  required CatalogSearchCandidate fallback,
  required CatalogSearchCandidate fullItem,
}) {
  return fullItem.displayCoverUrl != null
      ? fullItem
      : fullItem.copyWith(
          coverImageUrl: fallback.coverImageUrl,
          thumbnailImageUrl:
              fallback.thumbnailImageUrl ?? fallback.coverImageUrl,
        );
}

CatalogSearchCandidate mergeHydratedProviderAddResult({
  required CatalogSearchCandidate hydrated,
  required CatalogSearchCandidate sourceSelection,
}) {
  final hydratedEditions =
      hydrated.mapTransport((transport) => transport.editions);
  final sourceEditions =
      sourceSelection.mapTransport((transport) => transport.editions);
  if (hydratedEditions.isNotEmpty || sourceEditions.isEmpty) {
    return hydrated;
  }
  return hydrated.copyWith(editions: sourceEditions);
}

Future<void> submitProviderIngestCorrections({
  required ApiClient api,
  required String kind,
  required String itemId,
  required ProviderCorrectionPatch corrections,
}) {
  return api.adminUpdateCatalogItemFields(
    kind: kind,
    id: itemId,
    fields: corrections.fields,
  );
}
