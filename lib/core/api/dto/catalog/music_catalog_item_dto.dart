import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

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
