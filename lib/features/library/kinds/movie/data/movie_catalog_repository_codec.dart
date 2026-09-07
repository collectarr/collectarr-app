import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_codec_support.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_repository.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';

final class MovieCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const MovieCatalogRepositoryCodec();

  @override
  String get kind => 'movie';

  @override
  CatalogItem withTypedMetadata(CatalogItem item) =>
      catalogItemWithTypedMetadata(item, MovieMedia.fromJson);

  @override
  Future<void> upsert(LocalDatabase db, CatalogItem item) {
    return MovieRepository(db).updateMedia(
      MovieMedia.fromJson(catalogPayloadFor(item)),
    );
  }

  @override
  Future<List<CatalogItem>> list(LocalDatabase db) async {
    final media = await MovieRepository(db).search();
    return [
      for (final item in media)
        catalogProjection(
          'movie',
          item.id.value,
          item.title,
          item.rawPayload,
          MovieMedia.fromJson,
        ),
    ];
  }
}
