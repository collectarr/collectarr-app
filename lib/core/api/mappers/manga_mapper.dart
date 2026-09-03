import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/manga/contracts/manga_contracts.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

MangaCatalog mangaSeriesFromDto(CatalogItemDto dto) => MangaCatalog.fromJson({
      'id': dto.id,
      'kind': dto.kind,
      ...dto.payload,
    });

MangaCatalog mangaSeriesFromMetadataItem(LibraryMetadataItem item) =>
    MangaCatalog.fromJson({
      'id': item.identity.id,
      ...item.kindMetadata.toSyncPayload(),
    });
