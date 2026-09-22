import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/providers/library_provider_registry.dart';

CatalogSearchCandidate mergeProviderAddResult({
  required CatalogSearchCandidate ingested,
  required CatalogSearchCandidate edited,
}) {
  final ingestedMetadata = ingested.editMetadata;
  final editedMetadata = edited.editMetadata;
  final merged = ingested.copyWith(
    title: edited.title,
    displayTitle: editedMetadata.displayTitle ?? ingestedMetadata.displayTitle,
    localizedTitle:
        editedMetadata.localizedTitle ?? ingestedMetadata.localizedTitle,
    originalTitle:
        editedMetadata.originalTitle ?? ingestedMetadata.originalTitle,
    searchAliases: editedMetadata.searchAliases.isNotEmpty
        ? editedMetadata.searchAliases
        : ingestedMetadata.searchAliases,
    sortKey: editedMetadata.sortKey ?? ingestedMetadata.sortKey,
    synopsis: editedMetadata.synopsis ?? ingestedMetadata.synopsis,
    coverImageUrl:
        editedMetadata.coverImageUrl ?? ingestedMetadata.coverImageUrl,
    thumbnailImageUrl:
        editedMetadata.thumbnailImageUrl ?? ingestedMetadata.thumbnailImageUrl,
    coverImageData:
        editedMetadata.coverImageData ?? ingestedMetadata.coverImageData,
  );
  return edited.mapTransport(
    (transport) => CatalogSearchCandidate.fromItem(
      merged.mapTransport(
        (mergedTransport) => mergedTransport.withKindMetadata(
          transport.kindMetadata,
        ),
      ),
    ),
  );
}

CatalogSearchCandidate mergeResolvedProviderAddItem({
  required CatalogSearchCandidate fallback,
  required CatalogSearchCandidate fullItem,
}) {
  final fullMetadata = fullItem.editMetadata;
  final fallbackMetadata = fallback.editMetadata;
  return fullMetadata.coverImageUrl != null
      ? fullItem
      : fullItem.copyWith(
          coverImageUrl: fallbackMetadata.coverImageUrl,
          thumbnailImageUrl: fallbackMetadata.thumbnailImageUrl ??
              fallbackMetadata.coverImageUrl,
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
  final mediaKind = catalogMediaKindFromValue(kind);
  return api.adminUpdateCatalogItemFields(
    kind: kind,
    id: itemId,
    fields: providerCorrectionWireEncoderForKind(mediaKind)(corrections),
  );
}
