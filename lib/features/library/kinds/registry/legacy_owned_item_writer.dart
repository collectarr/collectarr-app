import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';

/// Structural compatibility writer for the transitional common Owned cache.
///
/// The interface knows only how to dispatch and persist a legacy boundary
/// value. The owning kind decides how that value becomes its complete typed
/// owned model.
abstract interface class LegacyOwnedItemWriter {
  CatalogMediaKind get kind;

  Future<void> upsert(OwnedItem item);
}
