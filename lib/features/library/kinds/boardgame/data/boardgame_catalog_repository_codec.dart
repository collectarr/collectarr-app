import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
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
  Object? typedMetadataFromDto(CatalogItemDto item) {
    final metadata = item.kindMetadata;
    if (metadata is BoardGameMedia) return metadata;
    return metadata is Map ? BoardGameMedia.fromJson(item.payload) : null;
  }

  @override
  CatalogItemDto withTypedMetadata(CatalogItemDto item) =>
      switch (typedMetadataFromDto(item)) {
        final metadata? => item.withKindMetadata(metadata),
        _ => item,
      };

  @override
  Future<void> upsert(LocalDatabase db, CatalogItemDto item) {
    return BoardGameRepository(db).updateMedia(
      BoardGameMedia.fromJson(catalogPayloadFor(item)),
    );
  }

  @override
  Future<List<CatalogItemDto>> list(LocalDatabase db) async {
    final media = await BoardGameRepository(db).search();
    return [
      for (final item in media) _projection(item),
    ];
  }
}

CatalogItemDto _projection(BoardGameMedia item) {
  final payload = item.rawPayload is Map
      ? Map<String, dynamic>.from(item.rawPayload)
      : <String, dynamic>{};
  payload['id'] ??= item.id.value;
  payload['kind'] ??= 'boardgame';
  payload['title'] ??= item.title;
  final projection = CatalogItemDto.fromJson(payload);
  return projection.withKindMetadata(
    BoardGameMedia.fromJson(projection.payload),
  );
}
