import '../domain/tv_owned_item.dart';

TvOwnedItem tvTransferOwnedItem(Object value) {
  if (value is TvOwnedItem) return value;
  throw ArgumentError.value(value, 'updated', 'Expected TvOwnedItem');
}
