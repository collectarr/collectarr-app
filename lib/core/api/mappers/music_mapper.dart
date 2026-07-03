import 'package:collectarr_app/core/api/generated/catalog_typed_dtos.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';

CatalogItem musicCatalogItemFromDto(MusicReleaseDto dto) => dto.toCatalogItem();
CatalogItem musicMediaCatalogItemFromDto(MusicMediaDto dto) => dto.toCatalogItem();
CatalogItem musicTrackCatalogItemFromDto(MusicTrackDto dto) => dto.toCatalogItem();
