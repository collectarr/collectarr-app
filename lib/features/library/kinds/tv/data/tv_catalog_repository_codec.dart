import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_codec_support.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';

final class TvCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const TvCatalogRepositoryCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.tv;

  @override
  CatalogItem withTypedMetadata(CatalogItem item) =>
      catalogItemWithTypedMetadata(item, TvSeries.fromJson);

  @override
  Future<void> upsert(LocalDatabase db, CatalogItem item) {
    return TvRepository(db).updateSeries(
      TvSeries.fromJson(catalogPayloadFor(item)),
    );
  }

  @override
  Future<List<CatalogItem>> list(LocalDatabase db) async {
    final media = await TvRepository(db).search();
    return [
      for (final item in media)
        catalogProjection(
          'tv',
          item.id,
          item.title,
          item.rawPayload,
          TvSeries.fromJson,
        ),
    ];
  }
}
