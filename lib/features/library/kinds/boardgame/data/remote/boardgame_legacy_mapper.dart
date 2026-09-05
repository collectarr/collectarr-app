import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_mapper.dart';

BoardGameCatalogItem boardGameWorkFromDto(CatalogItemDto dto) =>
    BoardGameCatalogMapper.mapDtoToBoardGame(dto);
