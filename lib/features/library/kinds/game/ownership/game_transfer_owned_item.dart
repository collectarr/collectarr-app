import '../domain/game_owned_item.dart';

GameOwnedItem gameTransferOwnedItem(Object value) {
  if (value is GameOwnedItem) return value;
  throw ArgumentError.value(value, 'updated', 'Expected GameOwnedItem');
}
