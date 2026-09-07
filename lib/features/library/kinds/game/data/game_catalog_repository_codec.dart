import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_codec_support.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_repository.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_media.dart';

final class GameCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const GameCatalogRepositoryCodec();

  @override
  String get kind => 'game';

  @override
  CatalogItem withTypedMetadata(CatalogItem item) =>
      catalogItemWithTypedMetadata(item, GameMedia.fromJson);

  @override
  Future<void> upsert(LocalDatabase db, CatalogItem item) {
    return GameRepository(db).updateMedia(
      GameMedia.fromJson(catalogPayloadFor(item)),
    );
  }

  @override
  Future<List<CatalogItem>> list(LocalDatabase db) async {
    final media = await GameRepository(db).search();
    return [
      for (final item in media)
        catalogProjection(
          'game',
          item.id.value,
          item.title,
          item.rawPayload,
          GameMedia.fromJson,
        ),
    ];
  }
}
