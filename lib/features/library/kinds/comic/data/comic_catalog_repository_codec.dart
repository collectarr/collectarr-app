import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_codec_support.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';

final class ComicCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const ComicCatalogRepositoryCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.comic;

  @override
  Object? typedMetadataFromDto(CatalogItemDto item) {
    final metadata = item.kindMetadata;
    if (metadata is ComicMedia) return metadata;
    return metadata is Map ? ComicMedia.fromJson(item.payload) : null;
  }

  @override
  CatalogItemDto withTypedMetadata(CatalogItemDto item) =>
      switch (typedMetadataFromDto(item)) {
        final metadata? => item.withKindMetadata(metadata),
        _ => item,
      };

  @override
  Future<void> upsert(LocalDatabase db, CatalogItemDto item) {
    return ComicRepository(db).updateMedia(
      ComicMedia.fromJson(catalogPayloadFor(item)),
    );
  }

  @override
  Future<List<CatalogItemDto>> list(LocalDatabase db) async {
    final media = await ComicRepository(db).search();
    return [
      for (final item in media) _projection(item),
    ];
  }

  @override
  Future<List<CatalogDisplaySummary>> listSummaries(LocalDatabase db) async {
    final media = await ComicRepository(db).search();
    return [
      for (final item in media)
        CatalogDisplaySummary.work(
          kind: kind,
          id: item.id?.value ?? '',
          title: item.title,
        ),
    ];
  }
}

CatalogItemDto _projection(ComicMedia item) {
  final payload = Map<String, dynamic>.from(item.rawPayload);
  payload['id'] ??= item.id?.value ?? '';
  payload['kind'] ??= 'comic';
  payload['title'] ??= item.title;
  final projection = CatalogItemDto.fromJson(payload);
  return projection.withKindMetadata(ComicMedia.fromJson(projection.payload));
}
