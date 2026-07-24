import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_publishing_details_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_series_details_dto.dart';

final class ComicCatalogItemDto extends TypedCatalogItemDto {
  ComicCatalogItemDto({
    required super.common,
    CatalogSeriesDetailsDto? series,
    CatalogPublishingDetailsDto? publishing,
  }) : super(
          seriesDetails: series,
          publishingDetails: publishing,
        );
}
