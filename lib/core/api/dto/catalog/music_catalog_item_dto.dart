import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_publishing_details_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_series_details_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/music_catalog_details_dto.dart';

final class MusicCatalogItemDto extends TypedCatalogItemDto {
  MusicCatalogItemDto({
    required super.common,
    CatalogSeriesDetailsDto? series,
    CatalogPublishingDetailsDto? publishing,
    MusicCatalogDetailsDto? music,
  }) : super(
          seriesDetails: series,
          publishingDetails: publishing,
          musicDetails: music,
        );
}
