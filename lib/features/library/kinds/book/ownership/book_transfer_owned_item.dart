import '../domain/book_owned_item.dart';

BookOwnedItem bookTransferOwnedItem(Object value) {
  if (value is BookOwnedItem) return value;
  throw ArgumentError.value(value, 'updated', 'Expected BookOwnedItem');
}
