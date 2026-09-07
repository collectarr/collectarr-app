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
  CatalogItem withTypedMetadata(CatalogItem item) =>
      catalogItemWithTypedMetadata(item, MangaMedia.fromJson);

  @override
  Future<void> upsert(LocalDatabase db, CatalogItem item) {
    return MangaRepository(db).updateMedia(
      MangaMedia.fromJson(catalogPayloadFor(item)),
    );
  }

  @override
  Future<List<CatalogItem>> list(LocalDatabase db) async {
    final media = await MangaRepository(db).search();
    return [
      for (final item in media)
        catalogProjection(
          'manga',
          item.id,
          item.title,
          item.rawPayload,
          MangaMedia.fromJson,
        ),
    ];
  }
}
