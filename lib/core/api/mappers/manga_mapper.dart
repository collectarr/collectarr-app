import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_mapper.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

BookCatalogItem mangaSeriesFromDto(CatalogItemDto dto) =>
    BookCatalogMapper.mapDtoToBook(dto);

BookCatalogItem mangaSeriesFromMetadataItem(LibraryMetadataItem item) =>
    BookCatalogMapper.mapMetadataItemToBook(item);
