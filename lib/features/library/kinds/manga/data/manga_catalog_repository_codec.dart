import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_codec_support.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_repository.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_media.dart';

final class MangaCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const MangaCatalogRepositoryCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.manga;

  @override
  CatalogItemDto withTypedMetadata(CatalogItemDto item) =>
      item.kindMetadata is Map
          ? item.withKindMetadata(MangaMedia.fromJson(item.payload))
          : item;

  @override
  Future<void> upsert(LocalDatabase db, CatalogItemDto item) {
    return MangaRepository(db).updateMedia(
      MangaMedia.fromJson(catalogPayloadFor(item)),
    );
  }

  @override
  Future<List<CatalogItemDto>> list(LocalDatabase db) async {
    final media = await MangaRepository(db).search();
    return [
      for (final item in media) _projection(item),
    ];
  }
}

CatalogItemDto _projection(MangaMedia item) {
  final payload = item.rawPayload is Map
      ? Map<String, dynamic>.from(item.rawPayload)
      : <String, dynamic>{};
  payload['id'] ??= item.id;
  payload['kind'] ??= 'manga';
  payload['title'] ??= item.title;
  final projection = CatalogItemDto.fromJson(payload);
  return projection.withKindMetadata(MangaMedia.fromJson(projection.payload));
}
