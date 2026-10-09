import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_summary_registry.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';

final class LibraryDetailHydrationService {
  const LibraryDetailHydrationService();

  Future<void> hydrate({
    required ApiClient api,
    required LocalDatabase database,
    required CatalogMediaKind kind,
    required String itemId,
  }) async {
    final json = await api.getCatalogItemJson(kind: kind, id: itemId);
    final metadata = libraryMetadataForKind(kind);
    final candidateBuilder = metadata.catalogDetailCandidateBuilder;
    final candidate = candidateBuilder == null
        ? CatalogSearchCandidate.fromApiJson(
            json: json,
            metadataDecoder: metadata.catalogMetadataDecoder,
            summaryBuilder: summarizeCatalogTransportPayload,
          )
        : candidateBuilder(json);
    await CatalogTransportRepository(database)
        .upsertTransports([candidate.toImportTransport()]);
  }
}
