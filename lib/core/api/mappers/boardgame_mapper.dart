import 'package:collectarr_app/core/api/generated/catalog_typed_dtos.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';

CatalogItem boardGameCatalogItemFromDto(BoardGameWorkDto dto) => dto.toCatalogItem();
CatalogItem boardGameEditionCatalogItemFromDto(BoardGameEditionDto dto) => dto.toCatalogItem();
