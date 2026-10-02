import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';

/// Structural dispatch boundary for a fully loaded kind-owned aggregate.
///
/// The generic host can carry the opaque value and its structural identity,
/// but it cannot enumerate or invoke callbacks for every concrete kind. The
/// owning kind interprets [value] after checking its own expected type.
abstract interface class LibraryCollectionItemDispatch {
  CollectionItemRef get ref;
  CatalogMediaKind get kind;
  Object get value;
}

final class OpaqueLibraryCollectionItemDispatch implements LibraryCollectionItemDispatch {
  const OpaqueLibraryCollectionItemDispatch({
    required this.ref,
    required this.kind,
    required this.value,
  });

  @override
  final CollectionItemRef ref;

  @override
  final CatalogMediaKind kind;

  @override
  final Object value;
}
