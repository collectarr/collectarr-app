import '../domain/movie_collection_item.dart';

MovieCollectionItem movieTransferCollectionItem(Object value) {
  if (value is MovieCollectionItem) return value;
  throw ArgumentError.value(value, 'updated', 'Expected MovieCollectionItem');
}
