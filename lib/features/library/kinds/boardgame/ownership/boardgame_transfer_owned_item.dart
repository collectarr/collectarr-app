import '../domain/boardgame_owned_item.dart';

BoardGameOwnedItem boardGameTransferOwnedItem(Object value) {
  if (value is BoardGameOwnedItem) return value;
  throw ArgumentError.value(value, 'updated', 'Expected BoardGameOwnedItem');
}
