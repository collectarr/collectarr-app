import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_codec_support.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_repository.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';

final class MovieCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const MovieCatalogRepositoryCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.movie;

  @override
  Object? typedMetadataFromDto(CatalogItemDto item) {
    final metadata = item.kindMetadata;
    if (metadata is MovieMedia) return metadata;
    return metadata is Map ? MovieMedia.fromJson(item.payload) : null;
  }

  @override
  CatalogItemDto withTypedMetadata(CatalogItemDto item) =>
      switch (typedMetadataFromDto(item)) {
        final metadata? => item.withKindMetadata(metadata),
        _ => item,
      };

  @override
  Future<void> upsert(LocalDatabase db, CatalogItemDto item) {
    return MovieRepository(db).updateMedia(
      MovieMedia.fromJson(catalogPayloadFor(item)),
    );
  }

  @override
  Future<List<CatalogItemDto>> list(LocalDatabase db) async {
    final media = await MovieRepository(db).search();
    return [
      for (final item in media) _projection(item),
    ];
  }

  @override
  Future<List<CatalogDisplaySummary>> listSummaries(LocalDatabase db) async {
    final media = await MovieRepository(db).search();
    return [
      for (final item in media)
        CatalogDisplaySummary.work(
          kind: kind,
          id: item.id.value,
          title: item.title,
        ),
    ];
  }
}

CatalogItemDto _projection(MovieMedia item) {
  final payload = Map<String, dynamic>.from(item.rawPayload);
  payload['id'] ??= item.id.value;
  payload['kind'] ??= 'movie';
  payload['title'] ??= item.title;
  final projection = CatalogItemDto.fromJson(payload);
  return projection.withKindMetadata(MovieMedia.fromJson(projection.payload));
}
