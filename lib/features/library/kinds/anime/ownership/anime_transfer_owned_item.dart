import '../domain/anime_owned_item.dart';

AnimeOwnedItem animeTransferOwnedItem(Object value) {
  if (value is AnimeOwnedItem) return value;
  throw ArgumentError.value(value, 'updated', 'Expected AnimeOwnedItem');
}
