import '../domain/music_collection_item.dart';

MusicCollectionItem musicTransferCollectionItem(Object value) {
  if (value is MusicCollectionItem) return value;
  throw ArgumentError.value(value, 'updated', 'Expected MusicCollectionItem');
}
