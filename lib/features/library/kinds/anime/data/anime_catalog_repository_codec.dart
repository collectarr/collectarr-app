import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_codec_support.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';

final class AnimeCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const AnimeCatalogRepositoryCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.anime;

  @override
  CatalogItemDto withTypedMetadata(CatalogItemDto item) =>
      item.kindMetadata is Map
          ? item.withKindMetadata(AnimeMedia.fromJson(item.payload))
          : item;

  @override
  Future<void> upsert(LocalDatabase db, CatalogItemDto item) {
    return AnimeRepository(db).updateMedia(
      AnimeMedia.fromJson(catalogPayloadFor(item)),
    );
  }

  @override
  Future<List<CatalogItemDto>> list(LocalDatabase db) async {
    final media = await AnimeRepository(db).search();
    return [
      for (final item in media) _projection(item),
    ];
  }
}

CatalogItemDto _projection(AnimeMedia item) {
  final payload = item.rawPayload is Map
      ? Map<String, dynamic>.from(item.rawPayload)
      : <String, dynamic>{};
  payload['id'] ??= item.id.value;
  payload['kind'] ??= 'anime';
  payload['title'] ??= item.title;
  final projection = CatalogItemDto.fromJson(payload);
  return projection.withKindMetadata(AnimeMedia.fromJson(projection.payload));
}
