import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_codec_support.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';

final class MusicCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const MusicCatalogRepositoryCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;

  @override
  CatalogItemDto withTypedMetadata(CatalogItemDto item) =>
      catalogItemWithTypedMetadata(item, MusicRelease.fromJson);

  @override
  Future<void> upsert(LocalDatabase db, CatalogItemDto item) {
    return MusicRepository(db).updateRelease(
      MusicRelease.fromJson(catalogPayloadFor(item)),
    );
  }

  @override
  Future<List<CatalogItemDto>> list(LocalDatabase db) async {
    final releases = await MusicRepository(db).search();
    return [
      for (final item in releases)
        catalogProjection(
          'music',
          item.id.value,
          item.title,
          item.rawPayload,
          MusicRelease.fromJson,
        ),
    ];
  }
}
