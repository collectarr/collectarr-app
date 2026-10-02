import '../domain/comic_collection_item.dart';

ComicCollectionItem comicTransferCollectionItem(Object value) {
  if (value is ComicCollectionItem) return value;
  throw ArgumentError.value(value, 'updated', 'Expected ComicCollectionItem');
}
