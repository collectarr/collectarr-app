import '../domain/game_collection_item.dart';

GameCollectionItem gameTransferCollectionItem(Object value) {
  if (value is GameCollectionItem) return value;
  throw ArgumentError.value(value, 'updated', 'Expected GameCollectionItem');
}
