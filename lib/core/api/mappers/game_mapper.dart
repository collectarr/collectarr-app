import 'package:collectarr_app/core/api/generated/catalog_typed_dtos.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';

CatalogItem gameCatalogItemFromDto(GameWorkDto dto) => dto.toCatalogItem();
CatalogItem gameReleaseCatalogItemFromDto(GameReleaseDto dto) => dto.toCatalogItem();
