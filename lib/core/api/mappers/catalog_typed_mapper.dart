import 'package:collectarr_app/core/api/generated/catalog_metadata_dto.dart';
import 'package:collectarr_app/core/api/generated/catalog_typed_dtos.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';

CatalogItem catalogItemFromTypedDto(CatalogTypedDto dto) {
  return CatalogItem.fromJson({
    ...dto.raw,
    'id': dto.id,
    'title': dto.title,
    'kind': dto.kind,
  });
}

CatalogItem catalogItemFromMetadataDto(CatalogMetadataDto dto) {
  return dto.toCatalogItem();
}
