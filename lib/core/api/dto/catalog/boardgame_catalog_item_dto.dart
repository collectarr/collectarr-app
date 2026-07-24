import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_publishing_details_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_series_details_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/game_catalog_details_dto.dart';

final class BoardGameCatalogItemDto extends TypedCatalogItemDto {
  BoardGameCatalogItemDto({
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
