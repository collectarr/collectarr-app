import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_publishing_details_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_series_details_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/video_catalog_details_dto.dart';

final class MovieCatalogItemDto extends TypedCatalogItemDto {
  MovieCatalogItemDto({
    required super.common,
    CatalogSeriesDetailsDto? series,
    CatalogPublishingDetailsDto? publishing,
    VideoCatalogDetailsDto? video,
  }) : super(
          seriesDetails: series,
          publishingDetails: publishing,
          videoDetails: video,
        );
}

final class TvCatalogItemDto extends TypedCatalogItemDto {
  TvCatalogItemDto({
    required super.common,
    CatalogSeriesDetailsDto? series,
    CatalogPublishingDetailsDto? publishing,
    VideoCatalogDetailsDto? video,
  }) : super(
          seriesDetails: series,
          publishingDetails: publishing,
          videoDetails: video,
        );
}

final class AnimeCatalogItemDto extends TypedCatalogItemDto {
  AnimeCatalogItemDto({
    required super.common,
    CatalogSeriesDetailsDto? series,
    CatalogPublishingDetailsDto? publishing,
    VideoCatalogDetailsDto? video,
  }) : super(
          seriesDetails: series,
          publishingDetails: publishing,
          videoDetails: video,
        );
}
