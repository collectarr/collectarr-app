import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';

final class LibraryDetailHydrationService {
  const LibraryDetailHydrationService();

  Future<void> hydrate({
    required ApiClient api,
    required LocalDatabase database,
    required CatalogMediaKind kind,
    required String itemId,
  }) async {
    final dto = await api.getTypedMetadataItem(kind: kind, id: itemId);
    final candidate = CatalogSearchCandidate.fromJson({
      ...dto.raw,
      'id': dto.id,
      'title': dto.title,
      'kind': dto.kind,
    });
    await CatalogTransportRepository(database)
        .upsertTransports([candidate.kindCapability.toImportTransport()]);
  }
}
