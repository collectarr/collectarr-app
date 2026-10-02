import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/catalog/library_catalog_registry.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';

final class LibraryAddHydrationService {
  const LibraryAddHydrationService();

  Future<CatalogSearchCandidate> hydrateCatalogCandidate({
    required ApiClient api,
    required LibraryKindRegistration type,
    required CatalogSearchCandidate fallback,
    required String itemId,
  }) async {
    if (libraryMetadataForKind(type.kind).catalogSearchResultsAreDetailed) {
      return fallback;
    }
    final json = await api.getCatalogItemJson(
      kind: fallback.summary.kind,
      id: itemId,
    );
    return CatalogSearchCandidate.fromApiJson(
      json: json,
      metadataDecoder: libraryMetadataForKind(type.kind).catalogMetadataDecoder,
      summaryBuilder: summarizeCatalogTransport,
    );
  }
}
