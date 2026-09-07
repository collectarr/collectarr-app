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
  Object? typedMetadataFromDto(CatalogItemDto item) {
    final metadata = item.kindMetadata;
    if (metadata is MusicRelease) return metadata;
    return metadata is Map ? MusicRelease.fromJson(item.payload) : null;
  }

  @override
  CatalogItemDto withTypedMetadata(CatalogItemDto item) =>
      switch (typedMetadataFromDto(item)) {
        final metadata? => item.withKindMetadata(metadata),
        _ => item,
      };

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
      for (final item in releases) _projection(item),
    ];
  }
}

CatalogItemDto _projection(MusicRelease item) {
  final payload = item.rawPayload is Map
      ? Map<String, dynamic>.from(item.rawPayload)
      : <String, dynamic>{};
  payload['id'] ??= item.id.value;
  payload['kind'] ??= 'music';
  payload['title'] ??= item.title;
  final projection = CatalogItemDto.fromJson(payload);
  return projection.withKindMetadata(MusicRelease.fromJson(projection.payload));
}
