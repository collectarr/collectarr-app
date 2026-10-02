import '../domain/boardgame_collection_item.dart';

BoardGameCollectionItem boardGameTransferCollectionItem(Object value) {
  if (value is BoardGameCollectionItem) return value;
  throw ArgumentError.value(value, 'updated', 'Expected BoardGameCollectionItem');
}
