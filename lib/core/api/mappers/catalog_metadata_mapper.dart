import 'package:collectarr_app/core/api/generated/catalog_metadata_dto.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';

CatalogItem catalogItemFromDto(CatalogMetadataDto dto) {
  return CatalogItem.fromJson(dto.toJson());
}
