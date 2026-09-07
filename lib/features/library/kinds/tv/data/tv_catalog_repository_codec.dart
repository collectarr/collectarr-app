import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_codec_support.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';

final class TvCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const TvCatalogRepositoryCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.tv;

  @override
  Object? typedMetadataFromDto(CatalogItemDto item) {
    final metadata = item.kindMetadata;
    if (metadata is TvSeries) return metadata;
    return metadata is Map ? TvSeries.fromJson(item.payload) : null;
  }

  @override
  CatalogItemDto withTypedMetadata(CatalogItemDto item) =>
      switch (typedMetadataFromDto(item)) {
        final metadata? => item.withKindMetadata(metadata),
        _ => item,
      };

  @override
  Future<void> upsert(LocalDatabase db, CatalogItemDto item) {
    return TvRepository(db).updateSeries(
      TvSeries.fromJson(catalogPayloadFor(item)),
    );
  }

  @override
  Future<List<CatalogItemDto>> list(LocalDatabase db) async {
    final media = await TvRepository(db).search();
    return [
      for (final item in media) _projection(item),
    ];
  }

  @override
  Future<List<CatalogDisplaySummary>> listSummaries(LocalDatabase db) async {
    final series = await TvRepository(db).search();
    return [
      for (final item in series)
        CatalogDisplaySummary.work(
          kind: kind,
          id: item.id,
          title: item.title,
        ),
    ];
  }
}

CatalogItemDto _projection(TvSeries item) {
  final payload = Map<String, dynamic>.from(item.rawPayload);
  payload['id'] ??= item.id;
  payload['kind'] ??= 'tv';
  payload['title'] ??= item.title;
  final projection = CatalogItemDto.fromJson(payload);
  return projection.withKindMetadata(TvSeries.fromJson(projection.payload));
}
