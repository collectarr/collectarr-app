import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_domain.dart';

ComicCatalogItem comicWorkFromDto(CatalogItemDto dto) =>
    ComicCatalogMapper.mapDtoToComic(dto);

ComicCatalogItem comicWorkFromMetadataItem(ShelfEntry source) {
    final catalog = source.catalogItem;
    final metadata = catalog?.kindMetadata;
    if (catalog == null || metadata is! ComicCatalogMetadata) {
        throw StateError('Expected ComicCatalogMetadata for comic source');
    }
    return ComicCatalogMapper.mapMetadataToComic(
        metadata,
        id: catalog.identity.id,
    );
}
