import '../domain/anime_collection_item.dart';

AnimeCollectionItem animeTransferCollectionItem(Object value) {
  if (value is AnimeCollectionItem) return value;
  throw ArgumentError.value(value, 'updated', 'Expected AnimeCollectionItem');
}
