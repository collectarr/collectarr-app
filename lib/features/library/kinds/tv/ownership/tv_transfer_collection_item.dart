import '../domain/tv_collection_item.dart';

TvCollectionItem tvTransferCollectionItem(Object value) {
  if (value is TvCollectionItem) return value;
  throw ArgumentError.value(value, 'updated', 'Expected TvCollectionItem');
}
