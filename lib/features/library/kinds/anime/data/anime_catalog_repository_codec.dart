import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_codec_support.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';

final class AnimeCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const AnimeCatalogRepositoryCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.anime;

  @override
  CatalogItem withTypedMetadata(CatalogItem item) =>
      catalogItemWithTypedMetadata(item, AnimeMedia.fromJson);

  @override
  Future<void> upsert(LocalDatabase db, CatalogItem item) {
    return AnimeRepository(db).updateMedia(
      AnimeMedia.fromJson(catalogPayloadFor(item)),
    );
  }

  @override
  Future<List<CatalogItem>> list(LocalDatabase db) async {
    final media = await AnimeRepository(db).search();
    return [
      for (final item in media)
        catalogProjection(
          'anime',
          item.id.value,
          item.title,
          item.rawPayload,
          AnimeMedia.fromJson,
        ),
    ];
  }
}
