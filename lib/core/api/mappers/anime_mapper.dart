import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/models/catalog/video_catalog_item.dart';
import 'package:collectarr_app/features/library/models/catalog/video_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/remote/anime_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';

VideoCatalogItem animeSeriesFromDto(CatalogItemDto dto) =>
    VideoCatalogMapper.mapDtoToVideo(dto);

VideoCatalogItem animeSeriesFromMetadataItem(CatalogItem item) =>
    VideoCatalogMapper.mapMetadataItemToVideo(item);

AnimeMedia animeMediaFromCoreDto(AnimeSeriesDto dto) =>
    AnimeCoreMapper.fromSeriesDto(dto);
