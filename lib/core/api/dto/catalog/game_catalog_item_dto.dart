import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

final class GameCatalogItemDto extends TypedCatalogItemDto {
  GameCatalogItemDto({
    required super.common,
    CatalogSeriesDetailsDto? series,
    CatalogPublishingDetailsDto? publishing,
    GameCatalogDetailsDto? game,
  }) : super(
          seriesDetails: series,
          publishingDetails: publishing,
          gameDetails: game,
        );
}
