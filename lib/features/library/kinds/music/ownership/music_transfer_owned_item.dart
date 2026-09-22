import '../domain/music_owned_item.dart';

MusicOwnedItem musicTransferOwnedItem(Object value) {
  if (value is MusicOwnedItem) return value;
  throw ArgumentError.value(value, 'updated', 'Expected MusicOwnedItem');
}
