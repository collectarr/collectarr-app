import '../domain/comic_owned_item.dart';

ComicOwnedItem comicTransferOwnedItem(Object value) {
  if (value is ComicOwnedItem) return value;
  throw ArgumentError.value(value, 'updated', 'Expected ComicOwnedItem');
}
