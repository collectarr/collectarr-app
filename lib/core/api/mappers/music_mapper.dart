import 'package:collectarr_app/core/api/generated/catalog_typed_dtos.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';

CatalogItem musicCatalogItemFromDto(MusicReleaseDto dto) =>
    CatalogItem.fromJson({
      ...dto.raw,
      'id': dto.id,
      'title': dto.title,
      'kind': dto.kind,
    });

CatalogItem musicMediaCatalogItemFromDto(MusicMediaDto dto) =>
    CatalogItem.fromJson({
      ...dto.raw,
      'id': dto.id,
      'title': dto.title,
      'kind': dto.kind,
    });

CatalogItem musicTrackCatalogItemFromDto(MusicTrackDto dto) =>
    CatalogItem.fromJson({
      ...dto.raw,
      'id': dto.id,
      'title': dto.title,
      'kind': dto.kind,
    });
