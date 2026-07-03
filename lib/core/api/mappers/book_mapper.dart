import 'package:collectarr_app/core/api/generated/catalog_typed_dtos.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';

CatalogItem bookCatalogItemFromDto(BookWorkDto dto) => dto.toCatalogItem();
CatalogItem bookEditionCatalogItemFromDto(BookEditionDto dto) => dto.toCatalogItem();
