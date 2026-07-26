import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_domain.dart';

ComicCatalogItem comicWorkFromDto(CatalogItemDto dto) =>
    ComicCatalogMapper.mapDtoToComic(dto);

ComicCatalogItem comicWorkFromMetadataItem(ShelfEntry source) =>
    ComicCatalogMapper.mapMetadataItemToComic(source.catalogItem!);
