import '../domain/manga_collection_item.dart';

MangaCollectionItem mangaTransferCollectionItem(Object value) {
  if (value is MangaCollectionItem) return value;
  throw ArgumentError.value(value, 'updated', 'Expected MangaCollectionItem');
}
