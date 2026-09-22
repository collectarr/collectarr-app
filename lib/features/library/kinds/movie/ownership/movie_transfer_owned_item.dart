import '../domain/movie_owned_item.dart';

MovieOwnedItem movieTransferOwnedItem(Object value) {
  if (value is MovieOwnedItem) return value;
  throw ArgumentError.value(value, 'updated', 'Expected MovieOwnedItem');
}
