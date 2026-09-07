import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_codec_support.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';

final class ComicCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const ComicCatalogRepositoryCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.comic;

  @override
  CatalogItem withTypedMetadata(CatalogItem item) =>
      catalogItemWithTypedMetadata(item, ComicMedia.fromJson);

  @override
  Future<void> upsert(LocalDatabase db, CatalogItem item) {
    return ComicRepository(db).updateMedia(
      ComicMedia.fromJson(catalogPayloadFor(item)),
    );
  }

  @override
  Future<List<CatalogItem>> list(LocalDatabase db) async {
    final media = await ComicRepository(db).search();
    return [
      for (final item in media)
        catalogProjection(
          'comic',
          item.id?.value,
          item.title,
          item.rawPayload,
          ComicMedia.fromJson,
        ),
    ];
  }
}
