import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/manga/contracts/manga_contracts.dart';

MangaCatalog mangaSeriesFromDto(CatalogItemDto dto) => MangaCatalog.fromJson({
      'id': dto.id,
      'kind': dto.kind,
      ...dto.payload,
    });

MangaCatalog mangaSeriesFromMetadataItem(CatalogItem item) =>
    MangaCatalog.fromJson({
      'id': item.identity.id,
      ...item.payload,
    });
