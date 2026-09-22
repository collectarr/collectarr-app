import '../domain/manga_owned_item.dart';

MangaOwnedItem mangaTransferOwnedItem(Object value) {
  if (value is MangaOwnedItem) return value;
  throw ArgumentError.value(value, 'updated', 'Expected MangaOwnedItem');
}
