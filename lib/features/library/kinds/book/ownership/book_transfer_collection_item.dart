import '../domain/book_collection_item.dart';

BookCollectionItem bookTransferCollectionItem(Object value) {
  if (value is BookCollectionItem) return value;
  throw ArgumentError.value(value, 'updated', 'Expected BookCollectionItem');
}
