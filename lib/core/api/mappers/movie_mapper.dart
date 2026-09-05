import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/remote/movie_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_release.dart';
import 'package:collectarr_app/features/library/models/catalog/video_catalog_item.dart';
import 'package:collectarr_app/features/library/models/catalog/video_catalog_mapper.dart';

// MovieWork is an alias for VideoCatalogItem (see movie_domain.dart).
// The generated API uses MovieWorkDto; we accept the generic CatalogItemDto
// since the legacy callers pass the full catalog response.
VideoCatalogItem movieWorkFromDto(CatalogItemDto dto) =>
    VideoCatalogMapper.mapDtoToVideo(dto);

MovieMedia movieMediaFromCoreDto(MovieWorkDto dto) =>
    MovieCoreMapper.fromWorkDto(dto);

MovieRelease movieReleaseFromCorePayload(Map<String, dynamic> json) =>
    MovieCoreMapper.fromReleasePayload(json);
