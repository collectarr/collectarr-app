import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_mapper.dart';

BookCatalogItem bookWorkFromDto(CatalogItemDto dto) =>
    BookCatalogMapper.mapDtoToBook(dto);
