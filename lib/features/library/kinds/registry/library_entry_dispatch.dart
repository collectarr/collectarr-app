import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';

/// Structural dispatch boundary for a fully loaded kind-entry aggregate.
///
/// The generic host can carry the opaque value and its structural identity,
/// but it cannot enumerate or invoke callbacks for every concrete kind. The
/// owning kind interprets [value] after checking its own expected type.
abstract interface class LibraryEntryDispatch {
  LibraryEntryRef get ref;
  CatalogMediaKind get kind;
  Object get value;
}

final class OpaqueLibraryEntryDispatch implements LibraryEntryDispatch {
  const OpaqueLibraryEntryDispatch({
    required this.ref,
    required this.kind,
    required this.value,
  });

  @override
  final LibraryEntryRef ref;

  @override
  final CatalogMediaKind kind;

  @override
  final Object value;
}
