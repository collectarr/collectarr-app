import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

DateTime? libraryKindReleaseDate(CatalogItem item) {
  return item.releaseDate;
}

int? libraryKindReleaseYear(CatalogItem item) {
  return item.releaseYear ?? item.releaseDate?.year;
}

List<CatalogEditionDto> libraryKindEditions(CatalogItem item) {
  return item.editions;
}

String? libraryKindTitleExtension(CatalogItem item) {
  final text = (item.titleExtension ?? item.editionTitle)?.trim();
  return text == null || text.isEmpty ? null : text;
}
