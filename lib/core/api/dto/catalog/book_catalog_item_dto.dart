import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

final class BookCatalogItemDto extends TypedCatalogItemDto {
  BookCatalogItemDto({
    required super.common,
    CatalogSeriesDetailsDto? series,
    CatalogPublishingDetailsDto? publishing,
  }) : super(
          seriesDetails: series,
          publishingDetails: publishing,
        );
}

final class MangaCatalogItemDto extends TypedCatalogItemDto {
  MangaCatalogItemDto({
    required super.common,
    CatalogSeriesDetailsDto? series,
    CatalogPublishingDetailsDto? publishing,
  }) : super(
          seriesDetails: series,
          publishingDetails: publishing,
        );
}
