import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_domain.dart';
import 'package:collectarr_app/features/library/kinds/video/catalog/video_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/video/catalog/video_catalog_mapper.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

VideoCatalogItem animeSeriesFromDto(CatalogItemDto dto) =>
    VideoCatalogMapper.mapDtoToVideo(dto);

VideoCatalogItem animeSeriesFromMetadataItem(LibraryMetadataItem item) =>
    VideoCatalogMapper.mapMetadataItemToVideo(item);
