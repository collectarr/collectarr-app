import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_transport.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';

LibraryAddCatalogTransport mergeProviderAddResult({
  required LibraryAddCatalogTransport ingested,
  required LibraryAddCatalogTransport edited,
}) {
  return ingested
      .copyWith(
        title: edited.title,
        displayTitle: edited.displayTitle ?? ingested.displayTitle,
        localizedTitle: edited.localizedTitle ?? ingested.localizedTitle,
        originalTitle: edited.originalTitle ?? ingested.originalTitle,
        searchAliases: edited.searchAliases ?? ingested.searchAliases,
        sortKey: edited.sortKey ?? ingested.sortKey,
        synopsis: edited.synopsis ?? ingested.synopsis,
        coverImageUrl: edited.coverImageUrl ?? ingested.coverImageUrl,
        thumbnailImageUrl:
            edited.thumbnailImageUrl ?? ingested.thumbnailImageUrl,
        coverImageData: edited.coverImageData ?? ingested.coverImageData,
      )
      .withKindMetadataFrom(edited);
}

LibraryAddCatalogTransport mergeResolvedProviderAddItem({
  required LibraryAddCatalogTransport fallback,
  required LibraryAddCatalogTransport fullItem,
}) {
  return fullItem.displayCoverUrl != null
      ? fullItem
      : fullItem.copyWith(
          coverImageUrl: fallback.coverImageUrl,
          thumbnailImageUrl:
              fallback.thumbnailImageUrl ?? fallback.coverImageUrl,
        );
}

LibraryAddCatalogTransport mergeHydratedProviderAddResult({
  required LibraryAddCatalogTransport hydrated,
  required LibraryAddCatalogTransport sourceSelection,
}) {
  if (hydrated.editions.isNotEmpty || sourceSelection.editions.isEmpty) {
    return hydrated;
  }
  return hydrated.copyWith(editions: sourceSelection.editions);
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
