import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_codec_support.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_repository.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_media.dart';

final class BoardGameCatalogRepositoryCodec
    implements CatalogKindRepositoryCodec {
  const BoardGameCatalogRepositoryCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.boardgame;

  @override
  CatalogItem withTypedMetadata(CatalogItem item) =>
      catalogItemWithTypedMetadata(item, BoardGameMedia.fromJson);

  @override
  Future<void> upsert(LocalDatabase db, CatalogItem item) {
    return BoardGameRepository(db).updateMedia(
      BoardGameMedia.fromJson(catalogPayloadFor(item)),
    );
  }

  @override
  Future<List<CatalogItem>> list(LocalDatabase db) async {
    final media = await BoardGameRepository(db).search();
    return [
      for (final item in media)
        catalogProjection(
          'boardgame',
          item.id.value,
          item.title,
          item.rawPayload,
          BoardGameMedia.fromJson,
        ),
    ];
  }
}
