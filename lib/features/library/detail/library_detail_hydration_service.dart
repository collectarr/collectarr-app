import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/music/data/remote/catalog_music_item_dto.dart';

final class LibraryDetailHydrationService {
  const LibraryDetailHydrationService();

  Future<void> hydrate({
    required ApiClient api,
    required LocalDatabase database,
    required CatalogMediaKind kind,
    required String itemId,
  }) async {
    final json = await api.getCatalogItemJson(kind: kind, id: itemId);
    final candidate = kind == CatalogMediaKind.music
        ? _musicCandidate(json)
        : CatalogSearchCandidate.fromApiJson(
            json: json,
            metadataDecoder:
                libraryMetadataForKind(kind).catalogMetadataDecoder,
          );
    await CatalogTransportRepository(database)
        .upsertTransports([candidate.kindCapability.toImportTransport()]);
  }

  CatalogSearchCandidate _musicCandidate(Map<String, dynamic> json) {
    final music = CatalogMusicItemDto.fromJson(json);
    final item = CatalogItemDto.raw(
      id: music.id,
      mediaKind: CatalogMediaKind.music,
      common: CatalogCommonDto.fromJson(json),
      kindMetadata: music,
    );
    return CatalogSearchCandidate.fromItem(item);
  }
}
